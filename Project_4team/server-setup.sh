#!/bin/bash
# =============================================================================
# AWS Ubuntu 서버 초기 설정 스크립트
# =============================================================================
# 사용법: sudo bash server-setup.sh
#
# 이 스크립트는 AWS EC2 Ubuntu 서버에서 실행됩니다.
# Java, Maven, Tomcat, MySQL, Python, Chrome 등을 설치합니다.
# =============================================================================

set -e  # 에러 발생 시 스크립트 중단

echo "========================================"
echo " AWS Ubuntu 서버 초기 설정 시작"
echo "========================================"

# MySQL 설치 여부 확인
echo ""
read -p "MySQL을 이 서버에 설치하시겠습니까? (y/n): " INSTALL_MYSQL
echo ""

# 시스템 업데이트
echo "[1/9] 시스템 패키지 업데이트..."
apt-get update -y
apt-get upgrade -y

# Java 11 설치
echo "[2/9] Java 11 JDK 설치..."
apt-get install -y openjdk-11-jdk
java -version

# Maven 설치
echo "[3/9] Maven 설치..."
apt-get install -y maven
mvn -version

# MySQL 설치 (선택)
if [[ "$INSTALL_MYSQL" =~ ^[Yy]$ ]]; then
    echo "[4/9] MySQL Server 설치..."
    apt-get install -y mysql-server

    # MySQL 서비스 시작 및 자동 시작 설정
    systemctl start mysql
    systemctl enable mysql

    echo "MySQL 상태 확인:"
    systemctl status mysql --no-pager

    echo ""
    echo "⚠️  MySQL 보안 설정을 진행하세요:"
    echo "    sudo mysql_secure_installation"
    echo ""
    echo "데이터베이스 생성:"
    echo "    sudo mysql"
    echo "    CREATE DATABASE my_app_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    echo "    CREATE USER 'restinfo_user'@'localhost' IDENTIFIED BY 'YourPassword';"
    echo "    GRANT ALL PRIVILEGES ON my_app_db.* TO 'restinfo_user'@'localhost';"
    echo "    FLUSH PRIVILEGES;"
    echo "    EXIT;"
    echo ""
else
    echo "[4/9] MySQL 설치 건너뛰기 (RDS 또는 외부 DB 사용)"
fi

# Tomcat 9 설치
echo "[5/9] Tomcat 9 설치..."
apt-get install -y tomcat9 tomcat9-admin
systemctl enable tomcat9
systemctl start tomcat9
echo "Tomcat 상태 확인:"
systemctl status tomcat9 --no-pager

# Python 환경 설치
echo "[6/9] Python3 및 pip 설치..."
apt-get install -y python3 python3-pip python3-venv
python3 --version
pip3 --version

# Google Chrome 설치 (Selenium 크롤러용)
echo "[7/9] Google Chrome 설치..."
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
apt-get update -y
apt-get install -y google-chrome-stable
google-chrome --version

# ChromeDriver 설치 (Selenium용)
echo "[8/9] ChromeDriver 설치..."
apt-get install -y unzip
CHROME_DRIVER_VERSION=$(curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE)
wget -N https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip -P /tmp/
unzip -o /tmp/chromedriver_linux64.zip -d /tmp/
mv -f /tmp/chromedriver /usr/local/bin/chromedriver
chmod +x /usr/local/bin/chromedriver
rm /tmp/chromedriver_linux64.zip
chromedriver --version

# 기타 유틸리티 설치
echo "[9/9] 유틸리티 설치 (git, curl, vim 등)..."
apt-get install -y git curl vim wget

echo ""
echo "========================================"
echo " ✅ 서버 초기 설정 완료!"
echo "========================================"
echo ""
echo "설치된 소프트웨어:"
echo "  - Java: $(java -version 2>&1 | head -n 1)"
echo "  - Maven: $(mvn -version | head -n 1)"
if [[ "$INSTALL_MYSQL" =~ ^[Yy]$ ]]; then
    echo "  - MySQL: $(systemctl is-active mysql) ($(mysql --version | awk '{print $5}' | sed 's/,//'))"
fi
echo "  - Tomcat: $(systemctl is-active tomcat9)"
echo "  - Python: $(python3 --version)"
echo "  - Chrome: $(google-chrome --version)"
echo ""
echo "다음 단계:"
if [[ "$INSTALL_MYSQL" =~ ^[Yy]$ ]]; then
    echo "  1. MySQL 보안 설정: sudo mysql_secure_installation"
    echo "  2. 데이터베이스 생성 (위 안내 참조)"
    echo "  3. application.properties 파일 설정 (db.url=jdbc:mysql://localhost:3306/...)"
    echo "  4. python/.env 파일 설정 (DB_HOST=localhost)"
    echo "  5. deploy.sh 스크립트로 애플리케이션 배포"
else
    echo "  1. application.properties 파일 설정"
    echo "  2. python/.env 파일 설정"
    echo "  3. deploy.sh 스크립트로 애플리케이션 배포"
fi
echo ""
echo "상세 가이드:"
echo "  - docs/EC2_MYSQL_SETUP.md (MySQL 설정)"
echo "  - DEPLOYMENT.md (전체 배포 가이드)"
echo "========================================"
