package mybatis.service;

import java.io.FileInputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import restinfo.util.ConfigLoader;

public class InputData {

    // 데이터베이스 연결 정보 (환경변수에서 로드)
    private static final String DB_URL = ConfigLoader.getProperty("db.url");
    private static final String DB_USER = ConfigLoader.getProperty("db.username");
    private static final String DB_PASSWORD = ConfigLoader.getProperty("db.password");

    public static void main(String[] args) {
        InputData inputData = new InputData();

        // Excel 파일 경로 (실제 파일 경로로 수정하세요)
        String excelFilePath = "휴게소_리뷰_전체_20241201_143022.xlsx"; // 실제 파일명으로 변경

        try {
            inputData.updateServiceAreaData(excelFilePath);
        } catch (Exception e) {
            System.err.println("데이터 업데이트 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Excel 파일을 읽어서 휴게소 데이터를 업데이트합니다.
     * 
     * @param excelFilePath Excel 파일 경로
     */
    public void updateServiceAreaData(String excelFilePath) {
        System.out.println("=== 휴게소 데이터 업데이트 시작 ===");
        System.out.println("파일 경로: " + excelFilePath);

        int successCount = 0;
        int failCount = 0;
        int notFoundCount = 0;

        try (Workbook workbook = new XSSFWorkbook(new FileInputStream(excelFilePath))) {
            Sheet sheet = workbook.getSheetAt(0);

            // 데이터베이스 연결
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {

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

                        System.out.println("처리 중: idx=" + idx + ", 휴게소명=" + name);

                        // 데이터베이스 업데이트
                        int result = updateServiceArea(conn, idx, rating, convenience);

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

            } catch (SQLException e) {
                System.err.println("데이터베이스 연결 실패: " + e.getMessage());
                e.printStackTrace();
            }

        } catch (IOException e) {
            System.err.println("Excel 파일 읽기 실패: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * 휴게소 데이터를 업데이트합니다.
     * 
     * @param conn        데이터베이스 연결
     * @param idx         휴게소 인덱스
     * @param rating      별점
     * @param convenience 편의시설
     * @return 업데이트된 행 수
     */
    private int updateServiceArea(Connection conn, int idx, String rating, String convenience) throws SQLException {
        String sql = "UPDATE ServiceArea SET Star = ?, Convenience = ? WHERE idx = ?";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, rating);
            pstmt.setString(2, convenience);
            pstmt.setInt(3, idx);

            return pstmt.executeUpdate();
        }
    }

    /**
     * 셀의 문자열 값을 가져옵니다.
     * 
     * @param cell 셀
     * @return 문자열 값
     */
    private String getStringCellValue(Cell cell) {
        if (cell == null) {
            return "";
        }

        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue().trim();
            case NUMERIC:
                return String.valueOf(cell.getNumericCellValue()).trim();
            case BOOLEAN:
                return String.valueOf(cell.getBooleanCellValue()).trim();
            case FORMULA:
                return cell.getCellFormula().trim();
            default:
                return "";
        }
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
        System.out.println("\n=== 업데이트 결과 ===");
        System.out.println("✅ 성공: " + successCount + "개");
        System.out.println("❌ 실패: " + failCount + "개");
        System.out.println("🔍 찾을 수 없음: " + notFoundCount + "개");
        System.out.println("📊 총 처리: " + (successCount + failCount + notFoundCount) + "개");

        if (successCount + failCount + notFoundCount > 0) {
            double successRate = (double) successCount / (successCount + failCount + notFoundCount) * 100;
            System.out.println("📈 성공률: " + String.format("%.1f", successRate) + "%");
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
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            int result = updateServiceArea(conn, idx, rating, convenience);

            if (result > 0) {
                System.out.println("✅ 휴게소 업데이트 성공: idx=" + idx);
            } else {
                System.out.println("❌ 휴게소를 찾을 수 없음: idx=" + idx);
            }

        } catch (SQLException e) {
            System.err.println("데이터베이스 업데이트 실패: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * 휴게소 정보를 조회합니다.
     * 
     * @param idx 휴게소 인덱스
     */
    public void getServiceAreaInfo(int idx) {
        String sql = "SELECT idx, SAname, Star, Convenience FROM ServiceArea WHERE idx = ?";

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idx);
            var rs = pstmt.executeQuery();

            if (rs.next()) {
                System.out.println("=== 휴게소 정보 ===");
                System.out.println("인덱스: " + rs.getInt("idx"));
                System.out.println("휴게소명: " + rs.getString("SAname"));
                System.out.println("별점: " + rs.getString("Star"));
                System.out.println("편의시설: " + rs.getString("Convenience"));
            } else {
                System.out.println("❌ 휴게소를 찾을 수 없음: idx=" + idx);
            }

        } catch (SQLException e) {
            System.err.println("데이터베이스 조회 실패: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
