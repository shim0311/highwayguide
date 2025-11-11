package restinfo.action;

import mybatis.vo.MenuVO;
import mybatis.vo.ServiceAreaVO;
import org.json.JSONArray;
import org.json.JSONObject;
import restinfo.dao.MenuDAO;
import restinfo.dao.ServiceAreaDAO;
import restinfo.util.ConfigLoader;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

//여기서 API 호출, 데이터비교, DAO호출을 하는 곳
public class UpdateFoodMenuAction implements Action {
    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) {
        // 1. AJAX 요청에 대한 기본 응답 설정(JSON)
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        JSONObject jsonResult = new JSONObject();

        new Thread(() -> {
            System.out.println(">>> Background task started for menu update...");
            String EXPRESSWAY_API_KEY = ConfigLoader.getProperty("EXPRESSWAY_ID");
            try {
                // 2. API 호출! - 모든휴게소 정보 가져오기
                Map<String, ServiceAreaVO> saMap = new HashMap<>();
                List<ServiceAreaVO> saList = ServiceAreaDAO.getAll();

                // 2-1. 모든 휴게소정보를 가져와서 Map에 저장한다.
                System.out.println("--- [1] DB 기반 Key 목록 (saMap) ---");
                for (ServiceAreaVO svo : saList) {
                    String direction = svo.getSADirection();

                    // ✨ 방향 문자열에서 괄호 안의 내용만 추출하는 로직 추가
                    int start = direction.indexOf('(');
                    int end = direction.indexOf(')');
                    if (start != -1 && end != -1 && end > start) {
                        direction = direction.substring(start + 1, end);
                    }

                    // ✨ 디버깅용 로그 추가
                    System.out.println("DB NAME: [" + svo.getSAName() + "], DB DIRECTION: [" + svo.getSADirection() + "]");

                    // 최종 key 생성: "휴게소" 글자 제거, 공백 제거, 정제된 방향 정보 합치기
                    String mapKey = svo.getSAName().replace("휴게소", "").trim()
                            + "(" + direction.trim()
                            + ")";

                    System.out.println("생성된 DB Key: " + mapKey);
                    saMap.put(mapKey, svo);
                }
                System.out.println("------------------------------------");

                //*** 디버깅 ***
                System.out.println("--- saMap 저장 확인 ---");
                System.out.println("총 " + saMap.size() + "개의 휴게소 정보가 Map에 저장되었습니다.");

                // Map에 저장된 데이터 중 샘플 Key 하나를 출력해봅니다.
                if (!saMap.isEmpty()) {
                    // KeySet에서 첫 번째 Key를 가져와 샘플로 출력
                    String sampleKey = saMap.keySet().iterator().next();
                    System.out.println("샘플 Key 형식: " + sampleKey);
                }
                System.out.println("-----------------------");

                // 3. API 호출! - 모든 음식메뉴 정보 한번에 가져오기(동적 페이징 사용)
                List<JSONObject> allMenuItems = new ArrayList<>();

                // 3-1. ConfigLoader에서 읽고있는 application.properties에서 페이지당 행 수를 읽어옴
                // 만약 행 수가 지정되지 않았다면 기본값으로 100으로 설정함
                String rowsPerPageStr = ConfigLoader.getProperty("menu.api.numOfRows");
                int numOfRows = (rowsPerPageStr != null) ? Integer.parseInt(rowsPerPageStr) : 100;

                // 3-2. 전체 갯수 확인을 위한 사전 API 호출
                String preCheckUrl = "https://data.ex.co.kr/openapi/restinfo/restBestfoodList?key="
                        + EXPRESSWAY_API_KEY
                        + "&type=json&numOfRows=1&pageNo=1"; // 데이터는 1개만 요청해서 속도 향상

                URL preCheckUrl1 = new URL(preCheckUrl);
                HttpURLConnection preConn = (HttpURLConnection) preCheckUrl1.openConnection();
                preConn.setRequestMethod("GET");

                StringBuilder preCheckSb = new StringBuilder();
                try (BufferedReader in = new BufferedReader(new InputStreamReader(
                        preConn.getInputStream(), StandardCharsets.UTF_8))) {
                    String line;
                    while ((line = in.readLine()) != null)
                        preCheckSb.append(line);
                }
                preConn.disconnect();

                JSONObject preResponse = new JSONObject(preCheckSb.toString());
                int totalCount = preResponse.getInt("count"); // API 응답에서 전체 개수를 동적으로 가져옴!

                // 3-3. 동적으로 계산된 페이지 수 만큼 반복
                int totalPages = (int) Math.ceil((double) totalCount / numOfRows); //전체페이지수 계산 68
                System.out.println("API 최신 메뉴: " + totalCount + "개, 총 페이지: " + totalPages);

                // 3-4. API 데이터를 가져오는 실제 반복문
                for (int pageNo = 1; pageNo <= totalPages; pageNo++) {
                    String menuUrl = "https://data.ex.co.kr/openapi/restinfo/restBestfoodList?key="
                            + EXPRESSWAY_API_KEY
                            + "&type=json&numOfRows=" + numOfRows // 설정 파일에서 읽어온 값 사용
                            + "&pageNo=" + pageNo;

                    URL url = new URL(menuUrl);
                    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                    conn.setRequestMethod("GET");

                    StringBuilder sb = new StringBuilder();
                    try (BufferedReader in = new BufferedReader(new InputStreamReader(
                            conn.getInputStream(), StandardCharsets.UTF_8))) {
                        String line;
                        while((line = in.readLine()) != null) sb.append(line);
                    }
                    conn.disconnect();
                    // --- api 호출 로직 종료 ---


                    JSONObject responseJson = new JSONObject(sb.toString());
                    if (!responseJson.has("list") || responseJson.getJSONArray("list").isEmpty()) {
                        System.out.println("Page " + pageNo + " is empty, skipping...");
                        continue; //중간에 빈 페이지가 있어도 계속 진행
                    }

                    JSONArray itemsOnPage = responseJson.getJSONArray("list");
                    for (int i = 0; i < itemsOnPage.length(); i++) {
                        allMenuItems.add(itemsOnPage.getJSONObject(i)); // Page별 아이템을 리스트에 추가
                    }

                    System.out.println("메뉴 데이터 수집 중... Page " + pageNo + "/" + totalPages);
                } //for의 끝

                System.out.println(" >>> 데이터 수집 완료! allMenuItems 리스트 크기: " + allMenuItems.size());

                // ************* 최종 테스트 로직 *************** 4, 5, 6, 7 로직 임시 대체
            /*System.out.println(">>> FINAL TEST STARTED <<<");

            // 1. 테스트할 데이터(1001번째)가 있는지 확인
            if (allMenuItems.size() > 1000) {
                // 2. 문제가 발생하는 구간의 첫 번째 데이터(1001번째)를 특정
                JSONObject problemApiItem = allMenuItems.get(1000); // 리스트 인덱스는 0부터 시작
                System.out.println(">>> Testing with data: " + problemApiItem.toString());

                // 3. 해당 데이터로 MenuVO 단 하나만 생성
                String stdRestNm = problemApiItem.optString("stdRestNm").trim();
                String direction = problemApiItem.optString("direction", "").trim();
                String apiKey;
                if (direction.isEmpty()) {
                    apiKey = stdRestNm.replace("휴게소", "");
                } else {
                    apiKey = stdRestNm.replace("휴게소", "") + "(" + direction + ")";
                }

                if (saMap.containsKey(apiKey)) {
                    ServiceAreaVO matchedSA = saMap.get(apiKey);
                    MenuVO testVO = new MenuVO();
                    testVO.setSAKey(Integer.parseInt(matchedSA.getIdx()));
                    testVO.setFoodName(problemApiItem.getString("foodNm"));
                    testVO.setPrice(problemApiItem.optString("foodCost", "0"));
                    testVO.setRecommend(problemApiItem.optString("recommendyn", "N"));
                    testVO.setBest(problemApiItem.optString("bestfoodyn", "N"));
                    testVO.setPremium(problemApiItem.optString("premiumyn", "N"));
                    testVO.setSeason((problemApiItem.optString("seasonMenu", null)));

                    // 4. 단 하나의 VO만 담긴 리스트를 만들어 DAO에 전달
                    List<MenuVO> testInsertList = new ArrayList<>();
                    testInsertList.add(testVO);

                    System.out.println(">>> Attempting to insert a single record...");
                    MenuDAO.batchInsert(testInsertList); // DAO는 수정 없이 그대로 사용

                    jsonResult.put("message", "TEST SUCCESS: 1001번째 데이터 1개 INSERT 성공!");
                } else {
                    jsonResult.put("message", "TEST FAILED: 1001번째 데이터의 휴게소 정보를 찾을 수 없음. 생성된 apiKey: " + apiKey);
                }
            } else {
                jsonResult.put("message", "TEST FAILED: 데이터가 1000개 미만임");
            }
            jsonResult.put("status", "success");*/
                //************** 구분선 ********************



                // 4. DB조회 : 기존 메뉴정보를 비교하기 위해 Map에 로드한다.
                Map<String, MenuVO> existingMenuMap = new HashMap<>(); //비교하기 위해 Map 객체 생성

                List<MenuVO> existingMenuList = MenuDAO.selectAllMenu(); //DAO에서 모든메뉴정보를 조회하여 리스트에 담는다.
                // 4-1 기존 메뉴정보들이 담긴 리스트를 순회하면서 Map에 담는다.
                for (MenuVO mvo : existingMenuList) {
                    // Key: "휴게소번호-음식이름
                    existingMenuMap.put(mvo.getSAKey() + "-" + mvo.getFoodName(), mvo);
                }

                // 5. 분류 리스트 준비(신규 / 수정)
                List<MenuVO> insertList = new ArrayList<>();
                List<MenuVO> updateList = new ArrayList<>();

                // 6. *** 메인 로직 ***
                // JAVA 메모리에서 두 API 데이터 조합 및 비교
                System.out.println("--- [2] API 기반 Key 목록 (apiKey) ---"); //debug
                int matchCount = 0; // 일치횟수를 세기 위함

                for (JSONObject apiItem : allMenuItems) {
                    String stdRestNm = apiItem.optString("stdRestNm").trim();
                    String direction = apiItem.optString("direction").trim();
                    String apiKey;

                    // 수정된 Key 생성 로직
                    if (direction.isEmpty()) {
                        // CASE 1: direction 필드가 비어있으면, stdRestNm에 이미 '(방향)'이 포함된 경우
                        // "서울만남(부산)휴게소" -> "서울만남(부산)" 으로 만듦
                        apiKey = stdRestNm.replace("휴게소", "");
                    } else {
                        // CASE 2: direction 필드에 값이 있으면, 기존 방식대로 조합
                        // stdRestNm: "기흥", direction: "부산" -> "기흥(부산)" 으로 만듦
                        apiKey = stdRestNm.replace("휴게소", "") + "(" + direction + ")";
                    }

                    // ✨ 여기서 두 Key가 일치하는지 바로 확인 가능!
                    System.out.println(apiKey + "  | 일치여부: " + saMap.containsKey(apiKey));

                    //모든 휴게소정보를 담은 Map에서 key를 가져온다.
                    if (saMap.containsKey(apiKey)) {
                        matchCount++; //key가 일치할 때마다 카운터 1 증가

                        ServiceAreaVO matchedSA = saMap.get(apiKey);
                        // --- newVO에 API 데이터와 휴게소 Idx 채우기 ---
                        MenuVO newVO = new MenuVO();
                        newVO.setSAKey(Integer.parseInt(matchedSA.getIdx()));
                        newVO.setFoodName(apiItem.getString("foodNm"));
                        newVO.setPrice(apiItem.optString("foodCost", "0"));
                        newVO.setRecommend(apiItem.optString("recommendyn", "N"));
                        newVO.setBest(apiItem.optString("bestfoodyn", "N"));
                        newVO.setPremium(apiItem.optString("premiumyn", "N"));
                        // API에 seasonMenu key가 없으면 null이 저장됨
                        newVO.setSeason((apiItem.optString("seasonMenu", null)));

                        String mapKey = newVO.getSAKey() + "-" + newVO.getFoodName();
                        MenuVO existingVO = existingMenuMap.get(mapKey);

                        if (existingVO == null) {
                            insertList.add(newVO);
                        } else if (!newVO.equals(existingVO)) {
                            updateList.add(newVO);
                        }
                    }
                    System.out.println("------------------------------------");
                }// for의 끝

                // 확인용
                System.out.println(">>> 데이터 분류 완료!");
                System.out.println(">>> insertList 크기: " + insertList.size());
                System.out.println(">>> updateList 크기: " + updateList.size());
                System.out.println(">>> Key 일치 확인 완료!");
                System.out.println(">>> 총 " + allMenuItems.size() + "개의 API 데이터 중 " + matchCount + "개가 DB 휴게소와 일치했습니다.");


                // 7. DB 일괄 처리
                final int BATCH_SIZE = 1000; //1000개씩 나눠서 실행

                // --- INSERT 작업 분할 실행 ---
                System.out.println(">>> Starting Batch INSERT for " + insertList.size() + " records...");
                for (int i = 0; i < insertList.size(); i += BATCH_SIZE) {
                    // insertList에서 1000개씩 잘라 subList를 만듦
                    List<MenuVO> subList = insertList.subList(i, Math.min(i + BATCH_SIZE, insertList.size()));

                    // 잘라낸 subList만 DAO에 전달하여 실행
                    MenuDAO.batchInsert(subList);
                    Thread.sleep(200);
                    System.out.println(">>> INSERTED " + subList.size() + " records... (" + (i + subList.size()) + "/" + insertList.size() + ")");
                }

                // UPDATE 작업 분할 실행 ---
                System.out.println(">>> Starting Batch UPDATE for " + updateList.size() + " records...");
                for (int i = 0; i < updateList.size(); i += BATCH_SIZE) {
                    List<MenuVO> subList = updateList.subList(i, Math.min(i + BATCH_SIZE, updateList.size()));
                    MenuDAO.batchUpdate(subList);
                    Thread.sleep(200);
                    System.out.println(">>> UPDATED " + subList.size() + " records... (" + (i + subList.size()) + "/" + updateList.size() + ")");
                }

                System.out.println(">>> Background task finished successfully!");

                //8. 최종 결과 응답!
                String message = String.format("업데이트 완료: %d개 신규 추가, %d개 정보 수정.",
                        insertList.size(), updateList.size());
                jsonResult.put("status", "success");
                jsonResult.put("message", message);

                //******************** 여기까지가 기존 코드 **********************

        } catch (Exception e) {
            e.printStackTrace();
            System.err.println(">>> Background task failed!");
            }
            // --- 백그라운드 작업 끝 ---
        }).start(); //스레드 시작!

        // ✨ 3. "작업이 시작되었습니다" 라는 메시지를 즉시 브라우저에 보냄
        /*try {
            jsonResult.put("status", "success");
            jsonResult.put("message", "메뉴 업데이트 작업이 시작되었습니다. 완료까지 몇 분 정도 소요될 수 있습니다.");

            try (PrintWriter out = response.getWriter()) {
                out.print(jsonResult.toString());
                out.flush();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }*/

        return null; //JSON응답으로 비동기식 처리!
    }
}
