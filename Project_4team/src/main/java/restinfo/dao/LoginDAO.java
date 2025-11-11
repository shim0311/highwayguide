package restinfo.dao;

import mybatis.service.FactoryService;
import mybatis.vo.UserVO;
import org.apache.ibatis.session.SqlSession;

public class LoginDAO {
    public static UserVO login(String ID){
        SqlSession ss = FactoryService.getFactory().openSession();
        UserVO lvo = ss.selectOne("restinfo.login", ID);
        ss.close();
        return lvo;
    }
}
