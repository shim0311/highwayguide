package restinfo.action;

import mybatis.vo.ServiceAreaVO;
import org.json.JSONArray;
import org.json.JSONObject;
import restinfo.dao.ServiceAreaDAO;
import restinfo.util.ConfigLoader;

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

// Guide 정보를 담는 클래스
class GuideInfo {
	String name;
	double x;
	double y;
	int roadIndex;
	String type; // "IC", "휴게소", "졸음쉼터"

	public GuideInfo(String name, double x, double y, int roadIndex, String type) {
		this.name = name;
		this.x = x;
		this.y = y;
		this.roadIndex = roadIndex;
		this.type = type;
	}
}

public class KaKaoMapV2 implements Action {

	// 서울역 좌표 (기준점)
	private static final double SEOUL_STATION_X = 37.553452224808936;
	private static final double SEOUL_STATION_Y = 126.97288438634867;

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
			// 카카오 API 키 설정 (환경변수에서 로드)
			String apiKey = ConfigLoader.getProperty("KAKAO_API_KEY");

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

			// 일반적인 경우 (forwardTo가 없거나 다른 값)에는 index.jsp로 이동
			return "index.jsp";

		} catch (Exception e) {
			if ("restArea".equalsIgnoreCase(forwardTo)) {
				sendJsonError(response, 500, "서버 오류", "요청 처리 중 오류가 발생했습니다.");
				return null;
			}
			request.setAttribute("error", "서버 오류");
			request.setAttribute("errorMessage", e.getMessage());
			// 에러 발생 시 index.jsp로 이동
			return "index.jsp";
		}
	}

	// -------------- 함수 --------------

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

				// 휴게소 정보 추출 (이전 IC 정보 및 방향 포함)
				List<String> allRestAreas = new ArrayList<>();
				List<String> restAreas = new ArrayList<>();
				List<String> restStops = new ArrayList<>();
				Map<String, GuideInfo> restAreaToPrevIC = new HashMap<>();
				Map<String, String> restAreaDirections = new HashMap<>();

				extractRestAreas(sections, allRestAreas, restAreas, restStops, restAreaToPrevIC, restAreaDirections);

				// 소요시간 계산
				List<Integer> allRestAreaDurations = calculateDurationsToRestAreas(sections, allRestAreas);
				List<Integer> restAreaDurations = calculateDurationsToRestAreas(sections, restAreas);
				List<Integer> restStopDurations = calculateDurationsToRestAreas(sections, restStops);

				// 🚀 DB에서 휴게소 상세 정보 조회 (졸음쉼터 제외, Menu 정보 포함)
				Map<String, ServiceAreaVO> serviceAreaVOs = new HashMap<>();
				if (!restAreas.isEmpty()) {

					// 휴게소만 DB 조회 (Menu 정보 포함)
					serviceAreaVOs = ServiceAreaDAO.getServiceAreasByNameAndDirectionWithMenu(
							restAreas, restAreaDirections);

				} else {
					System.out.println("=== 휴게소가 없어 DB 조회 생략 ===");
				}

				// request에 데이터 저장
				saveRouteDataToRequest(request, route, sections, allRestAreas, restAreas, restStops,
						allRestAreaDurations, restAreaDurations, restStopDurations,
						origin, destination, routeData, restAreaToPrevIC, restAreaDirections, serviceAreaVOs);

			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	// 휴게소 정보 추출 (이전 IC 정보 및 방향 포함)
	private void extractRestAreas(JSONArray sections, List<String> allRestAreas,
			List<String> restAreas, List<String> restStops,
			Map<String, GuideInfo> restAreaToPrevIC,
			Map<String, String> restAreaDirections) {

		List<GuideInfo> allGuides = new ArrayList<>();

		// 1단계: 모든 guide 정보를 순서대로 수집
		for (int i = 0; i < sections.length(); i++) {
			JSONObject section = sections.getJSONObject(i);
			if (section.has("guides")) {
				JSONArray guides = section.getJSONArray("guides");
				for (int j = 0; j < guides.length(); j++) {
					JSONObject guide = guides.getJSONObject(j);
					if (guide.has("name") && !guide.getString("name").isEmpty()) {
						String guideName = guide.getString("name");
						double x = guide.getDouble("x");
						double y = guide.getDouble("y");
						int roadIndex = guide.getInt("road_index");

						// IC인지 휴게소인지 졸음쉼터인지 판별
						String type = "기타";
						if (guideName.contains("IC")) {
							type = "IC";
						} else if (guideName.contains("휴게소") || guideName.contains("서비스") ||
								guideName.contains("REST") || guideName.contains("SERVICE")) {
							type = "휴게소";
						} else if (guideName.contains("졸음쉼터")) {
							type = "졸음쉼터";
						}

						GuideInfo guideInfo = new GuideInfo(guideName, x, y, roadIndex, type);
						allGuides.add(guideInfo);
					}
				}
			}
		}

		// 2단계: 휴게소를 찾고 이전 IC와 매핑, 방향 계산
		for (int i = 0; i < allGuides.size(); i++) {
			GuideInfo current = allGuides.get(i);

			if ("휴게소".equals(current.type)) {
				restAreas.add(current.name);
				allRestAreas.add(current.name);

				// 이전 IC 찾기
				GuideInfo prevIC = findPreviousIC(allGuides, i);
				if (prevIC != null) {
					restAreaToPrevIC.put(current.name, prevIC);

					// 방향 계산 및 저장
					String direction = calculateDirection(prevIC, current);
					restAreaDirections.put(current.name, direction);
				}
			} else if ("졸음쉼터".equals(current.type)) {
				restStops.add(current.name);
				allRestAreas.add(current.name);
			}
		}

	}

	// 이전 IC 찾기
	private GuideInfo findPreviousIC(List<GuideInfo> allGuides, int currentIndex) {
		// 현재 위치에서 역순으로 검색하여 가장 가까운 IC 찾기
		for (int i = currentIndex - 1; i >= 0; i--) {
			if ("IC".equals(allGuides.get(i).type)) {
				return allGuides.get(i);
			}
		}
		return null;
	}

	// 상행/하행 방향 계산
	private String calculateDirection(GuideInfo ic, GuideInfo restArea) {
		// IC에서 휴게소로의 벡터 계산
		double vectorX = restArea.x - ic.x;
		double vectorY = restArea.y - ic.y;

		// 서울역에서 IC로의 벡터
		double seoulToICX = ic.x - SEOUL_STATION_X;
		double seoulToICY = ic.y - SEOUL_STATION_Y;

		// 두 벡터의 내적 계산 (방향 일치도 확인)
		double dotProduct = vectorX * seoulToICX + vectorY * seoulToICY;

		// 방향 결정
		String direction;
		if (dotProduct > 0) {
			direction = "하행";
		} else if (dotProduct < 0) {
			direction = "상행";
		} else {
			direction = "방향불명"; // 수직인 경우
		}

		return direction;
	}

	// 서울역까지의 거리 계산 (디버깅용)
	private double calculateDistanceToSeoul(double x, double y) {
		double deltaX = x - SEOUL_STATION_X;
		double deltaY = y - SEOUL_STATION_Y;
		return Math.sqrt(deltaX * deltaX + deltaY * deltaY);
	}

	// request에 경로 데이터 저장
	private void saveRouteDataToRequest(HttpServletRequest request, JSONObject route, JSONArray sections,
			List<String> allRestAreas, List<String> restAreas, List<String> restStops,
			List<Integer> allRestAreaDurations, List<Integer> restAreaDurations,
			List<Integer> restStopDurations, String origin, String destination,
			JSONObject routeData, Map<String, GuideInfo> restAreaToPrevIC,
			Map<String, String> restAreaDirections, Map<String, ServiceAreaVO> serviceAreaVOs) {

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
		request.setAttribute("jsonResponse", routeData);

		// 휴게소별 이전 IC 정보 및 방향 저장
		request.setAttribute("restAreaToPrevIC", restAreaToPrevIC);
		request.setAttribute("restAreaDirections", restAreaDirections);

		// 휴게소 이름 리스트와 방향을 매핑하여 저장
		Map<String, String> restAreaNameToDirection = createRestAreaNameToDirectionMapping(restAreas,
				restAreaDirections);
		request.setAttribute("restAreaNameToDirection", restAreaNameToDirection);

		// 🚀 DB에서 조회한 휴게소 상세 정보 저장
		request.setAttribute("serviceAreaVOs", serviceAreaVOs);

		// API 응답용 데이터 구조 생성
		List<Map<String, Object>> restAreaApiData = createRestAreaApiData(restAreas, restAreaDirections,
				restAreaToPrevIC, serviceAreaVOs);
		request.setAttribute("restAreaApiData", restAreaApiData);

		// 간략한 방향 통계만 출력
		int upboundCount = 0, downboundCount = 0, unknownCount = 0;
		for (Map.Entry<String, String> entry : restAreaDirections.entrySet()) {
			String direction = entry.getValue();
			if ("상행".equals(direction))
				upboundCount++;
			else if ("하행".equals(direction))
				downboundCount++;
			else
				unknownCount++;
		}
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

	// 휴게소 이름 리스트와 방향을 매핑하는 메서드
	private Map<String, String> createRestAreaNameToDirectionMapping(List<String> restAreas,
			Map<String, String> restAreaDirections) {
		Map<String, String> nameToDirection = new HashMap<>();

		for (String restAreaName : restAreas) {
			String direction = restAreaDirections.get(restAreaName);
			if (direction != null) {
				nameToDirection.put(restAreaName, direction);
			} else {
				// 방향 정보가 없는 경우 기본값 설정
				nameToDirection.put(restAreaName, "방향불명");
			}
		}

		return nameToDirection;
	}

	// API 응답용 데이터 구조 생성 메서드
	private List<Map<String, Object>> createRestAreaApiData(List<String> restAreas,
			Map<String, String> restAreaDirections, Map<String, GuideInfo> restAreaToPrevIC,
			Map<String, ServiceAreaVO> serviceAreaVOs) {
		List<Map<String, Object>> apiData = new ArrayList<>();

		for (String restAreaName : restAreas) {
			Map<String, Object> restAreaInfo = new HashMap<>();

			// 기본 정보
			restAreaInfo.put("name", restAreaName);
			restAreaInfo.put("direction", restAreaDirections.getOrDefault(restAreaName, "방향불명"));

			// 이전 IC 정보
			GuideInfo prevIC = restAreaToPrevIC.get(restAreaName);
			if (prevIC != null) {
				Map<String, Object> icInfo = new HashMap<>();
				icInfo.put("name", prevIC.name);
				icInfo.put("x", prevIC.x);
				icInfo.put("y", prevIC.y);
				icInfo.put("roadIndex", prevIC.roadIndex);
				restAreaInfo.put("previousIC", icInfo);

				// 서울역까지의 거리 계산
				double icDistanceToSeoul = calculateDistanceToSeoul(prevIC.x, prevIC.y);
				double restAreaDistanceToSeoul = calculateDistanceToSeoul(prevIC.x, prevIC.y);
				restAreaInfo.put("icDistanceToSeoul", String.format("%.6f", icDistanceToSeoul));
				restAreaInfo.put("restAreaDistanceToSeoul", String.format("%.6f", restAreaDistanceToSeoul));
			} else {
				restAreaInfo.put("previousIC", null);
				restAreaInfo.put("icDistanceToSeoul", "0.000000");
				restAreaInfo.put("restAreaDistanceToSeoul", "0.000000");
			}

			// DB에서 휴게소 상세 정보 조회
			ServiceAreaVO serviceAreaVO = serviceAreaVOs.get(restAreaName);
			if (serviceAreaVO != null) {
				Map<String, Object> serviceAreaInfo = new HashMap<>();
				serviceAreaInfo.put("name", serviceAreaVO.getSAName());
				serviceAreaInfo.put("address", serviceAreaVO.getAddress());
				serviceAreaInfo.put("phone", serviceAreaVO.getTel());
				serviceAreaInfo.put("star", serviceAreaVO.getStar());
				serviceAreaInfo.put("convenience", serviceAreaVO.getConvenience());
				serviceAreaInfo.put("aiComment", serviceAreaVO.getAiComment());
				serviceAreaInfo.put("compactParking", serviceAreaVO.getCompactParking());
				serviceAreaInfo.put("largeParking", serviceAreaVO.getLargeParking());
				serviceAreaInfo.put("disabledParking", serviceAreaVO.getDisabledParking());
				serviceAreaInfo.put("latitude", serviceAreaVO.getLat());
				serviceAreaInfo.put("longitude", serviceAreaVO.getLng());
				serviceAreaInfo.put("wayNum", serviceAreaVO.getWayNum());
				serviceAreaInfo.put("direction", restAreaDirections.getOrDefault(restAreaName, "방향불명"));
				serviceAreaInfo.put("previousIC", prevIC != null ? prevIC.name : null);

				// 서울역까지의 거리 계산
				if (prevIC != null) {
					double icDistanceToSeoul = calculateDistanceToSeoul(prevIC.x, prevIC.y);
					double restAreaDistanceToSeoul = calculateDistanceToSeoul(
							serviceAreaVO.getLat() != null ? Double.parseDouble(serviceAreaVO.getLat()) : 0,
							serviceAreaVO.getLng() != null ? Double.parseDouble(serviceAreaVO.getLng()) : 0);
					serviceAreaInfo.put("icDistanceToSeoul", String.format("%.6f", icDistanceToSeoul));
					serviceAreaInfo.put("restAreaDistanceToSeoul", String.format("%.6f", restAreaDistanceToSeoul));
				}

				restAreaInfo.put("serviceArea", serviceAreaInfo);
			}

			apiData.add(restAreaInfo);
		}

		return apiData;
	}

	// 휴게소 이름으로 방향을 조회하는 메서드 (외부에서 사용 가능)
	public String getDirectionByRestAreaName(String restAreaName, Map<String, String> restAreaDirections) {
		return restAreaDirections.getOrDefault(restAreaName, "방향불명");
	}

	// 모든 휴게소의 방향 정보를 리스트로 반환하는 메서드 (외부에서 사용 가능)
	public List<String> getAllRestAreaDirections(List<String> restAreas, Map<String, String> restAreaDirections) {
		List<String> directions = new ArrayList<>();
		for (String restAreaName : restAreas) {
			directions.add(restAreaDirections.getOrDefault(restAreaName, "방향불명"));
		}
		return directions;
	}

}
