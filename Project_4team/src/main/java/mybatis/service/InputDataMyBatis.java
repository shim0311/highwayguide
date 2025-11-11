package mybatis.service;

import mybatis.vo.ServiceAreaVO;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import restinfo.dao.ServiceAreaDAO;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.List;

public class InputDataMyBatis {
	
	public static void main(String[] args) {
		InputDataMyBatis inputData = new InputDataMyBatis();
		
		// Excel 파일 경로 
		String excelFilePath = "/Users/tak/Code/HighWayTeamProject/work/Project_4team/review_data/merged_with_marketing_copy.xlsx";
		
		try {
			inputData.updateServiceAreaData(excelFilePath);
		} catch (Exception e) {
			System.err.println("데이터 업데이트 중 오류 발생: " + e.getMessage());
			e.printStackTrace();
		}
	}
	
	/**
	 * Excel 파일을 읽어서 휴게소 데이터를 MyBatis로 업데이트합니다.
	 *
	 * @param excelFilePath Excel 파일 경로
	 */
	public void updateServiceAreaData(String excelFilePath) {
		System.out.println("=== MyBatis 휴게소 데이터 업데이트 시작 ===");
		System.out.println("파일 경로: " + excelFilePath);
		
		int successCount = 0;
		int failCount = 0;
		int notFoundCount = 0;
		
		try (Workbook workbook = new XSSFWorkbook(new FileInputStream(excelFilePath))) {
			Sheet sheet = workbook.getSheetAt(0);
			
			// Excel의 각 행을 읽어서 처리
			for (Row row : sheet) {
				if (row.getRowNum() == 0) {
					System.out.println("헤더 행 건너뛰기");
					continue; // 헤더 건너뛰기
				}
				
				try {
					// Excel에서 데이터 추출 (Python 크롤링 결과에 맞춤)
					int idx = getIntCellValue(row.getCell(0)); // idx (첫 번째 컬럼)
					String name = getStringCellValue(row.getCell(1)); // 휴게소명
					String phone = getStringCellValue(row.getCell(2)); // 전화번호
					String rating = getStringCellValue(row.getCell(3)); // 별점
					String facilityInfo = getStringCellValue(row.getCell(4)); // 시설정보
					String convenience = getStringCellValue(row.getCell(5)); // 편의시설
					String aiComment = getStringCellValue(row.getCell(6)); // AI 코멘트 (6번째 컬럼)
					
					System.out.println("처리 중: idx=" + idx + ", 휴게소명=" + name);
					
					// null 값 체크 - null이면 업데이트하지 않음
					if (rating == null || rating.trim().isEmpty() || rating.equals("null")) {
						System.out.println("⚠️ 별점이 null이므로 업데이트 건너뜀: idx=" + idx);
						continue;
					}
					
					if (convenience == null || convenience.trim().isEmpty() || convenience.equals("null")) {
						System.out.println("⚠️ 편의시설이 null이므로 업데이트 건너뜀: idx=" + idx);
						continue;
					}
					
					// 먼저 해당 idx가 데이터베이스에 존재하는지 확인
					ServiceAreaVO existingArea = ServiceAreaDAO.getByIdx(String.valueOf(idx));
					if (existingArea == null) {
						System.out.println("❌ 데이터베이스에 존재하지 않는 idx: " + idx);
						notFoundCount++;
						continue;
					}
					
					// 전화번호 업데이트 조건 확인
					String existingTel = existingArea.getTel();
					boolean shouldUpdateTel = false;
					
					if (existingTel == null || existingTel.trim().isEmpty()) {
						// 공란인 경우
						shouldUpdateTel = true;
						System.out.println("📞 기존 전화번호가 공란입니다: idx=" + idx);
					} else {
						// 0이 5개 이상인지 확인
						long zeroCount = existingTel.chars().filter(ch -> ch == '0').count();
						if (zeroCount >= 5) {
							shouldUpdateTel = true;
							System.out.println("📞 기존 전화번호에 0이 5개 이상입니다: " + existingTel + " (idx=" + idx + ")");
						}
					}
					
					// 전화번호 업데이트
					if (shouldUpdateTel && phone != null && !phone.trim().isEmpty() && !phone.equals("null")) {
						int telResult = ServiceAreaDAO.updateTel(String.valueOf(idx), phone);
						if (telResult > 0) {
							System.out.println("📞 전화번호 업데이트 성공: " + phone + " (idx=" + idx + ")");
						} else {
							System.out.println("📞 전화번호 업데이트 실패: idx=" + idx);
						}
					}
					
					// AI 코멘트 업데이트 (별도로 처리)
					if (aiComment != null && !aiComment.trim().isEmpty() && !aiComment.equals("null")) {
						int aiCommentResult = ServiceAreaDAO.updateAiComment(String.valueOf(idx), aiComment);
						if (aiCommentResult > 0) {
							System.out.println("🤖 AI 코멘트 업데이트 성공: idx=" + idx);
						} else {
							System.out.println("🤖 AI 코멘트 업데이트 실패: idx=" + idx);
						}
					}
					
					// ServiceAreaDAO를 통해 데이터베이스 업데이트 (별점, 편의시설)
					int result = ServiceAreaDAO.updateStarAndConvenience(String.valueOf(idx), rating, convenience);
					
					if (result > 0) {
						System.out.println("✅ 업데이트 성공: idx=" + idx + ", 휴게소명=" + name);
						successCount++;
					} else {
						System.out.println("❌ 매칭 실패: idx=" + idx + ", 휴게소명=" + name);
						notFoundCount++;
					}
					
				} catch (Exception e) {
					System.err.println("❌ 행 " + (row.getRowNum() + 1) + " 처리 실패: " + e.getMessage());
					failCount++;
				}
			}
			
			// 결과 출력
			printResults(successCount, failCount, notFoundCount);
			
		} catch (IOException e) {
			System.err.println("Excel 파일 읽기 실패: " + e.getMessage());
			e.printStackTrace();
		}
	}
	
