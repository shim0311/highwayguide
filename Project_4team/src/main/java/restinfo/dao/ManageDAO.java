package restinfo.dao;

import mybatis.service.FactoryService;
import mybatis.vo.ServiceAreaVO;
import mybatis.vo.ShopVO;
import mybatis.vo.UserVO;
import org.apache.ibatis.session.SqlSession;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ManageDAO {

    public static int[] getPlatformCount(){
        // 가입플랫폼별 회원수 가져오는 메서드
        SqlSession ss = null;

        int[] counts = new int[3];

        try {

            ss = FactoryService.getFactory().openSession();

            counts[0] = ss.selectOne("User.getPlatformCount", "KAKAO");
            counts[1] = ss.selectOne("User.getPlatformCount", "NAVER");
            counts[2] = ss.selectOne("User.getPlatformCount", "ORIGIN");
        } catch (Exception e) {
            e.printStackTrace();
        }  finally {
            ss.close();
        }
        return counts;
    }

    public static List<Map<String, Object>> getSARank(){
        // 휴게소 순위 가져오는 메서드
        SqlSession ss = FactoryService.getFactory().openSession();
        List<Map<String, Object>> list = new ArrayList<>();
        try {
            list = ss.selectList("SA.getRanking");
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            ss.close();
        }
        return  list;
    }

    public static void initSA(List<ServiceAreaVO> list) {
        // 휴게소 업데이트하는 메서드
        int cnt = 0;
        SqlSession ss = null;
        try {
            ss = FactoryService.getFactory().openSession();

            for (ServiceAreaVO svo : list) {
                ServiceAreaVO vo = ss.selectOne("SA.search", svo);
                if (vo != null) {
                    ss.update("SA.update", svo);
                    svo.setIdx(vo.getIdx());
                } else
                    ss.insert("SA.insert", svo);
                ss.commit();
            }
        }  finally {
            if (ss != null)
                ss.close();
        }
        for(ServiceAreaVO svo : list) {
            System.out.println(svo.getIdx()+":::::::::::::::::;");
        }
        initShop(list);
    }

    public static void initShop(List<ServiceAreaVO> list) {
        // 입점업체 업데이트하는 메서드
        int cnt = 0;
        SqlSession ss = null;
        try {
            ss = FactoryService.getFactory().openSession();
            ss.delete("Shop.delete");
            ss.commit();
            for (ServiceAreaVO svo : list) {
                List<ShopVO> shops = svo.getShoplist();
                for (ShopVO shop : shops){
                    shop.setSAKey(svo.getIdx());
                    System.out.println(shop.getSAKey()+"\\\\\\\\\\\\\\");
                    System.out.println(shop.getShopName());
                }
                if (!shops.isEmpty())
                    ss.insert("Shop.insert", shops);
            }
                ss.commit();
        }  finally {
            if (ss != null)
                ss.close();
        }
    }

    public static List<UserVO> getAll() {
        // 모든회원 가져오는 메서드
        SqlSession ss = FactoryService.getFactory().openSession();
        List<UserVO> list = null;
        try {
            list = ss.selectList("User.getAllUsers");
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            ss.close();
        }
        return  list;
    }

    public static int deactivateAccount(String NickName) {
        SqlSession ss = FactoryService.getFactory().openSession();
        int cnt = 0;
        try {
            cnt = ss.update("User.deactivateAccountByNickName", NickName);
            if (cnt > 0)
                ss.commit();
            else
                ss.rollback();
        } catch (Exception e) {
            e.printStackTrace();
        }  finally {
            ss.close();
        }
        return cnt;
    }

}
