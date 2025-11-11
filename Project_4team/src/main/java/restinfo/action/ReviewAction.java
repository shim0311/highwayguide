package restinfo.action;

import restinfo.dao.ReviewDAO;
import restinfo.action.Action;
import mybatis.vo.CReviewVO;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.List;
import java.util.Map;

public class ReviewAction implements Action {

    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) {
        try {
            // 검색 파라미터 확인
            String searchKeyword = request.getParameter("search");
            List<CReviewVO> reviews;

            // 초기 로드 시에는 첫 10개만 가져오기
            int initialLoad = 10;

            if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                // 검색어가 있으면 검색 실행 (페이징)
                reviews = ReviewDAO.getReviewsWithPagingAndSearch(searchKeyword.trim(), 0, initialLoad);
                request.setAttribute("searchKeyword", searchKeyword.trim());
                request.setAttribute("isSearch", true);
            } else {
                // 검색어가 없으면 전체 리뷰 조회 (페이징)
                reviews = ReviewDAO.getReviewsWithPaging(0, initialLoad);
                request.setAttribute("isSearch", false);
            }

            request.setAttribute("reviews", reviews);

            // 통계 정보 조회
            Map<String, Object> stats = ReviewDAO.getReviewStats();

            // 검색인 경우 검색 결과 개수로 업데이트
            if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                int searchResultCount = ReviewDAO.getSearchResultCount(searchKeyword.trim());
                stats.put("totalReviews", searchResultCount);
            }

            request.setAttribute("stats", stats);

            // 리뷰 페이지로 포워딩
            return "/review.jsp";

        } catch (Exception e) {
            System.err.println("리뷰 페이지 로드 중 오류: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "리뷰 데이터를 불러오는 중 오류가 발생했습니다.");
            return "/review.jsp";
        }
    }
}
