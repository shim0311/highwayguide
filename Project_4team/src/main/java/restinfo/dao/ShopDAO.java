package restinfo.dao;

import mybatis.service.FactoryService;
import mybatis.vo.ShopVO;
import org.apache.ibatis.session.SqlSession;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ShopDAO {
    public static List<ShopVO> getShop(String idx, String text){

        SqlSession ss = FactoryService.getFactory().openSession();
        Map<String,String> m = new HashMap<>();
        m.put("idx",idx);
        m.put("text",text);

        List<ShopVO> list = ss.selectList("Shop.getShop",m);
        ss.close();

        return list;
    }

}
