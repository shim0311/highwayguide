#!/bin/bash
# =============================================================================
# AWS Ubuntu 서버 배포 스크립트
# =============================================================================
# 사용법: bash deploy.sh
#
# 이 스크립트는 프로젝트를 빌드하고 Tomcat에 배포합니다.
# =============================================================================

set -e  # 에러 발생 시 스크립트 중단

# 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 로그 함수
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "========================================"
echo " 프로젝트 배포 시작"
echo "========================================"

# 환경변수 확인
log_info "환경변수 확인 중..."
if [ ! -f "src/main/resources/application.properties" ]; then
    log_error "application.properties 파일이 없습니다!"
    log_error "배포 전에 application.properties 파일을 생성하세요."
    exit 1
fi

if [ ! -f "src/main/resources/mybatis/config/conf.xml" ]; then
    log_error "conf.xml 파일이 없습니다!"
    log_error "배포 전에 conf.xml 파일을 생성하세요."
    exit 1
fi

log_info "✅ 환경변수 파일 확인 완료"

# 기존 빌드 결과물 정리
log_info "기존 빌드 결과물 정리 중..."
mvn clean

# Maven 빌드
log_info "Maven 빌드 시작..."
mvn package -DskipTests

# WAR 파일 확인
WAR_FILE="target/Project_4team-1.0-SNAPSHOT.war"
if [ ! -f "$WAR_FILE" ]; then
    log_error "WAR 파일을 찾을 수 없습니다: $WAR_FILE"
    exit 1
fi

log_info "✅ 빌드 완료: $WAR_FILE"

# Tomcat 중지
log_info "Tomcat 중지 중..."
sudo systemctl stop tomcat9

# 기존 애플리케이션 삭제
log_info "기존 애플리케이션 삭제 중..."
sudo rm -rf /var/lib/tomcat9/webapps/ROOT
sudo rm -f /var/lib/tomcat9/webapps/ROOT.war

# 새 WAR 파일 배포
log_info "새 WAR 파일 배포 중..."
sudo cp "$WAR_FILE" /var/lib/tomcat9/webapps/ROOT.war

# Tomcat 시작
log_info "Tomcat 시작 중..."
sudo systemctl start tomcat9

# 배포 완료 대기 (30초)
log_info "배포 완료 대기 중 (30초)..."
sleep 30

# Tomcat 상태 확인
if sudo systemctl is-active --quiet tomcat9; then
    log_info "✅ Tomcat이 정상적으로 실행 중입니다."
else
    log_error "❌ Tomcat 실행 실패!"
    log_error "로그 확인: sudo tail -f /var/log/tomcat9/catalina.out"
    exit 1
fi

echo ""
echo "========================================"
echo " ✅ 배포 완료!"
echo "========================================"
echo ""
echo "애플리케이션 접속:"
echo "  - HTTP: http://your-server-ip:8080"
echo ""
echo "로그 확인:"
echo "  - sudo tail -f /var/lib/tomcat9/logs/catalina.out"
echo ""
echo "Tomcat 관리:"
echo "  - 중지: sudo systemctl stop tomcat9"
echo "  - 시작: sudo systemctl start tomcat9"
echo "  - 재시작: sudo systemctl restart tomcat9"
echo "  - 상태: sudo systemctl status tomcat9"
echo "========================================"
