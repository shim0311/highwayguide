package restinfo.util;

import java.io.InputStream;
import java.util.Properties;

public class ConfigLoader {

    private static final Properties properties = new Properties();

    // 클래스가 로드될 때 한 번만 실행되어 설정 값을 읽어옴
    static {
        try (InputStream input = ConfigLoader.class.getClassLoader().getResourceAsStream("application.properties")) {
            if (input == null) {
                System.out.println("Sorry, unable to find application.properties");
            }
            properties.load(input);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 키를 주면 값을 반환하는 메소드
    public static String getProperty(String key) {
        return properties.getProperty(key);
    }
}