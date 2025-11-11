package restinfo.action;

import com.google.gson.Gson;
import mybatis.vo.ServiceAreaVO;
import org.json.JSONArray;
import org.json.JSONObject;
import restinfo.dao.ServiceAreaDAO;
import restinfo.util.ConfigLoader;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.*;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

public class Geocoding {

    static class KakaoResponse { List<Document> documents; }
    static class Document { String x; String y; }

    public static void naverGeocoding(List<ServiceAreaVO> list) {

        String NAVER_CLIENT_ID = ConfigLoader.getProperty("NAVER_GEOCODING_CLIENT_ID");
        String NAVER_CLIENT_SECRET = ConfigLoader.getProperty("NAVER_GEOCODING_CLIENT_SECRET");

        System.out.println("네이버지오코딩을 이용하여 총 " + list.size() + "개의 휴게소 좌표 변환을 시작합니다.");

        for (ServiceAreaVO sa : list) {
            try {
                // 주소가 비어있으면 건너뛰기
                if (sa.getAddress() == null || sa.getAddress().trim().isEmpty()) {
                    System.out.println(sa.getSAName() + " -> 주소 없음, 건너뜁니다.");
                    continue;
                }

                String encodedAddress = URLEncoder.encode(sa.getAddress(), StandardCharsets.UTF_8);
                System.out.println(encodedAddress);
                String apiUrl = "https://maps.apigw.ntruss.com/map-geocode/v2/geocode?query=" + encodedAddress;

                URL url = new URL(apiUrl);
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod("GET");
                conn.setRequestProperty("Content-Type", "application/json");
                conn.setRequestProperty("X-NCP-APIGW-API-KEY-ID", NAVER_CLIENT_ID);
                conn.setRequestProperty("X-NCP-APIGW-API-KEY", NAVER_CLIENT_SECRET);

                BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = br.readLine()) != null) {
                    response.append(line);
                }
                br.close();
                // --- 👇 디버깅 코드 추가 ---
                System.out.println("네이버 서버 원본 응답: " + response.toString());

                // json 파싱
                JSONObject object = new JSONObject(response.toString());

                JSONArray jsonArray = object.getJSONArray("addresses");
                String lat = null;
                String lng = null;

                // addresses 안의 json 필드중 원하는 필드 가려내서 저장하기
                for (int i = 0; i < jsonArray.length(); i++) {
                    JSONObject obj = jsonArray.getJSONObject(i);

                    if (obj.get("x") != null)
                        lng = obj.getString("x");
                    if (obj.get("y") != null)
                        lat = obj.getString("y");
                }

                if (lat != null && lng != null) {
                    sa.setLat(lat);
                    sa.setLng(lng);
                } else
                    System.out.println(sa.getSAName() + " -> 좌표를 찾을 수 없음");


                Thread.sleep(100);
            }catch (Exception e){
                e.printStackTrace();
            }
        }
    }

