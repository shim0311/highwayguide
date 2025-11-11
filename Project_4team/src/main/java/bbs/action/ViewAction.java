package bbs.action;

import bbs.dao.BbsDAO;
import bbs.dao.LikeHateDAO;
import mybatis.vo.BbsVO;
import mybatis.vo.UserVO;
import restinfo.action.Action;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.Set;

public class ViewAction implements Action {
    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) {
        //파라미터 받기
        String postNum = request.getParameter("PostNum"); //기본키
        //한번이라도 읽은 게시물들은 list에 담아서 HttpSession에 저장해 둔다.
        //그럼 우선 HttpSession으로 부터 list를 얻어내자


        //게시물 정보를 가져와서 view로 전달
        BbsVO vo = BbsDAO.getPostNum(postNum); //사용자가 선택한 게시물을 검색해 온다.
        request.setAttribute("vo", vo);

        //좋아요, 싫어요 수 가져오기
        int likeCount = LikeHateDAO.getLikeCount(postNum);
        int hateCount = LikeHateDAO.getHateCount(postNum);
        // 결과를 request에 저장
        request.setAttribute("likeCount", likeCount);
        request.setAttribute("hateCount", hateCount);

        // 현재 사용자의 반응 여부 확인
        HttpSession session = request.getSession();
        UserVO loginUser = (UserVO) session.getAttribute("loginUser"); // 실제 세션 이름 확인

        // 로그인 상태일 때만 반응 여부를 DB에서 확인
        if (loginUser != null) {
            int userKey = loginUser.getIdx(); // 로그인한 사용자의 고유 키(idx) 가져오기
            boolean hasReacted = LikeHateDAO.checkReaction(postNum, userKey); // LikeHateDAO를 호출하여 이 글에 반응했는지 확인
            request.setAttribute("hasReacted", hasReacted); // 확인된 결과를 "hasReacted"라는 이름으로 request에 저장
        }
        // view.jsp로 forward
        return "bbs/view.jsp";
    }
}
