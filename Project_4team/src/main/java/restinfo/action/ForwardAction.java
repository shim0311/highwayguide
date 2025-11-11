package restinfo.action;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class ForwardAction implements Action {
    private String path;

    public ForwardAction(String path) {
        this.path = path; // 이동할 jsp경로
    }
    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) throws IOException {
        return path;
    }
}
