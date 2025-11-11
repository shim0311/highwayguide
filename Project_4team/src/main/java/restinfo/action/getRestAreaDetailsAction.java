package restinfo.action;

import com.google.gson.Gson;
import mybatis.vo.ServiceAreaVO;
import mybatis.vo.GasVO;
import mybatis.vo.UserVO;
import restinfo.dao.BookmarkDAO;
import restinfo.dao.ServiceAreaDAO;
import restinfo.dao.GasDAO;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class getRestAreaDetailsAction implements Action {
    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String saKey = request.getParameter("saKey");

        // ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼ [수정] 전체 로직을 try-catch로 감쌉니다 ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼
        try {
            ServiceAreaVO vo = ServiceAreaDAO.getOneArea(saKey);

            if (vo != null) {
                GasVO gvo = GasDAO.getgas(saKey);
                vo.setGasInfo(gvo);

                HttpSession session = request.getSession();
                UserVO user = (UserVO) session.getAttribute("loginUser");

                System.out.println("[DEBUG] 로그인 유저: " + user); // 1. 유저 정보가 잘 넘어오는지 확인

                if (user != null) {
                    String userKey = String.valueOf(user.getIdx());
                    System.out.println("[DEBUG] UserKey: " + userKey + ", SAKey: " + saKey); // 2. Key 값들이 잘 넘어오는지 확인

                    boolean isBookmarked = BookmarkDAO.isBookmarked(userKey, saKey);
                    System.out.println("[DEBUG] isBookmarked 결과: " + isBookmarked); // 3. DAO 호출 결과 확인

                    vo.setBookmarked(isBookmarked);
                } else {
                    vo.setBookmarked(false);
                }
            }

            String jsonResponse = new Gson().toJson(vo);

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(vo != null ? jsonResponse : "{}");

        } catch (Exception e) {
            // [핵심] 어떤 오류든 여기서 잡아서 무조건 콘솔에 출력합니다!
            System.err.println("===== getRestAreaDetailsAction에서 심각한 오류 발생! =====");
            e.printStackTrace(); // 오류의 상세 내용을 콘솔에 빨간색으로 출력
            System.err.println("======================================================");

            // 프론트엔드에는 여전히 서버 오류라고 알려줍니다.
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"서버 내부 오류가 발생했습니다.\"}");
        }


        return null;
    }
}