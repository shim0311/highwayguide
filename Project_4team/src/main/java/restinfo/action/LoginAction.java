package restinfo.action;

import mybatis.vo.UserVO;
import org.mindrot.jbcrypt.BCrypt;
import restinfo.dao.LoginDAO;
import restinfo.dao.BookmarkDAO;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.PrintWriter;

public class LoginAction implements Action {
	@Override
	public String execute(HttpServletRequest request, HttpServletResponse response) {
		// ID 추출
		String id = request.getParameter("username");
		String pwd = request.getParameter("password");

		// 아이디 입력 안됐거나 입력란이 비어있을경우
		if (id == null || id.trim().isEmpty()) {
			return "/login.jsp"; // 로그인창 이동 (자기 자신으로 포워딩 방지)
		}

		// ******** id 파라미터가 있으면, 비동기 로그인 수행 ********
		UserVO vo = LoginDAO.login(id); // DAO 호출

		boolean loginSuccess = false;
		String message = "";
		String redirectURL = ""; // 리다이렉트 URL 담을 변수

		// 로그인 처리
		if (vo != null && vo.getCancel().equals("1")) { // 탈퇴한 사용자일 경우
			loginSuccess = false;
			message = "이미 탈퇴한 사용자입니다.";
		} else if (vo != null && BCrypt.checkpw(pwd, vo.getPwd())) { // vo가 존재하고 비밀번호 일치하면 로그인 성공
			// 로그인 성공
			loginSuccess = true;
			HttpSession session = request.getSession();// 세션 생성
			session.setAttribute("loginUser", vo); // 세션에 vo객체 저장

			// 사용자의 북마크된 saKey 리스트를 세션에 저장
			try {
				String userIdx = String.valueOf(vo.getIdx());
				List<String> bookmarkedSaKeys = BookmarkDAO.getBookmarkedSaKeys(userIdx);
				session.setAttribute("bookmarkedSaKeys", bookmarkedSaKeys);
				System.out.println("북마크된 휴게소 개수: " + bookmarkedSaKeys.size());
			} catch (Exception e) {
				System.out.println("북마크 정보 조회 중 오류 발생: " + e.getMessage());
				e.printStackTrace();
			}

			// 세션에 저장된 사용자 정보 확인
			System.out.println("---------Session Check----------");
			UserVO sessionVO = (UserVO) session.getAttribute("loginUser");
			if (sessionVO != null) {
				System.out.println("세션에 저장된 객체: " + sessionVO.toString());
				System.out.println("회원번호(idx): " + sessionVO.getIdx());
				System.out.println("이름(name): " + sessionVO.getName());
			} else {
				System.out.println("오류: 세션에 객체가 저장되지 않았습니다.");
			}
			// if (vo.getAuthority() != null && Integer.valueOf(vo.getAuthority()) == 1)
			// redirectURL = "/WEB-INF/views/manage.jsp"; //관리자 페이지
			// else
			redirectURL = "index.jsp"; // 일반 사용자 페이지
		} else {
			// 로그인 실패
			loginSuccess = false;
			message = "아이디 또는 비밀번호가 일치하지 않습니다.";
		}

		// JSON 응답 생성
		try {
			// 여기서 응답을 JSON으로 설정
			response.setContentType("application/json");
			response.setCharacterEncoding("UTF-8");

			// 응답 데이터를 작성할 PrintWriter 얻기
			PrintWriter out = response.getWriter();

			// JSON 형식 문자열 생성
			String jsonResponse = String.format("{\"status\": \"%s\", \"message\": \"%s\", \"redirectURL\": \"%s\"}",
					loginSuccess ? "success" : "fail",
					message,
					redirectURL);

			// 응답한 JSON을 서버 콘솔에서 확인
			System.out.println("LoginAction 최종 응답 JSON: " + jsonResponse);
			// 클라이언트로 응답 전송
			out.print(jsonResponse);
			out.flush();
		} catch (Exception e) {
			e.printStackTrace();
		}

		// Controller한테 페이지 이동 안함
		return null; // 비동기 요청에 대한 응답(페이지 이동x)
	}

}
