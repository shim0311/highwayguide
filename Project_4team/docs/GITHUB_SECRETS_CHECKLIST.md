# GitHub Secrets 설정 체크리스트

이 문서는 GitHub Actions 자동 배포를 위해 설정해야 하는 모든 Secrets 목록입니다.

## 🔗 설정 위치

```
https://github.com/shim0311/highwayguide/settings/secrets/actions
```

Settings → Secrets and variables → Actions → New repository secret

---

## ✅ 설정할 Secrets (총 23개)

### 1️⃣ 데이터베이스 (3개)

```
Name: DB_URL
Value: jdbc:mysql://localhost:3306/my_app_db?useSSL=false&serverTimezone=Asia/Seoul
(EC2 MySQL 사용 시 localhost, RDS 사용 시 RDS 엔드포인트)

Name: DB_USERNAME
Value: restinfo_user

Name: DB_PASSWORD
Value: [강력한 비밀번호]
```

### 2️⃣ Google Mail - 비밀번호 찾기 기능 (2개)

```
Name: GOOGLE_SENDER_MAIL
Value: [본인 Gmail 주소]

Name: GOOGLE_APPLICATION_PASSWORD
Value: [Gmail 앱 비밀번호 16자]
```

📌 Gmail 앱 비밀번호 생성: https://myaccount.google.com/apppasswords

### 3️⃣ Naver OAuth - 소셜 로그인 (2개)

```
Name: NAVER_CLIENT_ID
Value: [Naver Developers에서 발급받은 Client ID]

Name: NAVER_CLIENT_SECRET
Value: [Naver Developers에서 발급받은 Client Secret]
```

📌 Naver Developers: https://developers.naver.com/apps

### 4️⃣ Kakao - 소셜 로그인 & 지도 API (2개)

```
Name: KAKAO_CLIENT_ID
Value: [Kakao Developers 앱 키]

Name: KAKAO_API_KEY
Value: [Kakao REST API 키]
```

📌 Kakao Developers: https://developers.kakao.com/

### 5️⃣ 고속도로 공공데이터 (1개)

```
Name: EXPRESSWAY_ID
Value: [고속도로 공공데이터 포털에서 발급받은 API 키]
```

📌 고속도로 공공데이터: https://data.ex.co.kr/

### 6️⃣ TMap API (1개)

```
Name: TMAP_APPKEY
Value: [TMap API 키]
```

📌 TMap API: https://tmapapi.sktelecom.com/

### 7️⃣ AWS S3 - 이미지 업로드 (4개)

```
Name: AWS_ACCESS_KEY_ID
Value: [AWS IAM Access Key ID]

Name: AWS_SECRET_ACCESS_KEY
Value: [AWS IAM Secret Access Key]

Name: AWS_S3_BUCKET_NAME
Value: [S3 버킷 이름]

Name: AWS_S3_BUCKET_URL
Value: https://[버킷이름].s3.ap-northeast-2.amazonaws.com/
```

📌 AWS IAM: https://console.aws.amazon.com/iam/

### 8️⃣ 서버 설정 (3개)

```
Name: SERVER_DOMAIN
Value: [EC2 퍼블릭 IP 또는 도메인]
예시: 3.34.123.456 또는 yourdomain.com

Name: SERVER_PORT
Value: 80

Name: SERVER_CONTEXT
Value: (비워두기 - 루트 컨텍스트)
```

### 9️⃣ EC2 배포 설정 (4개)

```
Name: EC2_HOST
Value: [EC2 퍼블릭 IP 주소]
예시: 3.34.123.456

Name: EC2_USERNAME
Value: ubuntu

Name: EC2_SSH_KEY
Value: [PEM 파일 전체 내용]
⚠️ 중요: -----BEGIN RSA PRIVATE KEY-----부터 -----END RSA PRIVATE KEY-----까지 전체 복사

Name: EC2_TARGET_PATH
Value: /home/ubuntu/Project_4team
```

---

## 📝 EC2 SSH 키 설정 방법

### PEM 파일 내용 복사하는 방법:

```bash
# macOS/Linux
cat your-key.pem

# 출력 전체를 복사해서 EC2_SSH_KEY에 붙여넣기
```

예시:
```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAwU...
(여러 줄)
...xyz123==
-----END RSA PRIVATE KEY-----
```

---

## 🔍 설정 확인 체크리스트

설정 완료 후 체크하세요:

- [ ] DB_URL (데이터베이스 URL)
- [ ] DB_USERNAME (DB 사용자명)
- [ ] DB_PASSWORD (DB 비밀번호)
- [ ] GOOGLE_SENDER_MAIL (Gmail 주소)
- [ ] GOOGLE_APPLICATION_PASSWORD (Gmail 앱 비밀번호)
- [ ] NAVER_CLIENT_ID (네이버 Client ID)
- [ ] NAVER_CLIENT_SECRET (네이버 Client Secret)
- [ ] KAKAO_CLIENT_ID (카카오 Client ID)
- [ ] KAKAO_API_KEY (카카오 REST API 키)
- [ ] EXPRESSWAY_ID (고속도로 API 키)
- [ ] TMAP_APPKEY (TMap API 키)
- [ ] AWS_ACCESS_KEY_ID (AWS Access Key)
- [ ] AWS_SECRET_ACCESS_KEY (AWS Secret Key)
- [ ] AWS_S3_BUCKET_NAME (S3 버킷 이름)
- [ ] AWS_S3_BUCKET_URL (S3 버킷 URL)
- [ ] SERVER_DOMAIN (서버 도메인/IP)
- [ ] SERVER_PORT (서버 포트)
- [ ] SERVER_CONTEXT (서버 컨텍스트)
- [ ] EC2_HOST (EC2 IP)
- [ ] EC2_USERNAME (EC2 사용자명)
- [ ] EC2_SSH_KEY (PEM 키 전체 내용)
- [ ] EC2_TARGET_PATH (배포 경로)

**총 22개 Secrets 설정 필요**

---

## 🚀 설정 완료 후

1. GitHub 저장소에 코드 push:
   ```bash
   git push origin dev
   ```

2. Actions 탭에서 워크플로우 실행 확인:
   ```
   https://github.com/shim0311/highwayguide/actions
   ```

3. 배포 성공 시 브라우저에서 확인:
   ```
   http://[EC2_IP]
   ```

---

## ⚠️ 주의사항

1. **Secrets는 한 번 저장하면 다시 볼 수 없습니다**
   - 값을 기록해두거나, application.properties.example 파일에 실제 값을 로컬에만 보관하세요

2. **PEM 키는 절대 Git에 커밋하지 마세요**
   - .gitignore에 *.pem이 이미 추가되어 있습니다

3. **API 키들은 각 서비스에서 재발급 가능합니다**
   - 노출 시 즉시 재발급하세요

4. **데이터베이스 비밀번호는 강력하게 설정**
   - 최소 12자 이상, 영문 대소문자, 숫자, 특수문자 조합

---

## 📚 관련 문서

- [GITHUB_ACTIONS_SETUP.md](docs/GITHUB_ACTIONS_SETUP.md) - 상세 설정 가이드
- [DEPLOYMENT.md](DEPLOYMENT.md) - 전체 배포 가이드
- [application.properties.example](application.properties.example) - 설정 템플릿
