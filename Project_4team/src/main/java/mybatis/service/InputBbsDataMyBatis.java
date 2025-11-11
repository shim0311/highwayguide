package mybatis.service;

import mybatis.vo.BbsVO;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import bbs.dao.BbsDAO;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.List;

public class InputBbsDataMyBatis {

    public static void main(String[] args) {
        InputBbsDataMyBatis inputData = new InputBbsDataMyBatis();

        // Excel 파일 경로
        String excelFilePath = "/Users/tak/Code/HighWayTeamProject/work/Project_4team/review_data/휴게소_리뷰_전체_20250819_154103.xlsx";

        try {
            inputData.insertBbsData(excelFilePath);
        } catch (Exception e) {
            System.err.println("데이터 삽입 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Excel 파일을 읽어서 게시판 데이터를 MyBatis로 삽입합니다.
     *
     * @param excelFilePath Excel 파일 경로
     */
    public void insertBbsData(String excelFilePath) {
        System.out.println("=== MyBatis 게시판 데이터 삽입 시작 ===");
        System.out.println("파일 경로: " + excelFilePath);

        int successCount = 0;
        int failCount = 0;
        int skipCount = 0;

        try (Workbook workbook = new XSSFWorkbook(new FileInputStream(excelFilePath))) {
            Sheet sheet = workbook.getSheetAt(0);

            // Excel의 각 행을 읽어서 처리
            for (Row row : sheet) {
                if (row.getRowNum() == 0) {
                    System.out.println("헤더 행 건너뛰기");
                    continue; // 헤더 건너뛰기
                }

                try {
                    // Excel에서 데이터 추출 (순서: SAKey, Writer, Content, ImageUrl)
                    // idx는 DB에서 auto increment로 자동 생성되므로 Excel에서 읽지 않음
                    String saKey = getStringCellValue(row.getCell(0)); // SAKey (첫 번째 컬럼)
                    String writer = getStringCellValue(row.getCell(1)); // Writer (두 번째 컬럼)
                    String content = getStringCellValue(row.getCell(2)); // Content (세 번째 컬럼)
                    String imageUrl = getStringCellValue(row.getCell(3)); // ImageUrl (네 번째 컬럼)

                    System.out.println("처리 중: SAKey=" + saKey + ", Writer=" + writer);

                    // null 값 체크 - 필수 필드가 null이면 건너뛰기
                    if (saKey == null || saKey.trim().isEmpty() || saKey.equals("null")) {
                        System.out.println("⚠️ SAKey가 null이므로 건너뜀");
                        skipCount++;
                        continue;
                    }

                    if (writer == null || writer.trim().isEmpty() || writer.equals("null")) {
                        System.out.println("⚠️ Writer가 null이므로 건너뜀");
                        skipCount++;
                        continue;
                    }

                    if (content == null || content.trim().isEmpty() || content.equals("null")) {
                        System.out.println("⚠️ Content가 null이므로 건너뜀");
                        skipCount++;
                        continue;
                    }

                    // 기본값 설정
                    String subject = "휴게소 리뷰"; // 기본 제목
                    String category = "Review"; // 기본 카테고리
                    String writeDate = java.time.LocalDateTime.now().toString(); // 현재 시간
                    String thumbsUp = "0"; // 기본값
                    String thumbsDown = "0"; // 기본값
                    String delete = "0"; // 기본값
                    String pwd = ""; // 기본값

                    // BbsDAO를 통해 데이터베이스에 삽입
                    int result = BbsDAO.add(subject, writer, content, imageUrl, category,
                            writeDate, thumbsUp, thumbsDown, delete, pwd);

                    if (result > 0) {
                        System.out.println("✅ 삽입 성공: SAKey=" + saKey + ", Writer=" + writer);
                        successCount++;
                    } else {
                        System.out.println("❌ 삽입 실패: SAKey=" + saKey + ", Writer=" + writer);
                        failCount++;
                    }

                } catch (Exception e) {
                    System.err.println("❌ 행 " + (row.getRowNum() + 1) + " 처리 실패: " + e.getMessage());
                    failCount++;
                }
            }

            // 결과 출력
            printResults(successCount, failCount, skipCount);

        } catch (IOException e) {
            System.err.println("Excel 파일 읽기 실패: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * 특정 게시물의 데이터를 삽입합니다.
     *
     * @param saKey    휴게소 키
     * @param writer   작성자
     * @param content  내용
     * @param imageUrl 이미지 URL
     */
    public void insertSpecificBbsData(String saKey, String writer, String content, String imageUrl) {
        try {
            // 기본값 설정
            String subject = "휴게소 리뷰";
            String category = "Review";
            String writeDate = java.time.LocalDateTime.now().toString();
            String thumbsUp = "0";
            String thumbsDown = "0";
            String delete = "0";
            String pwd = "";

            int result = BbsDAO.add(subject, writer, content, imageUrl, category,
                    writeDate, thumbsUp, thumbsDown, delete, pwd);

            if (result > 0) {
                System.out.println("✅ 게시물 삽입 성공: SAKey=" + saKey);
            } else {
                System.out.println("❌ 게시물 삽입 실패: SAKey=" + saKey);
            }

        } catch (Exception e) {
            System.err.println("MyBatis 삽입 실패: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * 게시물 정보를 조회합니다.
     *
     * @param postNum 게시물 번호
     */
    public void getBbsInfo(String postNum) {
        try {
            BbsVO bbs = BbsDAO.getPostNum(postNum);

            if (bbs != null) {
                System.out.println("=== 게시물 정보 ===");
                System.out.println("게시물 번호: " + bbs.getPostNum());
                System.out.println("휴게소 키: " + bbs.getSAKey());
                System.out.println("제목: " + bbs.getSubject());
                System.out.println("작성자: " + bbs.getWriter());
                System.out.println("내용: " + bbs.getContent());
                System.out.println("파일명: " + bbs.getFileName());
                System.out.println("카테고리: " + bbs.getCategory());
                System.out.println("작성일: " + bbs.getWriteDate());
            } else {
                System.out.println("❌ 게시물을 찾을 수 없음: " + postNum);
            }

        } catch (Exception e) {
            System.err.println("MyBatis 조회 실패: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * 모든 게시물 정보를 조회합니다.
     */
    public void getAllBbsData() {
        try {
            // 전체 게시물 수 조회
            int totalCount = BbsDAO.getTotalCount(null);
            System.out.println("=== 모든 게시물 정보 ===");
            System.out.println("총 " + totalCount + "개의 게시물이 있습니다.");

            // 최근 10개 게시물 조회 (예시)
            BbsVO[] recentBbs = BbsDAO.getList(null, null, 1, 10);

            if (recentBbs != null) {
                for (BbsVO bbs : recentBbs) {
                    System.out.println("게시물 번호: " + bbs.getPostNum() +
                            ", 휴게소 키: " + bbs.getSAKey() +
                            ", 제목: " + bbs.getSubject() +
                            ", 작성자: " + bbs.getWriter() +
                            ", 카테고리: " + bbs.getCategory());
                }
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
     * @param successCount 성공한 개수
     * @param failCount    실패한 개수
     * @param skipCount    건너뛴 개수
     */
    private void printResults(int successCount, int failCount, int skipCount) {
        System.out.println("\n=== MyBatis 게시판 데이터 삽입 결과 ===");
        System.out.println("✅ 성공: " + successCount + "개");
        System.out.println("❌ 실패: " + failCount + "개");
        System.out.println("⏭️ 건너뜀: " + skipCount + "개");
        System.out.println("📊 총 처리: " + (successCount + failCount + skipCount) + "개");

        if (successCount + failCount + skipCount > 0) {
            double successRate = (double) successCount / (successCount + failCount + skipCount) * 100;
            System.out.println("📈 성공률: " + String.format("%.1f", successRate) + "%");
        }
    }
}
