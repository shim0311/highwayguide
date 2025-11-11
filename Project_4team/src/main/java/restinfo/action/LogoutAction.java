package restinfo.action;

import restinfo.util.ConfigLoader;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.net.HttpURLConnection;
import java.net.URL;

public class LogoutAction implements Action {
	@Override
	public String execute(HttpServletRequest request, HttpServletResponse response) {
		// 현재 사용중인 세션을 얻기
		HttpSession session = request.getSession(false); //세션이 있을경우 세션을 새로 생성하지 않는다.
		
		// 세션이 존재할 경우 삭제
		if (session != null) {
			String provider = (String) session.getAttribute("login_provider");
			String accessToken = (String) session.getAttribute("access_token");
			if (provider != null && accessToken != null) {
				if ("kakao".equals(provider)) {
					unlinkKakao(accessToken);
				} else if ("naver".equals(provider)) {
					unlinkNaver(accessToken);
				}
			}
			session.invalidate(); //세션안에 있는 데이터 삭제후 세션 무효화
		}
		
		try {
			response.sendRedirect("Controller");
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		//Controller 한테 view 처리를 맡기지 않음
		return null;
	}
	
	// 카카오 연동해제
	private void unlinkKakao(String accessToken) {
		String reqURL = "https://kapi.kakao.com/v1/user/unlink";
		try {
			URL url = new URL(reqURL);
			HttpURLConnection conn = (HttpURLConnection) url.openConnection();
			conn.setRequestMethod("POST");
			conn.setRequestProperty("Authorization", "Bearer " + accessToken);
			
			int responseCode = conn.getResponseCode();
			System.out.println("KAKAO disconnect Code: " + responseCode);
			// 응답 내용 로깅 등 추가 가능
			
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	// 네이버 연동해제 (토큰 삭제)
	private void unlinkNaver(String accessToken) {
		String clientId = ConfigLoader.getProperty("NAVER_CLIENT_ID");
		String clientSecret = ConfigLoader.getProperty("NAVER_CLIENT_SECRET");
		String reqURL = "https://nid.naver.com/oauth2.0/token?grant_type=delete&client_id="
				+ clientId + "&client_secret=" + clientSecret + "&access_token=" + accessToken + "&service_provider=NAVER";
		try {
			URL url = new URL(reqURL);
			HttpURLConnection conn = (HttpURLConnection) url.openConnection();
			conn.setRequestMethod("GET");
			
			int responseCode = conn.getResponseCode();
			System.out.println("Naver disconnect Code: " + responseCode);
			// 응답 내용 로깅 등 추가 가능
			
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}