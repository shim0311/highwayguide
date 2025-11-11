#!/bin/bash
# =============================================================================
# Git 저장소 재설정 스크립트
# =============================================================================
# 기존 Git 연결을 해제하고 새로운 개인 저장소로 연결합니다.
# =============================================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "========================================"
echo " Git 저장소 재설정"
echo "========================================"
echo ""

# 현재 Git 상태 확인
echo -e "${YELLOW}[현재 Git 설정]${NC}"
echo "현재 remote:"
git remote -v
echo ""

# 새 저장소 URL 입력받기
echo -e "${GREEN}새로운 GitHub 저장소를 먼저 생성하세요!${NC}"
echo "https://github.com/new"
echo ""
read -p "새 저장소 URL을 입력하세요 (예: https://github.com/your-username/your-repo.git): " NEW_REPO_URL

if [ -z "$NEW_REPO_URL" ]; then
    echo -e "${RED}저장소 URL이 입력되지 않았습니다.${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}다음 작업을 수행합니다:${NC}"
echo "1. 기존 Git remote 제거"
echo "2. 새 저장소 연결"
echo "3. 민감정보 파일 확인"
echo "4. 초기 커밋 및 푸시"
echo ""
read -p "계속하시겠습니까? (y/n): " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "취소되었습니다."
    exit 0
fi

echo ""
echo "========================================"
echo " 1. 기존 remote 제거"
echo "========================================"

# 기존 remote 제거
git remote remove origin 2>/dev/null || true
git remote remove upstream 2>/dev/null || true

echo -e "${GREEN}✅ 기존 remote 제거 완료${NC}"

echo ""
echo "========================================"
echo " 2. 새 저장소 연결"
echo "========================================"

# 새 remote 추가
git remote add origin "$NEW_REPO_URL"

echo "새로운 remote:"
git remote -v

echo -e "${GREEN}✅ 새 저장소 연결 완료${NC}"

echo ""
echo "========================================"
echo " 3. 민감정보 파일 확인"
echo "========================================"

# .gitignore 확인
echo "민감정보 파일이 .gitignore에 포함되어 있는지 확인 중..."
echo ""
echo "제외된 파일들:"
git status --ignored | grep "^!!" || echo "  (없음)"

echo ""
echo -e "${YELLOW}⚠️  다음 파일들이 Git에 추적되지 않는지 확인하세요:${NC}"
echo "  - src/main/resources/application.properties"
echo "  - src/main/resources/mybatis/config/conf.xml"
echo "  - python/.env"
echo ""

# 민감정보가 staged되어 있는지 확인
if git diff --cached --name-only | grep -E "(application.properties|conf.xml|\.env)"; then
    echo -e "${RED}❌ 민감정보 파일이 staged되어 있습니다!${NC}"
    echo "다음 명령으로 unstage하세요:"
    echo "  git reset HEAD <file>"
    exit 1
fi

echo -e "${GREEN}✅ 민감정보 파일 확인 완료${NC}"

echo ""
echo "========================================"
echo " 4. 초기 커밋 및 푸시"
echo "========================================"

# 현재 브랜치 확인
CURRENT_BRANCH=$(git branch --show-current)
echo "현재 브랜치: $CURRENT_BRANCH"

# 변경사항 확인
echo ""
echo "커밋할 파일들:"
git status --short

echo ""
read -p "모든 변경사항을 커밋하고 푸시하시겠습니까? (y/n): " PUSH_CONFIRM

if [[ "$PUSH_CONFIRM" =~ ^[Yy]$ ]]; then
    # 커밋
    echo ""
    echo "커밋 메시지를 입력하세요:"
    read -p "> " COMMIT_MSG

    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Initial commit: AWS deployment setup"
    fi

    git add .
    git commit -m "$COMMIT_MSG"

    # 푸시 (force push for initial setup)
    echo ""
    echo "푸시 중..."
    git push -u origin "$CURRENT_BRANCH" --force

    echo ""
    echo -e "${GREEN}✅ 푸시 완료!${NC}"
else
    echo "푸시를 건너뛰었습니다."
    echo "나중에 수동으로 푸시하려면:"
    echo "  git push -u origin $CURRENT_BRANCH"
fi

echo ""
echo "========================================"
echo " ✅ Git 저장소 재설정 완료!"
echo "========================================"
echo ""
echo "저장소 URL: $NEW_REPO_URL"
echo ""
echo "다음 단계:"
echo "  1. GitHub에서 저장소 확인"
echo "  2. GitHub Actions 설정 (setup-github-actions.sh)"
echo "  3. GitHub Secrets 설정"
echo "========================================"
