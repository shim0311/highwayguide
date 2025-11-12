# EC2 배포 완벽 가이드 - 실전 기록

이 문서는 실제 EC2 배포 과정에서 발생한 모든 문제와 해결 방법을 기록한 실전 가이드입니다.

---

## 📋 목차

1. [사전 준비](#1-사전-준비)
2. [EC2 인스턴스 생성](#2-ec2-인스턴스-생성)
3. [SSH 접속](#3-ssh-접속)
4. [프로젝트 클론](#4-프로젝트-클론)
5. [서버 초기 설정](#5-서버-초기-설정)
6. [Tomcat 9 수동 설치](#6-tomcat-9-수동-설치)
7. [MySQL 설정](#7-mysql-설정)
8. [데이터베이스 생성](#8-데이터베이스-생성)
9. [환경변수 설정](#9-환경변수-설정)
10. [애플리케이션 배포](#10-애플리케이션-배포)
11. [MySQL Workbench 연결](#11-mysql-workbench-연결)
12. [GitHub Actions CI/CD](#12-github-actions-cicd)
13. [문제 해결 로그](#13-문제-해결-로그)

---

## 1. 사전 준비

### Git 커밋 메시지에서 Claude 언급 제거

**문제**: 커밋 메시지에 Claude Code 관련 내용이 포함되어 있었음

**해결**:
```bash
# 새로운 orphan 브랜치로 깨끗한 히스토리 생성
git checkout --orphan clean_dev

# 모든 파일 커밋
git commit -m "Initial commit: Highway Rest Area Information Service

High-quality web application for highway rest area information

Features:
- Route-based rest area search with Kakao/Naver Maps API
- Real-time gas price updates with Quartz Scheduler
- User reviews and ratings with Python web crawling
- Social login (Kakao/Naver OAuth)
- Bookmark favorites and community board

Tech Stack:
- Backend: Java 11, JSP/Servlet, MyBatis, MySQL 8.0
- Frontend: JSP/JSTL, Vanilla JS, CSS3
- Data Collection: Python 3, Selenium WebDriver
- DevOps: AWS EC2/RDS/S3, GitHub Actions CI/CD
- Server: Apache Tomcat 9"

# 기존 브랜치 교체
git branch -D dev
git branch -m dev
git push origin dev --force
```

---

## 2. EC2 인스턴스 생성

### AWS 콘솔에서 EC2 생성

**설정 사항**:
- AMI: Ubuntu Server 24.04 LTS
- 인스턴스 타입: t2.micro (프리티어) 또는 t2.small
- 키 페어: `highway.pem` 생성 및 다운로드
- 보안 그룹 설정:
  ```
  SSH (22) → My IP
  HTTP (80) → 0.0.0.0/0
  HTTPS (443) → 0.0.0.0/0
  Custom TCP (8080) → 0.0.0.0/0 (Tomcat)
  MySQL (3306) → 0.0.0.0/0 (또는 My IP)
  ```
- 스토리지: 20GB 이상

**생성된 정보**:
- EC2 퍼블릭 IP: `43.203.158.51`
- PEM 키 위치: `/Users/luka/highway.pem`

---

## 3. SSH 접속

### 문제 1: PEM 키 권한 오류

**오류 메시지**:
```
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@         WARNING: UNPROTECTED PRIVATE KEY FILE!          @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
Permissions 0644 for '/Users/luka/highway.pem' are too open.
```

**원인**: PEM 파일의 권한이 너무 개방되어 있음

**해결**:
```bash
# PEM 파일 권한 수정 (소유자만 읽기 가능)
chmod 400 /Users/luka/highway.pem

# 권한 확인
ls -la /Users/luka/highway.pem
# 출력: -r--------@ 1 luka staff 1674 Nov 11 14:54 /Users/luka/highway.pem
```

### 정상 접속

```bash
# SSH 접속
ssh -i /Users/luka/highway.pem ubuntu@43.203.158.51

# 처음 접속 시 fingerprint 확인
# Are you sure you want to continue connecting (yes/no)? → yes
```

---

## 4. 프로젝트 클론

```bash
# 홈 디렉토리로 이동
cd ~

# GitHub에서 프로젝트 클론
git clone https://github.com/shim0311/highwayguide.git

# 프로젝트 디렉토리 이동
cd highwayguide/Project_4team

# 디렉토리 구조 확인
ls -la
```

---

## 5. 서버 초기 설정

### server-setup.sh 실행

```bash
sudo bash server-setup.sh
```

**설치된 항목**:
1. ✅ Java 11
2. ✅ Maven
3. ✅ Python 3 & pip
4. ✅ Google Chrome & ChromeDriver
5. ✅ MySQL 8.0

**MySQL 설치 선택**:
```
MySQL을 이 서버에 설치하시겠습니까? (y/n): y
```

**MySQL 상태 확인**:
```bash
sudo systemctl status mysql
# ● mysql.service - MySQL Community Server
#      Active: active (running)
```

### 문제: Tomcat 9 설치 실패

**오류**:
```
E: Package 'tomcat9' has no installation candidate
E: Unable to locate package tomcat9-admin
```

**원인**: Ubuntu 24.04에는 기본 저장소에 Tomcat 9이 없음

**해결 방법**: Tomcat 9을 수동으로 설치해야 함 (다음 섹션 참조)

---

## 6. Tomcat 9 수동 설치

### 6.1 Tomcat 9 다운로드 및 설치

```bash
# 1. Tomcat 9 다운로드
cd ~
wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.93/bin/apache-tomcat-9.0.93.tar.gz

# 2. 압축 해제 및 이동
sudo tar xzvf apache-tomcat-9.0.93.tar.gz -C /opt
sudo mv /opt/apache-tomcat-9.0.93 /opt/tomcat9

# 3. Tomcat 전용 사용자 생성
sudo useradd -r -m -U -d /opt/tomcat9 -s /bin/false tomcat

# 4. 소유권 변경
sudo chown -R tomcat:tomcat /opt/tomcat9

# 5. bin 디렉토리 확인
sudo ls -la /opt/tomcat9/bin/
```

### 문제 1: bin 디렉토리 파일 확인

**오류**: `chmod: cannot access '/opt/tomcat9/bin/*.sh': No such file or directory`

**원인**: glob 패턴 문제 (파일은 실제로 존재함)

**확인**:
```bash
sudo ls -la /opt/tomcat9/bin/
# .sh 파일들이 이미 실행 권한(x)을 가지고 있음
```

### 6.2 systemd 서비스 생성

```bash
# systemd 서비스 파일 생성
sudo tee /etc/systemd/system/tomcat9.service > /dev/null << 'EOF'
[Unit]
Description=Apache Tomcat 9
After=network.target

[Service]
Type=forking
User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64"
Environment="CATALINA_HOME=/opt/tomcat9"
Environment="CATALINA_BASE=/opt/tomcat9"
Environment="CATALINA_PID=/opt/tomcat9/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat9/bin/startup.sh
ExecStop=/opt/tomcat9/bin/shutdown.sh

RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF
```

### 6.3 Tomcat 서비스 시작

```bash
# 서비스 등록 및 시작
sudo systemctl daemon-reload
sudo systemctl enable tomcat9
sudo systemctl start tomcat9

# 상태 확인
sudo systemctl status tomcat9
```

**성공 출력**:
```
● tomcat9.service - Apache Tomcat 9
     Loaded: loaded (/etc/systemd/system/tomcat9.service; enabled)
     Active: active (running) since Tue 2025-11-11 06:36:28 UTC
   Main PID: 9046 (java)
      Tasks: 30
     Memory: 156.0M
```

---

## 7. MySQL 설정

### 7.1 MySQL 보안 설정

```bash
sudo mysql_secure_installation
```

**설정 과정**:
```
1. Enter password for user root: [그냥 Enter - 비밀번호 없음]

2. VALIDATE PASSWORD COMPONENT? → y

3. Password validation policy:
   0 = LOW, 1 = MEDIUM, 2 = STRONG → 2

4. Skipping password set for root (auth_socket 사용)

5. Remove anonymous users? → y

6. Disallow root login remotely? → y

7. Remove test database? → y

8. Reload privilege tables? → y
```

**중요**: Ubuntu MySQL은 기본적으로 `auth_socket` 인증을 사용하므로 root 비밀번호가 설정되지 않고 `sudo mysql`로만 접속 가능

---

## 8. 데이터베이스 생성

### 8.1 데이터베이스 및 사용자 생성

```bash
# MySQL 접속 (sudo 필요)
sudo mysql
```

**SQL 실행**:
```sql
-- 데이터베이스 생성
CREATE DATABASE my_app_db
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- 사용자 생성
CREATE USER 'restinfo_user'@'localhost'
  IDENTIFIED BY 'YourStrongPassword123!';

-- 권한 부여
GRANT ALL PRIVILEGES ON my_app_db.*
  TO 'restinfo_user'@'localhost';

-- 권한 적용
FLUSH PRIVILEGES;

-- 종료
EXIT;
```

### 8.2 테이블 스키마 생성

```bash
# setup-database.sh 실행
cd ~/highwayguide/Project_4team
sudo bash setup-database.sh local
# → 비밀번호 입력 없이 Enter
```

**성공 출력**:
```
[INFO] ✅ 데이터베이스 스키마 생성 완료!
```

**생성된 테이블** (13개):
- User
- ServiceArea
- Gas
- Menu
- CrawlingData
- BookMark
- Board (BBS)
- Shop
- LikeHate
- Visit
- HighWay
- RestArea
- History

### 8.3 데이터베이스 확인

```bash
sudo mysql
```

```sql
USE my_app_db;
SHOW TABLES;

-- 테이블 개수 확인
SELECT COUNT(*) AS table_count
FROM information_schema.tables
WHERE table_schema = 'my_app_db';

EXIT;
```

---

## 9. 환경변수 설정

### 9.1 application.properties 생성

```bash
cd ~/highwayguide/Project_4team

# 템플릿 복사
cp application.properties.example src/main/resources/application.properties

# 편집
vim src/main/resources/application.properties
```

**설정 내용**:
```properties
# =============================================================================
# Database Configuration (필수!)
# =============================================================================
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://localhost:3306/my_app_db?useSSL=false&serverTimezone=Asia/Seoul
db.username=restinfo_user
db.password=YourStrongPassword123!

# =============================================================================
# Server Configuration (필수!)
# =============================================================================
server.domain=43.203.158.51
server.port=8080
server.context=

# OAuth Redirect URI (자동 생성)
oauth.redirect.base=http://${server.domain}:${server.port}${server.context}

# =============================================================================
# API Keys (더미값 - 나중에 실제 키로 교체)
# =============================================================================
GOOGLE_SENDER_MAIL=dummy@gmail.com
GOOGLE_APPLICATION_PASSWORD=dummypassword1234

NAVER_CLIENT_ID=dummy_naver_client_id
NAVER_CLIENT_SECRET=dummy_naver_secret

KAKAO_CLIENT_ID=dummy_kakao_client_id
KAKAO_API_KEY=dummy_kakao_api_key

EXPRESSWAY_ID=dummy_expressway_key

tmap.appkey=dummy_tmap_key

# AWS S3
aws.accessKeyId=dummy_aws_key
aws.secretAccessKey=dummy_aws_secret
aws.s3.bucketName=dummy-bucket
aws.s3.bucketUrl=https://dummy-bucket.s3.ap-northeast-2.amazonaws.com/
```

**vim 사용법**:
- `i` 키 → 편집 모드
- 수정 완료 후 `ESC` 키
- `:wq` 입력 후 Enter → 저장하고 종료

### 9.2 conf.xml 생성

```bash
# config 디렉토리 생성
mkdir -p src/main/resources/mybatis/config

# conf.xml 파일 생성
cat > src/main/resources/mybatis/config/conf.xml << 'EOF'
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
EOF

# 확인
cat src/main/resources/mybatis/config/conf.xml
```

---

## 10. 애플리케이션 배포

### 문제 1: Tomcat 경로 불일치

**오류**:
```
cp: cannot create regular file '/var/lib/tomcat9/webapps/ROOT.war': No such file or directory
```

**원인**: `deploy.sh` 스크립트가 `/var/lib/tomcat9`를 참조하지만 실제로는 `/opt/tomcat9`에 설치됨

**해결**:
```bash
# deploy.sh 파일에서 경로 자동 변경
sed -i 's|/var/lib/tomcat9|/opt/tomcat9|g' deploy.sh

# 변경 확인
grep "tomcat9" deploy.sh
```

### 배포 실행

```bash
bash deploy.sh
```

**프로세스**:
1. ✅ 환경변수 파일 확인 (application.properties, conf.xml)
2. ✅ Maven 빌드 (`mvn clean package`)
3. ✅ WAR 파일 생성 (`target/Project_4team-1.0-SNAPSHOT.war`)
4. ✅ Tomcat 중지
5. ✅ 기존 애플리케이션 삭제
6. ✅ 새 WAR 파일을 `/opt/tomcat9/webapps/ROOT.war`로 복사
7. ✅ Tomcat 재시작

**성공 출력**:
```
[INFO] BUILD SUCCESS
[INFO] ✅ 빌드 완료: target/Project_4team-1.0-SNAPSHOT.war
[INFO] 애플리케이션이 성공적으로 배포되었습니다!
[INFO] 접속: http://43.203.158.51:8080
```

### 브라우저 접속 테스트

```
http://43.203.158.51:8080
```

### 로그 확인

```bash
# Tomcat 로그 실시간 확인
sudo tail -f /opt/tomcat9/logs/catalina.out

# 특정 줄 수만 확인
sudo tail -100 /opt/tomcat9/logs/catalina.out
```

---

## 11. MySQL Workbench 연결

### 문제 1: root 계정으로 원격 접속 불가

**원인**: Ubuntu MySQL의 root는 `auth_socket` 인증을 사용하여 원격 접속 불가

**해결**: `restinfo_user` 계정 사용

### 11.1 원격 접속 허용 설정

```bash
sudo mysql
```

```sql
-- 모든 IP에서 접속 가능한 사용자 생성
CREATE USER 'restinfo_user'@'%'
  IDENTIFIED BY 'YourStrongPassword123!';

GRANT ALL PRIVILEGES ON my_app_db.*
  TO 'restinfo_user'@'%';

FLUSH PRIVILEGES;
EXIT;
```

### 11.2 MySQL 외부 접속 허용

```bash
# MySQL 설정 파일 수정
sudo sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

# 변경 확인
grep bind-address /etc/mysql/mysql.conf.d/mysqld.cnf
# 출력: bind-address = 0.0.0.0

# MySQL 재시작
sudo systemctl restart mysql

# 상태 확인
sudo systemctl status mysql

# 포트 확인 (0.0.0.0:3306으로 열려있어야 함)
sudo netstat -tulnp | grep 3306
# 출력: tcp 0 0 0.0.0.0:3306 0.0.0.0:* LISTEN
```

### 11.3 EC2 보안 그룹 설정

AWS 콘솔에서:
1. EC2 → 보안 그룹
2. MySQL/Aurora (3306) 포트 추가
3. 소스: `0.0.0.0/0` (모든 IP) 또는 본인 IP

### 11.4 Workbench 연결 설정

```
Connection Name: guide
Connection Method: Standard (TCP/IP)

Host: 43.203.158.51
Port: 3306
Username: restinfo_user
Password: YourStrongPassword123!
Default Schema: my_app_db

SSL: No
```

**연결 성공!** ✅

---

## 12. GitHub Actions CI/CD

### 12.1 필수 GitHub Secrets 설정

GitHub 레포지토리 → Settings → Secrets and variables → Actions

**총 22개 Secrets 필요**:

#### 데이터베이스 (3개)
```
Name: DB_URL
Value: jdbc:mysql://localhost:3306/my_app_db?useSSL=false&serverTimezone=Asia/Seoul

Name: DB_USERNAME
Value: restinfo_user

Name: DB_PASSWORD
Value: YourStrongPassword123!
```

#### 서버 설정 (3개)
```
Name: SERVER_DOMAIN
Value: 43.203.158.51

Name: SERVER_PORT
Value: 8080

Name: SERVER_CONTEXT
Value: (비워두기)
```

#### EC2 배포 (4개) - 가장 중요!
```
Name: EC2_HOST
Value: 43.203.158.51

Name: EC2_USERNAME
Value: ubuntu

Name: EC2_SSH_KEY
Value: [PEM 파일 전체 내용]

Name: EC2_TARGET_PATH
Value: /home/ubuntu/highwayguide/Project_4team
```

**EC2_SSH_KEY 설정 방법**:
```bash
# 로컬에서 PEM 키 내용 복사
cat /Users/luka/highway.pem

# -----BEGIN RSA PRIVATE KEY-----부터
# -----END RSA PRIVATE KEY-----까지 전체 복사
```

#### Google Mail (2개)
```
Name: GOOGLE_SENDER_MAIL
Value: your-email@gmail.com

Name: GOOGLE_APPLICATION_PASSWORD
Value: your-16-char-app-password
```

#### Naver OAuth (2개)
```
Name: NAVER_CLIENT_ID
Value: your-naver-client-id

Name: NAVER_CLIENT_SECRET
Value: your-naver-client-secret
```

#### Kakao (2개)
```
Name: KAKAO_CLIENT_ID
Value: your-kakao-client-id

Name: KAKAO_API_KEY
Value: your-kakao-rest-api-key
```

#### 기타 API (2개)
```
Name: EXPRESSWAY_ID
Value: your-expressway-api-key

Name: TMAP_APPKEY
Value: your-tmap-api-key
```

#### AWS S3 (4개)
```
Name: AWS_ACCESS_KEY_ID
Value: your-aws-access-key

Name: AWS_SECRET_ACCESS_KEY
Value: your-aws-secret-key

Name: AWS_S3_BUCKET_NAME
Value: your-bucket-name

Name: AWS_S3_BUCKET_URL
Value: https://your-bucket-name.s3.ap-northeast-2.amazonaws.com/
```

### 12.2 Secrets 값 자동 생성 (로컬)

```bash
cd /Users/luka/-SIST-Project2-HighwayRestInfo/Project_4team

# application.properties 파일 생성 (EC2 설정값 입력)
cp application.properties.example src/main/resources/application.properties
# → vim으로 실제 값 입력

# Secrets 템플릿 생성
bash generate-secrets-template.sh

# 생성된 파일 확인
cat github-secrets-values.txt

# 각 값을 복사해서 GitHub Secrets에 등록
```

### 12.3 자동 배포 테스트

```bash
# 로컬에서 커밋 및 푸시
git add .
git commit -m "Test automatic deployment"
git push origin dev
```

**GitHub Actions 워크플로우**:
1. ✅ JDK 11 설치
2. ✅ application.properties 생성 (Secrets로부터)
3. ✅ conf.xml 생성
4. ✅ Maven 빌드 (`mvn clean package`)
5. ✅ WAR 파일 생성 확인
6. ✅ EC2로 WAR 파일 전송 (SCP)
7. ✅ Tomcat 재시작
8. ✅ 배포 완료!

**Actions 확인**:
```
https://github.com/shim0311/highwayguide/actions
```

---

## 13. 문제 해결 로그

### 문제 정리

| 문제 | 원인 | 해결 방법 |
|------|------|-----------|
| SSH 접속 실패 (Permission denied) | PEM 키 권한 너무 개방 (0644) | `chmod 400 highway.pem` |
| Tomcat 9 설치 실패 | Ubuntu 24.04에 패키지 없음 | 수동 설치 (Apache Archive) |
| bin/*.sh 실행 권한 오류 | glob 패턴 문제 (실제로는 권한 있음) | 무시 (이미 실행 권한 있음) |
| conf.xml 파일 없음 | config 디렉토리 자체가 없음 | `mkdir -p`로 디렉토리 생성 후 파일 생성 |
| deploy.sh 경로 오류 | `/var/lib/tomcat9` 참조 | sed로 `/opt/tomcat9`로 변경 |
| Workbench 접속 실패 | MySQL이 127.0.0.1만 바인딩 | `bind-address = 0.0.0.0`로 변경 |
| root 원격 접속 불가 | auth_socket 인증 사용 | `restinfo_user@'%'` 생성 |

---

## 14. 유용한 명령어 모음

### EC2 관리

```bash
# SSH 접속
ssh -i /Users/luka/highway.pem ubuntu@43.203.158.51

# 시스템 업데이트
sudo apt update && sudo apt upgrade -y

# 디스크 용량 확인
df -h

# 메모리 사용량 확인
free -h

# 프로세스 확인
ps aux | grep tomcat
ps aux | grep mysql
```

### Tomcat 관리

```bash
# Tomcat 상태 확인
sudo systemctl status tomcat9

# Tomcat 시작/중지/재시작
sudo systemctl start tomcat9
sudo systemctl stop tomcat9
sudo systemctl restart tomcat9

# Tomcat 로그 확인
sudo tail -f /opt/tomcat9/logs/catalina.out
sudo tail -100 /opt/tomcat9/logs/catalina.out

# Tomcat 로그 파일 위치
ls -la /opt/tomcat9/logs/

# 배포된 애플리케이션 확인
ls -la /opt/tomcat9/webapps/
```

### MySQL 관리

```bash
# MySQL 상태 확인
sudo systemctl status mysql

# MySQL 시작/중지/재시작
sudo systemctl start mysql
sudo systemctl stop mysql
sudo systemctl restart mysql

# MySQL 접속 (root)
sudo mysql

# MySQL 접속 (restinfo_user)
mysql -u restinfo_user -p

# MySQL 로그 확인
sudo tail -f /var/log/mysql/error.log

# 데이터베이스 백업
mysqldump -u root -p my_app_db > backup_$(date +%Y%m%d).sql

# 데이터베이스 복원
mysql -u root -p my_app_db < backup_20251111.sql
```

### 애플리케이션 배포

```bash
# 배포 스크립트 실행
cd ~/highwayguide/Project_4team
bash deploy.sh

# 수동 빌드
./mvnw clean package

# WAR 파일 확인
ls -lh target/*.war

# 빌드 로그 확인
cat target/maven-status/maven-compiler-plugin/compile/default-compile/inputFiles.lst
```

### Git 관리

```bash
# 상태 확인
git status

# 변경 사항 확인
git diff

# 최근 커밋 확인
git log --oneline -5

# 원격 저장소 확인
git remote -v

# 최신 코드 가져오기
git pull origin dev
```

### 네트워크 확인

```bash
# 열린 포트 확인
sudo netstat -tulnp | grep LISTEN

# 특정 포트 확인
sudo netstat -tulnp | grep 8080
sudo netstat -tulnp | grep 3306

# 방화벽 상태 (Ubuntu)
sudo ufw status

# 외부 접속 테스트 (로컬에서)
curl http://43.203.158.51:8080
telnet 43.203.158.51 3306
```

---

## 15. 최종 체크리스트

### 배포 완료 확인

- [x] EC2 인스턴스 생성 완료
- [x] SSH 접속 가능
- [x] Java 11 설치 완료
- [x] Maven 설치 완료
- [x] Tomcat 9 설치 및 실행 중
- [x] MySQL 8.0 설치 및 실행 중
- [x] 데이터베이스 (my_app_db) 생성 완료
- [x] 테이블 스키마 생성 완료 (13개 테이블)
- [x] application.properties 설정 완료
- [x] conf.xml 설정 완료
- [x] WAR 파일 빌드 성공
- [x] Tomcat에 배포 완료
- [x] 브라우저에서 접속 가능 (http://43.203.158.51:8080)
- [x] MySQL Workbench 연결 가능
- [ ] GitHub Actions Secrets 설정 (22개)
- [ ] GitHub Actions 자동 배포 테스트

### 보안 체크

- [x] PEM 키 권한 설정 (400)
- [x] MySQL root 원격 접속 차단
- [x] MySQL 사용자 권한 최소화
- [x] EC2 보안 그룹 설정
- [ ] application.properties Git 커밋 방지 (.gitignore)
- [ ] conf.xml Git 커밋 방지 (.gitignore)
- [ ] PEM 키 안전한 장소 보관

### 다음 단계

1. **GitHub Secrets 설정** - 22개 모두 등록
2. **API 키 발급** - Kakao, Naver, 고속도로 API 등
3. **자동 배포 테스트** - git push 후 Actions 확인
4. **도메인 연결** (선택) - Route 53 또는 다른 DNS 서비스
5. **HTTPS 설정** (선택) - Let's Encrypt 인증서
6. **모니터링 설정** (선택) - CloudWatch, 로그 수집

---

## 16. 참고 자료

### 프로젝트 문서
- [COMPLETE_GUIDE.md](COMPLETE_GUIDE.md) - 올인원 완전 가이드
- [README.md](README.md) - 프로젝트 개요
- [GITHUB_SECRETS_CHECKLIST.md](GITHUB_SECRETS_CHECKLIST.md) - Secrets 체크리스트
- [docs/EC2_MYSQL_SETUP.md](docs/EC2_MYSQL_SETUP.md) - EC2 MySQL 상세 가이드
- [docs/GITHUB_ACTIONS_SETUP.md](docs/GITHUB_ACTIONS_SETUP.md) - CI/CD 상세 가이드

### 외부 링크
- [Apache Tomcat 9 Documentation](https://tomcat.apache.org/tomcat-9.0-doc/)
- [MySQL 8.0 Documentation](https://dev.mysql.com/doc/refman/8.0/en/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS EC2 User Guide](https://docs.aws.amazon.com/ec2/)

### API 서비스
- [Kakao Developers](https://developers.kakao.com/)
- [Naver Developers](https://developers.naver.com/)
- [고속도로 공공데이터](https://data.ex.co.kr/)
- [TMap API](https://tmapapi.sktelecom.com/)

---

## 17. 트러블슈팅 팁

### Tomcat이 시작하지 않을 때

```bash
# 로그 확인
sudo tail -100 /opt/tomcat9/logs/catalina.out

# 포트 충돌 확인
sudo lsof -i :8080

# Java 프로세스 확인
ps aux | grep java

# Tomcat 프로세스 강제 종료
sudo pkill -9 -f tomcat

# 다시 시작
sudo systemctl start tomcat9
```

### MySQL 접속이 안 될 때

```bash
# MySQL 실행 확인
sudo systemctl status mysql

# 포트 확인
sudo netstat -tulnp | grep 3306

# 에러 로그 확인
sudo tail -100 /var/log/mysql/error.log

# 사용자 및 권한 확인
sudo mysql -e "SELECT user, host FROM mysql.user;"
sudo mysql -e "SHOW GRANTS FOR 'restinfo_user'@'localhost';"
```

### 배포 실패 시

```bash
# Maven 빌드 테스트
./mvnw clean package

# 빌드 로그 확인
cat target/surefire-reports/*.txt

# WAR 파일 존재 확인
ls -lh target/*.war

# 환경변수 파일 확인
cat src/main/resources/application.properties
cat src/main/resources/mybatis/config/conf.xml

# Tomcat에 수동 배포
sudo cp target/Project_4team-1.0-SNAPSHOT.war /opt/tomcat9/webapps/ROOT.war
sudo systemctl restart tomcat9
```

### GitHub Actions 실패 시

1. **Actions 탭에서 로그 확인**
   - https://github.com/shim0311/highwayguide/actions
   - 실패한 step 클릭하여 상세 로그 확인

2. **흔한 오류**
   - `Permission denied (publickey)`: EC2_SSH_KEY 확인
   - `Secret not found`: GitHub Secrets 이름 오타 확인
   - `BUILD FAILURE`: 로컬에서 빌드 테스트

3. **로컬에서 재현**
   ```bash
   # 로컬에서 빌드 테스트
   ./mvnw clean package

   # SSH 연결 테스트
   ssh -i /Users/luka/highway.pem ubuntu@43.203.158.51 "echo 'Connection OK'"
   ```

---

**작성일**: 2025-11-11
**EC2 IP**: 43.203.158.51
**GitHub**: https://github.com/shim0311/highwayguide
**프로젝트**: Highway Rest Area Information Service

---

이 문서는 실제 배포 과정에서 발생한 모든 문제와 해결 방법을 기록한 것입니다.
추후 배포 시 이 문서를 참고하면 동일한 문제를 빠르게 해결할 수 있습니다.
