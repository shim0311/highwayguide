package restinfo.action;

import mybatis.vo.ServiceAreaVO;
import mybatis.vo.UserVO;
import restinfo.dao.ServiceAreaDAO;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

public class bookmarkdeleteAction implements Action{
    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        UserVO vo = (UserVO) session.getAttribute("loginUser");

        String Useridx= String.valueOf(vo.getIdx());
        String SAidx =request.getParameter("saKey");
        System.out.println(Useridx+"useridx이건 나올거임");
        System.out.println(SAidx+"d이게좀애매mamaem");

        int cnt = ServiceAreaDAO.deletebookmark(SAidx,Useridx);

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String jsonResponse;
        if (cnt > 0) {
            // 성공 시: JavaScript의 if (response.success)가 true가 됨
            jsonResponse = "{\"success\": true}";
        } else {
            // 실패 시: JavaScript의 if (response.success)가 false가 됨
            jsonResponse = "{\"success\": false, \"message\": \"삭제에 실패했습니다.\"}";
        }

        // - 생성된 JSON 문자열을 응답으로 보냅니다.
        response.getWriter().write(jsonResponse);

        // AJAX는 페이지 이동이 없으므로 null을 반환합니다.
        return null;
    }
}
