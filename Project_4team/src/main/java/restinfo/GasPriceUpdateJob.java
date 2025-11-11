package restinfo;

import mybatis.service.FactoryService;
import mybatis.vo.GasVO;
import mybatis.vo.ServiceAreaVO;
import org.apache.ibatis.session.SqlSession;
import org.json.JSONArray;
import org.json.JSONObject;
import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import restinfo.dao.GasDAO;
import restinfo.dao.ServiceAreaDAO;
import restinfo.util.ConfigLoader;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class GasPriceUpdateJob implements Job {

    @Override
    public void execute(JobExecutionContext context) throws JobExecutionException {
        System.out.println("=== [Quartz] 유가 정보 자동 업데이트 작업을 시작합니다. ===");

        String EXPRESSWAY_API_KEY = ConfigLoader.getProperty("EXPRESSWAY_ID");
        List<GasVO> gasList = new ArrayList<>();

        try {
            List<ServiceAreaVO> getSvarInfo = ServiceAreaDAO.getAll();
            String SAUrl = "https://data.ex.co.kr/openapi/restinfo/hiwaySvarInfoList?key="
                    + EXPRESSWAY_API_KEY + "&type=json&numOfRows=1000&svarGsstClssCd=1";

            // 1. API에서 모든 주유소 정보를 가져와 Map 생성
            URL url = new URL(SAUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            StringBuilder sb = new StringBuilder();
            try (BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
                String inputLine;
                while ((inputLine = in.readLine()) != null) sb.append(inputLine);
             }
            conn.disconnect();
            JSONArray allItems = new JSONObject(sb.toString()).getJSONArray("list");

            Map<String, String> getItemMap = new HashMap<>();
            for (int i = 0; i < allItems.length(); i++) {
                JSONObject item = allItems.getJSONObject(i);
                getItemMap.put(item.getString("svarNm"), item.getString("svarCd"));
            }

            // 2. DB 휴게소 목록을 기준으로 순회하며 이름 조립 및 매칭
            for (ServiceAreaVO serviceArea : getSvarInfo) {
                String saName = serviceArea.getSAName().replace("휴게소", "").trim();
                String saDirection = serviceArea.getSADirection().trim();

                if (saDirection.contains("(")) {
                    saDirection = saDirection.substring(saDirection.indexOf('('));
                }
                String findGsstNm = saName + saDirection + "주유소";
                String gsstSvarCd = getItemMap.get(findGsstNm);

                //System.out.println("휴게소이름: " + saName + " 휴게소" + saDirection + " 방향");
                if (gsstSvarCd != null) {
                    // 3.  누락되었던 가격 조회 로직 추가
                    try {
                        String gasPriceUrl = "https://data.ex.co.kr/openapi/business/curStateStation?key="
                                + EXPRESSWAY_API_KEY + "&type=json&serviceAreaCode2=" + gsstSvarCd;

                        URL url2 = new URL(gasPriceUrl);
                        HttpURLConnection conn2 = (HttpURLConnection) url2.openConnection();
                        conn2.setRequestMethod("GET");
                        conn2.setConnectTimeout(5000);
                        conn2.setReadTimeout(5000);

                        if (conn2.getResponseCode() != 200) {
                            System.err.println("가격 조회 API 오류! 응답 코드: " + conn2.getResponseCode() + " (주유소 코드: " + gsstSvarCd + ")");
                            conn2.disconnect();
                            continue;
                        }

                        StringBuilder sb2 = new StringBuilder();
                        try (BufferedReader in2 = new BufferedReader(new InputStreamReader(conn2.getInputStream(), StandardCharsets.UTF_8))) {
                            String inputLine;
                            while ((inputLine = in2.readLine()) != null) sb2.append(inputLine);
                        }
                        conn2.disconnect();

                        JSONObject json2 = new JSONObject(sb2.toString());
                        if (!json2.has("list") || json2.getJSONArray("list").isEmpty()) {
                            continue;
                        }

                        JSONObject priceData = json2.getJSONArray("list").getJSONObject(0);

                        GasVO gvo = new GasVO();
                        gvo.setSAKey(serviceArea.getIdx());
                        gvo.setGasoline(priceData.optString("gasolinePrice", "0"));
                        gvo.setDisel(priceData.optString("diselPrice", "0"));
                        gvo.setLPG(priceData.optString("lpgPrice", "0"));

                        gasList.add(gvo); // 리스트에 추가!

                    } catch (Exception e) {
                        System.err.println("가격 조회 중 예외 발생! (주유소 코드: " + gsstSvarCd + ")");
                        continue; // 오류 발생 시 다음 휴게소로 건너뛰기
                    }
                }
            }

            System.out.println("\n[Quartz] DAO 호출 직전, gasList 사이즈: " + gasList.size());
            // 4. 최종 결과를 DB에 저장 (INSERT / UPDATE 분기 처리)
            if(!gasList.isEmpty()) {
                SqlSession session = null;
                try {
                    session = FactoryService.getFactory().openSession();

                    // INSERT할 데이터와 UPDATE할 데이터를 담을 리스트를 각각 생성
                    List<GasVO> insertList = new ArrayList<>();
                    List<GasVO> updateList = new ArrayList<>();

                    // 전체 gasList를 순회하며 데이터가 DB에 있는지 확인
                    for (GasVO gvo : gasList) {
                        int cnt = session.selectOne("gas.selectCntSAKey", gvo.getSAKey());
                        if (cnt > 0) {
                            updateList.add(gvo); //이미 있으면 updateList에 추가
                        } else {
                            insertList.add(gvo); //없으면 insertList에 추가
                        }
                    }

                    // 각 DAO 메서드 호출
                    if (!insertList.isEmpty()) {
                        GasDAO.insertGasPrices(session, insertList);
                        System.out.println("총 " + insertList.size() + "개의 신규 데이터를 INSERT 했습니다.");
                    }
                    if (!updateList.isEmpty()) {
                        GasDAO.updateGasPrices(session, updateList);
                        System.out.println("총 " + updateList.size() + "개의 기존 데이터를 UPDATE 했습니다.");
                    }

                    session.commit(); //모든 작업이 성공하면 최종커밋
                } catch (Exception e) {
                    e.printStackTrace();
                    if(session != null) session.rollback();
                } finally {
                    if(session != null) session.close();
                }
            }

        } catch (Exception e) {
            System.err.println("[Quartz] 유가 정보 자동 업데이트 중 오류 발생!");
            e.printStackTrace();
        }
        System.out.println("=== [Quartz] 유가 정보 자동 업데이트 작업을 종료합니다. ===");
    }
}