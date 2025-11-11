package restinfo.dao;

import mybatis.service.FactoryService;
import mybatis.vo.MenuVO;
import org.apache.ibatis.session.ExecutorType;
import org.apache.ibatis.session.SqlSession;

import java.util.List;

public class MenuDAO {
    public static List<MenuVO> selectAllMenu() {
        try (SqlSession ss = FactoryService.getFactory().openSession()) { //DB 세션열기
            return ss.selectList("menu.selectAllMenu"); //모든 메뉴정보 불러오는 쿼리 실행
        }
    }

    // 테스트코드
    public static void batchInsert(List<MenuVO> insertList) {
        if (insertList == null || insertList.isEmpty()) return;

        System.out.println(">>> DAO: STARTING SINGLE INSERT TEST for " + insertList.size() + " records...");
        int successCount = 0;

        // Auto-commit을 true로 설정하여 한 줄씩 즉시 저장
        try (SqlSession ss = FactoryService.getFactory().openSession(true)) {
            for (MenuVO vo : insertList) {
                try {
                    ss.insert("menu.insertMenu", vo);
                    successCount++;
                } catch (Exception e) {
                    // ✨ 에러 발생 시, 문제가 된 데이터와 에러 내용을 상세히 출력
                    System.err.println("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
                    System.err.println(">>> BATCH INSERT FAILED AT RECORD: " + (successCount + 1));
                    System.err.println(">>> PROBLEMATIC DATA (VO): " + vo.getSAKey() + " - " + vo.getFoodName());
                    System.err.println(">>> ERROR MESSAGE:");
                    e.printStackTrace();
                    System.err.println("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

                    // 에러가 발생하면 테스트 중단
                    return;
                }
            }
        }
        System.out.println(">>> DAO: SINGLE INSERT TEST FINISHED. Success Count: " + successCount);
    }

    // List에 담긴 여러 메뉴들을 한번에 INSERT (Batch작업)
    /*public static void batchInsert(List<MenuVO> insertList) {
        if (insertList == null || insertList.isEmpty()) return;
        // Auto-commit false로 하나의 트랜잭션으로 관리
        try (SqlSession ss = FactoryService.getFactory().openSession(ExecutorType.BATCH, false)) {
            try {
                for (MenuVO vo : insertList) {
                    ss.insert("menu.insertMenu", vo);
                }
                ss.flushStatements();
                ss.commit();
                System.out.println(">>> DAO: Processed " + insertList.size() + " records for INSERT.");
            } catch (Exception e) {
                e.printStackTrace();
                ss.rollback();
            }
        }
    }*/

    // List에 담긴 여러 메뉴들을 한번에 UPDATE (Batch작업)
    public static void batchUpdate(List<MenuVO> updateList) {
        if (updateList == null || updateList.isEmpty()) return;
        try (SqlSession ss = FactoryService.getFactory().openSession(ExecutorType.BATCH, false)) {
            try {
                for (MenuVO vo : updateList) {
                    ss.update("menu.updateMenu", vo);
                }
                ss.flushStatements();
                ss.commit();
                System.out.println(">>> DAO: Processed " + updateList.size() + " records for UPDATE.");
            } catch (Exception e) {
                e.printStackTrace();
                ss.rollback();
            }
        }
    }
}