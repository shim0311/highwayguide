#!/bin/bash
# =============================================================================
# GitHub Secrets 템플릿 생성 스크립트
# =============================================================================
# 사용법: bash generate-secrets-template.sh
#
# 이 스크립트는 application.properties 파일을 읽어서
# GitHub Secrets 설정용 템플릿을 생성합니다.
# =============================================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "========================================"
echo " GitHub Secrets 템플릿 생성"
echo "========================================"
echo ""

# application.properties 파일 확인
PROPS_FILE="src/main/resources/application.properties"

if [ ! -f "$PROPS_FILE" ]; then
    echo -e "${RED}❌ application.properties 파일이 없습니다!${NC}"
    echo ""
    echo "먼저 application.properties 파일을 생성하세요:"
    echo "  cp application.properties.example src/main/resources/application.properties"
    echo "  vim src/main/resources/application.properties"
    exit 1
fi

echo -e "${GREEN}✅ application.properties 파일 발견${NC}"
echo ""

# 출력 파일
OUTPUT_FILE="github-secrets-values.txt"

echo -e "${YELLOW}⚠️  이 파일에는 민감정보가 포함됩니다!${NC}"
echo -e "${YELLOW}   절대 Git에 커밋하지 마세요!${NC}"
echo ""

# GitHub Secrets 템플릿 생성
cat > "$OUTPUT_FILE" << 'EOF'
# =============================================================================
# GitHub Secrets 설정 값
# =============================================================================
# ⚠️ 이 파일은 절대 Git에 커밋하지 마세요!
# ⚠️ GitHub Secrets 설정 후 이 파일을 삭제하세요!
# =============================================================================
#
# 설정 위치: https://github.com/shim0311/highwayguide/settings/secrets/actions
# Settings → Secrets and variables → Actions → New repository secret
#
# 아래 각 항목을 복사해서 GitHub Secrets에 등록하세요.
# =============================================================================

EOF

# application.properties에서 값 추출
echo "데이터베이스 설정을 읽는 중..."
echo "" >> "$OUTPUT_FILE"
echo "# ============================================" >> "$OUTPUT_FILE"
echo "# 데이터베이스 설정" >> "$OUTPUT_FILE"
echo "# ============================================" >> "$OUTPUT_FILE"

DB_URL=$(grep "^db.url=" "$PROPS_FILE" | cut -d'=' -f2-)
DB_USERNAME=$(grep "^db.username=" "$PROPS_FILE" | cut -d'=' -f2-)
DB_PASSWORD=$(grep "^db.password=" "$PROPS_FILE" | cut -d'=' -f2-)

echo "Name: DB_URL" >> "$OUTPUT_FILE"
echo "Value: $DB_URL" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Name: DB_USERNAME" >> "$OUTPUT_FILE"
echo "Value: $DB_USERNAME" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Name: DB_PASSWORD" >> "$OUTPUT_FILE"
echo "Value: $DB_PASSWORD" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Google Mail
echo "Google Mail 설정을 읽는 중..."
echo "# ============================================" >> "$OUTPUT_FILE"
echo "# Google Mail (비밀번호 찾기)" >> "$OUTPUT_FILE"
echo "# ============================================" >> "$OUTPUT_FILE"

GOOGLE_MAIL=$(grep "^GOOGLE_SENDER_MAIL=" "$PROPS_FILE" | cut -d'=' -f2-)
GOOGLE_PASSWORD=$(grep "^GOOGLE_APPLICATION_PASSWORD=" "$PROPS_FILE" | cut -d'=' -f2-)

echo "Name: GOOGLE_SENDER_MAIL" >> "$OUTPUT_FILE"
echo "Value: $GOOGLE_MAIL" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Name: GOOGLE_APPLICATION_PASSWORD" >> "$OUTPUT_FILE"
echo "Value: $GOOGLE_PASSWORD" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Naver OAuth
echo "Naver OAuth 설정을 읽는 중..."
echo "# ============================================" >> "$OUTPUT_FILE"
echo "# Naver OAuth (소셜 로그인)" >> "$OUTPUT_FILE"
echo "# ============================================" >> "$OUTPUT_FILE"

NAVER_ID=$(grep "^NAVER_CLIENT_ID=" "$PROPS_FILE" | cut -d'=' -f2-)
NAVER_SECRET=$(grep "^NAVER_CLIENT_SECRET=" "$PROPS_FILE" | cut -d'=' -f2-)

echo "Name: NAVER_CLIENT_ID" >> "$OUTPUT_FILE"
echo "Value: $NAVER_ID" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Name: NAVER_CLIENT_SECRET" >> "$OUTPUT_FILE"
echo "Value: $NAVER_SECRET" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Kakao
echo "Kakao 설정을 읽는 중..."
echo "# ============================================" >> "$OUTPUT_FILE"
echo "# Kakao (소셜 로그인 & 지도)" >> "$OUTPUT_FILE"
echo "# ============================================" >> "$OUTPUT_FILE"

KAKAO_CLIENT=$(grep "^KAKAO_CLIENT_ID=" "$PROPS_FILE" | cut -d'=' -f2-)
KAKAO_API=$(grep "^KAKAO_API_KEY=" "$PROPS_FILE" | cut -d'=' -f2-)

