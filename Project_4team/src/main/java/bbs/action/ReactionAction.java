package bbs.action;

import bbs.dao.BbsDAO;
import bbs.dao.LikeHateDAO;
import mybatis.vo.UserVO;
import restinfo.action.Action;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class ReactionAction implements Action {
    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) throws IOException {
        System.out.println("1. start ReactionAction"); //로그추가

        try{
            //파라미터 받기
            String type = request.getParameter("type");
            String postNum = request.getParameter("PostNum");

            //세션에서 로그인한 사용자 정보 가져오기
            HttpSession session = request.getSession();
            UserVO loginUser = (UserVO) session.getAttribute("loginUser");

            // 비로그인 사용자는 반응할 수 없도록 처리
            if (loginUser == null) {
                return null; // AJAX 호출이므로 null 반환
            }

            int userKey = loginUser.getIdx(); //사용자 고유키
            System.out.println("2. check parameter: type=" + type + ", postNum="
                    + postNum + ", userKey=" + userKey);
            // 3. 사용자가 이미 반응했는지 확인
            boolean hasReacted = LikeHateDAO.checkReaction(postNum, userKey);
            //System.out.println("3. DB reaction check" + hasReacted);

            if (!hasReacted) { // 아직 반응하지 않았을 때만 아래 로직 수행
                //System.out.println("4. new reaction DB start");
                // 4. 반응 기록하기 (트랜잭션 처리)
                LikeHateDAO.addReaction(postNum, userKey, type);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        //System.out.println("7. ReactionAction normally finished");
        return null; //AJAX로 처리하기때문에 페이지 이동 막기
    }
}
