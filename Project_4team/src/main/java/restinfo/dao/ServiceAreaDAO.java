package restinfo.dao;

import mybatis.service.FactoryService;
import mybatis.vo.ServiceAreaVO;
import org.apache.ibatis.session.SqlSession;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ServiceAreaDAO {
	public static List<ServiceAreaVO> getAll() {
		SqlSession ss = FactoryService.getFactory().openSession();
		List<ServiceAreaVO> list = ss.selectList("SA.all");
		ss.close();

		return list;
	}

	public static ServiceAreaVO getOneArea(String idx) {
		// idx는 클릭한 휴게소의 값임 그걸로 찾아서 휴게소 정보 갖고온 후
		// pjyrestAReaDEtail에 전달해준다음에 Detail jsp(아직만들지 않음)에 표현하자.
		SqlSession ss = FactoryService.getFactory().openSession();
		ServiceAreaVO vo = ss.selectOne("SA.getOne", idx);
		ss.close();

		return vo;
	}

	public static int updateXY(String idx, double lat, double lng) {
		int cnt = 0;
		SqlSession ss = FactoryService.getFactory().openSession();
		Map<String, Object> m = new HashMap<>();

		m.put("idx", idx); // String 타입
		m.put("lat", lat); // double 타입
		m.put("lng", lng); // double 타입

		cnt = ss.update("SA.xY", m);
		if (cnt > 0) {
			ss.commit();
		} else {
			ss.rollback();
		}
		ss.close();
		return cnt;
	}

	public static List<ServiceAreaVO> inBounds(double swLat, double swLng, double neLat, double neLng) {
		Map<String, Double> m = new HashMap<>();
		m.put("swLat", swLat);
		m.put("swLng", swLng);
		m.put("neLat", neLat);
		m.put("neLng", neLng);

		SqlSession ss = FactoryService.getFactory().openSession();
		List<ServiceAreaVO> list = ss.selectList("SA.inBounds", m);
		ss.close();

		return list;
	}

	public static List<ServiceAreaVO> Search(String text) {
		SqlSession ss = FactoryService.getFactory().openSession();
		List<ServiceAreaVO> list = ss.selectList("SA.searchInsert", text);
		ss.close();
		return list;

	}

	/**
	 * Excel 데이터로 별점과 편의시설을 업데이트합니다.
	 *
	 * @param idx         휴게소 인덱스
	 * @param rating      별점
	 * @param convenience 편의시설
	 * @return 업데이트된 행 수
	 */
	public static int updateStarAndConvenience(String idx, String rating, String convenience) {
		// null 값 체크
		if (rating == null || rating.trim().isEmpty() || rating.equals("null")) {
			System.out.println("⚠️ 별점이 null이므로 업데이트하지 않습니다: idx=" + idx);
			return 0;
		}

		if (convenience == null || convenience.trim().isEmpty() || convenience.equals("null")) {
			System.out.println("⚠️ 편의시설이 null이므로 업데이트하지 않습니다: idx=" + idx);
			return 0;
		}

		int cnt = 0;
		SqlSession ss = FactoryService.getFactory().openSession();

		try {
			ServiceAreaVO serviceArea = new ServiceAreaVO();
			serviceArea.setIdx(idx);
			serviceArea.setStar(rating);
			serviceArea.setConvenience(convenience);

			cnt = ss.update("SA.updateStarAndConvenience", serviceArea);

			if (cnt > 0) {
				ss.commit();
			} else {
				ss.rollback();
			}
		} catch (Exception e) {
			ss.rollback();
			throw e;
		} finally {
			ss.close();
		}

		return cnt;
	}

	/**
	 * Excel 데이터로 별점, 편의시설, AI 코멘트를 업데이트합니다.
	 *
	 * @param idx         휴게소 인덱스
	 * @param rating      별점
	 * @param convenience 편의시설
	 * @param aiComment   AI 코멘트
	 * @return 업데이트된 행 수
	 */
	public static int updateStarConvenienceAndAiComment(String idx, String rating, String convenience,
			String aiComment) {
		// null 값 체크
		if (rating == null || rating.trim().isEmpty() || rating.equals("null")) {
			System.out.println("⚠️ 별점이 null이므로 업데이트하지 않습니다: idx=" + idx);
			return 0;
		}

		if (convenience == null || convenience.trim().isEmpty() || convenience.equals("null")) {
			System.out.println("⚠️ 편의시설이 null이므로 업데이트하지 않습니다: idx=" + idx);
			return 0;
		}

		int cnt = 0;
		SqlSession ss = FactoryService.getFactory().openSession();

		try {
			ServiceAreaVO serviceArea = new ServiceAreaVO();
			serviceArea.setIdx(idx);
			serviceArea.setStar(rating);
			serviceArea.setConvenience(convenience);
			serviceArea.setAiComment(aiComment);

			cnt = ss.update("SA.updateStarConvenienceAndAiComment", serviceArea);

			if (cnt > 0) {
				ss.commit();
			} else {
				ss.rollback();
			}
		} catch (Exception e) {
			ss.rollback();
			throw e;
		} finally {
			ss.close();
		}

		return cnt;
	}

	/**
	 * Excel 데이터로 AI 코멘트를 업데이트합니다.
	 *
	 * @param idx       휴게소 인덱스
	 * @param aiComment AI 코멘트
	 * @return 업데이트된 행 수
	 */
	public static int updateAiComment(String idx, String aiComment) {
		// null 값 체크
		if (aiComment == null || aiComment.trim().isEmpty() || aiComment.equals("null")) {
			System.out.println("⚠️ AI 코멘트가 null이므로 업데이트하지 않습니다: idx=" + idx);
			return 0;
		}

		int cnt = 0;
		SqlSession ss = FactoryService.getFactory().openSession();

		try {
			ServiceAreaVO serviceArea = new ServiceAreaVO();
			serviceArea.setIdx(idx);
			serviceArea.setAiComment(aiComment);

			cnt = ss.update("SA.updateAiComment", serviceArea);

			if (cnt > 0) {
				ss.commit();
			} else {
				ss.rollback();
			}
		} catch (Exception e) {
			ss.rollback();
			throw e;
		} finally {
			ss.close();
		}

		return cnt;
	}

	/**
	 * Excel 데이터로 전화번호를 업데이트합니다.
	 *
	 * @param idx   휴게소 인덱스
	 * @param phone 전화번호
	 * @return 업데이트된 행 수
	 */
	public static int updateTel(String idx, String phone) {
		// null 값 체크
		if (phone == null || phone.trim().isEmpty() || phone.equals("null")) {
			System.out.println("⚠️ 전화번호가 null이므로 업데이트하지 않습니다: idx=" + idx);
			return 0;
		}

		int cnt = 0;
		SqlSession ss = FactoryService.getFactory().openSession();

		try {
			ServiceAreaVO serviceArea = new ServiceAreaVO();
			serviceArea.setIdx(idx);
			serviceArea.setTel(phone);

			cnt = ss.update("SA.updateTel", serviceArea);

			if (cnt > 0) {
				ss.commit();
			} else {
				ss.rollback();
			}
		} catch (Exception e) {
			ss.rollback();
			throw e;
		} finally {
			ss.close();
		}

		return cnt;
	}

	/**
	 * idx로 휴게소 정보를 조회합니다.
	 *
	 * @param idx 휴게소 인덱스
	 * @return 휴게소 정보
	 */
	public static ServiceAreaVO getByIdx(String idx) {
		SqlSession ss = FactoryService.getFactory().openSession();
		ServiceAreaVO serviceArea = ss.selectOne("SA.getByIdx", idx);
		ss.close();
		return serviceArea;
	}

	/**
	 * idx로 휴게소 정보를 조회합니다 (Menu 정보 포함).
	 *
	 * @param idx 휴게소 인덱스
	 * @return 휴게소 정보 (Menu 리스트 포함)
	 */
	public static ServiceAreaVO getByIdxWithMenu(String idx) {
		SqlSession ss = FactoryService.getFactory().openSession();
		ServiceAreaVO serviceArea = ss.selectOne("SA.getByIdxWithMenu", idx);
		ss.close();
		return serviceArea;
	}

	public static List<ServiceAreaVO> bookmarkedArea(String idx) {
		SqlSession ss = FactoryService.getFactory().openSession();
		List<ServiceAreaVO> list = ss.selectList("SA.getbookmark", idx);
		ss.close();

		return list;
	}

	public static int deletebookmark(String idx, String Useridx) {
		SqlSession ss = FactoryService.getFactory().openSession();
		Map<String, String> m = new HashMap<>();
		m.put("SAidx", idx);
		m.put("Useridx", Useridx);
		int cnt = ss.delete("SA.deletebookmark", m);
		if (cnt > 0)
			ss.commit();
		else
			ss.rollback();

		ss.close();
		return cnt;
	}

	/**
	 * 휴게소 이름과 방향으로 ServiceAreaVO 리스트를 조회합니다.
	 * 같은 이름의 휴게소가 상행/하행으로 존재하는 경우를 처리합니다.
	 *
	 * @param restAreaNames      휴게소 이름 리스트
	 * @param restAreaDirections 휴게소별 방향 정보 (상행/하행)
	 * @return 휴게소 이름을 키로 하는 Map<휴게소이름, ServiceAreaVO>
	 */
	public static Map<String, ServiceAreaVO> getServiceAreasByNameAndDirection(
			List<String> restAreaNames, Map<String, String> restAreaDirections) {

		Map<String, ServiceAreaVO> result = new HashMap<>();

		if (restAreaNames == null || restAreaNames.isEmpty()) {
			return result;
		}

		SqlSession ss = FactoryService.getFactory().openSession();

		try {
			for (String restAreaName : restAreaNames) {
				String direction = restAreaDirections.get(restAreaName);

				// 🚀 퍼지 매칭으로 휴게소 찾기
				ServiceAreaVO serviceArea = findServiceAreaByFuzzyMatching(restAreaName, direction, ss);

				if (serviceArea != null) {
					result.put(restAreaName, serviceArea);
				} else {
					System.out.println("❌ 실패: " + restAreaName);
				}
			}
		} catch (Exception e) {
			System.err.println("휴게소 정보 조회 중 오류 발생: " + e.getMessage());
			e.printStackTrace();
		} finally {
			ss.close();
		}

		return result;
	}

	/**
	 * 휴게소 이름과 방향으로 ServiceAreaVO 리스트를 조회합니다 (Menu 정보 포함).
	 * 같은 이름의 휴게소가 상행/하행으로 존재하는 경우를 처리합니다.
	 *
	 * @param restAreaNames      휴게소 이름 리스트
	 * @param restAreaDirections 휴게소별 방향 정보 (상행/하행)
	 * @return 휴게소 이름을 키로 하는 Map<휴게소이름, ServiceAreaVO> (Menu 리스트 포함)
	 */
	public static Map<String, ServiceAreaVO> getServiceAreasByNameAndDirectionWithMenu(
			List<String> restAreaNames, Map<String, String> restAreaDirections) {

		Map<String, ServiceAreaVO> result = new HashMap<>();

		if (restAreaNames == null || restAreaNames.isEmpty()) {
			return result;
		}

		SqlSession ss = FactoryService.getFactory().openSession();

		try {
			for (String restAreaName : restAreaNames) {
				String direction = restAreaDirections.get(restAreaName);

				// 🚀 퍼지 매칭으로 휴게소 찾기 (Menu 포함)
				ServiceAreaVO serviceArea = findServiceAreaByFuzzyMatchingWithMenu(restAreaName, direction, ss);

				if (serviceArea != null) {
					result.put(restAreaName, serviceArea);
				} else {
					System.out.println("❌ 실패: " + restAreaName);
				}
			}
		} catch (Exception e) {
			System.err.println("휴게소 정보 조회 중 오류 발생: " + e.getMessage());
			e.printStackTrace();
		} finally {
			ss.close();
		}

		return result;
	}

	/**
	 * 퍼지 매칭을 통해 휴게소를 찾는 메서드
	 * 여러 매칭 전략을 순차적으로 시도합니다.
	 *
	 * @param apiName   카카오 API에서 받은 휴게소 이름
	 * @param direction 방향 정보
	 * @param ss        SqlSession
	 * @return 매칭된 ServiceAreaVO 또는 null
	 */
	private static ServiceAreaVO findServiceAreaByFuzzyMatching(String apiName, String direction, SqlSession ss) {
		if (apiName == null || apiName.trim().isEmpty()) {
			return null;
		}

		String normalizedApiName = normalizeApiName(apiName);

		// 1단계: 정확 매칭 시도
		ServiceAreaVO exactMatch = findExactMatch(normalizedApiName, direction, ss);
		if (exactMatch != null) {
			return exactMatch;
		}

		// 2단계: 방향 포함 매칭 시도
		ServiceAreaVO directionMatch = findDirectionMatch(normalizedApiName, direction, ss);
		if (directionMatch != null) {
			return directionMatch;
		}

		// 3단계: 부분 문자열 매칭 시도
		ServiceAreaVO partialMatch = findPartialMatch(normalizedApiName, ss);
		if (partialMatch != null) {
			return partialMatch;
		}

		// 4단계: 키워드 매칭 시도
		ServiceAreaVO keywordMatch = findKeywordMatch(normalizedApiName, ss);
		if (keywordMatch != null) {
			return keywordMatch;
		}

		// 5단계: 유사도 기반 매칭 시도
		ServiceAreaVO similarityMatch = findSimilarityMatch(normalizedApiName, ss);
		if (similarityMatch != null) {
			return similarityMatch;
		}

		System.out.println("  ❌ 모든 매칭 전략 실패");
		return null;
	}

	/**
	 * API 이름을 정규화하는 메서드
	 */
	private static String normalizeApiName(String apiName) {
		String normalized = apiName;

		// 괄호와 내용 제거: (목포방향), (임시) 등
		normalized = normalized.replaceAll("\\([^)]*\\)", "");

		// 특수문자 제거: 공백, 하이픈, 점 등
		normalized = normalized.replaceAll("[\\s\\-\\.,]", "");

		// "휴게소" → "휴게소" (일관성 유지)
		if (normalized.endsWith("휴게소")) {
			normalized = normalized;
		}

		return normalized.trim();
	}

	/**
	 * 1단계: 정확 매칭
	 */
	private static ServiceAreaVO findExactMatch(String normalizedName, String direction, SqlSession ss) {
		try {
			Map<String, String> params = new HashMap<>();
			params.put("saname", normalizedName);
			params.put("sadirection", direction);

			return ss.selectOne("SA.getByNameAndDirection", params);
		} catch (Exception e) {
			return null;
		}
	}

	/**
	 * 2단계: 방향 포함 매칭
	 */
	private static ServiceAreaVO findDirectionMatch(String normalizedName, String direction, SqlSession ss) {
		try {
			// 방향 정보가 있는 경우, 방향으로 필터링하여 검색
			if (direction != null && !direction.equals("방향불명")) {
				List<ServiceAreaVO> areas = ss.selectList("SA.getByNameOnly", normalizedName);

				for (ServiceAreaVO area : areas) {
					String dbDirection = area.getSADirection();
					if (dbDirection != null && ((direction.equals("상행") && dbDirection.contains("상행")) ||
							(direction.equals("하행") && dbDirection.contains("하행")))) {
						return area;
					}
				}
			}
			return null;
		} catch (Exception e) {
			return null;
		}
	}

	/**
	 * 3단계: 부분 문자열 매칭
	 */
	private static ServiceAreaVO findPartialMatch(String normalizedName, SqlSession ss) {
		try {
			// 공통 키워드 추출
			String[] keywords = extractKeywords(normalizedName);

			for (String keyword : keywords) {
				if (keyword.length() >= 2) { // 2글자 이상인 키워드만 사용
					List<ServiceAreaVO> areas = ss.selectList("SA.findByPartialName", keyword);
					if (!areas.isEmpty()) {
						// 가장 긴 키워드와 매칭되는 것 선택
						return areas.get(0);
					}
				}
			}
			return null;
		} catch (Exception e) {
			return null;
		}
	}

	/**
	 * 4단계: 키워드 매칭
	 */
	private static ServiceAreaVO findKeywordMatch(String normalizedName, SqlSession ss) {
		try {
			String[] keywords = extractKeywords(normalizedName);

			for (String keyword : keywords) {
				if (keyword.length() >= 2) {
					List<ServiceAreaVO> areas = ss.selectList("SA.findByKeywords", keyword);
					if (!areas.isEmpty()) {
						return areas.get(0);
					}
				}
			}
			return null;
		} catch (Exception e) {
			return null;
		}
	}

	/**
	 * 5단계: 유사도 기반 매칭
	 */
	private static ServiceAreaVO findSimilarityMatch(String normalizedName, SqlSession ss) {
		try {
			// 모든 휴게소를 가져와서 유사도 계산
			List<ServiceAreaVO> allAreas = ss.selectList("SA.all");

			ServiceAreaVO bestMatch = null;
			double bestSimilarity = 0.0;

			for (ServiceAreaVO area : allAreas) {
				double similarity = calculateSimilarity(normalizedName, area.getSAName());
				if (similarity > bestSimilarity && similarity > 0.6) { // 60% 이상 유사도
					bestSimilarity = similarity;
					bestMatch = area;
				}
			}

			if (bestMatch != null) {
				System.out.println("    🎯 유사도: " + String.format("%.2f", bestSimilarity) + " (" + normalizedName
						+ " ↔ " + bestMatch.getSAName() + ")");
			}

			return bestMatch;
		} catch (Exception e) {
			return null;
		}
	}

	/**
	 * 퍼지 매칭을 통해 휴게소를 찾는 메서드 (Menu 정보 포함)
	 * 여러 매칭 전략을 순차적으로 시도합니다.
	 *
	 * @param apiName   카카오 API에서 받은 휴게소 이름
	 * @param direction 방향 정보
	 * @param ss        SqlSession
	 * @return 매칭된 ServiceAreaVO (Menu 리스트 포함) 또는 null
	 */
	private static ServiceAreaVO findServiceAreaByFuzzyMatchingWithMenu(String apiName, String direction,
			SqlSession ss) {
		if (apiName == null || apiName.trim().isEmpty()) {
			return null;
		}

		String normalizedApiName = normalizeApiName(apiName);

		// 1단계: 정확 매칭 시도 (Menu 포함)
		ServiceAreaVO exactMatch = findExactMatchWithMenu(normalizedApiName, direction, ss);
		if (exactMatch != null) {
			return exactMatch;
		}

		// 2단계: 방향 포함 매칭 시도 (Menu 포함)
		ServiceAreaVO directionMatch = findDirectionMatchWithMenu(normalizedApiName, direction, ss);
		if (directionMatch != null) {
			return directionMatch;
		}

		// 3단계: 부분 문자열 매칭 시도 (Menu 포함)
		ServiceAreaVO partialMatch = findPartialMatchWithMenu(normalizedApiName, ss);
		if (partialMatch != null) {
			return partialMatch;
		}

		// 4단계: 키워드 매칭 시도 (Menu 포함)
		ServiceAreaVO keywordMatch = findKeywordMatchWithMenu(normalizedApiName, ss);
		if (keywordMatch != null) {
			return keywordMatch;
		}

		// 5단계: 유사도 기반 매칭 시도 (Menu 포함)
		ServiceAreaVO similarityMatch = findSimilarityMatchWithMenu(normalizedApiName, ss);
		if (similarityMatch != null) {
			return similarityMatch;
		}

		System.out.println("  ❌ 모든 매칭 전략 실패");
		return null;
	}

	/**
	 * 1단계: 정확 매칭 (Menu 포함)
	 */
	private static ServiceAreaVO findExactMatchWithMenu(String normalizedName, String direction, SqlSession ss) {
		try {
			Map<String, String> params = new HashMap<>();
			params.put("saname", normalizedName);
			params.put("sadirection", direction);

			return ss.selectOne("SA.getByNameAndDirectionWithMenu", params);
		} catch (Exception e) {
			return null;
		}
	}

	/**
	 * 2단계: 방향 포함 매칭 (Menu 포함)
	 */
	private static ServiceAreaVO findDirectionMatchWithMenu(String normalizedName, String direction, SqlSession ss) {
		try {
			// 방향 정보가 있는 경우, 방향으로 필터링하여 검색
			if (direction != null && !direction.equals("방향불명")) {
				List<ServiceAreaVO> areas = ss.selectList("SA.getByNameOnlyWithMenu", normalizedName);

				for (ServiceAreaVO area : areas) {
					String dbDirection = area.getSADirection();
					if (dbDirection != null && ((direction.equals("상행") && dbDirection.contains("상행")) ||
							(direction.equals("하행") && dbDirection.contains("하행")))) {
						return area;
					}
				}
			}
			return null;
		} catch (Exception e) {
			return null;
		}
	}

	/**
	 * 3단계: 부분 문자열 매칭 (Menu 포함)
	 */
	private static ServiceAreaVO findPartialMatchWithMenu(String normalizedName, SqlSession ss) {
		try {
			// 공통 키워드 추출
			String[] keywords = extractKeywords(normalizedName);

			for (String keyword : keywords) {
				if (keyword.length() >= 2) { // 2글자 이상인 키워드만 사용
					List<ServiceAreaVO> areas = ss.selectList("SA.findByPartialName", keyword);
					if (!areas.isEmpty()) {
						// 이미 Menu 정보가 포함되어 있으므로 그대로 반환
						return areas.get(0);
					}
				}
			}
			return null;
		} catch (Exception e) {
			return null;
		}
	}

	/**
	 * 4단계: 키워드 매칭 (Menu 포함)
	 */
	private static ServiceAreaVO findKeywordMatchWithMenu(String normalizedName, SqlSession ss) {
		try {
			String[] keywords = extractKeywords(normalizedName);

			for (String keyword : keywords) {
				if (keyword.length() >= 2) {
					List<ServiceAreaVO> areas = ss.selectList("SA.findByKeywords", keyword);
					if (!areas.isEmpty()) {
						// 이미 Menu 정보가 포함되어 있으므로 그대로 반환
						return areas.get(0);
					}
				}
			}
			return null;
		} catch (Exception e) {
			return null;
		}
	}

	/**
	 * 5단계: 유사도 기반 매칭 (Menu 포함)
	 */
	private static ServiceAreaVO findSimilarityMatchWithMenu(String normalizedName, SqlSession ss) {
		try {
			// 모든 휴게소를 가져와서 유사도 계산 (Menu 포함)
			List<ServiceAreaVO> allAreas = ss.selectList("SA.getAllForSimilarity");

			ServiceAreaVO bestMatch = null;
			double bestSimilarity = 0.0;

			for (ServiceAreaVO area : allAreas) {
				double similarity = calculateSimilarity(normalizedName, area.getSAName());
				if (similarity > bestSimilarity && similarity > 0.6) { // 60% 이상 유사도
					bestSimilarity = similarity;
					bestMatch = area;
				}
			}

			if (bestMatch != null) {
				System.out.println("    🎯 유사도: " + String.format("%.2f", bestSimilarity) + " (" + normalizedName
						+ " ↔ " + bestMatch.getSAName() + ")");
				// 이미 Menu 정보가 포함되어 있으므로 그대로 반환
				return bestMatch;
			}

			return null;
		} catch (Exception e) {
			return null;
		}
	}

	/**
	 * 키워드 추출 메서드
	 */
	private static String[] extractKeywords(String name) {
		// "휴게소" 제거
		String withoutSuffix = name.replace("휴게소", "");

		// 주요 키워드들
		String[] commonKeywords = {
				"서울만남", "매송", "예산", "영광", "옥천", "천안", "청주", "대전", "부산", "울산"
		};

		// 공통 키워드가 포함되어 있는지 확인
		for (String keyword : commonKeywords) {
			if (withoutSuffix.contains(keyword)) {
				return new String[] { keyword, withoutSuffix };
			}
		}

		// 공통 키워드가 없으면 원본 이름 반환
		return new String[] { withoutSuffix, name };
	}

	/**
	 * 두 문자열의 유사도를 계산하는 메서드 (Jaro-Winkler 유사도)
	 */
	private static double calculateSimilarity(String s1, String s2) {
		if (s1 == null || s2 == null)
			return 0.0;

		// 간단한 유사도 계산 (실제로는 더 정교한 알고리즘 사용 가능)
		String longer = s1.length() > s2.length() ? s1 : s2;
		String shorter = s1.length() > s2.length() ? s2 : s1;

		if (longer.length() == 0)
			return 1.0;

		// 공통 문자 수 계산
		int commonChars = 0;
		for (int i = 0; i < shorter.length(); i++) {
			if (longer.contains(String.valueOf(shorter.charAt(i)))) {
				commonChars++;
			}
		}

		return (2.0 * commonChars) / (longer.length() + shorter.length());
	}
}
