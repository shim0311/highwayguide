package bbs.action;

import bbs.dao.BbsDAO;
import bbs.util.Paging;
import mybatis.vo.BbsVO;
import restinfo.action.Action;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class FaqAction implements Action {
    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) {
        String subject = null;

        // FAQ 게시판이므로 FAQ 카테고리의 총 게시물 수를 얻어낸다.
        int totalCount = BbsDAO.getTotalCount("Faq"); // category에 "Faq"를 전달하여 FAQ 글만 가져온다.

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

        // DAO(DB)를 호출하여 FAQ 게시물 목록을 받는다.
        // FAQ 목록만 가져오기 위해 category에 "Faq"를 전달한다.
        BbsVO[] ar = BbsDAO.getList("Faq", subject, page.getBegin(), page.getEnd());

        // JSP에서 표현하기 위해 request에 저장!
        request.setAttribute("ar", ar);
        request.setAttribute("page", page);
        request.setAttribute("nowPage", page.getNowPage());

        return "bbs/faq.jsp"; // FAQ 페이지로 forward
    }
}
