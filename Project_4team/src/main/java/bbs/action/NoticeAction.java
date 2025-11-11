package bbs.action;

import bbs.dao.BbsDAO;
import bbs.util.Paging;
import mybatis.vo.BbsVO;
import restinfo.action.Action;

import javax.security.auth.Subject;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class NoticeAction implements Action {
    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) {
        String subject = null;

        // 공지사항 게시판이므로 FAQ를 제외한 총 게시물 수를 얻어낸다.
        int totalCount = BbsDAO.getTotalCount(null); // category에 null을 전달하여 FAQ를 제외한 모든 글을 가져온다.

        // 페이징 처리 객체 생성
        Paging page = new Paging(5, 3);

        // 현재 페이지값을 파라미터로 받는다.
        String cPage = request.getParameter("cPage");

        int nowPage = 1;

        if (cPage != null && !cPage.isEmpty()) {
            nowPage = Integer.parseInt(cPage);
        }

        page.setTotalCount(totalCount);
        page.setNowPage(nowPage);

        // DAO(DB)를 호출하여 원하는 게시물 목록을 받는다.
        // FAQ를 제외한 목록을 가져오기 위해 category에 null을 전달한다.
        BbsVO[] ar = BbsDAO.getList(null, subject, page.getBegin(), page.getEnd());

        // JSP에서 표현하기 위해 request에 저장!
        request.setAttribute("ar", ar);
        request.setAttribute("page", page);
        request.setAttribute("nowPage", page.getNowPage());

        return "bbs/notice.jsp"; // 공지사항 페이지로 forward
    }
}
