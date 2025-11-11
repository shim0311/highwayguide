package restinfo.dao;

import mybatis.service.FactoryService;
import mybatis.vo.GasVO;
import org.apache.ibatis.session.SqlSession;

import java.util.List;

public class GasDAO {
    public static GasVO getgas(String idx) {
        SqlSession ss = FactoryService.getFactory().openSession();
        GasVO vo = ss.selectOne("gas.getGas", idx);
        ss.close();

        return vo;

    }

    //신규유가 정보들을 INSERT
    public static void insertGasPrices(SqlSession session, List<GasVO> gasList) {
        for (GasVO gvo : gasList) {
            session.insert("gas.insertGasPrices", gvo);
        }
    }

    //기존유가 정보들을 UPDATE
    public static void updateGasPrices(SqlSession session, List<GasVO> gasList) {
        for (GasVO gvo : gasList) {
            session.update("gas.updateGasPrices", gvo);
        }

    }
}