echo "Name: KAKAO_CLIENT_ID" >> "$OUTPUT_FILE"
echo "Value: $KAKAO_CLIENT" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Name: KAKAO_API_KEY" >> "$OUTPUT_FILE"
echo "Value: $KAKAO_API" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 고속도로 API
echo "고속도로 API 설정을 읽는 중..."
echo "# ============================================" >> "$OUTPUT_FILE"
echo "# 고속도로 공공데이터" >> "$OUTPUT_FILE"
echo "# ============================================" >> "$OUTPUT_FILE"

EXPRESSWAY_ID=$(grep "^EXPRESSWAY_ID=" "$PROPS_FILE" | cut -d'=' -f2-)

echo "Name: EXPRESSWAY_ID" >> "$OUTPUT_FILE"
echo "Value: $EXPRESSWAY_ID" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# TMap
echo "TMap API 설정을 읽는 중..."
echo "# ============================================" >> "$OUTPUT_FILE"
echo "# TMap API" >> "$OUTPUT_FILE"
echo "# ============================================" >> "$OUTPUT_FILE"

TMAP_KEY=$(grep "^tmap.appkey=" "$PROPS_FILE" | cut -d'=' -f2-)

echo "Name: TMAP_APPKEY" >> "$OUTPUT_FILE"
echo "Value: $TMAP_KEY" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# AWS S3
echo "AWS S3 설정을 읽는 중..."
echo "# ============================================" >> "$OUTPUT_FILE"
echo "# AWS S3 (이미지 업로드)" >> "$OUTPUT_FILE"
echo "# ============================================" >> "$OUTPUT_FILE"

AWS_ACCESS=$(grep "^aws.accessKeyId=" "$PROPS_FILE" | cut -d'=' -f2-)
AWS_SECRET=$(grep "^aws.secretAccessKey=" "$PROPS_FILE" | cut -d'=' -f2-)
AWS_BUCKET=$(grep "^aws.s3.bucketName=" "$PROPS_FILE" | cut -d'=' -f2-)
AWS_URL=$(grep "^aws.s3.bucketUrl=" "$PROPS_FILE" | cut -d'=' -f2-)

echo "Name: AWS_ACCESS_KEY_ID" >> "$OUTPUT_FILE"
echo "Value: $AWS_ACCESS" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Name: AWS_SECRET_ACCESS_KEY" >> "$OUTPUT_FILE"
echo "Value: $AWS_SECRET" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Name: AWS_S3_BUCKET_NAME" >> "$OUTPUT_FILE"
echo "Value: $AWS_BUCKET" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Name: AWS_S3_BUCKET_URL" >> "$OUTPUT_FILE"
echo "Value: $AWS_URL" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 서버 설정
echo "서버 설정을 읽는 중..."
echo "# ============================================" >> "$OUTPUT_FILE"
echo "# 서버 설정" >> "$OUTPUT_FILE"
echo "# ============================================" >> "$OUTPUT_FILE"

SERVER_DOMAIN=$(grep "^server.domain=" "$PROPS_FILE" | cut -d'=' -f2-)
SERVER_PORT=$(grep "^server.port=" "$PROPS_FILE" | cut -d'=' -f2-)
SERVER_CONTEXT=$(grep "^server.context=" "$PROPS_FILE" | cut -d'=' -f2-)

echo "Name: SERVER_DOMAIN" >> "$OUTPUT_FILE"
echo "Value: $SERVER_DOMAIN" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Name: SERVER_PORT" >> "$OUTPUT_FILE"
echo "Value: $SERVER_PORT" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Name: SERVER_CONTEXT" >> "$OUTPUT_FILE"
echo "Value: $SERVER_CONTEXT" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# EC2 배포 설정 (수동 입력 필요)
echo "# ============================================" >> "$OUTPUT_FILE"
echo "# EC2 배포 설정 (수동 입력 필요!)" >> "$OUTPUT_FILE"
echo "# ============================================" >> "$OUTPUT_FILE"
echo "Name: EC2_HOST" >> "$OUTPUT_FILE"
echo "Value: [EC2 퍼블릭 IP 입력]" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Name: EC2_USERNAME" >> "$OUTPUT_FILE"
echo "Value: ubuntu" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Name: EC2_SSH_KEY" >> "$OUTPUT_FILE"
echo "Value: [PEM 파일 전체 내용 복사]" >> "$OUTPUT_FILE"
echo "# 실행: cat your-key.pem" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Name: EC2_TARGET_PATH" >> "$OUTPUT_FILE"
echo "Value: /home/ubuntu/Project_4team" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo ""
echo "========================================"
echo -e " ${GREEN}✅ 템플릿 생성 완료!${NC}"
echo "========================================"
echo ""
echo "생성된 파일: $OUTPUT_FILE"
echo ""
echo -e "${YELLOW}다음 단계:${NC}"
echo "1. $OUTPUT_FILE 파일을 열어서 확인"
echo "2. 각 값을 복사해서 GitHub Secrets에 등록"
echo "3. 설정 완료 후 파일 삭제: rm $OUTPUT_FILE"
echo ""
echo -e "${RED}⚠️  이 파일은 민감정보를 포함하므로 절대 Git에 커밋하지 마세요!${NC}"
echo ""
