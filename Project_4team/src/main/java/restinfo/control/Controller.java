package restinfo.control;

import restinfo.action.Action;
import restinfo.action.ForwardAction;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;

@WebServlet("/Controller")
public class Controller extends HttpServlet {
    // useBodyEncodingForURI="true"*******
    // Properties파일의 경로를 저장하자!
    private String myParam = "/WEB-INF/action.properties";

    // 위의 myParam이라는 값이 action.properties의 경로를 가지고
    // 그 파일의 내용(클래스의 경로)들을 가져와서 객체로 생성한 후
    // 생성된 객체의 주소를 아래의 Map구조에 저장한다.
    private Map<String, Action> actionMap;

    public Controller() {
        actionMap = new HashMap<>();
    }

    private Properties prop;

    @Override
    public void init() throws ServletException {
        // 생성자 다음으로 딱! 한번 수행하는 함수
        // 첫 요청자에 의해 단 한번만 수행하는 곳이다.

        // 현재 서블릿이 생성될 때 멤버변수인 myParam값이 존재한다.
        // 그 myParam이 가지고 있는 값을 절대경로 만들어야 한다.
        // jsp에서는 application이라는 내장객체가 존재했지만 서블릿에서는
        // 직접 얻어내야 한다.
        ServletContext application = this.getServletContext();

        String realPath = application.getRealPath(myParam);
        // System.out.println(realPath);

        // 절대경로화 시킨 이유는
        // 해당 파일의 내용(클래스 경로)을 스트림을 이용하여
        // 읽어와서 Properties객체에 담기 위함이다.
        prop = new Properties();
        // prop.setProperty("index", "emp.action.IndexAction");
        // 위처럼 저장을 해야하지만 이렇게 하면 기능이 하나 생길때마다
        // 소스를 수정해야 하는 번거로움이 있다.

        // Properties의 load함수를 이용하여 내용들을 읽기한다. 이때 필요한
        // 객체가 InputStream이다.
        FileInputStream fis = null;
        try {
            // action.properties파일과 연결되는 스트림 준비
            fis = new FileInputStream(realPath);
            prop.load(fis);
            System.out.println("Action 설정 로드 완료: " + prop.size() + "개 액션");
        } catch (Exception e) {
            System.err.println("action.properties 로드 실패!");
            e.printStackTrace();
        }
        // 생성할 객체들의 경로가 모두 Properties객체로 저장된 상태다.
        // 하지만 현재 컨트롤러 입장에서는 생성할 객체가 몇개이며,
        // 어떤 객체인지 알지 못한다.
        // Properties에 저장된 키들을 모두 가져와서
        // 반복자(Iterator)로 수행해야 한다.
        Iterator<Object> it = prop.keySet().iterator();

        // 키들을 모두 얻었으니 키에 연결된 클래스 경로들을 하나씩
        // 얻어내어 객체를 생성한 후 actionMap에 저장한다.
        while (it.hasNext()) {
            // 먼저 키를 하나 얻어내어 문자열로 반환
            String key = (String) it.next();

            // 위에서 얻어낸 키와 연결된 값(value: 클래스 경로)을 얻어낸다.
            String value = prop.getProperty(key);// "emp.action.IndexAction"

            try {
                Object obj = null;
                //action.ForwardAction:/WEB-INF/views/forgotPw.jsp처럼 action뒤에 파일 경로명이 있을 때
                //':'기점으로 뒤에 있는 문자열(경로)을 앞의 액션에 저장시켜놓고 맵에 등록
                // 만약 properties에 ':'뒤에 다른 경로를 가진 FowardAction이 여러개 저장되어있더라도
                // it의 각 바퀴마다 다른 키값을 가진 property를 불러와 다른 목표 경로를
                // 각 객체의 생성자의 인자로 ':'뒤의 목표 경로를 던져주고 객체 단위로 맵에 저장하기 때운에
                // 같은 ForwardAction이어도 목표경로가 각자 다르기 떄문에 다른 경로로 간다
                if (value.contains(":"))
                    obj = new ForwardAction(value.split(":")[1]);
                else
                    obj = Class.forName(value).newInstance();
                actionMap.put(key, (Action) obj);
            } catch (Exception e) {
                System.err.println("Action 생성 실패: " + key + " -> " + value);
            }
        } // while의 끝
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // GET 요청은 POST로 넘겨서 모든 처리를 한 곳에서 관리
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 1. POST 요청의 한글 깨짐을 막기 위해 인코딩 설정
        request.setCharacterEncoding("UTF-8");

        // 2. type 파라미터를 받아 담당자를 찾음
        String type = request.getParameter("type");
        if (type == null)
            type = "mainpage";

        Action action = actionMap.get(type);
        System.out.println("요청 처리: " + type + " -> " + (action != null ? action.getClass().getSimpleName() : "NULL"));

        if (action == null) {
            System.out.println("ERROR: " + type + "에 해당하는 Action을 찾을 수 없습니다!");
            response.sendError(500, "Action not found: " + type);
            return;
        }

        // 3. 담당자에게 실제 작업 실행을 시킴
        String viewPath = action.execute(request, response);

        // 4. 특별한 경우 처리: KakaoMapAction에서 RestAreaAction으로 포워딩
        if ("FORWARD_TO_RESTAREA".equals(viewPath)) {
            // RestAreaAction을 실행
            Action restAreaAction = actionMap.get("restArea");
            if (restAreaAction != null) {
                viewPath = restAreaAction.execute(request, response);
            } else {
                // RestAreaAction이 없으면 에러 페이지로
                viewPath = "error.jsp";
            }
        }

        // 5. viewPath가 null이 아닐 경우에만 페이지 이동(forward)
        // (AJAX 통신은 null을 리턴하므로 이 부분은 실행되지 않음)
        if (viewPath != null) {
            RequestDispatcher disp = request.getRequestDispatcher(viewPath);
            disp.forward(request, response);
        }
    }
}
