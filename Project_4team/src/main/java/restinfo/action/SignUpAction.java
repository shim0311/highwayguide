package restinfo.action;

import mybatis.vo.UserVO;
import org.mindrot.jbcrypt.BCrypt;
import restinfo.dao.SignUpDAO;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.UnsupportedEncodingException;
import java.util.*;

public class SignUpAction implements Action {
    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) throws UnsupportedEncodingException {
        request.setCharacterEncoding("utf-8");
        String email = request.getParameter("email");
        String pwd = request.getParameter("password");
        String name = request.getParameter("name");

        //해쉬 값 으로 넣기
        String hashpwd = BCrypt.hashpw(pwd, BCrypt.gensalt());
        System.out.println(hashpwd);
        System.out.println(email);
        System.out.println(name);

        try {
            UserVO CheckVO = SignUpDAO.check(email,"ORIGIN");
            String str= makeNickName();
            if(CheckVO==null) {
                int cnt = SignUpDAO.add(email, str, hashpwd, name, "ORIGIN");
                if (cnt > 0) {
                    System.out.println("완료");
                } else {
                    System.out.println("안댐 (cnt=0)");
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);;
                }
            }else {
                // 이메일이 중복되는 경우: 409 Conflict 상태 코드 전송
                System.out.println("이메일 중복: " + email);
                response.setStatus(HttpServletResponse.SC_CONFLICT);
            }
        } catch (Exception e) {
           e.printStackTrace();

        }

        return null;
    }

    private String makeNickName() {

        // 닉네임을 비교하기 위해 기존의 DB에서 닉네임값들 불러오기
        List<String> nickNames = SignUpDAO.check("User");
        Set<Integer> set = new HashSet<>();

        // 각각 닉네임에서 뒤의 숫자만 얻어내기
        for (int i = 0; i < nickNames.size(); i++) {
            set.add(Integer.parseInt(nickNames.get(i).substring(4)));
        }

        int newNumber;

        do { // set구조에 값이 들어갈 때까지(중복되지 않는 수가 들어갈 때까지) 반복
            newNumber = (int)(Math.random() * 90000) + 10000;  // 10000 ~ 99999
        } while (set.contains(newNumber));

        return "User" + newNumber;
    }

}
