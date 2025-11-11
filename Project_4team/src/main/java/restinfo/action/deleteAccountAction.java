package restinfo.action;

import mybatis.vo.UserVO;
import restinfo.dao.updateUserDAO;
import restinfo.util.ConfigLoader; // ConfigLoader import 추가

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.HttpURLConnection; // HttpURLConnection import 추가
import java.net.URL; // URL import 추가

public class deleteAccountAction implements Action {
    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) throws IOException {

        HttpSession session = request.getSession();
        UserVO vo = (UserVO) session.getAttribute("loginUser");

        if (vo == null) {
            response.sendRedirect("index.jsp");
            return null;
        }

        // 소셜 연동 해제 로직 ---
        String provider = vo.getPlatform(); // UserVO에 플랫폼 정보가 있다고 가정
        String accessToken = (String) session.getAttribute("access_token");

        if (provider != null && accessToken != null) {
            if ("kakao".equalsIgnoreCase(provider)) { // 대소문자 구분 없이 비교
                unlinkKakao(accessToken);
            } else if ("naver".equalsIgnoreCase(provider)) {
                unlinkNaver(accessToken);
            }
        }
        // -----------------------------------------

        String id = vo.getID();

        int cnt = updateUserDAO.deactivateAccount(id, provider);

        if (cnt > 0) {
            System.out.println(id + " 계정 비활성화 및 연동 해제 성공");
        } else {
            System.out.println(id + " 계정 비활성화 실패");
        }

        session.invalidate();

        response.sendRedirect("index.jsp");
        return null;
    }

    // LogoutAction에 있던 메서드를 그대로 가져옵니다.
    // 카카오 연동해제
    private void unlinkKakao(String accessToken) {
        String reqURL = "https://kapi.kakao.com/v1/user/unlink";
        try {
            URL url = new URL(reqURL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Authorization", "Bearer " + accessToken);

            int responseCode = conn.getResponseCode();
            System.out.println("KAKAO disconnect Code on withdrawal: " + responseCode);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 네이버 연동해제 (토큰 삭제)
    private void unlinkNaver(String accessToken) {
        // 네이버 API 키는 외부에 노출되면 안되므로 ConfigLoader 등을 통해 안전하게 관리해야 합니다.
        String clientId = ConfigLoader.getProperty("NAVER_CLIENT_ID");
        String clientSecret = ConfigLoader.getProperty("NAVER_CLIENT_SECRET");
        String reqURL = "https://nid.naver.com/oauth2.0/token?grant_type=delete&client_id="
                + clientId + "&client_secret=" + clientSecret + "&access_token=" + accessToken + "&service_provider=NAVER";
        try {
            URL url = new URL(reqURL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");

            int responseCode = conn.getResponseCode();
            System.out.println("Naver disconnect Code on withdrawal: " + responseCode);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}