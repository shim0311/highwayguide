package restinfo.action;


import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
import java.util.*;

import jakarta.mail.Session;
import mybatis.vo.UserVO;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import restinfo.dao.SignUpDAO;
import restinfo.util.ConfigLoader;

import static java.lang.System.out;

public class NaverCallbackAction implements Action {

    private static final Logger log = LoggerFactory.getLogger(NaverCallbackAction.class);

    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) throws UnsupportedEncodingException {

        log.info("네이버 로그인 완료: {}", response.toString());

        // 네이버가 보내주는 state
        String returnedState = request.getParameter("state");

        //내가 만들어서 보낸 state
        String storedState = (String) request.getSession().getAttribute("mystate");

//        if (storedState == null || !storedState.equals(returnedState)) {
//            System.out.println("state 값이 일치하지 않습니다.");
//            return "index.jsp"; // 혹은 다른 에러 처리 페이지
//        }


        String clientId = ConfigLoader.getProperty("NAVER_CLIENT_ID");
        String clientSecret = ConfigLoader.getProperty("NAVER_CLIENT_SECRET");;//애플리케이션 클라이언트 시크릿값";
        String code = request.getParameter("code");


        log.info("Code: {}, State: {}", code, returnedState);
        // Redirect URI를 환경변수에서 로드 (로컬/운영 환경 분리)
        String redirectBase = ConfigLoader.getProperty("oauth.redirect.base");
        String redirectURI = URLEncoder.encode(redirectBase + "/Controller?type=naverCallback", StandardCharsets.UTF_8);
        String apiURL;
        apiURL = "https://nid.naver.com/oauth2.0/token?grant_type=authorization_code&";
        apiURL += "client_id=" + clientId;
        apiURL += "&client_secret=" + clientSecret;
        apiURL += "&redirect_uri=" + redirectURI;
        apiURL += "&code=" + code;
        apiURL += "&state=" + returnedState;
        String access_token = "";
        String refresh_token = "";
        out.println("apiURL="+apiURL);
        try {
            URL url = new URL(apiURL);
            HttpURLConnection con = (HttpURLConnection)url.openConnection();
            con.setRequestMethod("GET");
            int responseCode = con.getResponseCode();
            BufferedReader br;
            out.print("responseCode="+responseCode);
            if(responseCode==200) { // 정상 호출
                br = new BufferedReader(new InputStreamReader(con.getInputStream()));
            } else {  // 에러 발생
                br = new BufferedReader(new InputStreamReader(con.getErrorStream()));
            }
            String inputLine;
            StringBuffer res = new StringBuffer();
            while ((inputLine = br.readLine()) != null) {
                res.append(inputLine);
            }
            br.close();
            if(responseCode == 200) {
                out.println(res);

                // 1. JSON 파서 객체 생성
                JSONParser parser = new JSONParser();
                // 2. 응답 문자열(res)을 JSON 객체로 변환
                JSONObject jsonObj = (JSONObject) parser.parse(res.toString());

                access_token = (String) jsonObj.get("access_token");
                refresh_token = (String) jsonObj.get("refresh_token");
                log.info("Access Token: {}", access_token);
                log.info("Refresh Token: {}", refresh_token);

                String header = "Bearer " + access_token; // Bearer 다음에 공백 추가

                String profileApiURL = "https://openapi.naver.com/v1/nid/me";

                Map<String, String> requestHeaders = new HashMap<>();
                requestHeaders.put("Authorization", header);

                String responseBody = get(profileApiURL, requestHeaders);

                jsonObj = (JSONObject) parser.parse(responseBody);

                // 2. "response" 키를 이용해 중첩된 JSONObject를 가져옵니다.
                JSONObject profileResponse = (JSONObject) jsonObj.get("response");

                // 3. 중첩된 JSONObject에서 최종 데이터를 꺼냅니다.
                String userIdentifier = (String) profileResponse.get("id");
                String email = (String) profileResponse.get("email");
                String name = (String) profileResponse.get("name");

                log.info("사용자 식별값: {}, 이메일: {}, 이름: {}", userIdentifier, email, name);

                // 세션 저장
                UserVO CheckVO = SignUpDAO.check(email,"NAVER");
                if(CheckVO==null) {
                    UserVO vo = new UserVO();

                    // 닉네임 만들기
                    makeNickName(vo);

                    vo.setID(email);
                    vo.setName(name);
                    request.getSession().setAttribute("loginUser", vo);
                    request.getSession().setAttribute("login_provider", "naver");
                    request.getSession().setAttribute("access_token", access_token);
                    SignUpDAO.add(email, vo.getNickName(), userIdentifier, name, "NAVER");
                }else{
                    request.getSession().setAttribute("loginUser",CheckVO);
                    request.getSession().setAttribute("login_provider", "naver");
                    request.getSession().setAttribute("access_token", access_token);


                }
            }
        } catch (Exception e) {
            out.println(e);
        }

        return "index.jsp";
    }


    private static String get(String apiUrl, Map<String, String> requestHeaders){
        HttpURLConnection con = connect(apiUrl);
        try {
            con.setRequestMethod("GET");
            for(Map.Entry<String, String> header : requestHeaders.entrySet()) {
                con.setRequestProperty(header.getKey(), header.getValue());
            }

            int responseCode = con.getResponseCode(); // statusCode
            if (responseCode == HttpURLConnection.HTTP_OK) { // 정상 호출
                return readBody(con.getInputStream());
            } else { // 에러 발생
                return readBody(con.getErrorStream());
            }
        } catch (IOException e) {
            throw new RuntimeException("API 요청과 응답 실패", e);
        } finally {
            con.disconnect();
        }
    }


    private static HttpURLConnection connect(String apiUrl){
        try {
            URL url = new URL(apiUrl);
            return (HttpURLConnection)url.openConnection();
        } catch (MalformedURLException e) {
            throw new RuntimeException("API URL이 잘못되었습니다. : " + apiUrl, e);
        } catch (IOException e) {
            throw new RuntimeException("연결이 실패했습니다. : " + apiUrl, e);
        }
    }


    private static String readBody(InputStream body){
        InputStreamReader streamReader = new InputStreamReader(body);


        try (BufferedReader lineReader = new BufferedReader(streamReader)) {
            StringBuilder responseBody = new StringBuilder();


            String line;
            while ((line = lineReader.readLine()) != null) {
                responseBody.append(line);
            }


            return responseBody.toString();
        } catch (IOException e) {
            throw new RuntimeException("API 응답을 읽는데 실패했습니다.", e);
        }
    }

    private void makeNickName(UserVO vo) {

        // 닉네임을 비교하기 위해 기존의 DB에서 닉네임값들 불러오기
        List<String> nickNames = SignUpDAO.check("Naver");
        Set<Integer> set = new HashSet<>();

        // 각각 닉네임에서 뒤의 숫자만 얻어내기
        for (int i = 0; i < nickNames.size(); i++) {
            set.add(Integer.parseInt(nickNames.get(i).substring(5)));
        }

        int newNumber;

        do { // set구조에 값이 들어갈 때까지(중복되지 않는 수가 들어갈 때까지) 반복
            newNumber = (int)(Math.random() * 90000) + 10000;  // 10000 ~ 99999
        } while (set.contains(newNumber));

        vo.setNickName("Naver" + newNumber);
    }
}
