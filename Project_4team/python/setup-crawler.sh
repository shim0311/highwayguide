#!/bin/bash
# =============================================================================
# Python 크롤러 환경 설정 스크립트
# =============================================================================
# 사용법: bash setup-crawler.sh
#
# Python 가상환경을 생성하고 의존성 패키지를 설치합니다.
# =============================================================================

set -e

echo "========================================"
echo " Python 크롤러 환경 설정"
echo "========================================"

# 현재 디렉토리 확인
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# .env 파일 확인
if [ ! -f ".env" ]; then
    echo "❌ .env 파일이 없습니다!"
    echo "   .env.example을 참고하여 .env 파일을 생성하세요."
    exit 1
fi

# 가상환경 생성
echo "[1/3] Python 가상환경 생성 중..."
python3 -m venv venv

# 가상환경 활성화
echo "[2/3] 가상환경 활성화..."
source venv/bin/activate

# 의존성 설치
echo "[3/3] 의존성 패키지 설치 중..."
pip install --upgrade pip
pip install -r requirements.txt

echo ""
echo "========================================"
echo " ✅ 크롤러 환경 설정 완료!"
echo "========================================"
echo ""
echo "가상환경 활성화:"
echo "  source venv/bin/activate"
echo ""
echo "크롤러 실행:"
echo "  python getReviews.py"
echo "  python searchServiceArea.py"
echo ""
echo "가상환경 비활성화:"
echo "  deactivate"
echo "========================================"
