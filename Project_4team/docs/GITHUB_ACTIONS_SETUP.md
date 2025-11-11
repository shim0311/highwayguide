# GitHub Actions 설정 가이드

이 문서는 GitHub Actions를 사용한 자동 배포 설정 방법을 설명합니다.

---

## 📋 목차

1. [GitHub 저장소 생성](#github-저장소-생성)
2. [Git 재설정](#git-재설정)
3. [GitHub Secrets 설정](#github-secrets-설정)
4. [워크플로우 동작 확인](#워크플로우-동작-확인)
5. [문제 해결](#문제-해결)

---

## GitHub 저장소 생성

### 1. GitHub에서 새 저장소 생성

1. https://github.com/new 접속
2. Repository name: `highway-rest-info` (원하는 이름)
3. Public 또는 Private 선택
4. **❌ Initialize this repository with a README 체크 해제** (중요!)
5. Create repository 클릭

### 2. 저장소 URL 복사

생성된 저장소의 HTTPS URL을 복사하세요:
```
https://github.com/your-username/highway-rest-info.git
```

---

## Git 재설정

### 자동 스크립트 사용 (권장)

```bash
# 실행 권한 부여
chmod +x setup-new-git.sh

# 스크립트 실행
bash setup-new-git.sh
```

스크립트가 자동으로:
1. ✅ 기존 Git remote 제거
2. ✅ 새 저장소 연결
3. ✅ 민감정보 파일 확인
4. ✅ 초기 커밋 및 푸시

### 수동 설정

```bash
# 1. 기존 remote 제거
git remote remove origin
git remote remove upstream

# 2. 새 저장소 연결
git remote add origin https://github.com/your-username/highway-rest-info.git

# 3. 확인
git remote -v

# 4. 푸시
git branch -M main  # 또는 master
git push -u origin main --force
```

---

## GitHub Secrets 설정

### 1. GitHub Secrets 페이지 접속

```
Settings → Secrets and variables → Actions → New repository secret
```

### 2. 필수 Secrets 설정

다음 Secrets를 **모두** 추가하세요:

#### 데이터베이스 설정

| Secret Name | Value 예시 | 설명 |
|-------------|----------|------|
| `DB_URL` | `jdbc:mysql://localhost:3306/my_app_db?useSSL=false&serverTimezone=Asia/Seoul` | DB URL |
| `DB_USERNAME` | `restinfo_user` | DB 사용자명 |
| `DB_PASSWORD` | `YourStrongPassword123!` | DB 비밀번호 |

#### API Keys

| Secret Name | Value 예시 | 설명 |
|-------------|----------|------|
| `GOOGLE_SENDER_MAIL` | `your-email@gmail.com` | Gmail 주소 |
| `GOOGLE_APPLICATION_PASSWORD` | `abcd efgh ijkl mnop` | Gmail 앱 비밀번호 |
| `NAVER_CLIENT_ID` | `xxxxxxxxxxxxxxxx` | Naver Client ID |
| `NAVER_CLIENT_SECRET` | `xxxxxxxxxx` | Naver Client Secret |
| `KAKAO_CLIENT_ID` | `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` | Kakao Client ID |
| `KAKAO_API_KEY` | `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` | Kakao REST API Key |
| `EXPRESSWAY_ID` | `xxxxxxxxxxxxxxxxxx` | 고속도로 API Key |
| `TMAP_APPKEY` | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` | TMap API Key |

#### AWS S3

| Secret Name | Value 예시 | 설명 |
|-------------|----------|------|
| `AWS_ACCESS_KEY_ID` | `AKIAIOSFODNN7EXAMPLE` | AWS Access Key |
| `AWS_SECRET_ACCESS_KEY` | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` | AWS Secret Key |
| `AWS_S3_BUCKET_NAME` | `my-app-bucket` | S3 버킷 이름 |
| `AWS_S3_BUCKET_URL` | `https://my-app-bucket.s3.ap-northeast-2.amazonaws.com/` | S3 버킷 URL |

#### Server Configuration

| Secret Name | Value 예시 | 설명 |
|-------------|----------|------|
| `SERVER_DOMAIN` | `yourdomain.com` 또는 `3.34.123.456` | 서버 도메인/IP |
| `SERVER_PORT` | `8080` 또는 `80` | 서버 포트 |
| `SERVER_CONTEXT` | `` (빈 문자열) 또는 `/app` | 컨텍스트 경로 |

#### EC2 SSH 설정

| Secret Name | Value | 설명 |
|-------------|-------|------|
| `EC2_SSH_KEY` | PEM 키 파일 전체 내용 | EC2 SSH Private Key |
| `EC2_HOST` | `3.34.123.456` | EC2 Public IP |
| `EC2_USER` | `ubuntu` | EC2 사용자명 |

---

### 3. EC2 SSH 키 설정 (중요!)

#### PEM 키 내용 복사

```bash
# macOS/Linux
cat ~/.ssh/your-key.pem

# 출력된 전체 내용을 복사 (아래 형식)
```

```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA...
...전체 키 내용...
...
-----END RSA PRIVATE KEY-----
```

#### GitHub Secret에 추가

1. Secret name: `EC2_SSH_KEY`
2. Value: 위에서 복사한 **전체 내용** (BEGIN부터 END까지)
3. Add secret 클릭

---

## 워크플로우 동작 확인

### 1. 자동 배포 트리거

다음 상황에서 자동으로 배포가 시작됩니다:

- `main` 또는 `master` 브랜치에 push
- `main` 또는 `master` 브랜치로 PR merge

### 2. 수동 배포 실행

```
GitHub → Actions → Deploy to AWS EC2 → Run workflow → Run workflow
```

### 3. 워크플로우 진행 확인

```
GitHub → Actions → 실행 중인 워크플로우 클릭
```

각 단계별 로그를 실시간으로 확인할 수 있습니다:

1. ✅ Checkout code
2. ✅ Set up JDK 11
3. ✅ Create application.properties
4. ✅ Create MyBatis conf.xml
5. ✅ Build with Maven
6. ✅ Verify WAR file
7. ✅ Deploy to EC2
8. ✅ Deployment status

### 4. 배포 성공 확인

```bash
# EC2 서버에서
sudo systemctl status tomcat9

# 로그 확인
sudo tail -f /var/lib/tomcat9/logs/catalina.out
```

브라우저에서 접속:
```
http://your-server-ip:8080
```

---

## 워크플로우 흐름

```
┌─────────────────────────────────────────┐
│  1. 코드 push (main/master)              │
└──────────────┬──────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│  2. GitHub Actions 자동 실행             │
│     - JDK 11 설치                        │
│     - application.properties 생성        │
│     - conf.xml 생성                      │
└──────────────┬──────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│  3. Maven 빌드                           │
│     - mvn clean package                  │
│     - WAR 파일 생성                      │
└──────────────┬──────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│  4. EC2 배포                             │
│     - WAR 파일 전송 (SCP)                │
│     - Tomcat 재시작                      │
└──────────────┬──────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│  5. 배포 완료!                           │
│     http://your-server:8080              │
└─────────────────────────────────────────┘
```

---

## 문제 해결

### 1. "Error: Process completed with exit code 1"

**원인**: Maven 빌드 실패

**해결**:
```bash
# 로컬에서 빌드 테스트
mvn clean package

# 오류 확인 및 수정
```

### 2. "Permission denied (publickey)"

**원인**: SSH 키가 올바르지 않음

**해결**:
1. `EC2_SSH_KEY` Secret 확인
2. PEM 키 파일 전체 내용이 포함되었는지 확인
3. BEGIN/END 라인 포함 여부 확인

### 3. "Connection timed out"

**원인**: EC2 보안 그룹 설정

**해결**:
1. EC2 보안 그룹 → Inbound rules
2. SSH (22) 포트가 GitHub Actions IP에서 접근 가능한지 확인
3. 또는 `0.0.0.0/0` 허용 (주의!)

### 4. Tomcat 시작 실패

**원인**: 메모리 부족 또는 포트 충돌

**해결**:
```bash
# EC2에서
sudo systemctl status tomcat9
sudo tail -f /var/lib/tomcat9/logs/catalina.out

# 포트 확인
sudo lsof -i :8080
```

### 5. "Secret not found"

**원인**: GitHub Secrets 미설정

**해결**:
1. Settings → Secrets and variables → Actions
2. 필수 Secrets가 모두 설정되었는지 확인
3. Secret 이름 오타 확인

---

## 고급 설정

### 1. 다른 브랜치에서도 배포

`.github/workflows/deploy.yml` 수정:

```yaml
on:
  push:
    branches: [ main, master, develop ]  # develop 추가
```

### 2. PR에서는 빌드만 하고 배포 건너뛰기

현재 설정이 이미 이렇게 되어 있습니다:

```yaml
- name: Deploy to EC2
  if: github.event_name == 'push' && (github.ref == 'refs/heads/main' || github.ref == 'refs/heads/master')
```

PR에서는 빌드 테스트만 하고, `main` 브랜치 push 시에만 배포합니다.

### 3. Slack/Discord 알림 추가

워크플로우 끝에 추가:

```yaml
- name: Slack Notification
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}
```

### 4. 롤백 기능

이전 버전으로 돌아가려면:

```bash
# EC2에서
cd /var/lib/tomcat9/webapps
sudo cp ROOT.war.backup ROOT.war
sudo systemctl restart tomcat9
```

---

## 보안 권장사항

1. ✅ **절대 Secrets를 코드에 포함하지 마세요**
2. ✅ **PEM 키는 GitHub Secrets에만 저장**
3. ✅ **주기적으로 API 키 갱신**
4. ✅ **사용하지 않는 Secrets 삭제**
5. ✅ **Private 저장소 사용 권장**

---

## 참고 자료

- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [GitHub Secrets 관리](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Maven GitHub Actions](https://github.com/actions/setup-java)
