package restinfo.action;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class RegAction implements Action {
	@Override
	public String execute(HttpServletRequest request, HttpServletResponse response) {
		String viewPath = "signupOptions.jsp";

		return viewPath;
	}
}