	/**
	 * 특정 휴게소의 데이터만 업데이트합니다.
	 *
	 * @param idx         휴게소 인덱스
	 * @param rating      별점
	 * @param convenience 편의시설
	 */
	public void updateSpecificServiceArea(int idx, String rating, String convenience) {
		try {
			int result = ServiceAreaDAO.updateStarAndConvenience(String.valueOf(idx), rating, convenience);
			
			if (result > 0) {
				System.out.println("✅ 휴게소 업데이트 성공: idx=" + idx);
			} else {
				System.out.println("❌ 휴게소를 찾을 수 없음: idx=" + idx);
			}
			
		} catch (Exception e) {
			System.err.println("MyBatis 업데이트 실패: " + e.getMessage());
			e.printStackTrace();
		}
	}
	
	/**
	 * 특정 휴게소의 별점, 편의시설, AI 코멘트를 업데이트합니다.
	 *
	 * @param idx         휴게소 인덱스
	 * @param rating      별점
	 * @param convenience 편의시설
	 * @param aiComment   AI 코멘트
	 */
	public void updateSpecificServiceAreaWithAiComment(int idx, String rating, String convenience, String aiComment) {
		try {
			int result = ServiceAreaDAO.updateStarConvenienceAndAiComment(String.valueOf(idx), rating, convenience,
					aiComment);
			
			if (result > 0) {
				System.out.println("✅ 휴게소 업데이트 성공 (AI 코멘트 포함): idx=" + idx);
			} else {
				System.out.println("❌ 휴게소를 찾을 수 없음: idx=" + idx);
			}
			
		} catch (Exception e) {
			System.err.println("MyBatis 업데이트 실패: " + e.getMessage());
			e.printStackTrace();
		}
	}
	
	/**
	 * 특정 휴게소의 AI 코멘트만 업데이트합니다.
	 *
	 * @param idx       휴게소 인덱스
	 * @param aiComment AI 코멘트
	 */
	public void updateSpecificServiceAreaAiComment(int idx, String aiComment) {
		try {
			int result = ServiceAreaDAO.updateAiComment(String.valueOf(idx), aiComment);
			
			if (result > 0) {
				System.out.println("✅ AI 코멘트 업데이트 성공: idx=" + idx);
			} else {
				System.out.println("❌ 휴게소를 찾을 수 없음: idx=" + idx);
			}
			
		} catch (Exception e) {
			System.err.println("MyBatis AI 코멘트 업데이트 실패: " + e.getMessage());
			e.printStackTrace();
		}
	}
	
