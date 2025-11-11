# 데이터베이스 스키마 설정 가이드

이 문서는 `Db.sql` 파일을 서버에 전송하고 실행하는 방법을 설명합니다.

---

## 🎯 3가지 방법

### 방법 1: 자동 스크립트 사용 (가장 간단!) ⭐

#### A. 로컬에서 원격 서버로 자동 전송 + 실행

```bash
# 로컬 컴퓨터에서 실행
bash setup-database.sh <EC2-IP> <PEM-KEY>

# 예시
bash setup-database.sh 3.34.123.456 ~/.ssh/my-key.pem
```

스크립트가 자동으로:
1. SQL 파일을 EC2로 전송
2. MySQL에 데이터베이스 생성
3. 테이블 생성
4. 확인 후 SQL 파일 삭제

#### B. 서버에서 직접 실행

```bash
# EC2 서버에서
cd ~/Project_4team
bash setup-database.sh local
```

---

### 방법 2: SCP + 수동 실행

#### 1단계: 파일 전송 (로컬에서)

```bash
# Db.sql 파일 전송
scp -i your-key.pem \
    src/main/resources/Db.sql \
    ubuntu@your-ec2-ip:~/

# 여러 SQL 파일 전송
scp -i your-key.pem \
    src/main/resources/Db.sql \
    /Users/luka/Downloads/secondPrjDB.sql \
    ubuntu@your-ec2-ip:~/
```

#### 2단계: 서버에서 실행

```bash
# EC2 서버 접속
ssh -i your-key.pem ubuntu@your-ec2-ip

# MySQL에서 실행
mysql -u root -p my_app_db < ~/Db.sql

# 또는 MySQL 내에서
mysql -u root -p
```

```sql
USE my_app_db;
SOURCE /home/ubuntu/Db.sql;
SHOW TABLES;
EXIT;
```

---

### 방법 3: Git으로 전송

SQL 파일이 Git 저장소에 있는 경우:

```bash
# EC2 서버에서
cd ~/Project_4team
git pull

# SQL 파일 실행
mysql -u root -p my_app_db < src/main/resources/Db.sql
```

---

## 📊 Db.sql 파일 내용

이 파일은 다음 테이블들을 생성합니다:

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

---

## ✅ 테이블 생성 확인

```sql
-- MySQL 접속
mysql -u root -p

-- 데이터베이스 선택
USE my_app_db;

-- 테이블 목록 확인
SHOW TABLES;

-- 특정 테이블 구조 확인
DESCRIBE ServiceArea;
DESCRIBE User;

-- 테이블 개수 확인
SELECT COUNT(*) AS table_count
FROM information_schema.tables
WHERE table_schema = 'my_app_db';

-- 각 테이블의 행 개수
SELECT
    TABLE_NAME,
    TABLE_ROWS
FROM information_schema.tables
WHERE table_schema = 'my_app_db'
ORDER BY TABLE_NAME;
```

---

## 🔧 샘플 데이터 입력 (선택사항)

### 사용자 추가

```sql
INSERT INTO User (ID, NickName, Pwd, Name, Authority, Platform, Cancel)
VALUES ('admin@test.com', 'Admin', '$2a$10$...', '관리자', 1, 'local', 0);

INSERT INTO User (ID, NickName, Pwd, Name, Authority, Platform, Cancel)
VALUES ('user@test.com', 'TestUser', '$2a$10$...', '테스트', 0, 'local', 0);
```

### 휴게소 데이터

이미 있는 크롤링 데이터를 사용하거나, Python 크롤러로 수집:

```bash
cd python
source venv/bin/activate
python searchServiceArea.py
```

---

## 🚨 문제 해결

### 1. "Access denied" 오류

```bash
# MySQL root 비밀번호 확인
sudo mysql

# 비밀번호 재설정
ALTER USER 'root'@'localhost' IDENTIFIED BY 'NewPassword123!';
FLUSH PRIVILEGES;
EXIT;
```

### 2. "Database doesn't exist" 오류

```sql
-- 데이터베이스 생성
CREATE DATABASE my_app_db
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
```

### 3. "Table already exists" 오류

```sql
-- 기존 테이블 삭제 후 재생성 (주의!)
DROP DATABASE my_app_db;
CREATE DATABASE my_app_db
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- 다시 SQL 파일 실행
USE my_app_db;
SOURCE /home/ubuntu/Db.sql;
```

### 4. 파일 전송 실패

```bash
# PEM 키 권한 확인
chmod 400 your-key.pem

# 서버 연결 테스트
ssh -i your-key.pem ubuntu@your-ec2-ip "echo 'Connection OK'"

# 디스크 용량 확인
ssh -i your-key.pem ubuntu@your-ec2-ip "df -h"
```

---

## 📝 추가 작업

### 1. 데이터베이스 백업

```bash
# 백업 생성
mysqldump -u root -p my_app_db > backup_$(date +%Y%m%d).sql

# 압축 백업
mysqldump -u root -p my_app_db | gzip > backup_$(date +%Y%m%d).sql.gz
```

### 2. 인덱스 추가 (성능 향상)

```sql
-- 자주 검색하는 컬럼에 인덱스
CREATE INDEX idx_saname ON ServiceArea(SAName);
CREATE INDEX idx_direction ON ServiceArea(SADirection);
CREATE INDEX idx_user_id ON User(ID);
CREATE INDEX idx_nickname ON User(NickName);
```

### 3. 제약 조건 확인

```sql
-- 외래 키 확인
SELECT
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'my_app_db'
  AND REFERENCED_TABLE_NAME IS NOT NULL;
```

---

## 🔄 데이터베이스 마이그레이션

스키마를 수정한 후 서버에 적용:

```bash
# 1. 로컬에서 변경사항 커밋
git add src/main/resources/Db.sql
git commit -m "Update database schema"
git push

# 2. 서버에서 pull
ssh -i your-key.pem ubuntu@your-ec2-ip
cd ~/Project_4team
git pull

# 3. 백업 후 재생성
mysqldump -u root -p my_app_db > backup_before_migration.sql
mysql -u root -p my_app_db < src/main/resources/Db.sql
```

---

## 참고 문서

- [docs/EC2_MYSQL_SETUP.md](EC2_MYSQL_SETUP.md) - MySQL 설치 가이드
- [QUICKSTART.md](../QUICKSTART.md) - 빠른 시작 가이드
- [DEPLOYMENT.md](../DEPLOYMENT.md) - 전체 배포 가이드