/// ///////////////////////////////////////////////////////////////////////////////////////////////////////////

    public static void kakaoGeocoding(List<ServiceAreaVO> list) {

        List<ServiceAreaVO> failList = new ArrayList<>();

        String KAKAO_API_KEY = ConfigLoader.getProperty("KAKAO_API_KEY");
        Gson gson = new Gson();

        System.out.println("카카오지오코딩을 이용하여 총 " + list.size() + "개의 휴게소 좌표 변환을 시작합니다.");

        for (ServiceAreaVO sa : list) {
            try {
                // 주소가 비어있으면 건너뛰기
                if (sa.getAddress() == null || sa.getAddress().trim().isEmpty()) {
                    System.out.println(sa.getSAName() + " -> 주소 없음, 건너뜁니다.");
                    continue;
                }


                String encodedAddress = URLEncoder.encode(sa.getAddress(), StandardCharsets.UTF_8);
                System.out.println(encodedAddress);
                String apiUrl = "https://dapi.kakao.com/v2/local/search/address.json?query=" + encodedAddress;

                URL url = new URL(apiUrl);
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod("GET");
                conn.setRequestProperty("Authorization", "KakaoAK " + KAKAO_API_KEY);

                int code = conn.getResponseCode();

                InputStream is = (code >= 200 && code < 300) ?
                        conn.getInputStream() :
                        conn.getErrorStream();

                BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8));
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = br.readLine()) != null) {
                    response.append(line);
                }
                br.close();
                // --- 👇 디버깅 코드 추가 ---
                System.out.println("카카오 서버 원본 응답: " + response.toString());


                Geocoding.KakaoResponse kakaoResponse = gson.fromJson(response.toString(), Geocoding.KakaoResponse.class);
                if (kakaoResponse.documents != null && !kakaoResponse.documents.isEmpty()) {
                    Geocoding.Document doc = kakaoResponse.documents.get(0);
                    String lng = String.valueOf(doc.x); // 경도
                    String lat = String.valueOf(doc.y); // 위도

                    System.out.println(sa.getSAName() + " -> lat: " + lat + ", lng: " + lng);

                    sa.setLat(lat);
                    sa.setLng(lng);

                } else {
                    System.out.println(sa.getSAName() + " -> 좌표를 찾을 수 없음, 실패목록에 저장");
                    failList.add(sa);
                }

                // 3. 카카오 API 요청 제한을 피하기 위해 잠시 대기
                Thread.sleep(100);

            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        if (!failList.isEmpty()) {
            System.out.println("매핑실패 항목들 네이버 지오코딩으로 재시도");
            naverGeocoding(failList);
        } else
            System.out.println("--- 좌표 변환 작업 완료 ---");

    }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public static void kakaoGeocoding() {
        // 1. DB에서 모든 휴게소 목록을 불러옴
        List<ServiceAreaVO> list = ServiceAreaDAO.getAll();

        String KAKAO_API_KEY = ConfigLoader.getProperty("KAKAO_API_KEY");
        Gson gson = new Gson();

        System.out.println("총 " + list.size() + "개의 휴게소 좌표 변환을 시작합니다.");

        for (ServiceAreaVO sa : list) {
            try {
                // 주소가 비어있으면 건너뛰기
                if (sa.getAddress() == null || sa.getAddress().trim().isEmpty()) {
                    System.out.println(sa.getSAName() + " -> 주소 없음, 건너뜁니다.");
                    continue;
                }


                String encodedAddress = URLEncoder.encode(sa.getAddress(), StandardCharsets.UTF_8);
                System.out.println(encodedAddress);
                String apiUrl = "https://dapi.kakao.com/v2/local/search/address.json?query=" + encodedAddress;

                URL url = new URL(apiUrl);
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod("GET");
                conn.setRequestProperty("Authorization", "KakaoAK " + KAKAO_API_KEY);


                BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = br.readLine()) != null) {
                    response.append(line);
                }
                br.close();
                // --- 👇 디버깅 코드 추가 ---
                System.out.println("카카오 서버 원본 응답: " + response.toString());


                KakaoResponse kakaoResponse = gson.fromJson(response.toString(), KakaoResponse.class);
                if (kakaoResponse.documents != null && !kakaoResponse.documents.isEmpty()) {
                    Document doc = kakaoResponse.documents.get(0);
                    double lng = Double.parseDouble(doc.x); // 경도
                    double lat = Double.parseDouble(doc.y); // 위도

                    System.out.println(sa.getSAName() + " -> lat: " + lat + ", lng: " + lng);

                    // 2. DB에 UPDATE 쿼리를 실행하는 DAO 메소드 호출
                    ServiceAreaDAO.updateXY(sa.getIdx(), lat, lng);

                } else {
                    System.out.println(sa.getSAName() + " -> 좌표를 찾을 수 없음.");
                }

                // 3. 카카오 API 요청 제한을 피하기 위해 잠시 대기
                Thread.sleep(100);

            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        System.out.println("--- 좌표 변환 작업 완료 ---");
    }
}