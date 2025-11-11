import mysql.connector
import os
from dotenv import load_dotenv

# .env 파일에서 환경변수 로드
load_dotenv()

#Mysql 연결
conn = mysql.connector.connect(
    host=os.getenv("DB_HOST"),
    port=int(os.getenv("DB_PORT", "3306")),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    database=os.getenv("DB_NAME"),
    charset=os.getenv("DB_CHARSET", "utf8")
    )

cursor = conn.cursor()

#휴게소 이름 조회

cursor.execute("select SAname from ServiceArea")

ServiceArea = [row[0] for row in cursor.fetchall()]

print(ServiceArea)
for name in ServiceArea:
    print("-", name)

cursor.close()
conn.close()
