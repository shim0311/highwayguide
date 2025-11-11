package mybatis.service;

import mybatis.vo.CReviewVO;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import mybatis.service.FactoryService;
import org.apache.ibatis.session.SqlSession;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class InputCrawlingDataMyBatis {

    public static void main(String[] args) {
        InputCrawlingDataMyBatis inputData = new InputCrawlingDataMyBatis();

        // Excel 파일 경로
        String excelFilePath = "/Users/tak/Code/HighWayTeamProject/work/Project_4team/review_data/휴게소_리뷰_전체_20250819_154103.xlsx";

        try {
            inputData.insertCrawlingData(excelFilePath);
        } catch (Exception e) {
            System.err.println("데이터 삽입 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Excel 파일을 읽어서 CrawlingData 테이블에 데이터를 MyBatis로 삽입합니다.
     *
     * @param excelFilePath Excel 파일 경로
     */
    public void insertCrawlingData(String excelFilePath) {
        System.out.println("=== MyBatis CrawlingData 삽입 시작 ===");
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

                    // content가 null이면 빈 문자열로 설정 (나머지 데이터는 정상 삽입)
                    if (content == null || content.trim().isEmpty() || content.equals("null")) {
                        System.out.println("⚠️ Content가 null이므로 빈 문자열로 설정하여 삽입");
                        content = "";
                    }

                    // ImageUrl이 null이면 빈 문자열로 설정
                    if (imageUrl == null || imageUrl.trim().isEmpty() || imageUrl.equals("null")) {
                        System.out.println("⚠️ ImageUrl이 null이므로 빈 문자열로 설정하여 삽입");
                        imageUrl = "";
                    }

                    // CReviewVO 객체 생성
                    CReviewVO review = new CReviewVO();
                    review.setSAKey(saKey);
                    review.setWriter(writer);
                    review.setContent(content);
                    review.setImageUrl(imageUrl);

                    // MyBatis를 통해 데이터베이스에 삽입
                    int result = insertCrawlingDataToDB(review);

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
     * MyBatis를 통해 CrawlingData 테이블에 데이터를 삽입합니다.
     *
     * @param review CReviewVO 객체
     * @return 삽입된 행 수
     */
    private int insertCrawlingDataToDB(CReviewVO review) {
        SqlSession ss = FactoryService.getFactory().openSession();
        int result = 0;

        try {
            // crawlingdata.xml의 insert 쿼리 실행
            result = ss.insert("crawlingdata.insertCrawlingData", review);

            if (result > 0) {
                ss.commit();
            } else {
                ss.rollback();
            }

        } catch (Exception e) {
            ss.rollback();
            System.err.println("DB 삽입 중 오류: " + e.getMessage());
            throw e;
        } finally {
            ss.close();
        }

        return result;
    }

    /**
     * 특정 리뷰 데이터를 삽입합니다.
     *
     * @param saKey    휴게소 키
     * @param writer   작성자
     * @param content  내용
     * @param imageUrl 이미지 URL
     */
    public void insertSpecificCrawlingData(String saKey, String writer, String content, String imageUrl) {
        try {
            // null 값들을 빈 문자열로 처리
            if (content == null || content.trim().isEmpty() || content.equals("null")) {
                System.out.println("⚠️ Content가 null이므로 빈 문자열로 설정하여 삽입");
                content = "";
            }
            if (imageUrl == null || imageUrl.trim().isEmpty() || imageUrl.equals("null")) {
                System.out.println("⚠️ ImageUrl이 null이므로 빈 문자열로 설정하여 삽입");
                imageUrl = "";
            }

            // CReviewVO 객체 생성
            CReviewVO review = new CReviewVO();
            review.setSAKey(saKey);
            review.setWriter(writer);
            review.setContent(content);
            review.setImageUrl(imageUrl);

            int result = insertCrawlingDataToDB(review);

            if (result > 0) {
                System.out.println("✅ 리뷰 데이터 삽입 성공: SAKey=" + saKey);
            } else {
                System.out.println("❌ 리뷰 데이터 삽입 실패: SAKey=" + saKey);
            }

        } catch (Exception e) {
            System.err.println("MyBatis 삽입 실패: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * 리뷰 정보를 조회합니다.
     *
     * @param idx 인덱스
     */
    public void getCrawlingDataInfo(String idx) {
        SqlSession ss = FactoryService.getFactory().openSession();

        try {
            CReviewVO review = ss.selectOne("crawlingdata.getCrawlingDataByIdx", idx);

            if (review != null) {
                System.out.println("=== 리뷰 정보 ===");
                System.out.println("인덱스: " + review.getIdx());
                System.out.println("휴게소 키: " + review.getSAKey());
                System.out.println("작성자: " + review.getWriter());
                System.out.println("내용: " + review.getContent());
                System.out.println("이미지 URL: " + review.getImageUrl());
            } else {
                System.out.println("❌ 리뷰를 찾을 수 없음: " + idx);
            }

        } catch (Exception e) {
            System.err.println("MyBatis 조회 실패: " + e.getMessage());
            e.printStackTrace();
        } finally {
            ss.close();
        }
    }

    /**
     * 모든 리뷰 정보를 조회합니다.
     */
    public void getAllCrawlingData() {
        SqlSession ss = FactoryService.getFactory().openSession();

        try {
            java.util.List<CReviewVO> reviews = ss.selectList("crawlingdata.getAllCrawlingData");

            System.out.println("=== 모든 리뷰 정보 ===");
            System.out.println("총 " + reviews.size() + "개의 리뷰가 있습니다.");

            for (CReviewVO review : reviews) {
                System.out.println("Idx: " + review.getIdx() +
                        ", SAKey: " + review.getSAKey() +
                        ", Writer: " + review.getWriter() +
                        ", Content: " + review.getContent().substring(0, Math.min(review.getContent().length(), 50))
                        + "...");
            }

        } catch (Exception e) {
            System.err.println("MyBatis 조회 실패: " + e.getMessage());
            e.printStackTrace();
        } finally {
            ss.close();
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
     * 결과를 출력합니다.
     *
     * @param successCount 성공한 개수
     * @param failCount    실패한 개수
     * @param skipCount    건너뛴 개수
     */
    private void printResults(int successCount, int failCount, int skipCount) {
        System.out.println("\n=== MyBatis CrawlingData 삽입 결과 ===");
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
