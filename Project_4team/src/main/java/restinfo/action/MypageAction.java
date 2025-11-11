package restinfo.action;

import mybatis.vo.ServiceAreaVO;
import mybatis.vo.UserVO;
import mybatis.vo.GasVO;
import restinfo.dao.ServiceAreaDAO;
import restinfo.dao.GasDAO;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

public class MypageAction implements Action {
    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) throws IOException {

        HttpSession session = request.getSession();
        UserVO vo = (UserVO) session.getAttribute("loginUser");
        String idx= String.valueOf(vo.getIdx());

        // 1. 가장 먼저 로그인 유무를 확인해서 NullPointerException을 방지합니다.
        if (vo == null) {
            response.sendRedirect("Controller?type=login");
            return null;
        }


        List<ServiceAreaVO> list = ServiceAreaDAO.bookmarkedArea(idx);
       

        request.setAttribute("bookmarkedServiceAreas", list);

        

        return "mypage.jsp";
    }
}