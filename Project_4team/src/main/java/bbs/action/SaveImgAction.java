package bbs.action;

import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.google.gson.JsonObject;
import com.oreilly.servlet.MultipartRequest;
import com.oreilly.servlet.multipart.DefaultFileRenamePolicy;
import restinfo.action.Action;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.InputStream;
import java.io.PrintWriter;
import java.util.Properties; // 추가
import java.util.UUID;

public class SaveImgAction implements Action {

    // AWS 키를 담을 변수 선언
    private String accessKey;
    private String secretKey;
    private String bucketName;
    private String bucketUrl;

    // 생성자에서 properties 파일 읽어오기
    public SaveImgAction() {
        Properties prop = new Properties();
        // properties 파일 경로를 InputStream으로 읽어온다
        try (InputStream input = getClass().getClassLoader().getResourceAsStream("application.properties")) {
            if (input == null) {
                System.out.println("Sorry, unable to find application.properties");
                return;
            }
            // 프로퍼티 파일 로드
            prop.load(input);

            // 프로퍼티 값들을 변수에 할당
            this.accessKey = prop.getProperty("aws.accessKeyId");
            this.secretKey = prop.getProperty("aws.secretAccessKey");
            this.bucketName = prop.getProperty("aws.s3.bucketName");
            this.bucketUrl = prop.getProperty("aws.s3.bucketUrl");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) {
        // 이미지가 임시로 저장될 위치를 절대경로로 만들자
        ServletContext application = request.getServletContext();
        String tempPath = application.getRealPath("/temp_img");

        File tempDir = new File(tempPath);
        if (!tempDir.exists()) {
            tempDir.mkdirs();
        }

        try {
            // 파일 업로드 실행
            MultipartRequest mr = new MultipartRequest(request, tempPath,
                    1024 * 1024 * 5, "utf-8",
                    new DefaultFileRenamePolicy());

            String fname = null;
            File f = mr.getFile("upload");
            if (f != null) {
                fname = f.getName();
                String newFileName = UUID.randomUUID().toString() + "_" + fname;
                String contentType = mr.getContentType("upload");

                // AWS S3 클라이언트 생성 및 파일 업로드
                AWSCredentials credentials = new BasicAWSCredentials(this.accessKey, this.secretKey);
                AmazonS3Client s3Client = new AmazonS3Client(credentials).withRegion(Regions.AP_NORTHEAST_2);

                s3Client.putObject(new PutObjectRequest(this.bucketName, newFileName, f));
                        //.withCannedAcl(CannedAccessControlList.PublicRead));

                // 임시 파일 삭제
                f.delete();

                // ********** 직접 JSON 응답 생성 ************
                response.setContentType("application/json; charset=UTF-8");

                PrintWriter out = response.getWriter();
                JsonObject json = new JsonObject();
                json.addProperty("uploaded", 1);
                json.addProperty("fileName", newFileName);

                // 웹에서 접근 가능한 S3 URL 경로 생성
                String url = this.bucketUrl + newFileName;
                json.addProperty("url", url);

                out.print(json.toString());
                out.flush();
                out.close();
            }

        } catch (Exception e) {
            e.printStackTrace();

            try {
                response.setContentType("application/json; charset=UTF-8");
                PrintWriter out = response.getWriter();
                JsonObject json = new JsonObject();
                json.addProperty("uploaded", 0);
                JsonObject error = new JsonObject();
                error.addProperty("message", "파일 업로드 중 오류 발생: " + e.getMessage());
                json.add("error", error);
                out.print(json.toString());
                out.flush();
                out.close();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
        return null;
    }
}