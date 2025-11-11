package restinfo.dao;

import mybatis.service.FactoryService;
import mybatis.vo.UserVO;
import org.apache.ibatis.session.SqlSession;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SignUpDAO {
    public static int add(String id,String NickName, String Hpwd, String name, String platform) {
        Map<String, String> m = new HashMap<>();
        m.put("ID", id);
        m.put("NickName", NickName);
        m.put("Pwd", Hpwd);
        m.put("Name", name);
        m.put("platform",platform);



        SqlSession ss = FactoryService.getFactory().openSession();
        int cnt = ss.insert("restinfo.signUp", m);

        if (cnt > 0)
            ss.commit();
        else
            ss.rollback();
        ss.close();

        return cnt;

    }
    public static UserVO check(String email,String platform){
        SqlSession ss =FactoryService.getFactory().openSession();
        Map<String,String>m= new HashMap<>();
        m.put("email",email);
        m.put("platform",platform);
        UserVO vo=ss.selectOne("restinfo.selectID",m);
        ss.close();
        return vo;
    }

    public static List<String> check(String nickname){
        SqlSession ss = FactoryService.getFactory().openSession();
        List<String>res = ss.selectList("restinfo.searchNickName",nickname);
        ss.close();
        return res;
    }
}
