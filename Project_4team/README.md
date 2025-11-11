# 🚗 고속도로 휴게소 정보 서비스

전국 고속도로 휴게소의 실시간 정보(시설, 메뉴, 주유가격, 리뷰)를 제공하는 웹 애플리케이션

![Java](https://img.shields.io/badge/Java-11-007396?style=flat-square&logo=java)
![Spring](https://img.shields.io/badge/Framework-JSP%2FServlet-6DB33F?style=flat-square)
![MySQL](https://img.shields.io/badge/Database-MySQL-4479A1?style=flat-square&logo=mysql)
![AWS](https://img.shields.io/badge/Cloud-AWS-232F3E?style=flat-square&logo=amazon-aws)

---

## 📋 목차

- [주요 기능](#주요-기능)
- [기술 스택](#기술-스택)
- [빠른 시작](#빠른-시작)
- [배포 가이드](#배포-가이드)
- [프로젝트 구조](#프로젝트-구조)
- [API 문서](#api-문서)
- [기여 방법](#기여-방법)

---

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

---

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

---

## 🚀 빠른 시작

### 사전 요구사항

- Java 11+
- Maven 3.6+
- MySQL 8.0+
- (선택) Python 3.7+ (크롤러 사용 시)

### 로컬 실행

```bash
# 1. 저장소 클론
git clone https://github.com/your-username/highway-rest-info.git
cd highway-rest-info

# 2. 환경변수 설정
cp application.properties.example src/main/resources/application.properties
vim src/main/resources/application.properties
# → DB 정보, API 키 입력

# 3. 데이터베이스 생성
mysql -u root -p
CREATE DATABASE my_app_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
SOURCE src/main/resources/Db.sql;
EXIT;

# 4. 빌드 및 실행
./mvnw clean package
# WAR 파일을 Tomcat에 배포
```

자세한 내용: [QUICKSTART.md](QUICKSTART.md)

---

## ☁️ 배포 가이드

### AWS EC2 배포

```bash
# 1. 서버 접속
ssh -i your-key.pem ubuntu@your-ec2-ip

# 2. 프로젝트 클론
git clone https://github.com/your-username/highway-rest-info.git
cd highway-rest-info

# 3. 서버 초기 설정 (Java, Maven, Tomcat, MySQL 설치)
sudo bash server-setup.sh

# 4. 환경변수 설정
cp application.properties.example src/main/resources/application.properties
vim src/main/resources/application.properties

# 5. 데이터베이스 설정
bash setup-database.sh local

# 6. 배포
bash deploy.sh
```

### GitHub Actions 자동 배포

```bash
# 1. GitHub 저장소 생성 및 Git 재설정
bash setup-new-git.sh

# 2. GitHub Secrets 설정
# 📋 체크리스트: GITHUB_SECRETS_CHECKLIST.md 참고
# Settings → Secrets and variables → Actions
# 필요한 Secrets 추가 (총 22개)

# 🚀 간편 설정: application.properties가 있다면
bash generate-secrets-template.sh
# → github-secrets-values.txt 파일 생성됨
# → 복사-붙여넣기로 GitHub Secrets 설정

# 3. dev 브랜치에 push하면 자동 배포!
git push origin dev
```

자세한 내용:
- [GITHUB_SECRETS_CHECKLIST.md](GITHUB_SECRETS_CHECKLIST.md) - **Secrets 체크리스트** ⭐ 신규!
- [DEPLOYMENT.md](DEPLOYMENT.md) - 전체 배포 가이드
- [docs/EC2_MYSQL_SETUP.md](docs/EC2_MYSQL_SETUP.md) - MySQL 설정
- [docs/GITHUB_ACTIONS_SETUP.md](docs/GITHUB_ACTIONS_SETUP.md) - CI/CD 설정

---

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
│   │   │   │   └── util/         # Utilities
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
│   │       │   └── web.xml
│   │       ├── css/
│   │       ├── js/
│   │       └── *.jsp             # JSP Views
│   └── test/                     # Unit Tests
├── python/                       # Web Crawlers
│   ├── getReviews.py
│   ├── searchServiceArea.py
│   └── requirements.txt
├── .github/
│   └── workflows/
│       └── deploy.yml            # GitHub Actions
├── docs/                         # Documentation
├── deploy.sh                     # Deployment Script
├── server-setup.sh               # Server Setup Script
└── pom.xml                       # Maven Configuration
```

자세한 내용: [CLAUDE.md](CLAUDE.md)

---

## 📚 API 문서

### 주요 Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/Controller?type=kakaoMap` | 경로 검색 |
| GET | `/Controller?type=restArea` | 휴게소 목록 |
| POST | `/Controller?type=login` | 로그인 |
| POST | `/Controller?type=heartBookmark` | 북마크 추가/제거 |
| GET | `/Controller?type=getGasPrice` | 주유 가격 조회 |

### Action Mapping

모든 요청은 Front Controller를 통해 라우팅됩니다:

```
/Controller?type=<action_name>
```

`action.properties`에서 매핑 관리:
```properties
login=restinfo.action.LoginAction
kakaoMap=restinfo.action.KaKaoMapV2
```

---

## 🔧 개발 환경 설정

### Python 크롤러

```bash
cd python
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# 리뷰 수집
python getReviews.py "휴게소명"
```

### 데이터베이스 연결 테스트

```bash
cd python
python test_db.py
```

---

## 🤝 기여 방법

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

---

## 👥 Contributors

- **개발자 1** - Backend, API 통합
- **개발자 2** - Frontend, UI/UX
- **개발자 3** - 크롤러, 데이터 수집
- **개발자 4** - DevOps, 배포

---

## 📞 문의

프로젝트 관련 문의사항이 있으시면 Issues 탭을 이용해주세요.

---

## 🙏 Acknowledgments

- [고속도로 공공데이터 포털](https://data.ex.co.kr/)
- [Kakao Developers](https://developers.kakao.com/)
- [Naver Developers](https://developers.naver.com/)

---

**Made with ❤️ by Highway Rest Info Team**
