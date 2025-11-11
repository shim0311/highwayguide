package bbs.action;

import restinfo.action.Action;

import com.amazonaws.regions.Regions;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.GetObjectRequest;
import com.amazonaws.services.s3.model.S3Object;
import com.amazonaws.services.s3.model.S3ObjectInputStream;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class DownloadAction implements Action {

    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) throws IOException {

        // 1. 필요한 설정값 (S3 버킷 이름, 리전) 가져오기
        String bucketName = null;
        String awsRegion = null;
        Properties prop = new Properties();
        try (InputStream is = request.getServletContext().getResourceAsStream("/WEB-INF/classes/application.properties")) {
            if (is != null) {
                prop.load(is);
                bucketName = prop.getProperty("aws.s3.bucketName");
                awsRegion = prop.getProperty("aws.s3.region");
            }
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }

        // 2. 다운로드할 파일 이름 가져오기
        String fileName = request.getParameter("fileName");

        // 3. 파일 확장자를 기반으로 MIME 타입 동적 설정
        String mimeType = determineMimeType(fileName);

        // 4. HTTP 응답 헤더 설정
        response.setContentType(mimeType);
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

        // 5. S3 클라이언트 빌드
        AmazonS3 s3Client = AmazonS3ClientBuilder.standard()
                .withRegion(Regions.fromName(awsRegion))
                .build();

        S3Object s3Object = null;
        S3ObjectInputStream s3ObjectInputStream = null;
        ServletOutputStream servletOutputStream = null;

        try {
            // 6. S3에서 파일 객체 가져오기
            s3Object = s3Client.getObject(new GetObjectRequest(bucketName, fileName));
            s3ObjectInputStream = s3Object.getObjectContent();

            // 7. S3 파일 데이터를 읽어서 클라이언트(브라우저)로 전송
            servletOutputStream = response.getOutputStream();
            // **수정된 부분: 버퍼 크기를 1MB로 설정**
            byte[] buffer = new byte[1024 * 1024];
            int len;
            while ((len = s3ObjectInputStream.read(buffer)) != -1) {
                servletOutputStream.write(buffer, 0, len);
            }
            servletOutputStream.flush();

        } catch (Exception e) {
            e.printStackTrace();
            try {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "File download failed.");
            } catch (IOException ex) {
                ex.printStackTrace();
            }
        } finally {
            // 8. 사용한 리소스 정리 (스트림 닫기)
            try {
                if (servletOutputStream != null) servletOutputStream.close();
                if (s3ObjectInputStream != null) s3ObjectInputStream.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
            if (s3Object != null) s3Object.close();
        }

        return null;
    }

    /**
     * Determines the MIME type based on the file extension.
     * @param fileName The name of the file
     * @return The determined MIME type
     */
    private String determineMimeType(String fileName) {
        String mimeType = "application/octet-stream"; // default value
        if (fileName != null && fileName.contains(".")) {
            String extension = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
            switch (extension) {
                case "pdf":
                    mimeType = "application/pdf";
                    break;
                case "png":
                    mimeType = "image/png";
                    break;
                case "jpg":
                case "jpeg":
                    mimeType = "image/jpeg";
                    break;
                case "gif":
                    mimeType = "image/gif";
                    break;
                case "txt":
                    mimeType = "text/plain";
                    break;
                case "doc":
                case "docx":
                    mimeType = "application/msword";
                    break;
                case "xls":
                case "xlsx":
                    mimeType = "application/vnd.ms-excel";
                    break;
                case "ppt":
                case "pptx":
                    mimeType = "application/vnd.ms-powerpoint";
                    break;
                case "zip":
                    mimeType = "application/zip";
                    break;
                default:
                    // If the extension is not matched, keep the default
                    break;
            }
        }
        return mimeType;
    }
}