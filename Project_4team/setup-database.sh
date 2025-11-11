#!/bin/bash
# =============================================================================
# 데이터베이스 스키마 설정 스크립트
# =============================================================================
# 사용법 1 (로컬에서 원격 서버로): bash setup-database.sh <EC2-IP> <PEM-KEY>
# 사용법 2 (서버에서 직접): bash setup-database.sh local
# =============================================================================

set -e

# 색상 코드
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# SQL 파일 경로
SQL_FILE="src/main/resources/Db.sql"

# 로컬 실행인지 원격 실행인지 확인
if [ "$1" == "local" ]; then
    # ==========================================
    # 서버에서 직접 실행하는 경우
    # ==========================================
    log_info "로컬 MySQL에 스키마 생성 시작..."

    if [ ! -f "$SQL_FILE" ]; then
        log_error "SQL 파일을 찾을 수 없습니다: $SQL_FILE"
        exit 1
    fi

    # MySQL 접속 정보 입력
    read -p "MySQL root 비밀번호: " -s MYSQL_PASSWORD
    echo ""

    # 데이터베이스 생성
    log_info "데이터베이스 생성 중..."
    mysql -u root -p"$MYSQL_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS my_app_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

    # 스키마 생성
    log_info "테이블 생성 중..."
    mysql -u root -p"$MYSQL_PASSWORD" my_app_db < "$SQL_FILE"

    # 확인
    log_info "생성된 테이블 확인..."
    mysql -u root -p"$MYSQL_PASSWORD" my_app_db -e "SHOW TABLES;"

    log_info "✅ 데이터베이스 스키마 생성 완료!"

else
    # ==========================================
    # 로컬에서 원격 서버로 전송하는 경우
    # ==========================================
    if [ -z "$1" ] || [ -z "$2" ]; then
        log_error "사용법: bash setup-database.sh <EC2-IP> <PEM-KEY>"
        log_info "예시: bash setup-database.sh 3.34.123.456 ~/.ssh/my-key.pem"
        log_info "또는 서버에서 직접 실행: bash setup-database.sh local"
        exit 1
    fi

    EC2_IP=$1
    PEM_KEY=$2

    if [ ! -f "$PEM_KEY" ]; then
        log_error "PEM 키 파일을 찾을 수 없습니다: $PEM_KEY"
        exit 1
    fi

    if [ ! -f "$SQL_FILE" ]; then
        log_error "SQL 파일을 찾을 수 없습니다: $SQL_FILE"
        exit 1
    fi

    log_info "EC2 서버로 SQL 파일 전송 중..."
    scp -i "$PEM_KEY" "$SQL_FILE" ubuntu@$EC2_IP:~/Db.sql

    log_info "서버에서 스키마 생성 중..."
    ssh -i "$PEM_KEY" ubuntu@$EC2_IP << 'ENDSSH'
        echo "MySQL root 비밀번호를 입력하세요:"
        read -s MYSQL_PASSWORD

        echo "데이터베이스 생성 중..."
        mysql -u root -p"$MYSQL_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS my_app_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null

        echo "테이블 생성 중..."
        mysql -u root -p"$MYSQL_PASSWORD" my_app_db < ~/Db.sql 2>/dev/null

        echo "생성된 테이블 확인..."
        mysql -u root -p"$MYSQL_PASSWORD" my_app_db -e "SHOW TABLES;" 2>/dev/null

        echo "✅ 데이터베이스 스키마 생성 완료!"

        # SQL 파일 삭제 (보안)
        rm -f ~/Db.sql
ENDSSH

    log_info "✅ 원격 데이터베이스 설정 완료!"
fi

echo ""
echo "========================================"
echo " 다음 단계"
echo "========================================"
echo "1. 데이터 확인:"
echo "   mysql -u root -p"
echo "   USE my_app_db;"
echo "   SHOW TABLES;"
echo ""
echo "2. 샘플 데이터 입력 (필요시)"
echo "3. 애플리케이션 배포:"
echo "   bash deploy.sh"
echo "========================================"
