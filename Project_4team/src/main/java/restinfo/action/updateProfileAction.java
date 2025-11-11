package restinfo.action;

import com.google.gson.Gson; // Gson 라이브러리 추가하면 편리합니다.
import mybatis.vo.UserVO;
import restinfo.dao.updateUserDAO;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class updateProfileAction implements Action {
    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        String newNickName = request.getParameter("nickName");
        String favoriteSeason = request.getParameter("favoriteSeason");
        String home = request.getParameter("home");
        HttpSession session = request.getSession();
        UserVO vo = (UserVO) session.getAttribute("loginUser");

        // 닉네임 중복 검사 로직 (기존과 동일)
        String currentNickName = vo.getNickName();
        boolean isNicknameChanged = !newNickName.equals(currentNickName);

        if (isNicknameChanged) {
            int count = updateUserDAO.isNicknameTaken(newNickName);
            if (count > 0) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\": false, \"message\": \"이미 사용 중인 닉네임입니다.\"}");
                return null;
            }
        }

        String ID = vo.getID();
        String platform = vo.getPlatform();
        int cnt = updateUserDAO.update(newNickName, favoriteSeason, ID, platform, home);

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        Map<String, Object> responseData = new HashMap<>();

        if (cnt > 0) { // 업데이트 성공
            // 세션 정보 업데이트
            vo.setNickName(newNickName);
            vo.setInterest(favoriteSeason);
            vo.setHome(home);
            session.setAttribute("loginUser", vo);

            // 💡 [핵심] 성공 응답과 함께 변경된 데이터를 같이 보내줍니다.
            responseData.put("success", true);
            responseData.put("message", "성공적으로 수정되었습니다.");

            // 업데이트된 사용자 정보를 담을 Map 생성
            Map<String, String> updatedUser = new HashMap<>();
            updatedUser.put("nickName", newNickName);
            updatedUser.put("home", home);
            updatedUser.put("favoriteSeason", favoriteSeason);

            responseData.put("updatedUser", updatedUser);

        } else { // 업데이트 실패
            responseData.put("success", false);
            responseData.put("message", "정보 수정에 실패했습니다.");
        }

        // Map 객체를 JSON 문자열로 변환 (Gson 라이브러리 사용 추천)
        String jsonResponse = new Gson().toJson(responseData);
        response.getWriter().write(jsonResponse);

        return null;
    }
}