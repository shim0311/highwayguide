# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Java/JSP web application providing information about highway rest areas and service areas in Korea. The application includes features for viewing rest area details, gas prices, menus, reviews, bookmarks, and community boards. It integrates external APIs (Kakao/Naver Maps, highway data) and uses Python scripts for web scraping.

## Commands

### Build
```bash
./mvnw clean package
```
Produces WAR file at `target/Project_4team-1.0-SNAPSHOT.war`

### Test
```bash
./mvnw test
```

### Deploy
Deploy the WAR file to Apache Tomcat's webapps directory. For development, use IDE integration (IntelliJ IDEA with Tomcat configuration).

### Python Data Collection
```bash
cd python
python getReviews.py [keywords]      # Scrape reviews from Naver Maps
python searchServiceArea.py          # Scrape service area information
```

## Architecture

### Model 2 MVC with Front Controller Pattern

```
Client Request → Controller → Action → DAO ↔ MyBatis ↔ MySQL
                                  ↓
                              JSP Views
```

**Key Components:**

1. **Controller Layer** - Single front controller servlet ([src/main/java/restinfo/control/Controller.java](src/main/java/restinfo/control/Controller.java))
   - Routes all requests via `type` parameter (e.g., `?type=login`)
   - Maps request types to Action classes using [action.properties](src/main/resources/action.properties)
   - Uses reflection to dynamically load Action instances

2. **Action Layer** - Command pattern implementation
   - All actions implement the `Action` interface
   - Located in `restinfo.action` and `bbs.action` packages
   - Each action processes business logic and returns JSP view path
   - Use `ForwardAction` for simple page forwarding without logic

3. **DAO Layer** - Static methods for database access
   - Key DAOs: `ServiceAreaDAO`, `GasDAO`, `MenuDAO`, `ReviewDAO`, `BookmarkDAO`
   - Located in `restinfo.dao` and `bbs.dao` packages

4. **MyBatis Layer**
   - `FactoryService`: Singleton SqlSessionFactory ([mybatis/service/FactoryService.java](src/main/java/mybatis/service/FactoryService.java))
   - Configuration: `mybatis/config/conf.xml` (gitignored - contains DB credentials)
   - Mappers: XML files in [src/main/resources/mybatis/mapper/](src/main/resources/mybatis/mapper/)
   - Value Objects: `*VO.java` classes in `mybatis.vo` package

5. **Scheduled Jobs** - Quartz Scheduler
   - Initialized by `QuartzSchedulerListener` in [web.xml](src/main/webapp/WEB-INF/web.xml)
   - `GasPriceUpdateJob`: Automated gas price updates from external API

## Request Routing

All HTTP requests go through the front controller with pattern:
```
/Controller?type=<action_name>&<other_params>
```

The `type` parameter maps to Action classes via [action.properties](src/main/resources/action.properties):
```properties
login=restinfo.action.LoginAction
kakaoMap=restinfo.action.KakaoMapAction
```

## Database Access Pattern

Always use this pattern for MyBatis operations:
```java
SqlSession ss = FactoryService.getFactory().openSession();
try {
    // Query/update operations
    ss.commit();
} catch (Exception e) {
    ss.rollback();
} finally {
    ss.close();
}
```

## Adding New Features

### 1. Create a New Action
- Implement the `Action` interface in `restinfo.action` or `bbs.action`
- Add mapping to [action.properties](src/main/resources/action.properties)
- Return JSP path from `execute()` method

### 2. Create a New DAO
- Add static methods in appropriate DAO class or create new one
- Use MyBatis mapper for queries
- Follow existing naming conventions: `*DAO.java`

### 3. Create a MyBatis Mapper
- Add XML mapper in [src/main/resources/mybatis/mapper/](src/main/resources/mybatis/mapper/)
- Register in [conf.xml](src/main/resources/mybatis/config/conf.xml) (if not using auto-discovery)
- Create corresponding VO in `mybatis.vo` package

### 4. Add Scheduled Job
- Create class implementing Quartz `Job` interface
- Configure trigger in `QuartzSchedulerListener`
- Jobs run within servlet context lifecycle

## External Integrations

- **Kakao Map API**: Used for map display and location services
- **Naver Map API**: Alternative map provider and OAuth login
- **Expressway Data API**: Real-time highway and rest area information
- **AWS S3**: Image upload and storage
- **CCTV Integration**: Highway camera feeds

## Important Files

- [Controller.java](src/main/java/restinfo/control/Controller.java) - Front controller
- [action.properties](src/main/resources/action.properties) - Request-to-Action mapping
- [FactoryService.java](src/main/java/mybatis/service/FactoryService.java) - MyBatis session factory
- [web.xml](src/main/webapp/WEB-INF/web.xml) - Servlet configuration, CORS filter, Quartz listener
- [pom.xml](pom.xml) - Maven dependencies

## Special Features

### Fuzzy Matching for Service Areas
`ServiceAreaDAO` implements 5-stage fuzzy matching strategy for rest area name searches, handling common misspellings and variations.

### Password Security
Uses jBCrypt for password hashing. Never store plain text passwords.

### Excel Data Processing
Apache POI is available for import/export operations (e.g., loading service area data from Excel).

## Configuration Files

These files contain sensitive data and are gitignored:
- `src/main/resources/mybatis/config/conf.xml` - Database credentials
- `src/main/resources/application.properties` - API keys

Create these files based on example templates before running the application.

## Naming Conventions

- Actions: `*Action.java` (e.g., `LoginAction`, `KakaoMapAction`)
- DAOs: `*DAO.java` (e.g., `ServiceAreaDAO`, `GasDAO`)
- VOs: `*VO.java` (e.g., `ServiceAreaVO`, `UserVO`)
- MyBatis Mappers: `*.xml` matching DAO name

## Code Comments

Many comments and variable names are in Korean. This is intentional for the Korean development team.
