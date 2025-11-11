package bbs.action;

import bbs.dao.BbsDAO;
import mybatis.vo.BbsVO;
import mybatis.vo.UserVO;
import restinfo.action.Action;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
//delete ::::::
public class DelAction implements Action {
    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) {
        // 세션에서 로그인 사용자 정보 가져오기
        HttpSession session = request.getSession();
        UserVO loginUser = (UserVO)session.getAttribute("loginUser");

        // 파라미터로 넘어온 게시물 번호와 페이지 번호 받기
        String postNum = request.getParameter("PostNum");
        String cPage = request.getParameter("cPage");
        // 'returnTo' 파라미터를 추가로 가져와서 어느 페이지에서 요청했는지 확인
        String returnTo = request.getParameter("returnTo");

        System.out.println("-------------------------------------");
        System.out.println(postNum+"check");
        System.out.println(cPage);
        System.out.println("returnTo: " + returnTo); // 디버깅용 로그

        // 삭제할 게시물의 정보 가져오기(작성자 확인용)
        BbsVO vo = BbsDAO.getPostNum(postNum);
        System.out.println(vo);
        System.out.println("vo가져왔는가");

        // 권한 확인(로그인x || 관리자x || 본인작성x 일경우)
        if (loginUser == null || (!"1".equals(loginUser.getAuthority())
                && !loginUser.getID().equals(vo.getWriter()))) {
            try {
                // 권한이 없으면 원래 페이지로 돌아가기
                if ("faq".equals(returnTo)) {
                    response.sendRedirect("Controller?type=faq&cPage=" + cPage);
                } else {
                    response.sendRedirect("Controller?type=notice&cPage=" + cPage);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            return null; // 작업 중단
        }

        // 모든 권한 확인 통과 시 DB에서 게시물 삭제
        BbsDAO.delBbs(postNum);

        // 삭제 후, 'returnTo' 파라미터에 따라 올바른 목록 페이지로 리다이렉트
        try {
            String redirectURL;
            if ("faq".equals(returnTo)) {
                redirectURL = "Controller?type=faq&cPage=" + cPage;
            } else {
                redirectURL = "Controller?type=notice&cPage=" + cPage;
            }
            System.out.println("2. DelAction이 보낼 redirect URL: " + redirectURL);
            System.out.println("----------------------");

            response.sendRedirect(redirectURL);
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }
}
