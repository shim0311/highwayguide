# ⚡ 빠른 시작 가이드

이 문서는 프로젝트를 **가장 빠르게** 로컬 또는 AWS 서버에서 실행하는 방법을 설명합니다.

---

## 🎯 선택하세요

- **[로컬 개발 환경](#로컬-개발-환경)** - 내 컴퓨터에서 개발/테스트
- **[AWS 서버 배포](#aws-서버-배포)** - 운영 서버에 배포

---

## 💻 로컬 개발 환경

### 1️⃣ 사전 준비

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

### 2️⃣ MySQL 설정

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
SOURCE /Users/luka/Downloads/secondPrjDB.sql;

-- 확인
SHOW TABLES;
exit;
```

### 3️⃣ 환경변수 설정

#### Java 설정

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
# ... (나머지는 사용할 때 추가)
```

#### Python 설정 (크롤러 사용 시)

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

### 4️⃣ 연결 테스트

```bash
# Python 테스트
cd python
pip3 install python-dotenv mysql-connector-python
python3 test_db.py
```

성공하면 ✅ 표시가 나옵니다!

### 5️⃣ 애플리케이션 실행

```bash
# 빌드
./mvnw clean package

# IntelliJ IDEA에서 실행
# 1. Run → Edit Configurations
# 2. + → Tomcat Server → Local
# 3. Deployment 탭 → + → Artifact → Project_4team:war exploded
# 4. Application context: /Project_4team_war_exploded
# 5. Run!

# 또는 명령줄에서 Tomcat 사용
# WAR 파일을 Tomcat webapps에 복사 후 실행
```

### 6️⃣ 접속 확인

```
http://localhost:8080/Project_4team_war_exploded
```

---

## ☁️ AWS 서버 배포

### 1️⃣ 서버 접속

```bash
ssh -i your-key.pem ubuntu@your-ec2-ip
```

### 2️⃣ 프로젝트 클론

```bash
git clone https://github.com/your-username/Project_4team.git
cd Project_4team
```

### 3️⃣ 서버 초기 설정 (최초 1회만)

```bash
sudo bash server-setup.sh
```

이 명령은 자동으로 Java, Maven, Tomcat, Python, Chrome을 설치합니다.

**MySQL 설치 옵션**:
- 스크립트 실행 시 "MySQL을 이 서버에 설치하시겠습니까?" 질문이 나옵니다
- **y** 입력 → MySQL을 EC2에 직접 설치 (RDS 불필요, 비용 절감!)
- **n** 입력 → MySQL 건너뛰기 (RDS 또는 외부 DB 사용)

**MySQL 직접 설치한 경우 추가 작업**:

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

-- 테이블 생성 (자동 스크립트 사용 - 가장 간단!)
EXIT;
```

```bash
# 3. 테이블 스키마 생성 (자동)
bash setup-database.sh local
# → MySQL root 비밀번호 입력
# → 자동으로 테이블 생성 완료!

# 또는 수동으로
mysql -u root -p my_app_db < src/main/resources/Db.sql
```

상세 가이드:
- [docs/EC2_MYSQL_SETUP.md](docs/EC2_MYSQL_SETUP.md)
- [docs/DATABASE_SETUP_GUIDE.md](docs/DATABASE_SETUP_GUIDE.md) ⭐ 신규!

### 4️⃣ 환경변수 설정

```bash
# Java 설정
cp application.properties.example src/main/resources/application.properties
vim src/main/resources/application.properties
```

**운영 환경 설정**:

**Option A: EC2에 MySQL 직접 설치한 경우**

```properties
# DB 설정 (localhost)
db.url=jdbc:mysql://localhost:3306/my_app_db?useSSL=false&serverTimezone=Asia/Seoul
db.username=restinfo_user
db.password=StrongPassword123!
```

**Option B: AWS RDS 사용하는 경우**

```properties
# DB 설정 (RDS)
db.url=jdbc:mysql://restinfo-db-instance.c50u4mqy2h6b.ap-northeast-2.rds.amazonaws.com:3306/my_app_db?useSSL=true
db.username=admin
db.password=NEW_SECURE_PASSWORD  # ⚠️ 변경된 비밀번호!

# 서버 설정 (도메인 있는 경우)
server.domain=your-domain.com
server.port=80
server.context=

# 또는 IP만 사용하는 경우
server.domain=your-ec2-public-ip
server.port=8080
server.context=

# API 키들
KAKAO_API_KEY=your-kakao-api-key
NAVER_CLIENT_ID=your-naver-id
NAVER_CLIENT_SECRET=your-naver-secret
EXPRESSWAY_ID=your-expressway-key
# ...
```

**Python 설정** (크롤러 사용 시):

```bash
cp python/.env.example python/.env
vim python/.env
```

### 5️⃣ 배포

```bash
bash deploy.sh
```

자동으로:
- Maven 빌드
- WAR 파일 생성
- Tomcat 재시작

### 6️⃣ 접속 확인

```
http://your-ec2-ip:8080
```

또는 도메인:

```
http://your-domain.com
```

---

## 🚨 중요: 보안 조치

배포 전에 **반드시** 다음을 수행하세요:

### 1. DB 비밀번호 변경

```
AWS Console → RDS → Databases → restinfo-db-instance → Modify
→ New master password 입력 → Apply immediately
```

### 2. Kakao API 키 재발급

```
Kakao Developers → 내 애플리케이션 → REST API 키 → 재발급
```

### 3. OAuth Redirect URI 등록

**Naver Developers**:
```
http://your-domain.com/Controller?type=naverCallback
```

**Kakao Developers**:
```
http://your-domain.com/Controller?type=kakaoCallback
```

---

## 🐛 문제 해결

### MySQL 연결 실패

```bash
# MySQL 실행 확인
brew services list  # macOS
sudo systemctl status mysql  # Ubuntu

# 비밀번호 재설정
mysql -u root
ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_password';
FLUSH PRIVILEGES;
```

### Tomcat 시작 실패

```bash
# 로그 확인
sudo tail -f /var/lib/tomcat9/logs/catalina.out

# Tomcat 재시작
sudo systemctl restart tomcat9
```

### 포트 이미 사용 중

```bash
# 8080 포트 사용 프로세스 확인
sudo lsof -i :8080

# 프로세스 종료
sudo kill -9 <PID>
```

---

## 📚 상세 문서

더 자세한 정보는 다음 문서를 참고하세요:

- **[DEPLOYMENT.md](DEPLOYMENT.md)** - 전체 배포 가이드
- **[docs/MYSQL_SETUP.md](docs/MYSQL_SETUP.md)** - MySQL 상세 설정
- **[CLAUDE.md](CLAUDE.md)** - 프로젝트 아키텍처

---

## 💡 팁

### Python 크롤러 실행

```bash
cd python
bash setup-crawler.sh  # 최초 1회
source venv/bin/activate
python getReviews.py "휴게소명"
deactivate
```

### 빠른 재배포

```bash
# 코드 수정 후
bash deploy.sh
```

### 로그 실시간 확인

```bash
# 애플리케이션 로그
sudo tail -f /var/lib/tomcat9/logs/catalina.out

# MySQL 로그
sudo tail -f /var/log/mysql/error.log
```

---

## 🆘 도움이 필요하면

1. 로그 확인
2. [docs/MYSQL_SETUP.md](docs/MYSQL_SETUP.md)의 "문제 해결" 섹션
3. GitHub Issues 등록
4. 팀원에게 문의

---

**Happy Coding! 🚀**
