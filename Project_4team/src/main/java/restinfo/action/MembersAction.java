package restinfo.action;

import com.google.gson.Gson;
import mybatis.vo.UserVO;
import restinfo.dao.ManageDAO;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MembersAction implements Action {

    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String method = request.getParameter("method");
        Gson gson = new Gson();

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        if (method.equals("getAll")) {
            // 회원 로딩 후 json으로 반환해야하는 메서드
            List<UserVO> list = ManageDAO.getAll();

            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("members", list);

            out.print(gson.toJson(result));

            out.flush();
        } else if (method.equals("delete")) {
            // 특정 회원 탈퇴처리하는 메서드
            String Nickname = request.getParameter("NickName");

            int cnt = ManageDAO.deactivateAccount(Nickname);

            Map<String, Object> result = new HashMap<>();

            if (cnt > 0) {
                result.put("success", true);
                result.put("message", "회원이 성공적으로 삭제되었습니다.");
            } else {
                result.put("success", false);
                result.put("message", "회원 삭제에 실패했습니다.");
            }

            out.print(gson.toJson(result));
        }
        return null;
    }
}
