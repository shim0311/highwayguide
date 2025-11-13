# 🔍 SSH 연결 실패 진단 가이드

포트 22를 열어놨는데도 연결이 안 되는 경우 체크리스트

---

## ❗ 가장 흔한 실수

### 1. 보안 그룹 소스(Source) 설정 확인

**문제**: 포트는 열었지만 **소스(Source)를 잘못 설정**

#### ❌ 잘못된 설정
```
Type: SSH
Port: 22
Source: My IP (203.0.113.50/32)  ← 내 컴퓨터 IP만 허용
Description: SSH access
```

GitHub Actions는 **내 IP가 아닌 Microsoft Azure IP**에서 실행되므로 연결 불가!

#### ✅ 올바른 설정
```
Type: SSH
Port: 22
Source: 0.0.0.0/0  ← 모든 IP 허용 (또는 GitHub IP 범위)
Description: GitHub Actions SSH
```

---

## 📋 단계별 진단

### Step 1: 보안 그룹 설정 재확인 ⭐ 가장 중요

1. **AWS Console 접속**
   ```
   https://console.aws.amazon.com/ec2
   ```

2. **EC2 인스턴스 선택**
   - 왼쪽 메뉴 → **Instances**
   - 해당 인스턴스 체크

3. **보안 그룹 확인**
   - 하단 **Details** 탭
   - **Security groups** 확인 (예: `sg-0123456789abcdef0`)
   - 보안 그룹 링크 클릭

4. **Inbound rules 확인**
   - **Inbound rules** 탭 클릭
   - SSH 규칙 확인:

   ```
   Type    Protocol  Port  Source
   SSH     TCP       22    ???
   ```

5. **Source 값 확인**

   **만약 Source가 다음 중 하나라면 문제:**
   - `My IP` 또는 특정 IP (예: `203.0.113.50/32`)
   - 회사 IP 대역
   - 기타 제한된 IP

   **해결 방법:**
   - **Edit inbound rules** 클릭
   - Source를 `0.0.0.0/0` 또는 `::/0`으로 변경
   - **Save rules** 클릭

---

### Step 2: EC2 인스턴스 상태 확인

1. **인스턴스 상태**
   ```
   Instance state: running  ← 이거여야 함
   ```

   **만약 stopped이면:**
   - 인스턴스 선택
   - **Instance state** → **Start instance**

2. **퍼블릭 IP 확인**
   ```
   Public IPv4 address: 3.34.123.456  ← 이런 형식
   ```

   **만약 없으면 (—):**
   - EC2가 **프라이빗 서브넷**에 있음
   - **퍼블릭 서브넷으로 이동** 필요
   - 또는 **Elastic IP 할당**

---

### Step 3: GitHub Secrets 값 확인

1. **GitHub 저장소** → **Settings** → **Secrets and variables** → **Actions**

2. **EC2_HOST 확인**

   **올바른 값:**
   ```
   3.34.123.456  ← 퍼블릭 IPv4 주소
   ```

   **❌ 잘못된 값:**
   ```
   172.31.45.67  ← 프라이빗 IP (172.x, 10.x, 192.168.x)
   ip-172-31-45-67  ← 프라이빗 호스트명
   ```

   **확인 방법:**
   - EC2 Console → 인스턴스 선택
   - **Public IPv4 address** 복사
   - GitHub Secret `EC2_HOST`에 붙여넣기

---

### Step 4: 로컬에서 연결 테스트

**목적**: GitHub Actions 없이 직접 SSH 연결 시도

#### A. SSH 키 파일 준비
```bash
# 1. GitHub Secret의 EC2_SSH_KEY 내용 복사
# 2. 로컬에 파일 생성
nano my-ec2-key.pem

# 3. 붙여넣기 (BEGIN부터 END까지 전체)
# 4. 저장 후 권한 설정
chmod 600 my-ec2-key.pem
```

#### B. 연결 테스트
```bash
# EC2_HOST 값을 여기 입력
EC2_HOST="3.34.123.456"  # ← 실제 IP로 변경
EC2_USER="ubuntu"         # ← 실제 사용자로 변경

# 1. 포트 연결 테스트
nc -zv $EC2_HOST 22

# 결과 분석:
# ✅ "Connection to 3.34.123.456 22 port [tcp/ssh] succeeded!"
#    → 포트는 열려있음, SSH 키 문제일 수 있음
#
# ❌ "Operation timed out" 또는 "Connection refused"
#    → 보안 그룹 또는 EC2 상태 문제

# 2. SSH 연결 테스트
ssh -i my-ec2-key.pem -o ConnectTimeout=10 $EC2_USER@$EC2_HOST

# 결과 분석:
# ✅ "Welcome to Ubuntu..." → 연결 성공!
#    → GitHub Secret 값이 잘못됨
#
# ❌ "Connection timed out"
#    → 보안 그룹 또는 네트워크 문제
#
# ❌ "Permission denied (publickey)"
#    → SSH 키 문제
```

