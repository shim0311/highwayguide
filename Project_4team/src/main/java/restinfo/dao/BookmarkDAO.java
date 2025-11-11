package restinfo.dao;

import mybatis.service.FactoryService;
import org.apache.ibatis.session.SqlSession;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class BookmarkDAO {
    public static boolean isBookmarked(String userKey, String saKey) {
        SqlSession ss = FactoryService.getFactory().openSession();
        Map<String, String> m = new HashMap<>();
        m.put("userKey", userKey);
        m.put("saKey", saKey);

        Integer count = ss.selectOne("bookmark.isBookmarked", m);
        ss.close();
        return count != null && count > 0;
    }

    // 2. 즐겨찾기 추가 메서드
    public static int addBookmark(String userKey, String saKey) {
        SqlSession ss = FactoryService.getFactory().openSession();
        Map<String, String> m = new HashMap<>();
        m.put("userKey", userKey);
        m.put("saKey", saKey);

        int result = ss.insert("bookmark.add", m);
        if (result > 0) {
            ss.commit();
        } else {
            ss.rollback();
        }
        ss.close();
        return result;
    }

    // 3. 즐겨찾기 삭제 메서드
    public static int deleteBookmark(String userKey, String saKey) {
        SqlSession ss = FactoryService.getFactory().openSession();
        Map<String, String> m = new HashMap<>();
        m.put("userKey", userKey);
        m.put("saKey", saKey);

        int result = ss.delete("bookmark.delete", m);
        if (result > 0) {
            ss.commit();
        } else {
            ss.rollback();
        }
        ss.close();
        return result;
    }

    // 4. 사용자의 모든 북마크된 saKey 리스트 조회 메서드
    public static List<String> getBookmarkedSaKeys(String userKey) {
        SqlSession ss = FactoryService.getFactory().openSession();
        List<String> saKeyList = ss.selectList("bookmark.getBookmarkedSaKeys", userKey);
        ss.close();
        return saKeyList;
    }
}
