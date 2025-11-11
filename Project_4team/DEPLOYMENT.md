# AWS Ubuntu 서버 배포 가이드

이 문서는 프로젝트를 AWS EC2 Ubuntu 서버에 배포하는 전체 과정을 설명합니다.

---

## 🚨 중요 사항

### 즉시 조치 필요!

1. **노출된 DB 비밀번호 변경**
   - 현재 비밀번호: `gbrpthwjdqh` (GitHub에 노출됨)
   - AWS RDS 콘솔에서 즉시 변경하세요

2. **노출된 Kakao API 키 재발급**
   - 현재 키: `2bb9195b03b5b17418309109544a85c4` (GitHub에 노출됨)
   - Kakao Developers 콘솔에서 즉시 재발급하세요

---

## 📋 사전 준비

### 1. AWS 리소스 준비

- **EC2 인스턴스**: Ubuntu 20.04 LTS 이상
- **RDS MySQL**: 이미 존재 (`restinfo-db-instance.c50u4mqy2h6b.ap-northeast-2.rds.amazonaws.com`)
- **S3 버킷**: 이미지 업로드용
- **보안 그룹**:
  - 인바운드 규칙:
    - HTTP (80)
    - HTTPS (443)
    - SSH (22)
    - Tomcat (8080) - 선택사항
  - 아웃바운드 규칙: 모두 허용

### 2. 필요한 정보 준비

다음 정보를 준비하세요:

- ✅ Google Mail 앱 비밀번호
- ✅ Naver Client ID & Secret
- ✅ Kakao Client ID & API Key (재발급 후)
- ✅ Expressway API Key
- ✅ TMap API Key
- ✅ AWS S3 Access Key & Secret Key
- ✅ MySQL 비밀번호 (변경 후)

---

## 🚀 배포 단계

### Step 1: EC2 인스턴스 접속

```bash
ssh -i your-key.pem ubuntu@your-ec2-public-ip
```

### Step 2: 프로젝트 클론

```bash
cd ~
git clone https://github.com/your-repo/Project_4team.git
cd Project_4team
```

### Step 3: 서버 초기 설정

```bash
sudo bash server-setup.sh
```

이 스크립트는 다음을 설치합니다:
- Java 11
- Maven
- Tomcat 9
- Python 3
- Google Chrome & ChromeDriver

### Step 4: 환경변수 파일 설정

#### 4.1 Java 환경변수 (application.properties)

```bash
# 템플릿 복사
cp application.properties.example src/main/resources/application.properties

# 파일 편집
vim src/main/resources/application.properties
```

모든 `your-xxx` 부분을 실제 값으로 변경하세요.

**중요**: 로컬 개발과 운영 환경을 구분하세요!

```properties
# 로컬 개발
server.domain=localhost
server.port=8080
server.context=/Project_4team_war_exploded

# AWS 운영 (배포 시 사용)
server.domain=your-domain.com  # 또는 EC2 Public IP
server.port=80
server.context=
```

#### 4.2 Python 환경변수 (.env)

```bash
# 템플릿 복사
cp python/.env.example python/.env

# 파일 편집
vim python/.env
```

DB 정보를 실제 값으로 변경하세요.

### Step 5: 애플리케이션 배포

```bash
bash deploy.sh
```

배포 스크립트는 자동으로:
1. Maven 빌드 수행
2. WAR 파일 생성
3. Tomcat 중지
4. WAR 파일 배포
5. Tomcat 재시작

### Step 6: Python 크롤러 설정 (선택사항)

```bash
cd python
bash setup-crawler.sh
```

크롤러 실행:

```bash
source venv/bin/activate
python getReviews.py
python searchServiceArea.py
deactivate
```

### Step 7: 배포 확인

브라우저에서 접속:

```
http://your-ec2-public-ip:8080
```

또는 (포트 80으로 변경한 경우):

```
http://your-ec2-public-ip
```

---

## 🔧 문제 해결

### 애플리케이션이 시작되지 않는 경우

```bash
# Tomcat 로그 확인
sudo tail -f /var/lib/tomcat9/logs/catalina.out
```

흔한 오류:
- **ClassNotFoundException**: Maven 빌드 문제
- **SQLException**: DB 연결 정보 오류
- **FileNotFoundException**: `application.properties` 또는 `conf.xml` 누락

### Tomcat 관리 명령어

```bash
# 상태 확인
sudo systemctl status tomcat9

# 시작
sudo systemctl start tomcat9

# 중지
sudo systemctl stop tomcat9

# 재시작
sudo systemctl restart tomcat9

# 로그 실시간 확인
sudo tail -f /var/lib/tomcat9/logs/catalina.out
```

### Python 크롤러 오류

```bash
# 가상환경 재생성
cd python
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

---

## 🔒 보안 체크리스트

배포 전에 반드시 확인:

- [ ] DB 비밀번호 변경 완료
- [ ] Kakao API 키 재발급 완료
- [ ] `application.properties`가 Git에 커밋되지 않음 (`.gitignore` 확인)
- [ ] `python/.env`가 Git에 커밋되지 않음
- [ ] AWS 보안 그룹에서 불필요한 포트 차단
- [ ] OAuth Redirect URI가 운영 도메인으로 설정됨
- [ ] Naver/Kakao Developers 콘솔에서 Redirect URI 등록 완료

---

## 📊 성능 최적화 (선택사항)

### Nginx 리버스 프록시 설정

Tomcat 앞에 Nginx를 배치하여 성능 향상:

```bash
sudo apt-get install -y nginx

# Nginx 설정
sudo vim /etc/nginx/sites-available/default
```

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
sudo systemctl restart nginx
```

### SSL/TLS 인증서 설치 (HTTPS)

Let's Encrypt 무료 인증서:

```bash
sudo apt-get install -y certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

---

## 📝 추가 설정

### Python 크롤러 자동 실행 (Cron)

```bash
crontab -e
```

매일 새벽 2시에 리뷰 수집:

```cron
0 2 * * * cd /home/ubuntu/Project_4team/python && /home/ubuntu/Project_4team/python/venv/bin/python getReviews.py >> /home/ubuntu/crawler.log 2>&1
```

---

## 🆘 지원

문제가 발생하면:

1. 로그 확인: `sudo tail -f /var/lib/tomcat9/logs/catalina.out`
2. GitHub Issues 등록
3. 팀원에게 문의

---

## 📚 참고 자료

- [Tomcat 9 Documentation](https://tomcat.apache.org/tomcat-9.0-doc/)
- [MyBatis Documentation](https://mybatis.org/mybatis-3/)
- [AWS EC2 User Guide](https://docs.aws.amazon.com/ec2/)
- [Let's Encrypt](https://letsencrypt.org/)
