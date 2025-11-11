package restinfo.control;

import restinfo.model.TmapCongestionService;
import restinfo.model.TmapSearchService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/search")
public class RestAreaController extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String userKeyword = request.getParameter("keyword");
		
		if (userKeyword != null && !userKeyword.trim().isEmpty()) {
			// 모델(Model) 호출
			List<Map<String, String>> restAreas = TmapSearchService.searchRestAreas(userKeyword);
			
			// 혼잡도 정보 추가
			for (Map<String, String> restArea : restAreas) {
				String congestionLevelStr = TmapCongestionService.getCongestionLevel(restArea.get("id"));
				restArea.put("congestionStatus", getStatusMessage(congestionLevelStr));
			}
			
			// 결과를 리퀘스트에 저장하여 View(JSP)로 전달
			request.setAttribute("restAreas", restAreas);
		}
		
		// View(JSP)로 포워딩
		request.getRequestDispatcher("/restAreaList.jsp").forward(request, response);
	}
	
	private String getStatusMessage(String congestionLevelStr) {
		switch (congestionLevelStr) {
			case "1":
				return "🟢 원활";
			case "2":
				return "🟡 보통";
			case "3":
				return "🔴 혼잡";
			case "4":
				return "⚫ 매우 혼잡";
			default:
				return "혼잡도 미지원";
		}
	}
}