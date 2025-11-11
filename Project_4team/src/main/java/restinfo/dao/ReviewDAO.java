package restinfo.dao;

import mybatis.service.FactoryService;
import mybatis.vo.CReviewVO;
import mybatis.vo.ServiceAreaVO;
import org.apache.ibatis.session.SqlSession;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ReviewDAO {

    /**
     * 모든 리뷰 데이터를 ServiceArea와 조인하여 가져옵니다.
     * 
     * @return 리뷰 목록
     */
    public static List<CReviewVO> getAllReviewsWithServiceArea() {
        SqlSession ss = FactoryService.getFactory().openSession();
        List<CReviewVO> reviews = null;

        try {
            reviews = ss.selectList("crawlingdata.getAllReviewsWithServiceArea");
        } catch (Exception e) {
            System.err.println("리뷰 데이터 조회 실패: " + e.getMessage());
            e.printStackTrace();
        } finally {
            ss.close();
        }

        return reviews;
    }

    /**
     * 특정 휴게소의 리뷰 데이터를 가져옵니다.
     * 
     * @param saKey 휴게소 키
     * @return 리뷰 목록
     */
    public static List<CReviewVO> getReviewsBySAKey(String saKey) {
        SqlSession ss = FactoryService.getFactory().openSession();
        List<CReviewVO> reviews = null;

        try {
            reviews = ss.selectList("crawlingdata.getReviewsBySAKeyWithServiceArea", saKey);
        } catch (Exception e) {
            System.err.println("휴게소별 리뷰 데이터 조회 실패: " + e.getMessage());
            e.printStackTrace();
        } finally {
            ss.close();
        }

        return reviews;
    }

    /**
     * 리뷰 통계 정보를 가져옵니다.
     * 
     * @return 통계 맵
     */
    public static Map<String, Object> getReviewStats() {
        SqlSession ss = FactoryService.getFactory().openSession();
        Map<String, Object> stats = new HashMap<>();

        try {
            // 전체 리뷰 수
            int totalReviews = ss.selectOne("crawlingdata.getTotalCrawlingDataCount");
            stats.put("totalReviews", totalReviews);

            // 고유 휴게소 수
            int uniqueSAKeys = ss.selectOne("crawlingdata.getUniqueSAKeyCount");
            stats.put("uniqueSAKeys", uniqueSAKeys);

            // 고유 작성자 수
            int uniqueWriters = ss.selectOne("crawlingdata.getUniqueWriterCount");
            stats.put("uniqueWriters", uniqueWriters);

        } catch (Exception e) {
            System.err.println("리뷰 통계 조회 실패: " + e.getMessage());
            e.printStackTrace();
        } finally {
            ss.close();
        }

        return stats;
    }

    /**
     * 페이징을 위한 리뷰 데이터를 가져옵니다.
     * 
     * @param begin 시작 인덱스
     * @param end   끝 인덱스
     * @return 리뷰 목록
     */
    public static List<CReviewVO> getReviewsWithPaging(int begin, int end) {
        SqlSession ss = FactoryService.getFactory().openSession();
        List<CReviewVO> reviews = null;

        try {
            Map<String, Object> params = new HashMap<>();
            params.put("begin", begin);
            params.put("end", end);
            reviews = ss.selectList("crawlingdata.getReviewsWithPagingAndServiceArea", params);
        } catch (Exception e) {
            System.err.println("페이징 리뷰 데이터 조회 실패: " + e.getMessage());
            e.printStackTrace();
        } finally {
            ss.close();
        }

        return reviews;
    }

    /**
     * 휴게소 이름으로 리뷰를 검색합니다.
     * 
     * @param searchKeyword 검색 키워드
     * @return 리뷰 목록
     */
    public static List<CReviewVO> searchReviewsByServiceAreaName(String searchKeyword) {
        SqlSession ss = FactoryService.getFactory().openSession();
        List<CReviewVO> reviews = null;

        try {
            reviews = ss.selectList("crawlingdata.searchReviewsByServiceAreaName", searchKeyword);
        } catch (Exception e) {
            System.err.println("휴게소명 검색 실패: " + e.getMessage());
            e.printStackTrace();
        } finally {
            ss.close();
        }

        return reviews;
    }

    /**
     * 검색 결과에 대한 페이징 리뷰 데이터를 가져옵니다.
     * 
     * @param searchKeyword 검색 키워드
     * @param offset        시작 인덱스
     * @param limit         가져올 개수
     * @return 리뷰 목록
     */
    public static List<CReviewVO> getReviewsWithPagingAndSearch(String searchKeyword, int offset, int limit) {
        SqlSession ss = FactoryService.getFactory().openSession();
        List<CReviewVO> reviews = null;

        try {
            Map<String, Object> params = new HashMap<>();
            params.put("searchKeyword", searchKeyword);
            params.put("offset", offset);
            params.put("limit", limit);
            reviews = ss.selectList("crawlingdata.getReviewsWithPagingAndSearch", params);
        } catch (Exception e) {
            System.err.println("검색 페이징 리뷰 데이터 조회 실패: " + e.getMessage());
            e.printStackTrace();
        } finally {
            ss.close();
        }

        return reviews;
    }

    /**
     * 검색 결과 개수를 조회합니다.
     * 
     * @param searchKeyword 검색 키워드
     * @return 검색 결과 개수
     */
    public static int getSearchResultCount(String searchKeyword) {
        SqlSession ss = FactoryService.getFactory().openSession();
        int count = 0;

        try {
            count = ss.selectOne("crawlingdata.getSearchResultCount", searchKeyword);
        } catch (Exception e) {
            System.err.println("검색 결과 개수 조회 실패: " + e.getMessage());
            e.printStackTrace();
        } finally {
            ss.close();
        }

        return count;
    }
}
