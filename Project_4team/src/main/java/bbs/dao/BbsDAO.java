package bbs.dao;

import mybatis.service.FactoryService;
import mybatis.vo.BbsVO;
import org.apache.ibatis.session.SqlSession;

import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class BbsDAO {

    /**
     * 총 게시물 수를 반환하는 메서드 (기존의 totalCount 쿼리 대신 사용)
     * @param category 게시판 카테고리 (null이면 모든 게시물, 'Faq'이면 FAQ, 그 외는 공지사항)
     * @return 총 게시물 수
     */
    public static int getTotalCount(String category) {
        SqlSession ss = FactoryService.getFactory().openSession();
        int cnt = 0;
        if ("Faq".equals(category)) {
            cnt = ss.selectOne("Board.totalCountFaqOnly");
        } else {
            cnt = ss.selectOne("Board.totalCountExceptFaq");
        }
        ss.close();
        return cnt;
    }

    /**
     * 게시물 목록을 반환하는 메서드 (기존의 list 쿼리 대신 사용)
     * @param category 게시판 카테고리 (null이면 모든 게시물, 'Faq'이면 FAQ, 그 외는 공지사항)
     * @param subject 검색어
     * @param begin 시작 행
     * @param end 끝 행
     * @return 게시물 배열
     */
    public static BbsVO[] getList(String category, String subject, int begin, int end){
        BbsVO[] ar = null;

        Map<String, Object> map = new HashMap<>();
        map.put("subject", subject);
        map.put("begin", begin);
        map.put("end", end);

        SqlSession ss = FactoryService.getFactory().openSession();
        List<BbsVO> list = null;

        if ("Faq".equals(category)) {
            list = ss.selectList("Board.listFaqOnly", map);
        } else {
            list = ss.selectList("Board.listExceptFaq", map);
        }

        if(list != null && list.size() > 0){
            ar = new BbsVO[list.size()];
            list.toArray(ar);
        }
        ss.close();

        return ar;
    }


    //저장
    public static int add(String subject, String writer,
                          String content, String FileName, String category,
                          String writeDate, String ThumbsUp, String ThumbsDown,
                          String Delete, String Pwd){
        int cnt = 0;

        Map<String, String> map = new HashMap<>();
        map.put("subject", subject);
        map.put("writer", writer);
        map.put("content", content);
        map.put("FileName", FileName);
        map.put("category", category);
        map.put("writeDate", writeDate);
        map.put("ThumbsUp", ThumbsUp);
        map.put("ThumbsDown", ThumbsDown);
        map.put("Delete", Delete);
        map.put("Pwd", Pwd);

        SqlSession ss = FactoryService.getFactory().openSession();
        cnt = ss.insert("Board.add", map);
        if(cnt > 0)
            ss.commit();
        else
            ss.rollback();
        ss.close();

        return cnt;
    }

    // 기본키를 인자로 하여 게시물 가져오기
    public static BbsVO getPostNum(String PostNum){
        SqlSession ss = FactoryService.getFactory().openSession();
        BbsVO vo = ss.selectOne("Board.getBbs", PostNum);
        ss.close();
        return vo;
    }

    //수정
    public static int edit(String PostNum, String subject, String content, String FileName, String category){

        Map<String, String> map = new HashMap<>();
        map.put("PostNum", PostNum);
        map.put("subject", subject);
        map.put("content", content);
        map.put("category", category);

        if(FileName != null){
            map.put("FileName", FileName);
        }

        SqlSession ss = FactoryService.getFactory().openSession();
        int cnt = ss.update("Board.edit", map);
        if(cnt > 0)
            ss.commit();
        else
            ss.rollback();
        ss.close();

        return cnt;
    }

    //삭제
    public static int delBbs(String PostNum) {
        SqlSession ss = FactoryService.getFactory().openSession();
        int cnt = ss.update("Board.del", PostNum);
        if (cnt > 0) {
            ss.commit();
        } else {
            ss.rollback();
        }
        ss.close();
        return cnt;
    }

    // 좋아요
    public static int ThumbsUp(String PostNum) {
        SqlSession ss = FactoryService.getFactory().openSession();
        int cnt = ss.update("Board.Like", PostNum);
        if (cnt > 0) {
            ss.commit();
        } else {
            ss.rollback();
        }
        ss.close();
        return cnt;
    }

    // 싫어요
    public static int ThumbsDown(String PostNum) {
        SqlSession ss = FactoryService.getFactory().openSession();
        int cnt = ss.update("Board.Hate", PostNum);
        if (cnt > 0) {
            ss.commit();
        } else {
            ss.rollback();
        }
        ss.close();
        return cnt;
    }

}