	/**
	 * 휴게소 정보를 조회합니다.
	 *
	 * @param idx 휴게소 인덱스
	 */
	public void getServiceAreaInfo(int idx) {
		try {
			ServiceAreaVO serviceArea = ServiceAreaDAO.getByIdx(String.valueOf(idx));
			
			if (serviceArea != null) {
				System.out.println("=== 휴게소 정보 ===");
				System.out.println("인덱스: " + serviceArea.getIdx());
				System.out.println("휴게소명: " + serviceArea.getSAName());
				System.out.println("별점: " + serviceArea.getStar());
				System.out.println("편의시설: " + serviceArea.getConvenience());
				System.out.println("AI 코멘트: " + serviceArea.getAiComment());
			} else {
				System.out.println("❌ 휴게소를 찾을 수 없음: idx=" + idx);
			}
			
		} catch (Exception e) {
			System.err.println("MyBatis 조회 실패: " + e.getMessage());
			e.printStackTrace();
		}
	}
	
	/**
	 * 모든 휴게소 정보를 조회합니다.
	 */
	public void getAllServiceAreas() {
		try {
			List<ServiceAreaVO> serviceAreas = ServiceAreaDAO.getAll();
			
			System.out.println("=== 모든 휴게소 정보 ===");
			System.out.println("총 " + serviceAreas.size() + "개의 휴게소가 있습니다.");
			
			for (ServiceAreaVO serviceArea : serviceAreas) {
				System.out.println("idx: " + serviceArea.getIdx() +
						", 이름: " + serviceArea.getSAName() +
						", 별점: " + serviceArea.getStar() +
						", 편의시설: " + serviceArea.getConvenience() +
						", AI 코멘트: " + serviceArea.getAiComment());
			}
			
		} catch (Exception e) {
			System.err.println("MyBatis 조회 실패: " + e.getMessage());
			e.printStackTrace();
		}
	}
	
	/**
	 * 셀의 문자열 값을 가져옵니다.
	 *
	 * @param cell 셀
	 * @return 문자열 값 (null이면 null 반환)
	 */
	private String getStringCellValue(Cell cell) {
		if (cell == null) {
			return null;
		}
		
		String value = "";
		switch (cell.getCellType()) {
			case STRING:
				value = cell.getStringCellValue().trim();
				break;
			case NUMERIC:
				value = String.valueOf(cell.getNumericCellValue()).trim();
				break;
			case BOOLEAN:
				value = String.valueOf(cell.getBooleanCellValue()).trim();
				break;
			case FORMULA:
				value = cell.getCellFormula().trim();
				break;
			case BLANK:
				value = null;
				break;
			default:
				value = "";
		}
		
		// 빈 문자열이면 null 반환
		if (value != null && value.isEmpty()) {
			return null;
		}
		
		return value;
	}
	
	/**
	 * 셀의 정수 값을 가져옵니다.
	 *
	 * @param cell 셀
	 * @return 정수 값
	 */
	private int getIntCellValue(Cell cell) {
		if (cell == null) {
			return 0;
		}
		
		switch (cell.getCellType()) {
			case NUMERIC:
				return (int) cell.getNumericCellValue();
			case STRING:
				try {
					return Integer.parseInt(cell.getStringCellValue().trim());
				} catch (NumberFormatException e) {
					return 0;
				}
			default:
				return 0;
		}
	}
	
	/**
	 * 결과를 출력합니다.
	 *
	 * @param successCount  성공한 개수
	 * @param failCount     실패한 개수
	 * @param notFoundCount 찾을 수 없는 개수
	 */
	private void printResults(int successCount, int failCount, int notFoundCount) {
		System.out.println("\n=== MyBatis 업데이트 결과 ===");
		System.out.println("✅ 성공: " + successCount + "개");
		System.out.println("❌ 실패: " + failCount + "개");
		System.out.println("🔍 찾을 수 없음: " + notFoundCount + "개");
		System.out.println("📊 총 처리: " + (successCount + failCount + notFoundCount) + "개");
		
		if (successCount + failCount + notFoundCount > 0) {
			double successRate = (double) successCount / (successCount + failCount + notFoundCount) * 100;
			System.out.println("📈 성공률: " + String.format("%.1f", successRate) + "%");
		}
	}
}
