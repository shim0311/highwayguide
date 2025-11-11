package restinfo.action;

import mybatis.vo.GasVO;
import mybatis.vo.ServiceAreaVO;
import org.json.JSONArray;
import org.json.JSONObject;
import restinfo.dao.GasDAO;
import restinfo.dao.ServiceAreaDAO;
import restinfo.util.ConfigLoader;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class GetGasPriceAction implements Action {

    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) {

        String EXPRESSWAY_API_KEY = ConfigLoader.getProperty("EXPRESSWAY_ID");
        List<GasVO> gasList = new ArrayList<>(); // 휴게소의 주유소가격 정보를 담을 리스트

        try {
            // DAO를 통해서 ServiceArea에 저장된 휴게소 목록을 불러온다.
            List<ServiceAreaVO> getSvarInfo = ServiceAreaDAO.getAll();

            // API에서 휴게소와 주유소 정보를 가져오기
            String SAUrl = "https://data.ex.co.kr/openapi/restinfo/hiwaySvarInfoList?key="
                    + EXPRESSWAY_API_KEY
                    + "&type=json&numOfRows=2000";

            // 📡 URL 객체 생성 + 연결 설정
            URL url = new URL(SAUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");

            // 📥 응답 데이터를 읽어오기 위한 스트림
            StringBuilder sb = new StringBuilder();
            try (BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
                String inputLine;
                while ((inputLine = in.readLine()) != null) {
                    sb.append(inputLine);
                }
            }
            conn.disconnect();

            JSONObject json = new JSONObject(sb.toString());
            JSONArray allItems = json.getJSONArray("list");

            for (int i = 0; i < 5 && i < allItems.length(); i++) {
                // API가 보내준 객체 내용을 그대로 출력한다.
                System.out.println(allItems.getJSONObject(i).toString());
            }
            System.out.println("--------------------------------------------------\n");

            Map<String, String> getItemMap = new HashMap<>();
            for (int i = 0; i < allItems.length(); i++) {
                JSONObject item = allItems.getJSONObject(i);

                if ("1".equals(item.getString("svarGsstClssCd"))) {
                    getItemMap.put(item.getString("svarNm"), item.getString("svarCd"));
                }
            }

            // *** DB에 저장된 휴게소 목록을 순회 ***
            for (ServiceAreaVO serviceArea : getSvarInfo) {

                String saName = serviceArea.getSAName().replace("휴게소", ""); //휴게소이름 가져오기
                String saDirection = serviceArea.getSADirection(); //SADirection 가져오기
                String findGsstNm = saName + saDirection + "주유소";

                System.out.println("==> 2. [DB기반 조립 이름]: '" + findGsstNm + "'");

                String gsstSvarCd = getItemMap.get(findGsstNm);

                if (gsstSvarCd != null) {
                    System.out.println("    ...Matching Success!!! (" + gsstSvarCd + ")"); // 매칭 성공 시 로그 추가
                    // 실제 가격 정보가 있는 API URL과 요청 변수(serviceAreaCode2)
                    String gasPriceUrl = "https://data.ex.co.kr/openapi/business/curStateStation?key="
                            + EXPRESSWAY_API_KEY
                            + "&type=json&serviceAreaCode2=" + gsstSvarCd;

                    // 두 번째 API 호출을 위한 새로운 연결 및 스트림 객체 필요
                    URL url2 = new URL(gasPriceUrl);
                    HttpURLConnection conn2 = (HttpURLConnection) url2.openConnection();
                    conn2.setRequestMethod("GET");

                    StringBuilder sb2 = new StringBuilder();
                    // conn2의 InputStream으로 새로운 BufferedReader를 생성
                    try (BufferedReader in2 = new BufferedReader(new InputStreamReader(conn2.getInputStream(), StandardCharsets.UTF_8))) {
                        String inputLine;
                        while ((inputLine = in2.readLine()) != null) {
                            sb2.append(inputLine);
                        }
                    }
                    conn2.disconnect();

                    // 두 번째 API 호출 결과인 sb2를 파싱한다.
                    JSONObject json2 = new JSONObject(sb2.toString());

                    if (!json2.has("list") || json2.getJSONArray("list").isEmpty()) {
                        continue;
                    }
                    JSONArray gasPriceItems = json2.getJSONArray("list");
                    JSONObject priceData = gasPriceItems.getJSONObject(0);

                    GasVO gvo = new GasVO();
                    gvo.setSAKey(serviceArea.getIdx());
                    gvo.setGasoline(priceData.optString("gasolinePrice", "0"));
                    gvo.setDisel(priceData.optString("diselPrice", "0"));
                    gvo.setLPG(priceData.optString("lpgPrice", "0"));
                    gasList.add(gvo);
                }
            }

            System.out.println("DAO 호출 직전, gasList 사이즈: " + gasList.size());
            System.out.println(gasList.get(0).getGasoline());
            if (!gasList.isEmpty()) {
                GasVO firstItem = gasList.get(0);
                System.out.println("첫 번째 데이터 샘플: SAKey=" + firstItem.getSAKey() + ", 휘발유=" + firstItem.getGasoline());
            }

            request.setAttribute("message", gasList.size() + "개 휴게소의 유가 정보가 Success!!!");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "유가 정보 처리 중 failure !!!.");
        }
        return ""; // 결과를 보여줄 JSP 페이지
    }
}