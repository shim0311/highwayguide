# GitHub Actions SSH 연결 타임아웃 해결 가이드

## 🔴 문제 증상
```
ssh: connect to host *** port 22: Connection timed out
scp: Connection closed
Error: Process completed with exit code 255.
```

## 🔍 진단 체크리스트

### 1. EC2 인스턴스 상태 확인
1. AWS Console 접속: https://console.aws.amazon.com/ec2
2. 인스턴스 목록에서 해당 인스턴스 찾기
3. **인스턴스 상태**가 `running` 인지 확인
4. **퍼블릭 IPv4 주소** 확인 (예: `3.34.123.456`)

✅ **조치**: 인스턴스가 stopped이면 시작

---

### 2. 보안 그룹 설정 확인 ⭐ 가장 중요

#### A. 현재 보안 그룹 확인
1. EC2 인스턴스 선택
2. **보안** 탭 클릭
3. **보안 그룹** 클릭 (예: `sg-xxxxxxxxx`)

#### B. Inbound 규칙 확인
**현재 규칙 예시:**
```
Type    Protocol  Port  Source          Description
SSH     TCP       22    203.0.113.0/32  My Office IP
HTTP    TCP       80    0.0.0.0/0       Public access
```

#### C. GitHub Actions IP 허용 추가

**⚠️ 문제**: GitHub Actions는 Microsoft Azure IP 범위에서 실행되므로 매번 다른 IP 사용

**해결 방법 3가지:**

##### 옵션 1: 모든 IP 허용 (가장 간단, 보안 낮음)
```
Type: SSH
Protocol: TCP
Port: 22
Source: 0.0.0.0/0
Description: GitHub Actions SSH
```

**⚠️ 주의**: 보안상 권장하지 않음

##### 옵션 2: GitHub Actions IP 범위 허용 (권장)
1. GitHub Actions IP 범위 확인:
   ```bash
   curl https://api.github.com/meta | jq -r '.actions[]'
   ```

2. 주요 IP 범위 추가 (예시):
   ```
   13.64.0.0/11
   13.104.0.0/14
   20.20.0.0/16
   20.33.0.0/16
   20.42.0.0/15
   20.96.0.0/12
   20.192.0.0/10
   40.64.0.0/10
   ```

3. 보안 그룹에 규칙 추가:
   - **Edit inbound rules** 클릭
   - **Add rule** 클릭
   - Type: `SSH`
   - Port: `22`
   - Source: `13.64.0.0/11` (위 IP 범위들을 각각 추가)
   - Description: `GitHub Actions - Azure IP Range`

##### 옵션 3: Elastic IP + 특정 IP만 허용 (가장 안전)
1. Elastic IP 할당 (고정 IP)
2. 사무실/집 IP만 SSH 허용
3. GitHub Actions는 **AWS Systems Manager Session Manager** 사용

---

### 3. GitHub Secrets 값 확인

#### A. EC2_HOST 값 확인
1. GitHub 저장소 → **Settings** → **Secrets and variables** → **Actions**
2. `EC2_HOST` Secret 확인

**올바른 값:**
- 퍼블릭 IPv4 주소: `3.34.123.456` (예시)
- 또는 Elastic IP
- 또는 도메인: `ec2-3-34-123-456.ap-northeast-2.compute.amazonaws.com`

**❌ 잘못된 값:**
- 프라이빗 IP: `172.31.x.x`
- 오래된 IP

#### B. EC2_USER 값 확인
일반적인 값:
- Ubuntu: `ubuntu`
- Amazon Linux: `ec2-user`
- RHEL: `ec2-user`

#### C. EC2_SSH_KEY 값 확인
- PEM 파일 전체 내용 (BEGIN부터 END까지)
- 줄바꿈 포함

---

### 4. 로컬에서 SSH 연결 테스트

#### A. SSH 키 파일 저장
```bash
# PEM 파일 생성
nano ec2-key.pem
# GitHub Secret의 EC2_SSH_KEY 내용 붙여넣기
chmod 600 ec2-key.pem
```

