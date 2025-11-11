package restinfo.action;

import org.mindrot.jbcrypt.BCrypt;
import restinfo.dao.updateUserDAO;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;

public class ForgotPasswordAction implements Action {

    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String todo = request.getParameter("todo");
        String path = null;

        if ( todo!= null && todo.equals("savePassword")) {
            // 바꾼 비번 새로 저장
            String Idx = request.getParameter("Idx");
            String Password = request.getParameter("password");

            System.out.println("Idx: " + Idx + " new Password: " + Password);

            //해쉬 값 으로 넣기
            String hashpwd = BCrypt.hashpw(Password, BCrypt.gensalt());
            System.out.println(hashpwd);

            int cnt = updateUserDAO.changeAccount(Idx, hashpwd);

            path = "index.jsp";
        } else {
            // 이메일 주소를 받아 db에 있는 이메일인지 확인하고 있다면 해당 이메일로 비밀번호 재설정 링크를 보내야 됨
            String email = request.getParameter("email");
            System.out.println("email: " + email);
            int idx = updateUserDAO.checkAccount(email);
            System.out.println("Idx: " + idx);
            // JSON 응답을 위한 설정
            response.setContentType("application/json;charset=UTF-8");
            PrintWriter out = response.getWriter();

            if (idx != 0) {
                // 이메일로 검색한 계정이 있을때 수행되는 영역 여기서 이제 해당 이메일로 비밀번호 변경 jsp 보내야 됨
                out.print("{\"success\":true,\"message\":\"비밀번호 재설정 이메일이 발송되었습니다.\"}");
                // 나중에 이 사용자가 비밀번호를 바꿀 것을 예상해서 Idx만 세션에 저장해놓는다
                request.getSession().setAttribute("Idx", idx);
            } else {
                // 검색한 이메일이 db에 없는 경우 수행되는 영역 즉, 가입한적 없는 사용자임
                out.print("{\"success\":false,\"message\":\"가입되지 않은 이메일 주소입니다.\"}");
            }

            out.flush();
            out.close();
            // JSON 응답이므로 페이지 이동 없으므로 path 안건드림
        }
        return path;
    }
}
