package restinfo.action;

import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class KakaoMapAction implements Action {
	
	@Override
	public String execute(HttpServletRequest request, HttpServletResponse response)
			throws UnsupportedEncodingException {
		String origin = request.getParameter("origin");
		String destination = request.getParameter("destination");
		String priority = request.getParameter("priority");
		// 요청 후 어떤 Action으로 포워딩할지 결정하는 파라미터
		// "restArea"인 경우 RestAreaAction으로 자동 포워딩됨
		String forwardTo = request.getParameter("forwardTo");
		
		try {
			// 카카오 API 키 설정
			String apiKey = "2bb9195b03b5b17418309109544a85c4";
			
			// 주소를 좌표로 변환
			String originCoords = getCoordinates(origin.trim(), apiKey);
			String destinationCoords = getCoordinates(destination.trim(), apiKey);
			
			if (originCoords == null || destinationCoords == null) {
				// 에러 정보를 request에 저장
				request.setAttribute("error", "주소 변환 실패");
				request.setAttribute("errorMessage", "입력한 주소를 좌표로 변환할 수 없습니다. 정확한 주소를 입력해주세요.");
				request.setAttribute("origin", origin);
				request.setAttribute("destination", destination);
				// forwardTo와 관계없이 index.jsp로 돌아가기
				return "Controller";
			}
			// 카카오 모빌리티 API 호출
			JSONObject routeData = callKakaoMobilityAPI(originCoords, destinationCoords, priority,
					apiKey);
			// 경로 데이터 처리 및 저장
			processRouteData(request, routeData, origin, destination);
			
			// forwardTo가 "restArea"이면 RestAreaAction으로 포워딩
			if ("restArea".equalsIgnoreCase(forwardTo)) {
				// 특별한 문자열을 반환하여 Controller가 RestAreaAction을 실행하도록 함
				// Controller에서 이 문자열을 받으면 RestAreaAction을 실행
				// 데이터는 이미 processRouteData에서 request에 저장됨
				return "FORWARD_TO_RESTAREA";
			}
			
			// 일반적인 경우 (forwardTo가 없거나 다른 값)에는 Controller로 이동
			return "Controller";
			
		} catch (Exception e) {
			if ("restArea".equalsIgnoreCase(forwardTo)) {
				sendJsonError(response, 500, "서버 오류", "요청 처리 중 오류가 발생했습니다.");
				return null;
			}
			request.setAttribute("error", "서버 오류");
			request.setAttribute("errorMessage", e.getMessage());
			// "Controller"를 반환하면 컨트롤러가 해당 문자열을 JSP 파일명으로 인식하여 Controller.jsp를 찾게 됩니다.
			// 만약 Controller.java 액션을 실행하려면 별도의 포워딩 로직이나 다른 방식이 필요합니다.
			return "Controller";
		}
	}


//    -------------- 함수 --------------
	
	// JSON 에러 응답 전송
	private void sendJsonError(HttpServletResponse response, int status, String error, String message) {
		response.setStatus(status);
		response.setContentType("application/json; charset=UTF-8");
		try {
			JSONObject errorJson = new JSONObject();
			errorJson.put("error", error);
			errorJson.put("message", message);
			response.getWriter().write(errorJson.toString());
			response.getWriter().flush();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	// 카카오 모빌리티 API 호출
	private JSONObject callKakaoMobilityAPI(String originCoords, String destinationCoords,
	                                        String priority, String apiKey) {
		try {
			StringBuilder urlBuilder = new StringBuilder();
			urlBuilder.append("https://apis-navi.kakaomobility.com/v1/directions");
			urlBuilder.append("?origin=").append(URLEncoder.encode(originCoords, StandardCharsets.UTF_8));
			urlBuilder.append("&destination=").append(URLEncoder.encode(destinationCoords, StandardCharsets.UTF_8));
			
			if (priority != null && !priority.trim().isEmpty()) {
				urlBuilder.append("&priority=").append(priority);
			}
			
			urlBuilder
					.append("&summary=false&car_fuel=GASOLINE&car_hipass=false&alternatives=false&road_details=false");
			
			URL url = new URL(urlBuilder.toString());
			HttpURLConnection conn = (HttpURLConnection) url.openConnection();
			conn.setRequestMethod("GET");
			conn.setRequestProperty("Authorization", "KakaoAK " + apiKey);
			conn.setRequestProperty("Content-Type", "application/json");
			
			int responseCode = conn.getResponseCode();
			BufferedReader in;
			
			if (responseCode >= 200 && responseCode < 300) {
				in = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
			} else {
				in = new BufferedReader(new InputStreamReader(conn.getErrorStream(), StandardCharsets.UTF_8));
			}
			
			StringBuilder response = new StringBuilder();
			String inputLine;
			while ((inputLine = in.readLine()) != null) {
				response.append(inputLine);
			}
			in.close();
			conn.disconnect();
			
			if (responseCode >= 200 && responseCode < 300) {
				return new JSONObject(response.toString());
			} else {
				return null;
			}
			
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
	
	// 경로 데이터 처리
	private void processRouteData(HttpServletRequest request, JSONObject routeData,
	                              String origin, String destination) {
		try {
			if (routeData.has("routes") && routeData.getJSONArray("routes").length() > 0) {
				JSONObject route = routeData.getJSONArray("routes").getJSONObject(0);
				JSONArray sections = route.getJSONArray("sections");
				
				// 휴게소 정보 추출
				List<String> allRestAreas = new ArrayList<>();
				List<String> restAreas = new ArrayList<>();
				List<String> restStops = new ArrayList<>();
				
				extractRestAreas(sections, allRestAreas, restAreas, restStops);
				
				// 소요시간 계산
				List<Integer> allRestAreaDurations = calculateDurationsToRestAreas(sections, allRestAreas);
				List<Integer> restAreaDurations = calculateDurationsToRestAreas(sections, restAreas);
				List<Integer> restStopDurations = calculateDurationsToRestAreas(sections, restStops);
				
				// request에 데이터 저장
				saveRouteDataToRequest(request, route, sections, allRestAreas, restAreas, restStops,
						allRestAreaDurations, restAreaDurations, restStopDurations,
						origin, destination, routeData);
				
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	// 휴게소 정보 추출
	private void extractRestAreas(JSONArray sections, List<String> allRestAreas,
	                              List<String> restAreas, List<String> restStops) {
		for (int i = 0; i < sections.length(); i++) {
			JSONObject section = sections.getJSONObject(i);
			if (section.has("guides")) {
				JSONArray guides = section.getJSONArray("guides");
				for (int j = 0; j < guides.length(); j++) {
					JSONObject guide = guides.getJSONObject(j);
					if (guide.has("name") && !guide.getString("name").isEmpty()) {
						String guideName = guide.getString("name");
						
						if (guideName.contains("휴게소") || guideName.contains("서비스") ||
								guideName.contains("REST") || guideName.contains("SERVICE")) {
							restAreas.add(guideName);
							allRestAreas.add(guideName);
						} else if (guideName.contains("졸음쉼터")) {
							restStops.add(guideName);
							allRestAreas.add(guideName);
						}
					}
				}
			}
		}
	}
	
	// request에 경로 데이터 저장
	private void saveRouteDataToRequest(HttpServletRequest request, JSONObject route, JSONArray sections,
	                                    List<String> allRestAreas, List<String> restAreas, List<String> restStops,
	                                    List<Integer> allRestAreaDurations, List<Integer> restAreaDurations,
	                                    List<Integer> restStopDurations, String origin, String destination,
	                                    JSONObject routeData) {
		
		// 기본 정보
		request.setAttribute("origin", origin);
		request.setAttribute("destination", destination);
		
		// 휴게소 정보
		request.setAttribute("allRestAreas", allRestAreas);
		request.setAttribute("restAreas", restAreas);
		request.setAttribute("restStops", restStops);
		// 소요시간 정보
		request.setAttribute("allRestAreaDurations", allRestAreaDurations);
		request.setAttribute("restAreaDurations", restAreaDurations);
		request.setAttribute("restStopDurations", restStopDurations);
		
		// 요약 정보
		if (route.has("summary")) {
			JSONObject summary = route.getJSONObject("summary");
			request.setAttribute("summary", summary);
			request.setAttribute("distance", summary.optInt("distance", 0));
			request.setAttribute("duration", summary.optInt("duration", 0));
			
			if (summary.has("fare")) {
				JSONObject fare = summary.getJSONObject("fare");
				request.setAttribute("taxiFare", fare.optInt("taxi", 0));
				request.setAttribute("tollFare", fare.optInt("toll", 0));
			}
		}
		
		// 전체 JSON 응답 (디버깅용)
		System.out.println(routeData.toString());
		request.setAttribute("jsonResponse", routeData);
	}
	
	/**
	 * 주소를 좌표로 변환하는 메서드
	 *
	 * @param address 변환할 주소 (한글)
	 * @param apiKey  카카오 API 키
	 * @return "경도,위도" 형태의 좌표 문자열, 실패시 null
	 */
	private String getCoordinates(String address, String apiKey) {
		try {
			String encodedAddress = URLEncoder.encode(address, StandardCharsets.UTF_8);
			String geocodingUrl = "https://dapi.kakao.com/v2/local/search/address.json?query=" + encodedAddress;
			
			URL url = new URL(geocodingUrl);
			HttpURLConnection conn = (HttpURLConnection) url.openConnection();
			conn.setRequestMethod("GET");
			conn.setRequestProperty("Authorization", "KakaoAK " + apiKey);
			
			int responseCode = conn.getResponseCode();
			BufferedReader in = new BufferedReader(
					new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
			StringBuilder response = new StringBuilder();
			String inputLine;
			while ((inputLine = in.readLine()) != null) {
				response.append(inputLine);
			}
			in.close();
			conn.disconnect();
			
			if (responseCode >= 200 && responseCode < 300) {
				JSONObject jsonResponse = new JSONObject(response.toString());
				if (jsonResponse.has("documents") && jsonResponse.getJSONArray("documents").length() > 0) {
					JSONObject document = jsonResponse.getJSONArray("documents").getJSONObject(0);
					String x = document.getString("x");
					String y = document.getString("y");
					return x + "," + y;
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return null;
	}
	
	/**
	 * 휴게소/졸음쉼터 간의 소요시간을 계산하는 메서드
	 *
	 * @param sections  경로의 sections 배열
	 * @param restAreas 휴게소/졸음쉼터 이름 리스트
	 * @return 각 휴게소/졸음쉼터 간의 소요시간 리스트 (초 단위)
	 */
	private List<Integer> calculateDurationsToRestAreas(JSONArray sections, List<String> restAreas) {
		List<Integer> durations = new ArrayList<>();
		Map<String, Integer> restAreaDurations = new HashMap<>();
		List<String> foundRestAreas = new ArrayList<>();
		int currentDuration = 0;
		int lastRestAreaDuration = 0;
		
		for (int i = 0; i < sections.length(); i++) {
			JSONObject section = sections.getJSONObject(i);
			
			if (section.has("guides")) {
				JSONArray guides = section.getJSONArray("guides");
				for (int j = 0; j < guides.length(); j++) {
					JSONObject guide = guides.getJSONObject(j);
					
					int guideDuration = guide.optInt("duration", 0);
					currentDuration += guideDuration;
					
					if (guide.has("name") && !guide.getString("name").isEmpty()) {
						String guideName = guide.getString("name");
						
						boolean isRestArea = false;
						if (restAreas.contains(guideName)) {
							isRestArea = true;
						} else if (guideName.contains("휴게소") || guideName.contains("서비스") ||
								guideName.contains("REST") || guideName.contains("SERVICE")) {
							isRestArea = true;
						} else if (guideName.contains("졸음쉼터")) {
							isRestArea = true;
						}
						
						if (isRestArea && restAreas.contains(guideName)) {
							if (!foundRestAreas.contains(guideName)) {
								foundRestAreas.add(guideName);
								
								if (foundRestAreas.size() == 1) {
									restAreaDurations.put(guideName, currentDuration);
								} else {
									int segmentDuration = currentDuration - lastRestAreaDuration;
									restAreaDurations.put(guideName, segmentDuration);
								}
								
								lastRestAreaDuration = currentDuration;
							}
						}
					}
				}
			}
		}
		
		for (String restArea : restAreas) {
			if (restAreaDurations.containsKey(restArea)) {
				durations.add(restAreaDurations.get(restArea));
			} else {
				durations.add(0);
			}
		}
		
		return durations;
	}
	
}
