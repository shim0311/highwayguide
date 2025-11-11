package restinfo.model;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import java.io.InputStream;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

public class TmapSearchService {
    private static final String APP_KEY;
    private static final String POI_SEARCH_URL = "https://apis.openapi.sk.com/tmap/pois";

    static {
        Properties properties = new Properties();
        try (InputStream input = TmapSearchService.class.getClassLoader().getResourceAsStream("application.properties")) {
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

    public static List<Map<String, String>> searchRestAreas(String userKeyword) {
        List<Map<String, String>> restAreas = new ArrayList<>();
        if (APP_KEY == null) {
            System.err.println("API 키가 설정되지 않았습니다.");
            return restAreas;
        }

        HttpClient client = HttpClient.newHttpClient();

        // 사용자가 입력한 키워드에 " 휴게소"를 붙여서 API 검색어를 만듭니다.
        String searchKeyword = userKeyword + " 휴게소";
        String encodedKeyword = URLEncoder.encode(searchKeyword, StandardCharsets.UTF_8);
        String urlWithParams = String.format("%s?version=1&searchKeyword=%s", POI_SEARCH_URL, encodedKeyword);

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

            if (jsonObject != null && jsonObject.has("searchPoiInfo")) {
                JsonArray poiArray = jsonObject.getAsJsonObject("searchPoiInfo")
                        .getAsJsonObject("pois")
                        .getAsJsonArray("poi");

                List<String> keywordWords = Arrays.asList(userKeyword.split("\\s+"));

                for (JsonElement element : poiArray) {
                    JsonObject poi = element.getAsJsonObject();
                    String poiName = poi.get("name").getAsString();
                    String lowerBizName = poi.get("lowerBizName").getAsString();

                    boolean allKeywordsMatch = true;
                    for (String word : keywordWords) {
                        if (!poiName.contains(word)) {
                            allKeywordsMatch = false;
                            break;
                        }
                    }

                    if (lowerBizName.equals("고속도로휴게소") && allKeywordsMatch && poiName.contains("방향")) {
                        Map<String, String> restAreaInfo = new HashMap<>();
                        restAreaInfo.put("name", poiName);
                        restAreaInfo.put("id", poi.get("id").getAsString());

                        if (poi.has("roadName")) {
                            restAreaInfo.put("roadName", poi.get("roadName").getAsString());
                        } else {
                            restAreaInfo.put("roadName", "정보 없음");
                        }

                        restAreas.add(restAreaInfo);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("API 호출 또는 JSON 파싱 중 오류가 발생했습니다: " + e.getMessage());
        }
        return restAreas;
    }
}