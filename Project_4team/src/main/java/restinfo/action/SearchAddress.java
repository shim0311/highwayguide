package restinfo.action;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

public class SearchAddress implements Action {

    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response)
            throws UnsupportedEncodingException {
        String keyword = request.getParameter("keyword");

        // 키워드가 없으면 기본 키워드로 테스트
        if (keyword == null || keyword.trim().isEmpty()) {
            keyword = "강남";
        }

        try {
            // 카카오 API 키 (기존 프로젝트와 동일)
            String apiKey = "2bb9195b03b5b17418309109544a85c4";

            // URL 인코딩
            String encodedKeyword = URLEncoder.encode(keyword.trim(), StandardCharsets.UTF_8);

            // 카카오 로컬 키워드 검색 API 호출
            String apiUrl = "https://dapi.kakao.com/v2/local/search/keyword.json?query=" + encodedKeyword + "&size=10";

            URL url = new URL(apiUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Authorization", "KakaoAK " + apiKey);
            conn.setRequestProperty("Content-Type", "application/json;charset=UTF-8");

            int responseCode = conn.getResponseCode();

            // 응답 읽기
            BufferedReader br = new BufferedReader(
                    new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
            StringBuilder responseBuilder = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                responseBuilder.append(line);
            }
            br.close();
            conn.disconnect();

            String jsonResponse = responseBuilder.toString();

            // JSON 응답을 클라이언트에 전달
            response.setContentType("application/json; charset=UTF-8");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(jsonResponse);
            response.getWriter().flush();

        } catch (Exception e) {

            // 에러 발생 시 에러 응답
            try {
                response.setContentType("application/json; charset=UTF-8");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
                response.getWriter().flush();
            } catch (Exception ex) {
                // 에러 처리
            }
        }

        return null; // JSON 응답이므로 페이지 이동 없음
    }
}
