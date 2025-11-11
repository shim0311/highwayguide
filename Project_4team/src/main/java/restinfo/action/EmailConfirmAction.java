package restinfo.action;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.UnsupportedEncodingException;

public class EmailConfirmAction implements Action{
    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) throws UnsupportedEncodingException {

        // script에서 사용자가 입력한 code
        String submittedCode = request.getParameter("code");
        System.out.println("코드는"+submittedCode);
        // 실제로 메일로 전송된 코드
        HttpSession session = request.getSession();
        Integer realAuthCode = (Integer) session.getAttribute("code");




        if (realAuthCode != null && submittedCode != null && submittedCode.equals(String.valueOf(realAuthCode))) {
            // 인증 성공
            System.out.println("이메일 인증 성공");
            response.setStatus(HttpServletResponse.SC_OK);

            // ⭐ 중요: 성공 후에는 세션에서 인증번호를 반드시 제거하여 재사용을 방지
            session.removeAttribute("code");
            session.removeAttribute("email"); // 관련 이메일 정보도 함께 제거

        } else {
            // 인증 실패
            System.out.println("이메일 인증 실패");
            // 400 Bad Request - 클라이언트가 잘못된 값을 보냈다는 의미
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }

        return null; // AJAX 응답이므로 null 리턴
    }
}
