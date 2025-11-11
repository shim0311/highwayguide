package restinfo.action;

import com.google.gson.Gson;
import mybatis.vo.ShopVO;
import restinfo.dao.ShopDAO;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

public class getStoresAction implements Action{
    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String idx = request.getParameter("saKey");
        String text = request.getParameter("searchText");

        // 오직 매장 목록만 조회합니다.
        List<ShopVO> shopList = ShopDAO.getShop(idx, text);

        // List를 바로 JSON 배열로 변환합니다.
        Gson gson = new Gson();
        String jsonString = gson.toJson(shopList);

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(jsonString);

        return null;
    }
}