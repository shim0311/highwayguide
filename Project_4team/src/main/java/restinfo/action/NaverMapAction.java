package restinfo.action;

import java.io.*;
import java.net.*;
import javax.crypto.*;
import javax.crypto.spec.*;
import java.util.Base64;
import javax.servlet.*;
import javax.servlet.http.*;

public class NaverMapAction extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json; charset=UTF-8");

        try {
            String action = request.getParameter("action");
            String accessKey = request.getParameter("accessKey");
            String secretKey = request.getParameter("secretKey");

            if (action != null && accessKey != null && secretKey != null) {
                String timestamp = String.valueOf(System.currentTimeMillis());
                String method = "GET";
                String apiResponse = "";

                if ("geocoding".equals(action)) {
                    String query = request.getParameter("query");
                    String url = "/map-geocode/v2/geocode";

                    // 한글 인코딩 문제 해결
                    String encodedQuery = java.net.URLEncoder.encode(query, "UTF-8");
                    String fullUrl = "https://naveropenapi.apigw.ntruss.com" + url + "?query=" + encodedQuery;

                    System.out.println("=== 지오코딩 API 호출 ===");
                    System.out.println("원본 쿼리: " + query);
                    System.out.println("인코딩된 쿼리: " + encodedQuery);
                    System.out.println("URL: " + fullUrl);
                    System.out.println("AccessKey: " + accessKey);
                    System.out.println("SecretKey: " + secretKey);

                    // 네이버 클라우드 플랫폼 API 인증 방식
                    HttpURLConnection connection = (HttpURLConnection) new URL(fullUrl).openConnection();
                    connection.setRequestMethod(method);
                    connection.setRequestProperty("X-NCP-APIGW-TIMESTAMP", timestamp);
                    connection.setRequestProperty("X-NCP-IAM-ACCESS-KEY", accessKey);

                    // 서명 생성 - 올바른 포맷
                    String message = method + " " + url + "\n" + timestamp + "\n" + accessKey;
                    Mac mac = Mac.getInstance("HmacSHA256");
                    SecretKeySpec signingKey = new SecretKeySpec(secretKey.getBytes("UTF-8"), "HmacSHA256");
                    mac.init(signingKey);
                    byte[] rawHmac = mac.doFinal(message.getBytes("UTF-8"));
                    String signature = Base64.getEncoder().encodeToString(rawHmac);

                    connection.setRequestProperty("X-NCP-APIGW-SIGNATURE-V2", signature);

                    // 추가 헤더 시도
                    connection.setRequestProperty("X-NCP-APIGW-API-KEY-ID", accessKey);
                    connection.setRequestProperty("X-NCP-APIGW-API-KEY", secretKey);

                    System.out.println("=== API 호출 헤더 ===");
                    System.out.println("X-NCP-APIGW-TIMESTAMP: " + timestamp);
                    System.out.println("X-NCP-IAM-ACCESS-KEY: " + accessKey);
                    System.out.println("X-NCP-APIGW-SIGNATURE-V2: " + signature);
                    System.out.println("X-NCP-APIGW-API-KEY-ID: " + accessKey);
                    System.out.println("X-NCP-APIGW-API-KEY: " + secretKey);
                    System.out.println("Message: " + message);

                    int responseCode = connection.getResponseCode();
                    System.out.println("응답 코드: " + responseCode);

                    if (responseCode == 200) {
                        BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream()));
                        StringBuilder result = new StringBuilder();
                        String line;
                        while ((line = reader.readLine()) != null) {
                            result.append(line);
                        }
                        reader.close();
                        apiResponse = result.toString();
                        System.out.println("성공 응답: " + apiResponse);
                    } else {
                        BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getErrorStream()));
                        StringBuilder result = new StringBuilder();
                        String line;
                        while ((line = reader.readLine()) != null) {
                            result.append(line);
                        }
                        reader.close();
                        apiResponse = "{\"error\":{\"code\":" + responseCode + ",\"message\":" + result.toString()
                                + "}}";
                        System.out.println("에러 응답: " + apiResponse);
                    }

                } else if ("reverseGeocoding".equals(action)) {
                    String lat = request.getParameter("lat");
                    String lng = request.getParameter("lng");
                    String url = "/map-reversegeocode/v2/gc";
                    String fullUrl = "https://naveropenapi.apigw.ntruss.com" + url + "?coords=" + lng + "," + lat
                            + "&sourcecrs=epsg:4326&targetcrs=epsg:4326&orders=legalcode,admcode,addr,roadaddr&output=json";

                    System.out.println("=== 역지오코딩 API 호출 ===");
                    System.out.println("URL: " + fullUrl);
                    System.out.println("AccessKey: " + accessKey);
                    System.out.println("SecretKey: " + secretKey);

                    // 네이버 클라우드 플랫폼 API 인증 방식
                    HttpURLConnection connection = (HttpURLConnection) new URL(fullUrl).openConnection();
                    connection.setRequestMethod(method);
                    connection.setRequestProperty("X-NCP-APIGW-TIMESTAMP", timestamp);
                    connection.setRequestProperty("X-NCP-IAM-ACCESS-KEY", accessKey);

                    // 서명 생성 - 올바른 포맷
                    String message = method + " " + url + "\n" + timestamp + "\n" + accessKey;
                    Mac mac = Mac.getInstance("HmacSHA256");
                    SecretKeySpec signingKey = new SecretKeySpec(secretKey.getBytes("UTF-8"), "HmacSHA256");
                    mac.init(signingKey);
                    byte[] rawHmac = mac.doFinal(message.getBytes("UTF-8"));
                    String signature = Base64.getEncoder().encodeToString(rawHmac);

                    connection.setRequestProperty("X-NCP-APIGW-SIGNATURE-V2", signature);

                    int responseCode = connection.getResponseCode();
                    if (responseCode == 200) {
                        BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream()));
                        StringBuilder result = new StringBuilder();
                        String line;
                        while ((line = reader.readLine()) != null) {
                            result.append(line);
                        }
                        reader.close();
                        apiResponse = result.toString();
                    } else {
                        BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getErrorStream()));
                        StringBuilder result = new StringBuilder();
                        String line;
                        while ((line = reader.readLine()) != null) {
                            result.append(line);
                        }
                        reader.close();
                        apiResponse = "{\"error\":{\"code\":" + responseCode + ",\"message\":" + result.toString()
                                + "}}";
                    }

                } else if ("search".equals(action)) {
                    String query = request.getParameter("query");
                    String url = "/map-place/v1/search";
                    String encodedQuery = java.net.URLEncoder.encode(query, "UTF-8");
                    String fullUrl = "https://naveropenapi.apigw.ntruss.com" + url + "?query=" + encodedQuery
                            + "&display=5";

                    System.out.println("=== 검색 API 호출 ===");
                    System.out.println("URL: " + fullUrl);
                    System.out.println("AccessKey: " + accessKey);
                    System.out.println("SecretKey: " + secretKey);

                    // 네이버 클라우드 플랫폼 API 인증 방식
                    HttpURLConnection connection = (HttpURLConnection) new URL(fullUrl).openConnection();
                    connection.setRequestMethod(method);
                    connection.setRequestProperty("X-NCP-APIGW-TIMESTAMP", timestamp);
                    connection.setRequestProperty("X-NCP-IAM-ACCESS-KEY", accessKey);

                    // 서명 생성 - 올바른 포맷
                    String message = method + " " + url + "\n" + timestamp + "\n" + accessKey;
                    Mac mac = Mac.getInstance("HmacSHA256");
                    SecretKeySpec signingKey = new SecretKeySpec(secretKey.getBytes("UTF-8"), "HmacSHA256");
                    mac.init(signingKey);
                    byte[] rawHmac = mac.doFinal(message.getBytes("UTF-8"));
                    String signature = Base64.getEncoder().encodeToString(rawHmac);

                    connection.setRequestProperty("X-NCP-APIGW-SIGNATURE-V2", signature);

                    int responseCode = connection.getResponseCode();
                    if (responseCode == 200) {
                        BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream()));
                        StringBuilder result = new StringBuilder();
                        String line;
                        while ((line = reader.readLine()) != null) {
                            result.append(line);
                        }
                        reader.close();
                        apiResponse = result.toString();
                    } else {
                        BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getErrorStream()));
                        StringBuilder result = new StringBuilder();
                        String line;
                        while ((line = reader.readLine()) != null) {
                            result.append(line);
                        }
                        reader.close();
                        apiResponse = "{\"error\":{\"code\":" + responseCode + ",\"message\":" + result.toString()
                                + "}}";
                    }
                }

                response.getWriter().print(apiResponse);

            } else {
                response.getWriter().print("{\"error\":{\"message\":\"필수 파라미터가 누락되었습니다.\"}}");
            }

        } catch (Exception e) {
            response.getWriter().print("{\"error\":{\"message\":\"" + e.getMessage() + "\"}}");
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}