#### B. SSH 연결 테스트
```bash
# 기본 연결
ssh -i ec2-key.pem ubuntu@3.34.123.456

# 상세 디버그 모드
ssh -vvv -i ec2-key.pem ubuntu@3.34.123.456

# 타임아웃 설정
ssh -i ec2-key.pem -o ConnectTimeout=10 ubuntu@3.34.123.456
```

**성공 예시:**
```
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.15.0-1044-aws x86_64)
ubuntu@ip-172-31-x-x:~$
```

**실패 예시:**
```
ssh: connect to host 3.34.123.456 port 22: Connection timed out
```

---

### 5. VPC/네트워크 설정 확인

#### A. 서브넷 확인
1. EC2 인스턴스 → **Networking** 탭
2. **Subnet ID** 클릭
3. **Route Table** 확인:
   ```
   Destination    Target
   10.0.0.0/16    local
   0.0.0.0/0      igw-xxxxx  ← 인터넷 게이트웨이 있어야 함
   ```

#### B. Network ACL 확인
1. VPC → **Network ACLs**
2. Inbound Rules 확인:
   ```
   Rule #  Type   Protocol  Port  Source      Allow/Deny
   100     SSH    TCP       22    0.0.0.0/0   ALLOW
   ```

---

## ✅ 빠른 해결 단계

### Step 1: EC2 퍼블릭 IP 확인
```bash
# AWS CLI 사용
aws ec2 describe-instances \
  --instance-ids i-xxxxxxxxx \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text
```

### Step 2: 보안 그룹에 GitHub Actions IP 추가
```bash
# AWS CLI로 규칙 추가
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxxxxxx \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0 \
  --description "GitHub Actions SSH"
```

### Step 3: GitHub Secret 업데이트
1. EC2_HOST = 최신 퍼블릭 IP
2. EC2_USER = ubuntu (또는 ec2-user)
3. EC2_SSH_KEY = PEM 파일 내용

### Step 4: GitHub Actions 재실행
1. GitHub 저장소 → **Actions** 탭
2. 실패한 워크플로우 클릭
3. **Re-run all jobs** 클릭

---

## 🔒 보안 강화 방법

### 방법 1: Elastic IP 사용
```bash
# Elastic IP 할당
aws ec2 allocate-address --domain vpc

# Elastic IP 연결
aws ec2 associate-address \
  --instance-id i-xxxxxxxxx \
  --allocation-id eipalloc-xxxxxxxxx
```

### 방법 2: AWS Systems Manager 사용
GitHub Actions에서 SSH 대신 SSM 사용:
```yaml
- name: Deploy via SSM
  run: |
    aws ssm send-command \
      --instance-ids i-xxxxxxxxx \
      --document-name "AWS-RunShellScript" \
      --parameters 'commands=["sudo systemctl restart tomcat9"]'
```

### 방법 3: 포트 변경
SSH 포트를 22에서 다른 포트로 변경:
```bash
# EC2에서 실행
sudo sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config
sudo systemctl restart sshd
```

보안 그룹에서 포트 2222 허용

---

## 📞 추가 도움

### AWS 공식 문서
- [보안 그룹 규칙](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)
- [SSH 연결 문제 해결](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/TroubleshootingInstancesConnecting.html)

### GitHub Actions IP 범위
- [GitHub Meta API](https://api.github.com/meta)
- [GitHub IP 범위 문서](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners#ip-addresses)

---

## ✅ 체크리스트

배포 전 확인:
- [ ] EC2 인스턴스 상태: `running`
- [ ] 퍼블릭 IP 확인 및 GitHub Secret 업데이트
- [ ] 보안 그룹에 SSH 포트 22 허용 (0.0.0.0/0 또는 GitHub IP 범위)
- [ ] SSH 키 권한: `chmod 600`
- [ ] 로컬에서 SSH 연결 테스트 성공
- [ ] Tomcat이 실행 중인지 확인
- [ ] 방화벽 규칙 확인

---

**마지막 업데이트: 2025-11-13**
