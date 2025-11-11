# 🚗 고속도로 휴게소 정보 서비스 - 완전한 가이드

전국 고속도로 휴게소의 실시간 정보(시설, 메뉴, 주유가격, 리뷰)를 제공하는 웹 애플리케이션의 모든 것을 담은 올인원 가이드입니다.

![Java](https://img.shields.io/badge/Java-11-007396?style=flat-square&logo=java)
![Spring](https://img.shields.io/badge/Framework-JSP%2FServlet-6DB33F?style=flat-square)
![MySQL](https://img.shields.io/badge/Database-MySQL-4479A1?style=flat-square&logo=mysql)
![AWS](https://img.shields.io/badge/Cloud-AWS-232F3E?style=flat-square&logo=amazon-aws)

---

## 📋 목차

1. [프로젝트 개요](#1-프로젝트-개요)
2. [빠른 시작 - 로컬 환경](#2-빠른-시작---로컬-환경)
3. [AWS 서버 배포](#3-aws-서버-배포)
4. [GitHub Actions CI/CD 설정](#4-github-actions-cicd-설정)
5. [데이터베이스 설정](#5-데이터베이스-설정)
6. [프로젝트 아키텍처](#6-프로젝트-아키텍처)
7. [개발 가이드](#7-개발-가이드)
8. [문제 해결](#8-문제-해결)
9. [보안 가이드](#9-보안-가이드)

---

# 1. 프로젝트 개요

## 🎯 주요 기능

### 🗺️ 경로 기반 휴게소 검색
- 출발지-도착지 입력 시 경로상 휴게소 자동 추천
- 카카오맵/네이버맵 API 통합
- 상행/하행 방향 자동 계산

### ⛽ 실시간 주유 가격 정보
- Quartz Scheduler를 통한 자동 업데이트
- 휘발유/경유/LPG 가격 제공

### 🍽️ 휴게소 상세 정보
- 메뉴, 편의시설, 주차 정보
- 사용자 리뷰 및 평점
- AI 생성 코멘트

### 📹 고속도로 CCTV
- 실시간 CCTV 영상 제공

### 👤 사용자 기능
- 소셜 로그인 (카카오/네이버)
- 북마크 즐겨찾기
- 비밀번호 찾기 (이메일 인증)

## 🛠️ 기술 스택

### Backend
- **Language**: Java 11
- **Framework**: JSP/Servlet 4.0 (MVC Pattern)
- **ORM**: MyBatis 3.5
- **Database**: MySQL 8.0
- **Server**: Apache Tomcat 9

### Frontend
- **Template**: JSP/JSTL
- **JavaScript**: Vanilla JS, AJAX
- **CSS**: CSS3 (Grid, Flexbox)
- **UI**: Font Awesome, CKEditor

### DevOps
- **CI/CD**: GitHub Actions
- **Cloud**: AWS EC2, RDS, S3
- **Scheduler**: Quartz

### Data Collection
- **Language**: Python 3
- **Framework**: Selenium WebDriver
- **Data Processing**: Pandas

### External APIs
- 카카오맵 API / 네이버맵 API
- 고속도로 공공데이터 API
- AWS S3 (이미지 저장)

## 📁 프로젝트 구조

```
Project_4team/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   ├── restinfo/
│   │   │   │   ├── action/       # MVC Action Layer
│   │   │   │   ├── control/      # Front Controller
│   │   │   │   ├── dao/          # Data Access Objects
│   │   │   │   └── util/         # Utilities (ConfigLoader)
│   │   │   ├── mybatis/
│   │   │   │   ├── service/      # MyBatis Factory
│   │   │   │   └── vo/           # Value Objects
│   │   │   └── bbs/              # Board (BBS) Module
│   │   ├── resources/
│   │   │   ├── mybatis/
│   │   │   │   ├── config/       # conf.xml (gitignored)
│   │   │   │   └── mapper/       # SQL Mappers
│   │   │   ├── application.properties (gitignored)
│   │   │   └── Db.sql            # Database Schema
│   │   └── webapp/
│   │       ├── WEB-INF/
│   │       │   ├── web.xml
│   │       │   └── action.properties
│   │       ├── css/, js/
│   │       └── *.jsp             # JSP Views
├── python/                       # Web Crawlers
│   ├── getReviews.py
│   ├── searchServiceArea.py
│   ├── .env (gitignored)
│   └── requirements.txt
├── .github/workflows/
│   └── deploy.yml                # GitHub Actions
├── docs/                         # Documentation
├── deploy.sh                     # Deployment Script
├── server-setup.sh               # Server Setup Script
├── setup-database.sh             # Database Setup Script
├── setup-new-git.sh              # Git Migration Script
├── generate-secrets-template.sh  # Secrets Helper Script
└── pom.xml                       # Maven Configuration
```

---

# 2. 빠른 시작 - 로컬 환경

## 1️⃣ 사전 준비

필수 소프트웨어 설치:

```bash
# macOS
brew install openjdk@11 maven mysql

# Ubuntu
sudo apt install openjdk-11-jdk maven mysql-server

# Windows
# - JDK 11: https://adoptopenjdk.net/
# - Maven: https://maven.apache.org/download.cgi
# - MySQL: https://dev.mysql.com/downloads/installer/
```

## 2️⃣ MySQL 설정

```bash
# MySQL 시작
brew services start mysql  # macOS
sudo systemctl start mysql  # Ubuntu

# 데이터베이스 생성
mysql -u root -p
```

```sql
CREATE DATABASE my_app_db
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- SQL 파일 실행 (있는 경우)
SOURCE src/main/resources/Db.sql;

-- 확인
SHOW TABLES;
EXIT;
```

## 3️⃣ 환경변수 설정

### Java 설정

```bash
# 템플릿 복사
cp application.properties.example src/main/resources/application.properties

# 편집
vim src/main/resources/application.properties
```

**최소 설정** (로컬 테스트용):

```properties
# DB 설정 (필수!)
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://localhost:3306/my_app_db?useSSL=false&serverTimezone=Asia/Seoul
db.username=root
db.password=YOUR_MYSQL_PASSWORD

# 서버 설정
server.domain=localhost
server.port=8080
server.context=/Project_4team_war_exploded

# OAuth Redirect URI
oauth.redirect.base=http://${server.domain}:${server.port}${server.context}

# API 키들 (나중에 설정 가능)
KAKAO_API_KEY=your-key-here
NAVER_CLIENT_ID=your-id-here
NAVER_CLIENT_SECRET=your-secret-here
```

### MyBatis 설정

`conf.xml` 템플릿 생성:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE configuration PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
"http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
  <properties resource="application.properties"/>
  <environments default="development">
    <environment id="development">
      <transactionManager type="JDBC"/>
      <dataSource type="POOLED">
        <property name="driver" value="${db.driver}"/>
        <property name="url" value="${db.url}"/>
        <property name="username" value="${db.username}"/>
        <property name="password" value="${db.password}"/>
      </dataSource>
    </environment>
  </environments>
  <mappers>
    <mapper resource="mybatis/mapper/serviceArea.xml"/>
    <mapper resource="mybatis/mapper/gas.xml"/>
    <mapper resource="mybatis/mapper/menu.xml"/>
    <mapper resource="mybatis/mapper/login.xml"/>
    <mapper resource="mybatis/mapper/signUp.xml"/>
    <mapper resource="mybatis/mapper/bookmark.xml"/>
    <mapper resource="mybatis/mapper/shop.xml"/>
    <mapper resource="mybatis/mapper/bbs.xml"/>
    <mapper resource="mybatis/mapper/likeHate.xml"/>
    <mapper resource="mybatis/mapper/user.xml"/>
    <mapper resource="mybatis/mapper/crawlingdata.xml"/>
  </mappers>
</configuration>
```

### Python 설정 (크롤러 사용 시)

```bash
cp python/.env.example python/.env
vim python/.env
```

```bash
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=YOUR_MYSQL_PASSWORD
DB_NAME=my_app_db
DB_CHARSET=utf8
```

## 4️⃣ 연결 테스트

```bash
# Python 테스트
cd python
pip3 install python-dotenv mysql-connector-python
python3 test_db.py
```

성공하면 ✅ 표시가 나옵니다!

## 5️⃣ 애플리케이션 실행

```bash
# 빌드
./mvnw clean package

# IntelliJ IDEA에서 실행
# 1. Run → Edit Configurations
# 2. + → Tomcat Server → Local
# 3. Deployment 탭 → + → Artifact → Project_4team:war exploded
# 4. Application context: /Project_4team_war_exploded
# 5. Run!
```

## 6️⃣ 접속 확인

```
http://localhost:8080/Project_4team_war_exploded
```

---

# 3. AWS 서버 배포

## 1️⃣ 서버 접속

```bash
ssh -i your-key.pem ubuntu@your-ec2-ip
```

## 2️⃣ 프로젝트 클론

```bash
cd ~
git clone https://github.com/shim0311/highwayguide.git
cd highwayguide/Project_4team
```

## 3️⃣ 서버 초기 설정 (최초 1회만)

```bash
sudo bash server-setup.sh
```

이 스크립트는 다음을 설치합니다:
- Java 11
- Maven
- Tomcat 9
- Python 3 & pip
- Google Chrome & ChromeDriver

**MySQL 설치 옵션**:
- 스크립트 실행 시 "MySQL을 이 서버에 설치하시겠습니까?" 질문이 나옵니다
- **y** 입력 → MySQL을 EC2에 직접 설치 (RDS 불필요, 비용 절감!)
- **n** 입력 → MySQL 건너뛰기 (RDS 또는 외부 DB 사용)

### MySQL 직접 설치한 경우 추가 작업

```bash
# 1. MySQL 보안 설정
sudo mysql_secure_installation
# → root 비밀번호 설정 (강력하게!)
# → 익명 사용자 제거: Y
# → root 원격 로그인 차단: Y
# → 테스트 DB 제거: Y

# 2. 데이터베이스 생성
sudo mysql
```

```sql
CREATE DATABASE my_app_db
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE USER 'restinfo_user'@'localhost' IDENTIFIED BY 'StrongPassword123!';
GRANT ALL PRIVILEGES ON my_app_db.* TO 'restinfo_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

```bash
# 3. 테이블 스키마 생성 (자동)
bash setup-database.sh local
# → MySQL root 비밀번호 입력
# → 자동으로 테이블 생성 완료!
```

## 4️⃣ 환경변수 설정

```bash
# Java 설정
cp application.properties.example src/main/resources/application.properties
vim src/main/resources/application.properties
```

**운영 환경 설정** (EC2 MySQL 사용):

```properties
# DB 설정 (localhost)
db.url=jdbc:mysql://localhost:3306/my_app_db?useSSL=false&serverTimezone=Asia/Seoul
db.username=restinfo_user
db.password=StrongPassword123!

# 서버 설정
server.domain=your-ec2-public-ip
server.port=80
server.context=

# API 키들
KAKAO_API_KEY=your-kakao-api-key
NAVER_CLIENT_ID=your-naver-id
NAVER_CLIENT_SECRET=your-naver-secret
EXPRESSWAY_ID=your-expressway-key
TMAP_APPKEY=your-tmap-key

# AWS S3
aws.accessKeyId=your-aws-access-key-id
aws.secretAccessKey=your-aws-secret-access-key
aws.s3.bucketName=your-bucket-name
aws.s3.bucketUrl=https://your-bucket-name.s3.ap-northeast-2.amazonaws.com/

# Google Mail (비밀번호 찾기)
GOOGLE_SENDER_MAIL=your-email@gmail.com
GOOGLE_APPLICATION_PASSWORD=your-16-char-app-password
```

**Python 설정** (크롤러 사용 시):

```bash
cp python/.env.example python/.env
vim python/.env
```

## 5️⃣ 배포

```bash
bash deploy.sh
```

자동으로:
- Maven 빌드
- WAR 파일 생성
- Tomcat 재시작

## 6️⃣ 접속 확인

```
http://your-ec2-ip
```

---

# 4. GitHub Actions CI/CD 설정

## 1️⃣ GitHub 저장소 생성

1. https://github.com/new 접속
2. Repository name 입력
3. Public 또는 Private 선택
4. **❌ Initialize with README 체크 해제** (중요!)
5. Create repository 클릭

## 2️⃣ Git 재설정

```bash
# 기존 remote 제거 및 새 저장소 연결
bash setup-new-git.sh
# → 새 레포지토리 URL 입력
# → 자동으로 푸시 완료
```

## 3️⃣ GitHub Secrets 설정

### Secrets 페이지 접속

```
https://github.com/[username]/[repo]/settings/secrets/actions
Settings → Secrets and variables → Actions → New repository secret
```

### 🚀 간편 설정 방법

```bash
# application.properties 파일이 있다면
bash generate-secrets-template.sh

# github-secrets-values.txt 파일 생성됨
cat github-secrets-values.txt

# → 각 값을 복사해서 GitHub Secrets에 붙여넣기
```

### ✅ 설정할 Secrets (총 22개)

#### 데이터베이스 (3개)
```
DB_URL=jdbc:mysql://localhost:3306/my_app_db?useSSL=false&serverTimezone=Asia/Seoul
DB_USERNAME=restinfo_user
DB_PASSWORD=[강력한 비밀번호]
```

#### Google Mail (2개)
```
GOOGLE_SENDER_MAIL=[Gmail 주소]
GOOGLE_APPLICATION_PASSWORD=[Gmail 앱 비밀번호 16자]
```
📌 생성: https://myaccount.google.com/apppasswords

#### Naver OAuth (2개)
```
NAVER_CLIENT_ID=[Naver Client ID]
NAVER_CLIENT_SECRET=[Naver Client Secret]
```
📌 발급: https://developers.naver.com/apps

#### Kakao (2개)
```
KAKAO_CLIENT_ID=[Kakao 앱 키]
KAKAO_API_KEY=[Kakao REST API 키]
```
📌 발급: https://developers.kakao.com/

#### 고속도로 공공데이터 (1개)
```
EXPRESSWAY_ID=[고속도로 API 키]
```
📌 발급: https://data.ex.co.kr/

#### TMap (1개)
```
TMAP_APPKEY=[TMap API 키]
```
📌 발급: https://tmapapi.sktelecom.com/

#### AWS S3 (4개)
```
AWS_ACCESS_KEY_ID=[AWS Access Key]
AWS_SECRET_ACCESS_KEY=[AWS Secret Key]
AWS_S3_BUCKET_NAME=[S3 버킷 이름]
AWS_S3_BUCKET_URL=https://[버킷이름].s3.ap-northeast-2.amazonaws.com/
```
📌 발급: AWS IAM Console

#### 서버 설정 (3개)
```
SERVER_DOMAIN=[EC2 IP 또는 도메인]
SERVER_PORT=80
SERVER_CONTEXT=(비워두기)
```

#### EC2 배포 (4개)
```
EC2_HOST=[EC2 퍼블릭 IP]
EC2_USERNAME=ubuntu
EC2_SSH_KEY=[PEM 파일 전체 내용]
EC2_TARGET_PATH=/home/ubuntu/Project_4team
```

**EC2_SSH_KEY 설정 방법:**
```bash
cat your-key.pem
# -----BEGIN RSA PRIVATE KEY-----부터
# -----END RSA PRIVATE KEY-----까지 전체 복사
```

## 4️⃣ 자동 배포 테스트

```bash
# dev 브랜치에 push
git push origin dev

# GitHub Actions 실행 확인
# https://github.com/[username]/[repo]/actions
```

워크플로우가 자동으로:
1. ✅ JDK 11 설치
2. ✅ application.properties 생성 (Secrets로부터)
3. ✅ conf.xml 생성
4. ✅ Maven 빌드 (mvn clean package)
5. ✅ WAR 파일 생성 확인
6. ✅ EC2로 WAR 파일 전송 (SCP)
7. ✅ Tomcat 재시작
8. ✅ 배포 완료!

## 5️⃣ 배포 확인

```
http://[EC2_IP]
```

---

# 5. 데이터베이스 설정

## MySQL 설치 옵션

### Option A: EC2에 직접 설치 (비용 절감)

**장점**: RDS 비용 없음, 완전한 제어
**단점**: 백업/관리 직접 수행 필요

```bash
# server-setup.sh 실행 시 y 선택
sudo bash server-setup.sh
# → MySQL을 이 서버에 설치하시겠습니까? y

# 보안 설정
sudo mysql_secure_installation

# 데이터베이스 생성
sudo mysql
CREATE DATABASE my_app_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'restinfo_user'@'localhost' IDENTIFIED BY 'StrongPassword123!';
GRANT ALL PRIVILEGES ON my_app_db.* TO 'restinfo_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# 테이블 생성 (자동)
bash setup-database.sh local
```

### Option B: AWS RDS 사용

**장점**: 자동 백업, Multi-AZ, 관리 간편
**단점**: 추가 비용 발생

```bash
# RDS 인스턴스 생성 (AWS Console)
# → MySQL 8.0
# → db.t3.micro (Free Tier)
# → Public access: Yes (또는 VPC Peering)

# application.properties
db.url=jdbc:mysql://your-rds-endpoint:3306/my_app_db?useSSL=true
db.username=admin
db.password=your-rds-password
```

## 데이터베이스 스키마

`Db.sql` 파일에는 다음 테이블들이 정의되어 있습니다:

1. **User** - 사용자 정보
2. **ServiceArea** - 휴게소 정보
3. **Gas** - 주유 가격 정보
4. **Menu** - 휴게소 메뉴
5. **CrawlingData** - 크롤링 데이터
6. **BookMark** - 북마크
7. **Board** - 게시판
8. **Shop** - 상점 정보
9. **LikeHate** - 좋아요/싫어요
10. **Visit** - 방문 기록
11. **HighWay** - 고속도로 정보
12. **RestArea** - 휴게소 기본 정보
13. **History** - 이력

## SQL 파일 전송 및 실행

### 방법 1: 자동 스크립트 (가장 간단!)

```bash
# 로컬에서 원격 서버로
bash setup-database.sh <EC2-IP> <PEM-KEY>

# 서버에서 직접
bash setup-database.sh local
```

### 방법 2: SCP + 수동 실행

```bash
# 파일 전송
scp -i your-key.pem src/main/resources/Db.sql ubuntu@your-ec2-ip:~/

# 서버에서 실행
ssh -i your-key.pem ubuntu@your-ec2-ip
mysql -u root -p my_app_db < ~/Db.sql
```

## 데이터베이스 확인

```sql
mysql -u root -p

USE my_app_db;
SHOW TABLES;
DESCRIBE ServiceArea;

-- 테이블 개수 확인
SELECT COUNT(*) AS table_count
FROM information_schema.tables
WHERE table_schema = 'my_app_db';
```

## 백업 설정 (EC2 MySQL 사용 시)

```bash
# 수동 백업
mysqldump -u root -p my_app_db > backup_$(date +%Y%m%d).sql

# 압축 백업
mysqldump -u root -p my_app_db | gzip > backup_$(date +%Y%m%d).sql.gz

# Cron 자동 백업 (매일 새벽 2시)
crontab -e
0 2 * * * mysqldump -u root -pYOUR_PASSWORD my_app_db | gzip > /home/ubuntu/backups/backup_$(date +\%Y\%m\%d).sql.gz
```

---

# 6. 프로젝트 아키텍처

## Model 2 MVC with Front Controller Pattern

```
Client Request → Controller → Action → DAO ↔ MyBatis ↔ MySQL
                                  ↓
                              JSP Views
```

## 핵심 컴포넌트

### 1. Controller Layer
**파일**: `src/main/java/restinfo/control/Controller.java`

- 단일 Front Controller Servlet
- 모든 요청을 `type` 파라미터로 라우팅 (예: `?type=login`)
- `action.properties`를 통해 type → Action 매핑
- Reflection을 사용한 동적 Action 로딩

**요청 패턴**:
```
/Controller?type=<action_name>&<other_params>
```

**action.properties 예시**:
```properties
login=restinfo.action.LoginAction
kakaoMap=restinfo.action.KaKaoMapV2
restArea=restinfo.action.RestAreaAction
```

### 2. Action Layer
**위치**: `restinfo.action`, `bbs.action` 패키지

- Command Pattern 구현
- 모든 Action은 `Action` 인터페이스 구현
- `execute()` 메소드에서 비즈니스 로직 처리 후 JSP 경로 반환

**Action 인터페이스**:
```java
public interface Action {
    String execute(HttpServletRequest request, HttpServletResponse response);
}
```

**ForwardAction**: 단순 페이지 이동용 (로직 없음)

### 3. DAO Layer
**위치**: `restinfo.dao`, `bbs.dao` 패키지

- Static 메소드로 데이터베이스 접근
- 주요 DAO: `ServiceAreaDAO`, `GasDAO`, `MenuDAO`, `ReviewDAO`, `BookmarkDAO`

**MyBatis 사용 패턴**:
```java
SqlSession ss = FactoryService.getFactory().openSession();
try {
    // Query/update operations
    List<ServiceAreaVO> list = ss.selectList("serviceArea.getList");
    ss.commit();
} catch (Exception e) {
    ss.rollback();
} finally {
    ss.close();
}
```

### 4. MyBatis Layer

**FactoryService**: Singleton SqlSessionFactory
- 파일: `mybatis/service/FactoryService.java`
- 설정: `mybatis/config/conf.xml`
- Mapper: `src/main/resources/mybatis/mapper/*.xml`
- VO: `mybatis.vo` 패키지

**conf.xml 구조**:
```xml
<configuration>
  <properties resource="application.properties"/>
  <environments default="development">
    <environment id="development">
      <transactionManager type="JDBC"/>
      <dataSource type="POOLED">
        <property name="driver" value="${db.driver}"/>
        <property name="url" value="${db.url}"/>
        <property name="username" value="${db.username}"/>
        <property name="password" value="${db.password}"/>
      </dataSource>
    </environment>
  </environments>
  <mappers>
    <mapper resource="mybatis/mapper/serviceArea.xml"/>
    <!-- 다른 mapper들... -->
  </mappers>
</configuration>
```

### 5. Scheduled Jobs

**Quartz Scheduler**:
- 초기화: `QuartzSchedulerListener` (web.xml 등록)
- 작업: `GasPriceUpdateJob` - 주유 가격 자동 업데이트

## 주요 기능 구현

### 1. 소셜 로그인 (OAuth 2.0)

**Kakao**:
1. `KakaoCallbackAction`: 인가 코드 수신
2. Access Token 요청
3. 사용자 정보 조회
4. 세션 생성

**Naver**:
1. `NaverCallbackAction`: 인가 코드 수신
2. Access Token 요청
3. 사용자 정보 조회
4. 세션 생성

### 2. 비밀번호 찾기

1. `ForgotPasswordAction`: 이메일 입력
2. `EmailSendAction`: 인증 코드 발송 (Gmail SMTP)
3. `EmailConfirmAction`: 코드 확인
4. 비밀번호 재설정

### 3. 경로 기반 휴게소 검색

1. `KaKaoMapV2`: Kakao Mobility API 호출
2. 2단계 API 요청:
   - 1단계: 경로 좌표 리스트 획득
   - 2단계: 경로 요약 정보 (거리, 시간)
3. 방향 계산 (상행/하행)
4. 경로상 휴게소 필터링

### 4. 실시간 주유 가격

1. `GasPriceUpdateJob`: Quartz로 정기 실행
2. 고속도로 공공데이터 API 호출
3. `GetGasPriceAction`: 최신 가격 조회

### 5. 리뷰 크롤링

**Python Selenium**:
- `getReviews.py`: 네이버 지도 리뷰 크롤링
- `searchServiceArea.py`: 휴게소 정보 크롤링
- Headless Chrome으로 동적 페이지 처리

### 6. 이미지 업로드

**AWS S3**:
- `SaveImgAction`: 파일 업로드
- CKEditor에서 이미지 삽입

---

# 7. 개발 가이드

## 새 기능 추가하기

### 1. 새 Action 만들기

```java
package restinfo.action;

import javax.servlet.http.*;

public class MyNewAction implements Action {
    @Override
    public String execute(HttpServletRequest request, HttpServletResponse response) {
        // 1. 파라미터 추출
        String param = request.getParameter("param");

        // 2. 비즈니스 로직
        MyDAO dao = new MyDAO();
        List<MyVO> list = dao.getList(param);

        // 3. request에 데이터 저장
        request.setAttribute("list", list);

        // 4. JSP 경로 반환
        return "myPage.jsp";
    }
}
```

**action.properties에 등록**:
```properties
myNew=restinfo.action.MyNewAction
```

**호출**:
```
/Controller?type=myNew&param=value
```

### 2. 새 DAO 만들기

```java
package restinfo.dao;

import mybatis.service.FactoryService;
import mybatis.vo.MyVO;
import org.apache.ibatis.session.SqlSession;
import java.util.List;

public class MyDAO {

    public static List<MyVO> getList(String param) {
        SqlSession ss = FactoryService.getFactory().openSession();
        List<MyVO> list = null;
        try {
            list = ss.selectList("myMapper.getList", param);
        } finally {
            ss.close();
        }
        return list;
    }

    public static int insert(MyVO vo) {
        SqlSession ss = FactoryService.getFactory().openSession();
        int result = 0;
        try {
            result = ss.insert("myMapper.insert", vo);
            ss.commit();
        } catch (Exception e) {
            ss.rollback();
        } finally {
            ss.close();
        }
        return result;
    }
}
```

### 3. MyBatis Mapper 만들기

**파일**: `src/main/resources/mybatis/mapper/myMapper.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
"http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="myMapper">

    <select id="getList" parameterType="String" resultType="mybatis.vo.MyVO">
        SELECT * FROM my_table
        WHERE column = #{param}
    </select>

    <insert id="insert" parameterType="mybatis.vo.MyVO">
        INSERT INTO my_table (col1, col2)
        VALUES (#{col1}, #{col2})
    </insert>

</mapper>
```

**conf.xml에 등록**:
```xml
<mapper resource="mybatis/mapper/myMapper.xml"/>
```

### 4. VO (Value Object) 만들기

```java
package mybatis.vo;

public class MyVO {
    private int id;
    private String col1;
    private String col2;

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getCol1() { return col1; }
    public void setCol1(String col1) { this.col1 = col1; }

    public String getCol2() { return col2; }
    public void setCol2(String col2) { this.col2 = col2; }
}
```

### 5. JSP 뷰 만들기

```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Page</title>
</head>
<body>
    <h1>My Data</h1>
    <c:forEach var="item" items="${list}">
        <div>${item.col1} - ${item.col2}</div>
    </c:forEach>
</body>
</html>
```

## 환경변수 사용하기

### Java에서 ConfigLoader 사용

```java
import restinfo.util.ConfigLoader;

String apiKey = ConfigLoader.getProperty("KAKAO_API_KEY");
String dbUrl = ConfigLoader.getProperty("db.url");
```

### Python에서 .env 사용

```python
import os
from dotenv import load_dotenv

load_dotenv()

db_host = os.getenv("DB_HOST")
db_user = os.getenv("DB_USER")
```

## 빌드 및 테스트

```bash
# 빌드
./mvnw clean package

# 테스트
./mvnw test

# 특정 테스트만 실행
./mvnw test -Dtest=MyTest

# 배포 (로컬)
# WAR 파일을 Tomcat webapps에 복사

# 배포 (AWS)
bash deploy.sh
```

---

# 8. 문제 해결

## MySQL 관련

### "Access denied" 오류

```bash
# root 비밀번호 재설정
sudo mysql
ALTER USER 'root'@'localhost' IDENTIFIED BY 'NewPassword123!';
FLUSH PRIVILEGES;
EXIT;
```

### "Can't connect to MySQL server" 오류

```bash
# MySQL 상태 확인
sudo systemctl status mysql

# MySQL 재시작
sudo systemctl restart mysql

# 포트 확인
sudo netstat -tulpn | grep 3306
```

### 데이터베이스 없음

```sql
CREATE DATABASE my_app_db
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
```

## Tomcat 관련

### Tomcat 시작 실패

```bash
# 상태 확인
sudo systemctl status tomcat9

# 로그 확인
sudo tail -f /var/lib/tomcat9/logs/catalina.out

# 재시작
sudo systemctl restart tomcat9
```

### 포트 이미 사용 중

```bash
# 8080 포트 사용 프로세스 확인
sudo lsof -i :8080

# 프로세스 종료
sudo kill -9 <PID>
```

### 메모리 부족

```bash
# Tomcat 메모리 설정
sudo vim /etc/default/tomcat9

# 추가
JAVA_OPTS="-Xms512m -Xmx1024m"

# 재시작
sudo systemctl restart tomcat9
```

## 빌드 오류

### "ClassNotFoundException"

```bash
# 의존성 다시 다운로드
./mvnw clean install -U

# Maven 캐시 삭제
rm -rf ~/.m2/repository
./mvnw clean package
```

### "BUILD FAILURE"

```bash
# 상세 로그 확인
./mvnw clean package -X

# 특정 테스트 건너뛰기
./mvnw clean package -DskipTests
```

## GitHub Actions 오류

### "Permission denied (publickey)"

**해결**: `EC2_SSH_KEY` Secret 확인
- PEM 키 파일 전체 내용 포함 여부
- BEGIN/END 라인 포함 여부

```bash
# PEM 키 확인
cat your-key.pem
# 전체 내용을 EC2_SSH_KEY에 복사
```

### "Error: Process completed with exit code 1"

**해결**: Maven 빌드 오류
```bash
# 로컬에서 빌드 테스트
./mvnw clean package

# 오류 수정 후 다시 push
```

### "Secret not found"

**해결**: GitHub Secrets 설정 확인
- Settings → Secrets and variables → Actions
- 필수 Secrets가 모두 설정되었는지 확인
- Secret 이름 오타 확인

## Python 크롤러 오류

### "ModuleNotFoundError"

```bash
cd python
pip install -r requirements.txt
```

### ChromeDriver 버전 불일치

```bash
# ChromeDriver 재설치
wget https://chromedriver.storage.googleapis.com/LATEST_RELEASE
DRIVER_VERSION=$(cat LATEST_RELEASE)
wget https://chromedriver.storage.googleapis.com/$DRIVER_VERSION/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
sudo mv chromedriver /usr/local/bin/
sudo chmod +x /usr/local/bin/chromedriver
```

## 일반적인 디버깅

### 로그 확인

```bash
# Tomcat 로그
sudo tail -f /var/lib/tomcat9/logs/catalina.out

# MySQL 로그
sudo tail -f /var/log/mysql/error.log

# 시스템 로그
sudo journalctl -u tomcat9 -f
```

### 디스크 용량 확인

```bash
df -h

# 큰 파일 찾기
sudo du -sh /* | sort -hr | head -10
```

### 메모리 확인

```bash
free -h

# 프로세스별 메모리
ps aux --sort=-%mem | head -10
```

---

# 9. 보안 가이드

## 민감정보 보호

### ✅ 절대 Git에 커밋하지 마세요

```
application.properties
conf.xml
python/.env
*.pem
```

### .gitignore 확인

```bash
# .gitignore에 포함되어 있는지 확인
cat .gitignore | grep application.properties
```

### GitHub Secret Scanning

GitHub이 자동으로 감지하는 민감정보:
- AWS Access Keys
- Database Passwords
- API Keys

**노출 시 즉시 조치**:
1. 해당 키/비밀번호 즉시 재발급
2. GitHub Secret Scanning 경고 확인
3. Git 히스토리에서 제거 (필요시)

## API 키 보안

### OAuth Redirect URI 등록

**Kakao Developers**:
```
Settings → Platform → Web → Redirect URI 추가
http://your-domain.com/Controller?type=kakaoCallback
```

**Naver Developers**:
```
API 설정 → Callback URL 추가
http://your-domain.com/Controller?type=naverCallback
```

### API 키 로테이션

주기적으로 API 키 재발급:
1. 새 키 발급
2. application.properties 업데이트
3. GitHub Secrets 업데이트
4. 서버 재배포
5. 구 키 삭제

## 데이터베이스 보안

### 강력한 비밀번호 사용

```bash
# 비밀번호 요구사항
# - 최소 12자 이상
# - 영문 대소문자, 숫자, 특수문자 조합
# - 사전에 없는 단어

# 예시
MySecureP@ssw0rd2025!
Highw@y#Rest$2025
```

### 접근 제한

```sql
-- localhost만 허용
CREATE USER 'restinfo_user'@'localhost' IDENTIFIED BY 'password';

-- 특정 IP만 허용
CREATE USER 'restinfo_user'@'3.34.123.456' IDENTIFIED BY 'password';
```

### 백업 암호화

```bash
# 백업 시 암호화
mysqldump -u root -p my_app_db | gzip | openssl enc -aes-256-cbc -salt -out backup.sql.gz.enc

# 복원
openssl enc -d -aes-256-cbc -in backup.sql.gz.enc | gunzip | mysql -u root -p my_app_db
```

## AWS 보안

### 보안 그룹 최소 권한

```
# 인바운드 규칙
SSH (22) → My IP만 허용
HTTP (80) → 0.0.0.0/0
HTTPS (443) → 0.0.0.0/0
Tomcat (8080) → 필요시만 허용
```

### IAM 최소 권한

S3 접근용 IAM 사용자:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::your-bucket-name/*"
    }
  ]
}
```

### SSH 키 관리

```bash
# PEM 키 권한 설정
chmod 400 your-key.pem

# 키 백업 (안전한 장소)
cp your-key.pem ~/backups/
```

## 애플리케이션 보안

### XSS 방지

JSP에서 출력 시 이스케이프:
```jsp
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<!-- 안전하지 않음 -->
<div>${userInput}</div>

<!-- 안전함 -->
<div><c:out value="${userInput}"/></div>
```

### SQL Injection 방지

MyBatis PreparedStatement 사용:
```xml
<!-- 안전함 -->
<select id="getUser" parameterType="String">
    SELECT * FROM User WHERE ID = #{id}
</select>

<!-- 위험! (사용 금지) -->
<select id="getUser" parameterType="String">
    SELECT * FROM User WHERE ID = '${id}'
</select>
```

### 비밀번호 해싱

jBCrypt 사용:
```java
import org.mindrot.jbcrypt.BCrypt;

// 비밀번호 해싱
String hashed = BCrypt.hashpw(password, BCrypt.gensalt());

// 비밀번호 검증
boolean isValid = BCrypt.checkpw(inputPassword, hashedPassword);
```

## HTTPS 설정 (선택)

### Let's Encrypt 무료 인증서

```bash
# Certbot 설치
sudo apt-get install -y certbot python3-certbot-nginx

# Nginx 설치 (아직 없다면)
sudo apt-get install -y nginx

# 인증서 발급
sudo certbot --nginx -d your-domain.com

# 자동 갱신 확인
sudo certbot renew --dry-run
```

### Nginx 리버스 프록시 설정

```nginx
server {
    listen 443 ssl;
    server_name your-domain.com;

    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$host$request_uri;
}
```

---

# 10. 추가 자료

## 외부 링크

- [고속도로 공공데이터 포털](https://data.ex.co.kr/)
- [Kakao Developers](https://developers.kakao.com/)
- [Naver Developers](https://developers.naver.com/)
- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [MyBatis 공식 문서](https://mybatis.org/mybatis-3/)
- [Tomcat 9 문서](https://tomcat.apache.org/tomcat-9.0-doc/)

## 개별 문서

더 자세한 내용은 다음 개별 문서를 참고하세요:

- `README.md` - 프로젝트 개요
- `QUICKSTART.md` - 빠른 시작 가이드
- `DEPLOYMENT.md` - 상세 배포 가이드
- `CLAUDE.md` - 아키텍처 상세 설명
- `GITHUB_SECRETS_CHECKLIST.md` - Secrets 체크리스트
- `docs/EC2_MYSQL_SETUP.md` - EC2 MySQL 설정
- `docs/GITHUB_ACTIONS_SETUP.md` - GitHub Actions 설정
- `docs/DATABASE_SETUP_GUIDE.md` - 데이터베이스 설정

## 도움말

### 스크립트 목록

```bash
./mvnw clean package         # Maven 빌드
bash deploy.sh                # 서버 배포
bash server-setup.sh          # 서버 초기 설정
bash setup-database.sh local  # 데이터베이스 설정
bash setup-new-git.sh         # Git 재설정
bash generate-secrets-template.sh  # Secrets 템플릿 생성
```

### 유용한 명령어

```bash
# Tomcat 관리
sudo systemctl status tomcat9
sudo systemctl restart tomcat9
sudo tail -f /var/lib/tomcat9/logs/catalina.out

# MySQL 관리
sudo systemctl status mysql
mysql -u root -p
sudo tail -f /var/log/mysql/error.log

# 디스크/메모리 확인
df -h
free -h
```

---

**Made with ❤️ by Highway Rest Info Team**

© 2025 Highway Rest Area Information Service. All rights reserved.
