package restinfo.action;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;

public class VideoProxyAction implements Action {

    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String temporaryUrl = request.getParameter("temporaryUrl");

        if (temporaryUrl == null || temporaryUrl.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("temporaryUrl parameter is missing.");
            return null;
        }

        try {
            System.out.println("프록시 요청 시작: " + temporaryUrl);

            URL url = new URL(temporaryUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setInstanceFollowRedirects(true); // 리다이렉션 자동 추적 설정

            // 연결을 시도하고 응답 코드를 확인합니다.
            int responseCode = conn.getResponseCode();

            // 응답 코드가 정상 범위(200-399)일 때만 최종 URL을 가져옵니다.
            if (responseCode >= 200 && responseCode <= 399) {
                String finalUrl = conn.getURL().toString();
                System.out.println("프록시 응답 (최종 URL): " + finalUrl);
                response.setContentType("text/plain;charset=UTF-8");
                response.getWriter().write(finalUrl);
            } else {
                // 오류 응답을 받은 경우, 에러 로그를 남기고 클라이언트에 빈 문자열 반환
                System.err.println("프록시 요청 실패! 응답 코드: " + responseCode);
                response.setStatus(HttpServletResponse.SC_OK);
                response.setContentType("text/plain;charset=UTF-8");
                response.getWriter().write(""); // 빈 문자열 반환
            }

            conn.disconnect();

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Error fetching video stream URL.");
        }

        return null;
    }
}
