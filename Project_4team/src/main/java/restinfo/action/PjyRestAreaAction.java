package restinfo.action;

import com.google.gson.Gson;
import mybatis.vo.ServiceAreaVO;
import restinfo.dao.ServiceAreaDAO; // DAO 클래스 import 가정

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

public class PjyRestAreaAction implements Action {
    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) {
        String method = request.getMethod();
        Gson gson = new Gson();
        String json = ""; // 최종 결과를 담을 변수

        if ("GET".equalsIgnoreCase(method)) {
            // --- GET 요청 처리 (지도 영역 데이터 로드) ---
            System.out.println("GET 요청 처리 시작: loadRestAreas");

            String swLatStr = request.getParameter("swLat");
            String swLngStr = request.getParameter("swLng");
            String neLatStr = request.getParameter("neLat");
            String neLngStr = request.getParameter("neLng");

            double swLat = Double.parseDouble(swLatStr);
            double swLng = Double.parseDouble(swLngStr);
            double neLat = Double.parseDouble(neLatStr);
            double neLng = Double.parseDouble(neLngStr);

            List<ServiceAreaVO> list = ServiceAreaDAO.inBounds(swLat, swLng, neLat, neLng);
            json = gson.toJson(list); // 결과를 json 변수에 저장

        } else if ("POST".equalsIgnoreCase(method)) {
            // --- POST 요청 처리 (이름으로 검색) ---
            // ★★★ 중요: JSP의 검색 AJAX 호출 type을 'POST'로 유지
            System.out.println("POST 요청 처리 시작: searchRestArea");

            String text = request.getParameter("searchText");


            List<ServiceAreaVO> list = ServiceAreaDAO.Search(text);
            json = gson.toJson(list); // 결과를 json 변수에 저장
        }

        // --- 공통 응답 처리 ---
        // GET이든 POST든, 위에서 만들어진 json 변수의 내용을 최종적으로 한 번만 응답합니다.
        response.setContentType("application/json; charset=UTF-8");
        try (PrintWriter o = response.getWriter()) {
            o.print(json);
            o.flush();
        } catch (IOException e) {
            e.printStackTrace();
        }

        return null;
    }
}