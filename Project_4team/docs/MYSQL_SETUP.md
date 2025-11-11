# MySQL 설정 가이드

이 문서는 프로젝트에서 MySQL을 설정하는 방법을 설명합니다.

---

## 목차

1. [AWS RDS MySQL 사용 (운영 환경)](#aws-rds-mysql)
2. [로컬 MySQL 설치 (개발 환경)](#로컬-mysql-설치)
3. [데이터베이스 스키마 생성](#데이터베이스-스키마)
4. [연결 테스트](#연결-테스트)

---

## AWS RDS MySQL

### 현재 RDS 정보

- **엔드포인트**: `restinfo-db-instance.c50u4mqy2h6b.ap-northeast-2.rds.amazonaws.com`
- **포트**: `3306`
- **데이터베이스**: `my_app_db`
- **사용자**: `admin`
- **비밀번호**: ⚠️ **GitHub에 노출되어 즉시 변경 필요!**

### 🚨 비밀번호 변경 (즉시 조치!)

#### 1. AWS Console에서 변경

```
1. AWS Console 로그인
2. Services → RDS → Databases
3. 'restinfo-db-instance' 클릭
4. 'Modify' 버튼 클릭
5. 'New master password' 입력 (강력한 비밀번호 사용)
6. 'Continue' → 'Apply immediately' 선택 → 'Modify DB instance'
```

#### 2. 환경변수 파일 업데이트

**Java 설정** (`src/main/resources/application.properties`):

```properties
db.password=YOUR_NEW_SECURE_PASSWORD
```

**Python 설정** (`python/.env`):

```bash
DB_PASSWORD=YOUR_NEW_SECURE_PASSWORD
```

### RDS 보안 그룹 설정

EC2에서 RDS에 접속하려면 보안 그룹 설정이 필요합니다:

```
1. AWS Console → RDS → Databases → restinfo-db-instance
2. 'Connectivity & security' 탭 클릭
3. 'VPC security groups' 클릭
4. 'Inbound rules' 탭
5. 'Edit inbound rules' 클릭
6. 'Add rule':
   - Type: MySQL/Aurora
   - Port: 3306
   - Source: EC2 인스턴스의 보안 그룹 또는 IP
7. 'Save rules'
```

---

## 로컬 MySQL 설치

개발 환경에서 로컬 MySQL을 사용하는 방법입니다.

### macOS

#### Homebrew로 설치

```bash
# MySQL 설치
brew install mysql

# MySQL 서비스 시작
brew services start mysql

# MySQL 버전 확인
mysql --version
```

#### 초기 보안 설정

```bash
mysql_secure_installation
```

프롬프트에서:
- `Set root password?` → **Y** → 강력한 비밀번호 입력
- `Remove anonymous users?` → **Y**
- `Disallow root login remotely?` → **Y**
- `Remove test database?` → **Y**
- `Reload privilege tables now?` → **Y**

#### MySQL 접속

```bash
mysql -u root -p
```

### Ubuntu/Debian

```bash
# MySQL 설치
sudo apt-get update
sudo apt-get install mysql-server

# MySQL 서비스 시작
sudo systemctl start mysql
sudo systemctl enable mysql

# 초기 보안 설정
sudo mysql_secure_installation
```

### Windows

1. [MySQL Community Server 다운로드](https://dev.mysql.com/downloads/mysql/)
2. 설치 프로그램 실행
3. "Developer Default" 선택
4. Root 비밀번호 설정
5. MySQL 서비스 시작

---

## 데이터베이스 스키마

### 1. 데이터베이스 생성

```sql
-- MySQL 접속
mysql -u root -p

-- 데이터베이스 생성
CREATE DATABASE my_app_db
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- 사용자 생성 (선택사항 - 보안 강화)
CREATE USER 'restinfo_user'@'localhost' IDENTIFIED BY 'strong_password';
CREATE USER 'restinfo_user'@'%' IDENTIFIED BY 'strong_password';

-- 권한 부여
GRANT ALL PRIVILEGES ON my_app_db.* TO 'restinfo_user'@'localhost';
GRANT ALL PRIVILEGES ON my_app_db.* TO 'restinfo_user'@'%';

FLUSH PRIVILEGES;

-- 데이터베이스 선택
USE my_app_db;
```

### 2. 테이블 생성

프로젝트에 SQL 파일이 있다면:

```bash
# SQL 파일 실행 (예시)
mysql -u root -p my_app_db < /Users/luka/Downloads/secondPrjDB.sql
```

또는 MySQL 내에서:

```sql
USE my_app_db;
SOURCE /Users/luka/Downloads/secondPrjDB.sql;
```

### 3. 테이블 확인

```sql
-- 모든 테이블 확인
SHOW TABLES;

-- 특정 테이블 구조 확인
DESCRIBE ServiceArea;
DESCRIBE User;
```

---

## 환경변수 설정

### 로컬 개발 환경

**Java** (`src/main/resources/application.properties`):

```properties
# 로컬 MySQL 설정
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://localhost:3306/my_app_db?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8
db.username=root
db.password=YOUR_LOCAL_MYSQL_PASSWORD
```

**Python** (`python/.env`):

```bash
# 로컬 MySQL 설정
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=YOUR_LOCAL_MYSQL_PASSWORD
DB_NAME=my_app_db
DB_CHARSET=utf8
```

### AWS 운영 환경

**Java** (`src/main/resources/application.properties`):

```properties
# AWS RDS MySQL 설정
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://restinfo-db-instance.c50u4mqy2h6b.ap-northeast-2.rds.amazonaws.com:3306/my_app_db?useSSL=true&serverTimezone=Asia/Seoul&characterEncoding=UTF-8
db.username=admin
db.password=YOUR_RDS_PASSWORD
```

**Python** (`python/.env`):

```bash
# AWS RDS MySQL 설정
DB_HOST=restinfo-db-instance.c50u4mqy2h6b.ap-northeast-2.rds.amazonaws.com
DB_PORT=3306
DB_USER=admin
DB_PASSWORD=YOUR_RDS_PASSWORD
DB_NAME=my_app_db
DB_CHARSET=utf8
```

---

## 연결 테스트

### Java에서 테스트

`src/main/java/test/DBConnectionTest.java` 생성:

```java
package test;

import mybatis.service.FactoryService;
import org.apache.ibatis.session.SqlSession;

public class DBConnectionTest {
    public static void main(String[] args) {
        try {
            SqlSession session = FactoryService.getFactory().openSession();
            System.out.println("✅ 데이터베이스 연결 성공!");
            System.out.println("Connection: " + session.getConnection());
            session.close();
        } catch (Exception e) {
            System.err.println("❌ 데이터베이스 연결 실패!");
            e.printStackTrace();
        }
    }
}
```

실행:

```bash
mvn compile
mvn exec:java -Dexec.mainClass="test.DBConnectionTest"
```

### Python에서 테스트

`python/test_db.py` 생성:

```python
import os
from dotenv import load_dotenv
import mysql.connector

# .env 파일 로드
load_dotenv()

try:
    conn = mysql.connector.connect(
        host=os.getenv("DB_HOST"),
        port=int(os.getenv("DB_PORT", "3306")),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        database=os.getenv("DB_NAME"),
        charset=os.getenv("DB_CHARSET", "utf8")
    )

    print("✅ 데이터베이스 연결 성공!")
    print(f"연결 정보: {conn.get_server_info()}")

    cursor = conn.cursor()
    cursor.execute("SELECT DATABASE()")
    db_name = cursor.fetchone()[0]
    print(f"현재 데이터베이스: {db_name}")

    cursor.close()
    conn.close()

except mysql.connector.Error as e:
    print(f"❌ 데이터베이스 연결 실패!")
    print(f"에러: {e}")
```

실행:

```bash
cd python
source venv/bin/activate
python test_db.py
```

### 명령줄에서 직접 테스트

```bash
# 로컬 MySQL
mysql -u root -p -e "SELECT 1;"

# RDS MySQL
mysql -h restinfo-db-instance.c50u4mqy2h6b.ap-northeast-2.rds.amazonaws.com \
      -u admin \
      -p \
      -D my_app_db \
      -e "SELECT DATABASE();"
```

---

## 문제 해결

### 1. "Access denied for user" 오류

**원인**: 비밀번호가 틀렸거나 사용자가 없음

**해결**:
```sql
-- MySQL root로 접속
mysql -u root -p

-- 비밀번호 재설정
ALTER USER 'admin'@'%' IDENTIFIED BY 'new_password';
FLUSH PRIVILEGES;
```

### 2. "Can't connect to MySQL server" 오류

**원인**: MySQL 서비스가 실행 중이 아님

**해결**:
```bash
# macOS
brew services restart mysql

# Ubuntu
sudo systemctl restart mysql

# 상태 확인
brew services list  # macOS
sudo systemctl status mysql  # Ubuntu
```

### 3. "Unknown database 'my_app_db'" 오류

**원인**: 데이터베이스가 생성되지 않음

**해결**:
```sql
CREATE DATABASE my_app_db
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
```

### 4. RDS 연결 타임아웃

**원인**: 보안 그룹 설정 문제

**해결**:
1. RDS 보안 그룹에서 3306 포트 개방
2. EC2 인스턴스의 IP/보안 그룹을 Inbound 규칙에 추가
3. VPC 설정 확인 (같은 VPC 내에 있어야 함)

### 5. "Public Key Retrieval is not allowed" 오류

**원인**: MySQL 8.0+ 인증 방식 문제

**해결**:
```properties
# application.properties에 추가
db.url=jdbc:mysql://localhost:3306/my_app_db?allowPublicKeyRetrieval=true&useSSL=false
```

---

## 유용한 SQL 명령어

### 데이터베이스 관리

```sql
-- 모든 데이터베이스 확인
SHOW DATABASES;

-- 현재 데이터베이스 확인
SELECT DATABASE();

-- 데이터베이스 삭제 (주의!)
DROP DATABASE my_app_db;

-- 데이터베이스 크기 확인
SELECT
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.TABLES
WHERE table_schema = 'my_app_db'
GROUP BY table_schema;
```

### 테이블 관리

```sql
-- 테이블 목록
SHOW TABLES;

-- 테이블 구조
DESCRIBE ServiceArea;

-- 테이블 생성문 확인
SHOW CREATE TABLE ServiceArea;

-- 테이블 데이터 개수
SELECT COUNT(*) FROM ServiceArea;

-- 테이블 비우기 (데이터만 삭제)
TRUNCATE TABLE ServiceArea;

-- 테이블 삭제
DROP TABLE ServiceArea;
```

### 사용자 관리

```sql
-- 모든 사용자 확인
SELECT User, Host FROM mysql.user;

-- 사용자 권한 확인
SHOW GRANTS FOR 'admin'@'%';

-- 사용자 삭제
DROP USER 'username'@'localhost';
```

### 백업 및 복구

```bash
# 데이터베이스 백업
mysqldump -u root -p my_app_db > backup_$(date +%Y%m%d).sql

# 특정 테이블만 백업
mysqldump -u root -p my_app_db ServiceArea User > tables_backup.sql

# 복구
mysql -u root -p my_app_db < backup_20250111.sql
```

---

## 성능 최적화

### 인덱스 확인 및 생성

```sql
-- 인덱스 확인
SHOW INDEX FROM ServiceArea;

-- 인덱스 생성 (예시)
CREATE INDEX idx_saname ON ServiceArea(SAname);
CREATE INDEX idx_direction ON ServiceArea(SADirection);

-- 복합 인덱스
CREATE INDEX idx_name_direction ON ServiceArea(SAname, SADirection);
```

### 쿼리 성능 분석

```sql
-- 쿼리 실행 계획 확인
EXPLAIN SELECT * FROM ServiceArea WHERE SAname = '안성휴게소';

-- 느린 쿼리 로그 활성화
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2;  -- 2초 이상 걸리는 쿼리 로깅
```

---

## 보안 권장사항

1. ✅ **강력한 비밀번호 사용**: 최소 12자, 대소문자+숫자+특수문자
2. ✅ **root 원격 접속 차단**: `'root'@'localhost'`만 허용
3. ✅ **애플리케이션용 전용 사용자 생성**: root 대신 제한된 권한 사용
4. ✅ **정기적인 백업**: cron으로 자동 백업 설정
5. ✅ **SSL/TLS 사용**: 운영 환경에서 암호화된 연결 사용
6. ✅ **불필요한 포트 차단**: 보안 그룹에서 3306 포트 제한

---

## 참고 자료

- [MySQL 8.0 공식 문서](https://dev.mysql.com/doc/refman/8.0/en/)
- [AWS RDS for MySQL](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html)
- [MyBatis 공식 문서](https://mybatis.org/mybatis-3/)
- [MySQL Connector/J](https://dev.mysql.com/doc/connector-j/8.0/en/)
