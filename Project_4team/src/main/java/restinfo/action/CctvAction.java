package restinfo.action;

import restinfo.action.Action;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.io.FileInputStream;
import java.util.Properties;

public class CctvAction implements Action {

    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String minX = request.getParameter("minX");
        String minY = request.getParameter("minY");
        String maxX = request.getParameter("maxX");
        String maxY = request.getParameter("maxY");

        // 1. application.properties 파일에서 API 키를 읽어오는 로직
        String apiKey = "";
        try {
            // 프로젝트의 리소스 폴더에 있는 application.properties 파일 경로
            String resourcePath = request.getServletContext().getRealPath("/WEB-INF/classes/application.properties");
            Properties prop = new Properties();
            FileInputStream fis = new FileInputStream(resourcePath);
            prop.load(fis);
            apiKey = prop.getProperty("cctv.api.key");
            fis.close();
        } catch (Exception e) {
            System.err.println("Failed to read application.properties: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return null;
        }

        try {
            StringBuilder urlBuilder = new StringBuilder("https://openapi.its.go.kr:9443/cctvInfo");

            // 2. 읽어온 apiKey 변수를 사용
            urlBuilder.append("?" + URLEncoder.encode("apiKey", "UTF-8") + "=" + URLEncoder.encode(apiKey, "UTF-8"));

            urlBuilder.append("&" + URLEncoder.encode("type", "UTF-8") + "=" + URLEncoder.encode("all", "UTF-8"));
            urlBuilder.append("&" + URLEncoder.encode("cctvType", "UTF-8") + "=" + URLEncoder.encode("4", "UTF-8"));
            urlBuilder.append("&" + URLEncoder.encode("minX", "UTF-8") + "=" + URLEncoder.encode(minX, "UTF-8"));
            urlBuilder.append("&" + URLEncoder.encode("maxX", "UTF-8") + "=" + URLEncoder.encode(maxX, "UTF-8"));
            urlBuilder.append("&" + URLEncoder.encode("minY", "UTF-8") + "=" + URLEncoder.encode(minY, "UTF-8"));
            urlBuilder.append("&" + URLEncoder.encode("maxY", "UTF-8") + "=" + URLEncoder.encode(maxY, "UTF-8"));
            urlBuilder.append("&" + URLEncoder.encode("getType", "UTF-8") + "=" + URLEncoder.encode("json", "UTF-8"));

            // 디버깅을 위해 호출 URL을 서버 로그에 출력합니다.
            System.out.println("CCTV API 호출 URL: " + urlBuilder.toString());

            URL url = new URL(urlBuilder.toString());
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Content-type", "application/json;charset=UTF-8");

            BufferedReader rd;
            if (conn.getResponseCode() >= 200 && conn.getResponseCode() <= 300) {
                rd = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));
            } else {
                rd = new BufferedReader(new InputStreamReader(conn.getErrorStream(), "UTF-8"));
            }

            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = rd.readLine()) != null) {
                sb.append(line);
            }
            rd.close();
            conn.disconnect();

            // 디버깅을 위해 API 응답을 서버 로그에 출력합니다.
            System.out.println("CCTV API 응답: " + sb.toString());

            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write(sb.toString());

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }

        return null;
    }
}
