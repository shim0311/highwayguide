# EC2 Ubuntu 서버에 MySQL 설치 및 설정 가이드

팀 프로젝트를 개인 서버에 배포할 때, RDS 대신 EC2에 MySQL을 직접 설치하는 방법입니다.

---

## 📋 목차

1. [MySQL 설치](#mysql-설치)
2. [보안 설정](#보안-설정)
3. [데이터베이스 생성](#데이터베이스-생성)
4. [원격 접속 설정](#원격-접속-설정)
5. [백업 설정](#백업-설정)
6. [환경변수 설정](#환경변수-설정)

---

## MySQL 설치

### 1. EC2 서버 접속

```bash
ssh -i your-key.pem ubuntu@your-ec2-public-ip
```

### 2. MySQL 설치

```bash
# 패키지 업데이트
sudo apt update
sudo apt upgrade -y

# MySQL Server 설치
sudo apt install mysql-server -y

# 설치 확인
mysql --version
```

### 3. MySQL 서비스 시작

```bash
# MySQL 시작
sudo systemctl start mysql

# 부팅 시 자동 시작 설정
sudo systemctl enable mysql

# 상태 확인
sudo systemctl status mysql
```

---

## 보안 설정

### 1. MySQL 초기 보안 설정

```bash
sudo mysql_secure_installation
```

프롬프트에 따라 진행:

```
1. VALIDATE PASSWORD COMPONENT?
   → y (비밀번호 강도 검증 활성화)

2. Password validation policy level
   → 2 (STRONG - 권장)

3. Set root password?
   → y
   → 강력한 비밀번호 입력 (예: MySecureP@ssw0rd2025!)

4. Remove anonymous users?
   → y (익명 사용자 제거)

5. Disallow root login remotely?
   → y (root 원격 로그인 차단)

6. Remove test database?
   → y (테스트 DB 제거)

7. Reload privilege tables now?
   → y (권한 테이블 즉시 적용)
```

### 2. Root 비밀번호 설정 (다른 방법)

만약 위 방법으로 안 되면:

```bash
# MySQL root로 접속 (비밀번호 없음)
sudo mysql

# root 비밀번호 설정
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'YourStrongPassword123!';
FLUSH PRIVILEGES;
EXIT;

# 이제 비밀번호로 접속 가능
mysql -u root -p
```

---

## 데이터베이스 생성

### 1. MySQL 접속

```bash
mysql -u root -p
# 비밀번호 입력
```

### 2. 데이터베이스 및 사용자 생성

```sql
-- 데이터베이스 생성
CREATE DATABASE my_app_db
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- 애플리케이션 전용 사용자 생성 (보안 강화)
-- localhost에서만 접속 가능 (같은 서버)
CREATE USER 'restinfo_user'@'localhost' IDENTIFIED BY 'AppPassword2025!';

-- 모든 IP에서 접속 가능 (필요한 경우만)
CREATE USER 'restinfo_user'@'%' IDENTIFIED BY 'AppPassword2025!';

-- 권한 부여
GRANT ALL PRIVILEGES ON my_app_db.* TO 'restinfo_user'@'localhost';
GRANT ALL PRIVILEGES ON my_app_db.* TO 'restinfo_user'@'%';

-- 권한 적용
FLUSH PRIVILEGES;

-- 사용자 확인
SELECT User, Host FROM mysql.user;

-- 데이터베이스 선택
USE my_app_db;
```

### 3. SQL 파일로 테이블 생성

로컬에 SQL 파일이 있다면:

**방법 1: 파일을 서버에 업로드**

```bash
# 로컬에서 실행
scp -i your-key.pem /Users/luka/Downloads/secondPrjDB.sql ubuntu@your-ec2-ip:~/

# 서버에서 실행
mysql -u root -p my_app_db < ~/secondPrjDB.sql
```

**방법 2: MySQL 내에서 실행**

```sql
USE my_app_db;
SOURCE /home/ubuntu/secondPrjDB.sql;
```

### 4. 테이블 확인

```sql
-- 테이블 목록
SHOW TABLES;

-- 특정 테이블 구조
DESCRIBE ServiceArea;

-- 데이터 개수 확인
SELECT COUNT(*) FROM ServiceArea;
```

---

## 원격 접속 설정

### 1. MySQL 설정 파일 수정

```bash
sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf
```

다음 줄을 찾아서 수정:

```ini
# 기존
bind-address = 127.0.0.1

# 변경 (모든 IP에서 접속 허용)
bind-address = 0.0.0.0
```

### 2. MySQL 재시작

```bash
sudo systemctl restart mysql
```

### 3. 방화벽 설정 (UFW 사용 시)

```bash
# MySQL 포트 개방
sudo ufw allow 3306/tcp

# 상태 확인
sudo ufw status
```

### 4. AWS 보안 그룹 설정

```
1. AWS Console → EC2 → Security Groups
2. 사용 중인 보안 그룹 선택
3. Inbound rules → Edit inbound rules
4. Add rule:
   - Type: MySQL/Aurora
   - Protocol: TCP
   - Port range: 3306
   - Source:
     * Custom: 0.0.0.0/0 (모든 IP - 주의!)
     * 또는 My IP (본인 IP만)
     * 또는 EC2 보안 그룹 (같은 VPC 내에서만)
5. Save rules
```

**⚠️ 보안 경고**:
- `0.0.0.0/0` (모든 IP 허용)은 보안상 위험합니다!
- 가능하면 특정 IP만 허용하세요.
- 또는 애플리케이션과 같은 서버에 설치하여 `localhost`만 사용하세요.

### 5. 연결 테스트

**로컬에서 EC2 MySQL 접속**:

```bash
mysql -h your-ec2-public-ip -u restinfo_user -p
```

성공하면 ✅ MySQL 프롬프트가 나타납니다!

---

## 백업 설정

### 1. 수동 백업

```bash
# 전체 데이터베이스 백업
mysqldump -u root -p my_app_db > backup_$(date +%Y%m%d_%H%M%S).sql

# 특정 테이블만 백업
mysqldump -u root -p my_app_db ServiceArea User > tables_backup.sql

# 압축하여 백업
mysqldump -u root -p my_app_db | gzip > backup_$(date +%Y%m%d).sql.gz
```

### 2. 자동 백업 스크립트

```bash
# 백업 스크립트 생성
sudo vim /usr/local/bin/mysql_backup.sh
```

```bash
#!/bin/bash
# MySQL 자동 백업 스크립트

BACKUP_DIR="/home/ubuntu/mysql_backups"
DB_NAME="my_app_db"
DB_USER="root"
DB_PASS="YourRootPassword"
DATE=$(date +%Y%m%d_%H%M%S)

# 백업 디렉토리 생성
mkdir -p $BACKUP_DIR

# 백업 실행
mysqldump -u $DB_USER -p$DB_PASS $DB_NAME | gzip > $BACKUP_DIR/backup_$DATE.sql.gz

# 7일 이상 된 백업 삭제
find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +7 -delete

echo "백업 완료: backup_$DATE.sql.gz"
```

```bash
# 실행 권한 부여
sudo chmod +x /usr/local/bin/mysql_backup.sh

# 테스트
sudo /usr/local/bin/mysql_backup.sh
```

### 3. Cron으로 자동 백업

```bash
# crontab 편집
crontab -e
```

```cron
# 매일 새벽 2시에 백업
0 2 * * * /usr/local/bin/mysql_backup.sh >> /home/ubuntu/backup.log 2>&1
```

### 4. 백업 복구

```bash
# 압축된 백업 복구
gunzip < backup_20250111_020000.sql.gz | mysql -u root -p my_app_db

# 일반 백업 복구
mysql -u root -p my_app_db < backup_20250111_020000.sql
```

---

## 환경변수 설정

### 1. Java 설정 (application.properties)

```properties
# Database Configuration (로컬 MySQL)
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://localhost:3306/my_app_db?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8
db.username=restinfo_user
db.password=AppPassword2025!

# 또는 같은 서버의 공개 IP 사용
# db.url=jdbc:mysql://your-ec2-private-ip:3306/my_app_db?useSSL=false&serverTimezone=Asia/Seoul
```

### 2. Python 설정 (.env)

```bash
# 로컬 MySQL (같은 서버)
DB_HOST=localhost
DB_PORT=3306
DB_USER=restinfo_user
DB_PASSWORD=AppPassword2025!
DB_NAME=my_app_db
DB_CHARSET=utf8

# 또는 EC2 Private IP 사용
# DB_HOST=172.31.x.x
```

### 3. 연결 테스트

```bash
# Python 테스트
cd python
python3 test_db.py
```

성공하면:
```
✅ 데이터베이스 연결 성공!
📊 MySQL 버전: 8.0.xx-Ubuntu
📁 현재 데이터베이스: my_app_db
📋 테이블 목록 (x개):
  - ServiceArea: 100개 행
  - User: 50개 행
  ...
```

---

## 성능 최적화

### 1. MySQL 메모리 설정

```bash
sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf
```

```ini
[mysqld]
# 기본 설정
max_connections = 100
connect_timeout = 10
wait_timeout = 600

# 메모리 최적화 (EC2 t2.micro: 1GB RAM 기준)
innodb_buffer_pool_size = 256M
innodb_log_file_size = 64M

# 쿼리 캐시 (MySQL 5.7 이하)
# query_cache_size = 16M
# query_cache_limit = 1M

# 로그 설정
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow-query.log
long_query_time = 2
```

```bash
# MySQL 재시작
sudo systemctl restart mysql
```

### 2. 인덱스 최적화

```sql
-- 자주 검색하는 컬럼에 인덱스 생성
CREATE INDEX idx_saname ON ServiceArea(SAname);
CREATE INDEX idx_direction ON ServiceArea(SADirection);

-- 복합 인덱스
CREATE INDEX idx_name_dir ON ServiceArea(SAname, SADirection);

-- 인덱스 확인
SHOW INDEX FROM ServiceArea;
```

---

## 모니터링

### 1. MySQL 상태 확인

```sql
-- 현재 연결 확인
SHOW PROCESSLIST;

-- 데이터베이스 크기 확인
SELECT
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.TABLES
WHERE table_schema = 'my_app_db'
GROUP BY table_schema;

-- 테이블별 크기
SELECT
    table_name AS 'Table',
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)'
FROM information_schema.TABLES
WHERE table_schema = 'my_app_db'
ORDER BY (data_length + index_length) DESC;
```

### 2. 로그 확인

```bash
# 에러 로그
sudo tail -f /var/log/mysql/error.log

# 느린 쿼리 로그
sudo tail -f /var/log/mysql/slow-query.log

# 일반 쿼리 로그 (필요 시)
sudo tail -f /var/log/mysql/mysql.log
```

---

## 문제 해결

### 1. "Access denied" 오류

```sql
-- MySQL root로 접속
sudo mysql

-- 사용자 비밀번호 재설정
ALTER USER 'restinfo_user'@'localhost' IDENTIFIED BY 'NewPassword123!';
FLUSH PRIVILEGES;
```

### 2. "Can't connect to MySQL server" 오류

```bash
# MySQL 실행 확인
sudo systemctl status mysql

# MySQL 재시작
sudo systemctl restart mysql

# 포트 확인
sudo netstat -tulpn | grep 3306
```

### 3. 디스크 용량 부족

```bash
# 디스크 사용량 확인
df -h

# MySQL 데이터 디렉토리 크기
sudo du -sh /var/lib/mysql

# 오래된 로그 삭제
sudo rm /var/log/mysql/*.log.1
```

### 4. 메모리 부족

```bash
# 메모리 사용량 확인
free -h

# MySQL 프로세스 메모리 확인
ps aux | grep mysql

# MySQL 재시작 (메모리 해제)
sudo systemctl restart mysql
```

---

## 보안 체크리스트

- [ ] Root 비밀번호를 강력하게 설정
- [ ] 애플리케이션 전용 사용자 생성 (root 직접 사용 금지)
- [ ] 원격 접속이 필요 없으면 bind-address를 127.0.0.1로 유지
- [ ] AWS 보안 그룹에서 3306 포트를 특정 IP만 허용
- [ ] 정기적인 백업 설정 (cron)
- [ ] 백업 파일 암호화 (중요한 경우)
- [ ] SSL/TLS 연결 사용 (운영 환경)
- [ ] 불필요한 테스트 데이터베이스 삭제
- [ ] MySQL 버전을 최신으로 유지

---

## 비용 절감 팁

RDS 대신 EC2에 MySQL을 설치하면:

- ✅ **비용 절감**: RDS 추가 비용 없음
- ✅ **완전한 제어**: 설정 자유롭게 변경 가능
- ⚠️ **관리 부담**: 백업, 모니터링 직접 관리 필요
- ⚠️ **가용성**: 수동으로 HA 구성 필요

**추천**:
- 개인 프로젝트/포트폴리오: EC2 MySQL
- 운영 서비스: RDS (자동 백업, Multi-AZ 등)

---

## 참고 자료

- [MySQL 8.0 Documentation](https://dev.mysql.com/doc/refman/8.0/en/)
- [Ubuntu MySQL Installation](https://ubuntu.com/server/docs/databases-mysql)
- [MySQL Performance Tuning](https://dev.mysql.com/doc/refman/8.0/en/optimization.html)
