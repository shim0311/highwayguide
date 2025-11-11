package restinfo;

import org.quartz.*;
import org.quartz.impl.StdSchedulerFactory;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

@WebListener
public class QuartzSchedulerListener implements ServletContextListener {

    private Scheduler scheduler;

    // 웹 애플리케이션(Tomcat)이 시작될 때 딱 한 번 호출되는 메서드
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try {
            // --- 1. Job(직원)에게 업무 지시서(JobDetail)를 줍니다. ---
            JobDetail job = JobBuilder.newJob(GasPriceUpdateJob.class) // GasPriceUpdateJob 클래스를 실행
                    .withIdentity("gasPriceUpdateJob", "group1") // Job의 이름과 그룹 설정
                    .build();

            // --- 2. Trigger(알람 시계)를 설정합니다. ---
            // Cron 표현식을 사용하여 "매일 새벽 2시 정각에 실행"하도록 설정
            Trigger trigger = TriggerBuilder.newTrigger()
                    .withIdentity("dailyTrigger", "group1") // Trigger의 이름과 그룹 설정
                    .startNow() // 서버 시작 시 즉시 스케줄 시작
                    // *********** 주기 설정하려면 .withSchedule에서 원하는 시간으로 수정하면됨 *********
                        // 설정하고 나면 .startNow()는 주석처리할것!!!
                    //.withSchedule(CronScheduleBuilder.cronSchedule("0 0 2 * * ?")) // 매일 02:00:00에 실행
                    .build();

            // --- 3. Scheduler(사장님)가 Job과 Trigger를 받아 스케줄링을 시작합니다. ---
            SchedulerFactory factory = new StdSchedulerFactory();
            scheduler = factory.getScheduler();
            scheduler.start();
            scheduler.scheduleJob(job, trigger); // Job과 Trigger 등록

            System.out.println(">>> [Quartz] 스케줄러가 성공적으로 시작되고, 작업이 등록되었습니다.");

        } catch (SchedulerException e) {
            e.printStackTrace();
        }
    }

    // 웹 애플리케이션이 종료될 때 호출되는 메서드
    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        try {
            if (scheduler != null) {
                scheduler.shutdown(); // 스케줄러를 안전하게 종료
                System.out.println(">>> [Quartz] 스케줄러가 종료되었습니다.");
            }
        } catch (SchedulerException e) {
            e.printStackTrace();
        }
    }
}
