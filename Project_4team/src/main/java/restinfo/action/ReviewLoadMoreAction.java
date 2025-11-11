package restinfo.action;

import restinfo.dao.ReviewDAO;
import restinfo.action.Action;
import mybatis.vo.CReviewVO;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

public class ReviewLoadMoreAction implements Action {

    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) {
        try {
            // AJAX 요청에 대한 JSON 응답 설정
            response.setContentType("application/json; charset=UTF-8");
            PrintWriter out = response.getWriter();

            // 파라미터 받기
            String pageStr = request.getParameter("page");
            String searchKeyword = request.getParameter("search");
            int page = 1;

            if (pageStr != null && !pageStr.trim().isEmpty()) {
                page = Integer.parseInt(pageStr);
            }

            // 페이지당 아이템 수
            int itemsPerPage = 10;
            int offset = (page - 1) * itemsPerPage;

            List<CReviewVO> reviews;

            if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                // 검색 결과에 대한 페이징
                reviews = ReviewDAO.getReviewsWithPagingAndSearch(searchKeyword.trim(), offset, itemsPerPage);
            } else {
                // 전체 리뷰에 대한 페이징
                reviews = ReviewDAO.getReviewsWithPaging(offset, itemsPerPage);
            }

            // JSON 응답 생성
            StringBuilder json = new StringBuilder();
            json.append("{\"reviews\":[");

            for (int i = 0; i < reviews.size(); i++) {
                CReviewVO review = reviews.get(i);
                json.append("{");
                json.append("\"idx\":\"").append(escapeJson(review.getIdx())).append("\",");
                json.append("\"saKey\":\"").append(escapeJson(review.getSAKey())).append("\",");
                json.append("\"writer\":\"").append(escapeJson(review.getWriter())).append("\",");
                json.append("\"content\":\"").append(escapeJson(review.getContent())).append("\",");
                json.append("\"imageUrl\":\"").append(escapeJson(review.getImageUrl())).append("\",");
                json.append("\"serviceAreaName\":\"").append(escapeJson(review.getServiceAreaName())).append("\",");
                json.append("\"serviceAreaAddress\":\"").append(escapeJson(review.getServiceAreaAddress()))
                        .append("\",");
                json.append("\"serviceAreaStar\":\"").append(escapeJson(review.getServiceAreaStar())).append("\"");
                json.append("}");

                if (i < reviews.size() - 1) {
                    json.append(",");
                }
            }

            json.append("],\"hasMore\":").append(reviews.size() == itemsPerPage).append("}");

            out.print(json.toString());
            out.flush();

            return null; // AJAX 요청이므로 포워딩하지 않음

        } catch (Exception e) {
            System.err.println("리뷰 추가 로드 중 오류: " + e.getMessage());
            e.printStackTrace();

            try {
                response.setContentType("application/json; charset=UTF-8");
                PrintWriter out = response.getWriter();
                out.print("{\"error\":\"리뷰를 불러오는 중 오류가 발생했습니다.\"}");
                out.flush();
            } catch (IOException ex) {
                ex.printStackTrace();
            }

            return null;
        }
    }

    /**
     * JSON 문자열에서 특수 문자를 이스케이프합니다.
     */
    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
