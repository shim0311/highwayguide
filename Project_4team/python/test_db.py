#!/usr/bin/env python3
"""
MySQL 데이터베이스 연결 테스트 스크립트

사용법:
    python test_db.py

환경변수:
    .env 파일에 DB 정보가 설정되어 있어야 합니다.
"""

import os
import sys
from dotenv import load_dotenv
import mysql.connector
from mysql.connector import Error

# .env 파일 로드
load_dotenv()

def test_connection():
    """MySQL 연결을 테스트합니다."""

    print("=" * 60)
    print(" MySQL 연결 테스트")
    print("=" * 60)

    # 환경변수 확인
    required_vars = ["DB_HOST", "DB_USER", "DB_PASSWORD", "DB_NAME"]
    missing_vars = [var for var in required_vars if not os.getenv(var)]

    if missing_vars:
        print(f"\n❌ 누락된 환경변수: {', '.join(missing_vars)}")
        print("python/.env 파일을 확인하세요!")
        return False

    # 연결 정보 출력
    print(f"\n📍 연결 정보:")
    print(f"  - Host: {os.getenv('DB_HOST')}")
    print(f"  - Port: {os.getenv('DB_PORT', '3306')}")
    print(f"  - User: {os.getenv('DB_USER')}")
    print(f"  - Database: {os.getenv('DB_NAME')}")
    print(f"  - Charset: {os.getenv('DB_CHARSET', 'utf8')}")

    try:
        # MySQL 연결
        print("\n🔌 데이터베이스 연결 시도 중...")
        conn = mysql.connector.connect(
            host=os.getenv("DB_HOST"),
            port=int(os.getenv("DB_PORT", "3306")),
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASSWORD"),
            database=os.getenv("DB_NAME"),
            charset=os.getenv("DB_CHARSET", "utf8")
        )

        print("✅ 데이터베이스 연결 성공!\n")

        # 서버 정보 확인
        cursor = conn.cursor()

        # MySQL 버전
        cursor.execute("SELECT VERSION()")
        version = cursor.fetchone()[0]
        print(f"📊 MySQL 버전: {version}")

        # 현재 데이터베이스
        cursor.execute("SELECT DATABASE()")
        db_name = cursor.fetchone()[0]
        print(f"📁 현재 데이터베이스: {db_name}")

        # 테이블 목록
        cursor.execute("SHOW TABLES")
        tables = cursor.fetchall()

        if tables:
            print(f"\n📋 테이블 목록 ({len(tables)}개):")
            for table in tables:
                # 테이블 행 수 확인
                cursor.execute(f"SELECT COUNT(*) FROM {table[0]}")
                count = cursor.fetchone()[0]
                print(f"  - {table[0]}: {count:,}개 행")
        else:
            print("\n⚠️  테이블이 없습니다. SQL 파일을 실행하여 스키마를 생성하세요.")

        # 연결 종료
        cursor.close()
        conn.close()

        print("\n" + "=" * 60)
        print("✅ 모든 테스트 통과!")
        print("=" * 60)

        return True

    except Error as e:
        print(f"\n❌ 데이터베이스 연결 실패!")
        print(f"에러 코드: {e.errno}")
        print(f"에러 메시지: {e.msg}")

        # 일반적인 오류에 대한 해결책 제시
        if e.errno == 1045:
            print("\n💡 해결 방법:")
            print("  - DB_USER와 DB_PASSWORD가 올바른지 확인하세요")
            print("  - MySQL 사용자 권한을 확인하세요")
        elif e.errno == 2003:
            print("\n💡 해결 방법:")
            print("  - DB_HOST가 올바른지 확인하세요")
            print("  - MySQL 서버가 실행 중인지 확인하세요")
            print("  - 방화벽/보안 그룹 설정을 확인하세요")
        elif e.errno == 1049:
            print("\n💡 해결 방법:")
            print(f"  - 데이터베이스 '{os.getenv('DB_NAME')}'가 존재하지 않습니다")
            print("  - MySQL에서 데이터베이스를 생성하세요:")
            print(f"    CREATE DATABASE {os.getenv('DB_NAME')};")

        print("\n" + "=" * 60)
        return False

    except Exception as e:
        print(f"\n❌ 예상치 못한 오류!")
        print(f"에러: {str(e)}")
        print("\n" + "=" * 60)
        return False


if __name__ == "__main__":
    # .env 파일 존재 확인
    env_path = os.path.join(os.path.dirname(__file__), ".env")
    if not os.path.exists(env_path):
        print("❌ .env 파일이 없습니다!")
        print(f"경로: {env_path}")
        print("\n.env.example을 참고하여 .env 파일을 생성하세요.")
        sys.exit(1)

    # 연결 테스트 실행
    success = test_connection()
    sys.exit(0 if success else 1)
