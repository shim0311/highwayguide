package restinfo.action;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

/**
 * NAVER Cloud Platform Maps API의 Directions 5 API를 호출하는 서블릿
 * 
 * 주요 기능:
 * 1. 클라이언트로부터 출발지/목적지 좌표를 받음
 * 2. NAVER Cloud Platform의 Directions 5 API를 호출
 * 3. 경로 정보를 JSON 형태로 클라이언트에 반환
 * 
 * 동작 흐름:
 * POST 요청 → 좌표 파싱 → NAVER API 호출 → 응답 처리 → JSON 반환
 */
public class TestAction implements Action {

	/**
	 * 서블릿의 메인 실행 메서드
	 * 
	 * @param request  HTTP 요청 객체 (클라이언트로부터 받은 데이터)
	 * @param response HTTP 응답 객체 (클라이언트로 보낼 데이터)
	 * @return 다음에 실행할 JSP 페이지 경로 (null이면 더 이상 처리하지 않음)
	 */
	@Override
	public String execute(HttpServletRequest request, HttpServletResponse response) {

		System.out.println("=== TestAction 실행 ===");
		System.out.println("요청 메서드: " + request.getMethod());

		// POST 요청 처리 (Directions API)
		// GET 요청은 JSP 페이지를 반환하고, POST 요청은 API 호출을 처리
		if ("POST".equals(request.getMethod())) {
			String action = request.getParameter("action");
			System.out.println("Action 파라미터: " + action);

			// "directions" 액션인 경우 Directions 5 API 호출
			if ("directions".equals(action)) {
				System.out.println("Directions API 호출 시작");
				try {
					// 클라이언트로부터 전송된 좌표 데이터 파싱
					String startX = request.getParameter("startX"); // 출발지 경도
					String startY = request.getParameter("startY"); // 출발지 위도
					String endX = request.getParameter("endX"); // 목적지 경도
					String endY = request.getParameter("endY"); // 목적지 위도

					System.out.println("출발지 좌표: " + startX + ", " + startY);
					System.out.println("목적지 좌표: " + endX + ", " + endY);

					// NAVER Cloud Platform Directions 5 API URL 구성
					// API 엔드포인트: https://maps.apigw.ntruss.com/map-direction/v1/driving
					String directionsUrl = "https://maps.apigw.ntruss.com/map-direction/v1/driving";

					// 쿼리 파라미터 구성: start=경도,위도&goal=경도,위도&avoid=
					// start: 출발지 좌표, goal: 목적지 좌표, avoid: 회피할 경로 (현재는 빈 값)
					String queryParams = "start=" + startX + "," + startY + "&goal=" + endX + "," + endY + "&avoid=";
					String fullUrl = directionsUrl + "?" + queryParams;

					System.out.println("API 호출 URL: " + fullUrl);

					// HTTP 연결 객체 생성
					URL apiUrl = new URL(fullUrl);
					HttpURLConnection connection = (HttpURLConnection) apiUrl.openConnection();

					// HTTP 메서드를 GET으로 설정 (NAVER API는 GET 방식 사용)
					connection.setRequestMethod("GET");

					// NAVER Cloud Platform Maps API 인증 정보 설정
					// Maps API는 복잡한 서명 대신 단순한 API 키 인증 사용
					String accessKeyId = "a3kqiwwu0n"; // Client ID (API 키 ID)
					String accessKey = "Q4FikPxcG6mAoJmGC76bm8Oe6SXzYfYFlhvdrVNc"; // Client Secret (API 키)

					System.out.println("=== Maps API 인증 정보 ===");
					System.out.println("Access Key ID: " + accessKeyId);
					System.out.println("Access Key: " + accessKey);

					// HTTP 헤더 설정 - NAVER Maps API 인증 방식
					// x-ncp-apigw-api-key-id: Client ID
					// x-ncp-apigw-api-key: Client Secret
					// Content-Type: application/json (JSON 응답 요청)
					connection.setRequestProperty("x-ncp-apigw-api-key-id", accessKeyId);
					connection.setRequestProperty("x-ncp-apigw-api-key", accessKey);
					connection.setRequestProperty("Content-Type", "application/json");

					System.out.println("=== API 호출 헤더 ===");
					System.out.println("x-ncp-apigw-api-key-id: " + accessKeyId);
					System.out.println("x-ncp-apigw-api-key: " + accessKey);

					// NAVER API 서버에 HTTP 요청 전송하고 응답 코드 확인
					int responseCode = connection.getResponseCode();
					System.out.println("API 응답 코드: " + responseCode);

					// 응답 코드에 따라 적절한 스트림 선택
					// 200-299: 성공 응답 → InputStream 사용
					// 그 외: 오류 응답 → ErrorStream 사용
					InputStream inputStream = (responseCode >= 200 && responseCode < 300) ? connection.getInputStream()
							: connection.getErrorStream();

					// API 응답 데이터를 문자열로 읽기
					StringBuilder apiResponse = new StringBuilder();
					BufferedReader br = new BufferedReader(new InputStreamReader(inputStream, StandardCharsets.UTF_8));
					String line;
					while ((line = br.readLine()) != null) {
						apiResponse.append(line);
					}
					br.close();
					connection.disconnect(); // HTTP 연결 명시적 종료 (메모리 누수 방지)

					// 읽어온 응답 데이터를 문자열로 변환
					String responseText = apiResponse.toString();
					System.out.println(
							"API 응답 (처음 500자): " + responseText.substring(0, Math.min(500, responseText.length())));

					// 클라이언트에게 JSON 응답 전송
					// CORS 헤더 추가: 브라우저의 보안 정책으로 인한 차단 방지
					response.setContentType("application/json"); // JSON 형식임을 명시
					response.setCharacterEncoding("UTF-8"); // 한글 인코딩 설정
					response.setHeader("Access-Control-Allow-Origin", "*"); // 모든 도메인에서 접근 허용
					response.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS"); // 허용할 HTTP 메서드
					response.setHeader("Access-Control-Allow-Headers", "Content-Type"); // 허용할 헤더
					response.setHeader("Content-Length",
							String.valueOf(responseText.getBytes(StandardCharsets.UTF_8).length)); // 응답 크기 명시

					// 응답 데이터를 클라이언트로 전송
					response.getWriter().print(responseText);
					response.getWriter().flush(); // 버퍼 강제 플러시 (데이터 즉시 전송)
					response.getWriter().close(); // Writer 명시적 종료 (메모리 누수 방지)
					System.out.println("JSON 응답 전송 완료");
					return null; // 더 이상 JSP 처리하지 않음 (JSON 응답만 전송)

				} catch (Exception e) {
					// 예외 발생 시 오류 정보를 JSON 형태로 클라이언트에 전송
					System.out.println("Directions API 오류: " + e.getMessage());
					e.printStackTrace();
					response.setContentType("application/json");
					response.setCharacterEncoding("UTF-8");
					response.setHeader("Access-Control-Allow-Origin", "*");
					response.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
					response.setHeader("Access-Control-Allow-Headers", "Content-Type");
					return null; // 더 이상 처리하지 않음
				}
			} else {
				// 알 수 없는 action 파라미터인 경우
				System.out.println("알 수 없는 action: " + action);
			}
		} else {
			// GET 요청인 경우 JSP 페이지 반환
			System.out.println("GET 요청 - JSP 페이지 반환");
		}

		// POST 요청이 아니거나 directions 액션이 아닌 경우 test.jsp 페이지 반환
		return "test.jsp";
	}
}
