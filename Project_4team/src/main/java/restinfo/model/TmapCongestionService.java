package restinfo.model;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import java.io.InputStream;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.Properties;

public class TmapCongestionService {
    private static final String APP_KEY;
    // 네가 찾아낸 정확한 API 엔드포인트를 사용합니다.
    private static final String CONGESTION_API_BASE_URL = "https://apis.openapi.sk.com/puzzle/place/congestion/rltm/pois";

    static {
        Properties properties = new Properties();
        try (InputStream input = TmapCongestionService.class.getClassLoader().getResourceAsStream("application.properties")) {
            if (input == null) {
                APP_KEY = null;
            } else {
                properties.load(input);
                APP_KEY = properties.getProperty("tmap.appkey");
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Failed to load application.properties");
        }
    }

    public static String getCongestionLevel(String restAreaId) {
        if (APP_KEY == null) {
            System.err.println("API 키가 설정되지 않았습니다.");
            return "미지원";
        }

        HttpClient client = HttpClient.newHttpClient();
        // poiId를 URL 경로에 추가하여 API를 호출합니다.
        String urlWithParams = String.format("%s/%s", CONGESTION_API_BASE_URL, restAreaId);

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(urlWithParams))
                .header("appKey", APP_KEY)
                .header("Accept", "application/json")
                .GET()
                .build();

        try {
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            Gson gson = new Gson();
            JsonObject jsonObject = gson.fromJson(response.body(), JsonObject.class);

            // 네가 제공한 응답 JSON 구조에 맞게 데이터를 파싱합니다.
            if (jsonObject != null && jsonObject.has("contents")) {
                JsonObject contents = jsonObject.getAsJsonObject("contents");
                if (contents.has("rltm") && contents.getAsJsonArray("rltm").size() > 0) {
                    JsonObject rltm = contents.getAsJsonArray("rltm").get(0).getAsJsonObject();
                    if (rltm.has("congestionLevel")) {
                        int level = rltm.get("congestionLevel").getAsInt();
                        return String.valueOf(level);
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("API 호출 또는 JSON 파싱 중 오류가 발생했습니다: " + e.getMessage());
        }

        // 호출 실패 또는 데이터가 없을 경우 "미지원" 반환
        return "미지원";
    }
}