package restinfo.action;

import mybatis.vo.UserVO;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class MainpageAction implements Action {
	@Override
	public String execute(HttpServletRequest request, HttpServletResponse response) {
		String redirectUrl = null;

		redirectUrl = "index.jsp";

		return redirectUrl;
	}
}	
