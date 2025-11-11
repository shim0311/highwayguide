package restinfo.action;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.json.JSONArray;
import restinfo.dao.ManageDAO;

public class getStatusAction implements Action{

    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // 구분자(chartType)는 같은 액션에서 여러 유형을 처리할 때 사용
        // 현재는 사용하지 않지만, 확장을 고려해 파라미터만 읽어둔다.
         String chartType = request.getParameter("chartType");

         if (chartType.equals("donut")) {// 도넛차트 아이템 가져와서 json으로 반환

             // JSON 응답 설정
             response.setContentType("application/json; charset=UTF-8");

             // DB에서 [kakao, naver, local] 순으로 개수 조회
             int[] counts = ManageDAO.getPlatformCount();

             // JSON 배열로 응답
             try (PrintWriter out = response.getWriter()) {
                 out.print("[" + counts[0] + "," + counts[1] + "," + counts[2] + "]");
                 out.flush();
             }
         }else if (chartType.equals("bar")) { // 막대그래프 아이템 가져와서 JSONarray로 반환

             List<Map<String, Object>> list = ManageDAO.getSARank();
             List<Map<String, Object>> Rank = new ArrayList<>();
             System.out.println(list.size());

             for (Map<String, Object> map : list) {
                 Map<String, Object> item = new HashMap<>();

                 String str = map.get("SADirection").toString();
                 if (str.contains("("))
                     str = str.substring(str.indexOf("("), str.indexOf(")") + 1);
                 item.put("name", map.get("SAName") + str);
                 item.put("count", map.get("cnt"));
                 Rank.add(item);
             }

             // JSON 배열로 응답
             JSONArray jsonArray = new JSONArray(Rank);
             // JSON 응답 설정
             response.setContentType("application/json; charset=UTF-8");

             try (PrintWriter out = response.getWriter()) {
                 out.print(jsonArray);
                 out.flush();
             }
         }
        // 포워딩 없음 (AJAX 응답 완료)
        return null;
    }
}