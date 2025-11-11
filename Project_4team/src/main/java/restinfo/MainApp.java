package restinfo;

import restinfo.model.TmapSearchService;
import restinfo.model.TmapCongestionService;
import java.util.List;
import java.util.Map;

public class MainApp {
    public static void main(String[] args) {
        String userKeyword = "행담도";

        List<Map<String, String>> restAreas = TmapSearchService.searchRestAreas(userKeyword);

        System.out.println("====== " + userKeyword + " 휴게소 목록 ======");

        if (restAreas.isEmpty()) {
            System.out.println("원하는 휴게소를 찾을 수 없습니다.");
        } else {
            for (int i = 0; i < restAreas.size(); i++) {
                Map<String, String> restArea = restAreas.get(i);

                String congestionLevelStr = TmapCongestionService.getCongestionLevel(restArea.get("id"));

                String statusMessage = "";
                switch (congestionLevelStr) {
                    case "1":
                        statusMessage = "🟢 (원활)";
                        break;
                    case "2":
                        statusMessage = "🟡 (보통)";
                        break;
                    case "3":
                        statusMessage = "🔴 (혼잡)";
                        break;
                    case "4":
                        statusMessage = "⚫ (매우 혼잡)";
                        break;
                    case "미지원":
                        statusMessage = "(혼잡도 정보 미지원)";
                        break;
                    default:
                        statusMessage = "(알 수 없음)";
                        break;
                }

                System.out.println(String.format("%d. %s %s (%s)", i + 1, restArea.get("name"), statusMessage, restArea.get("roadName")));
            }
        }
        System.out.println("============================\n");
    }
}