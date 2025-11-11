package bbs.dao;

import mybatis.service.FactoryService;
import org.apache.ibatis.session.SqlSession;

import java.util.HashMap;
import java.util.Map;

public class LikeHateDAO {
    //사용자가 특정 게시물에 반응했는지 확인
    public static boolean checkReaction(String postNum, int userKey) {
        SqlSession ss = FactoryService.getFactory().openSession();
        Map<String, Object> map = new HashMap<>();
        map.put("postNum", postNum);
        map.put("userKey", userKey);

        int count = 0;
        try {
            // 반응 기록이 있으면 1 이상, 없으면 0을 반환
            count = ss.selectOne("LikeHate.checkReaction", map);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (ss != null) {
                ss.close();
            }
        }
        return count > 0;
    }

    //사용자의 반응을 DB에 저장
    public static boolean addReaction(String postNum, int userKey, String reactionType) {
        SqlSession ss = FactoryService.getFactory().openSession(); //세션 오픈
        Map<String, Object> map = new HashMap<>();
        map.put("postNum", Integer.parseInt(postNum));
        map.put("userKey", userKey);

        // 현재 테이블 구조에 맞게 ThumbsUp 또는 ThumbsDown에 1을 저장
        if(reactionType.equals("like")) {
            map.put("thumbsUp", 1); //좋아요 눌렀을때 thumbsUp + 1
            map.put("thumbsDown", 0);
        } else {
            map.put("thumbsUp", 0);
            map.put("thumbsDown", 1); //싫어요 눌렀을때 thumbsDown + 1
        }

        int cnt = 0;
        try {
            cnt = ss.insert("LikeHate.addReaction", map);
            if (cnt > 0) {
                ss.commit();
            } else {
                ss.rollback();
            }
        } catch (Exception e) {
            e.printStackTrace();
            ss.rollback();
        } finally {
            if(ss != null) {
                ss.close();
            }
        }
        return cnt > 0;
    }

    // 특정 게시물의 총 좋아요 수 반환
    public static int getLikeCount(String postNum) {
        SqlSession ss = FactoryService.getFactory().openSession();
        int count = 0;
        try {
            count = ss.selectOne("LikeHate.getLikeCount", postNum);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if(ss != null) {
                ss.close();
            }
        }
        return count;
    }

    // 특정 게시물의 총 싫어요 수를 반환
    public static int getHateCount(String postNum) {
        SqlSession ss = FactoryService.getFactory().openSession();
        int count = 0;
        try {
            count = ss.selectOne("LikeHate.getHateCount", postNum);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if(ss != null) {
                ss.close();
            }
        }
        return count;
    }
}