---

### Step 5: VPC/네트워크 설정 확인

#### A. 서브넷 타입 확인
```
EC2 → Instances → 인스턴스 선택 → Networking 탭
→ Subnet ID 클릭
→ Route table 확인
```

**필수 라우트:**
```
Destination       Target
10.0.0.0/16      local
0.0.0.0/0        igw-xxxxx  ← 인터넷 게이트웨이 필수!
```

**만약 igw가 없으면:**
- EC2가 인터넷에 연결 불가
- 퍼블릭 서브넷으로 이동 필요

#### B. Network ACL 확인
```
VPC → Network ACLs → 해당 NACL 선택
→ Inbound rules 확인
```

**필수 규칙:**
```
Rule #  Type   Protocol  Port  Source      Allow/Deny
100     SSH    TCP       22    0.0.0.0/0   ALLOW
*       All    All       All   0.0.0.0/0   DENY
```

---

### Step 6: EC2에서 SSH 서비스 확인

**EC2에 AWS Systems Manager로 접속 (SSH 없이)**

1. **EC2 Console** → 인스턴스 선택
2. **Connect** 버튼 클릭
3. **Session Manager** 탭
4. **Connect** 클릭

**SSH 서비스 상태 확인:**
```bash
# SSH 서비스 상태
sudo systemctl status sshd

# SSH 포트 확인
sudo netstat -tlnp | grep :22

# 방화벽 확인 (있다면)
sudo ufw status
```

---

## 🔧 빠른 해결 체크리스트

### ✅ 반드시 확인할 것

- [ ] **보안 그룹 Source가 `0.0.0.0/0`인가?** ⭐ 가장 중요
- [ ] **EC2 인스턴스 상태가 `running`인가?**
- [ ] **퍼블릭 IPv4 주소가 있는가?**
- [ ] **GitHub Secret `EC2_HOST`가 퍼블릭 IP인가?**
- [ ] **로컬에서 `nc -zv [IP] 22` 연결 되는가?**
- [ ] **로컬에서 SSH 연결 되는가?**

---

## 📊 문제별 해결 방법

### 문제 1: "Connection timed out"

**원인:**
- 보안 그룹 Source가 잘못됨
- EC2가 stopped 상태
- 잘못된 IP 사용 (프라이빗 IP)

**해결:**
```bash
# 1. 보안 그룹 Source를 0.0.0.0/0으로 변경
# 2. EC2 인스턴스 시작
# 3. EC2_HOST를 퍼블릭 IP로 업데이트
```

---

### 문제 2: "Permission denied (publickey)"

**원인:**
- EC2_SSH_KEY가 잘못됨
- EC2_USER가 잘못됨

**해결:**
```bash
# 1. PEM 파일 내용 재확인
# 2. EC2_USER 확인:
#    - Ubuntu: ubuntu
#    - Amazon Linux: ec2-user
#    - RHEL: ec2-user
```

---

### 문제 3: 로컬은 되는데 GitHub Actions는 안 됨

**원인:**
- 보안 그룹 Source에 내 IP만 허용

**해결:**
```bash
# 보안 그룹 Source를 0.0.0.0/0으로 변경
# 또는 GitHub Actions IP 범위 추가:
# 13.64.0.0/11, 13.104.0.0/14, 20.20.0.0/16 등
```

---

## 🛠️ AWS CLI로 보안 그룹 확인/수정

### 보안 그룹 확인
```bash
# 인스턴스의 보안 그룹 ID 확인
aws ec2 describe-instances \
  --instance-ids i-xxxxxxxxx \
  --query 'Reservations[0].Instances[0].SecurityGroups[*].GroupId' \
  --output text

# 보안 그룹 규칙 확인
aws ec2 describe-security-groups \
  --group-ids sg-xxxxxxxxx \
  --query 'SecurityGroups[0].IpPermissions'
```

### 보안 그룹 수정 (포트 22 전체 허용)
```bash
# SSH 포트 모든 IP 허용
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxxxxxx \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0
```

---

## 💡 추천 해결 순서

1. **먼저**: 보안 그룹 Source를 `0.0.0.0/0`로 변경
2. **그 다음**: GitHub Actions 재실행
3. **여전히 안 되면**: 로컬에서 SSH 연결 테스트
4. **로컬도 안 되면**: EC2 인스턴스/네트워크 설정 확인
5. **로컬은 되는데 GitHub Actions 안 되면**: GitHub Secrets 값 재확인

---

## 📞 추가 지원

위 모든 단계를 시도했는데도 안 되면:

1. **GitHub Actions 로그 전체** 확인
2. **AWS EC2 인스턴스 ID** 확인
3. **보안 그룹 ID** 확인
4. **VPC 구성** 확인

위 정보를 가지고 추가 진단 필요

---

**마지막 업데이트: 2025-11-13**
