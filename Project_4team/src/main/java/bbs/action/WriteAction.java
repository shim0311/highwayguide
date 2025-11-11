package bbs.action;

import bbs.dao.BbsDAO;
import com.oreilly.servlet.MultipartRequest;
import com.oreilly.servlet.multipart.DefaultFileRenamePolicy;
import mybatis.vo.BbsVO;
import mybatis.vo.UserVO;
import restinfo.action.Action;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.util.Properties;
import java.util.UUID; // 파일명 중복 방지를 위한 UUID 추가

// S3 관련 라이브러리 추가
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.AmazonServiceException;
import com.amazonaws.SdkClientException;
import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.regions.Regions;

public class WriteAction implements Action {
    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) {

        String viewPath = null;

        String enc_type = request.getContentType();

        if (enc_type == null) {
            // GET 요청일 경우, 글쓰기 페이지로 이동
            viewPath = "/bbs/write.jsp";
        } else if (enc_type.startsWith("multipart")) {
            // POST 요청 (첨부파일 포함)일 경우, 파일 처리 및 DB 저장
            try {
                // S3 설정 정보를 application.properties 파일에서 읽어옴
                Properties prop = new Properties();
                InputStream is = getClass().getClassLoader().getResourceAsStream("application.properties");
                if (is == null) {
                    throw new IOException("application.properties 파일을 찾을 수 없습니다.");
                }
                prop.load(is);

                final String accessKey = prop.getProperty("aws.accessKeyId");
                final String secretKey = prop.getProperty("aws.secretAccessKey");
                final String bucketName = prop.getProperty("aws.s3.bucketName");
                final Regions region = Regions.fromName(prop.getProperty("aws.s3.region"));

                // 파일을 임시로 저장할 로컬 경로 설정
                ServletContext application = request.getServletContext();
                String realPath = application.getRealPath("/bbs_upload");

                File saveDir = new File(realPath);
                if (!saveDir.exists()) {
                    saveDir.mkdirs();
                }

                // MultipartRequest를 사용하여 파일 및 폼 데이터 파싱
                MultipartRequest mr = new MultipartRequest(request, realPath,
                        1024 * 1024 * 5, "utf-8",
                        new DefaultFileRenamePolicy());

                // 폼 데이터 얻기
                String subject = mr.getParameter("subject");
                String writer = mr.getParameter("writer");
                String content = mr.getParameter("content");
                String category = mr.getParameter("category");
                String writeDate = mr.getParameter("writeDate");
                String ThumbsUp = mr.getParameter("ThumbsUp");
                String ThumbsDown = mr.getParameter("ThumbsDown");
                String Delete = mr.getParameter("Delete");
                String Pwd = mr.getParameter("Pwd");
                if(Pwd == null){
                    Pwd = "";
                }

                // 파일 업로드 관련 변수
                File f = mr.getFile("file");
                String s3FileKey = null; // S3에 저장될 고유한 파일명

                if (f != null) {
                    try {
                        // S3 클라이언트 생성
                        AWSCredentials credentials = new BasicAWSCredentials(accessKey, secretKey);
                        AmazonS3 s3client = AmazonS3ClientBuilder.standard()
                                .withCredentials(new AWSStaticCredentialsProvider(credentials))
                                .withRegion(region)
                                .build();

                        // 파일명 중복을 피하기 위해 고유한 S3 Key 생성
                        String originalFileName = mr.getFilesystemName("file");
                        String fileExtension = "";
                        int dotIndex = originalFileName.lastIndexOf('.');
                        if (dotIndex > 0) {
                            fileExtension = originalFileName.substring(dotIndex);
                        }
                        s3FileKey = UUID.randomUUID().toString() + fileExtension;

                        // S3에 업로드할 요청 객체 생성
                        PutObjectRequest putObjectRequest = new PutObjectRequest(bucketName, s3FileKey, f);

                        // 파일 업로드
                        s3client.putObject(putObjectRequest);

                        // 로컬 임시 파일 삭제 (매우 중요!)
                        f.delete();

                    } catch (AmazonServiceException ase) {
                        System.err.println("S3 서비스 오류: " + ase.getMessage());
                        // S3 업로드 실패 시 예외 처리
                        throw new IOException("S3 업로드에 실패했습니다.", ase);
                    } catch (SdkClientException sce) {
                        System.err.println("S3 클라이언트 오류: " + sce.getMessage());
                        // S3 클라이언트 측 오류 발생 시 예외 처리
                        throw new IOException("S3 클라이언트 오류가 발생했습니다.", sce);
                    }
                }

                // DB에 저장할 파일명은 S3에 저장된 고유 키(s3FileKey)로 변경
                int result = BbsDAO.add(subject, writer, content, s3FileKey, category,
                        writeDate, ThumbsUp, ThumbsDown, Delete, Pwd);

                if(result > 0) {
                    // **이 부분만 수정되었습니다.**
                    if ("Faq".equals(category)) {
                        response.sendRedirect("Controller?type=faq");
                    } else {
                        response.sendRedirect("Controller?type=notice");
                    }
                } else {
                    response.setContentType("text/html;charset=utf-8");
                    PrintWriter out = response.getWriter();
                    out.println("<script>alert('게시글 등록에 실패했습니다.'); history.back();</script>");
                    out.flush();
                }

            } catch (Exception e) {
                e.printStackTrace();
                try {
                    response.setContentType("text/html; charset=UTF-8");
                    PrintWriter out = response.getWriter();
                    out.println("<script>alert('게시글 등록 중 오류가 발생했습니다.'); history.back();</script>");
                    out.flush();
                } catch (IOException ex) {
                    ex.printStackTrace();
                }
            }
            return null;
        }
        return viewPath;
    }
}