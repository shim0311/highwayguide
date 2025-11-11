from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.action_chains import ActionChains
import time
import pandas as pd
from datetime import datetime
import mysql.connector
import json
import os
from dotenv import load_dotenv

# .env 파일에서 환경변수 로드
load_dotenv()

def switch_frame(driver, frame):
    driver.switch_to.default_content()  # frame 초기화
    driver.switch_to.frame(frame)  # frame 변경

def time_wait(driver, num, code):
    try:
        wait = WebDriverWait(driver, num).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, code)))
    except:
        print(code, '태그를 찾지 못하였습니다.')
        driver.quit()
    return wait

def scroll_to_bottom(driver: webdriver.Chrome, pause_sec: float = 1.0) -> None:
    """Continuously scroll to the bottom until the height no longer grows."""
    last_height = driver.execute_script("return document.body.scrollHeight")
    while True:
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        time.sleep(pause_sec)
        new_height = driver.execute_script("return document.body.scrollHeight")
        if new_height == last_height:
            break
        last_height = new_height

def scroll_down_a_bit(driver: webdriver.Chrome, pixels: int = 300) -> None:
    """스크롤을 지정된 픽셀만큼만 아래로 내립니다."""
    driver.execute_script(f"window.scrollBy(0, {pixels});")
    time.sleep(0.2)  # 스크롤 후 대기 시간 단축

def collect_reviews(driver: webdriver.Chrome) -> list:
    """
    리뷰 데이터를 수집하는 함수 (작성자, 내용, 사진링크)
    """
    reviews = []
    
    try:
        # 리뷰 탭 클릭 (getReviews.py 로직 참고)
        print("리뷰 탭을 찾아서 클릭합니다...")
        
        # 탭 메뉴 찾기
        tab_menus = driver.find_elements(By.CSS_SELECTOR, ".tpj9w._tab-menu")
        
        if not tab_menus:
            print("탭 메뉴를 찾을 수 없습니다.")
            return reviews
        
        print(f"탭 메뉴 {len(tab_menus)}개를 찾았습니다.")
        
        # 리뷰 탭 인덱스 결정 - "리뷰" 텍스트가 포함된 탭 찾기
        review_index = "2"  # 기본값
        for i, tab in enumerate(tab_menus):
            tab_text = tab.text.strip()
            if "리뷰" in tab_text:
                review_index = str(i)
                print(f"리뷰 탭 발견: 인덱스 {review_index} (텍스트: {tab_text})")
                break
        print(f"리뷰 탭 인덱스: {review_index}")
        
        # 리뷰 탭 클릭 (element click intercepted 오류 해결)
        try:
            review_button = driver.find_element(
                By.CSS_SELECTOR, f'.tpj9w._tab-menu[data-index="{review_index}"]'
            )
            
            # 방해하는 헤더 요소 제거
            try:
                header = driver.find_element(By.CSS_SELECTOR, '#_header')
                driver.execute_script("arguments[0].remove();", header)
                print("방해하는 헤더 요소 제거 완료")
            except:
                pass
            
            # 요소가 보이도록 스크롤
            driver.execute_script("arguments[0].scrollIntoView(true);", review_button)
            time.sleep(1)
            
            # JavaScript로 강제 클릭 (element click intercepted 방지)
            driver.execute_script("arguments[0].click();", review_button)
            print("리뷰 탭 클릭 완료 (JavaScript)")
            time.sleep(2)
        except Exception as e:
            print(f"리뷰 탭 클릭 실패: {e}")
            # 일반 클릭으로 재시도
            try:
                review_button = driver.find_element(
                    By.CSS_SELECTOR, f'.tpj9w._tab-menu[data-index="{review_index}"]'
                )
                review_button.click()
                print("리뷰 탭 클릭 완료 (일반 클릭)")
                time.sleep(2)
            except Exception as e2:
                print(f"리뷰 탭 클릭 재시도 실패: {e2}")
                return reviews
        
        # 리뷰 섹션으로 스크롤
        print("리뷰 섹션으로 스크롤 중...")
        driver.execute_script("window.scrollBy(0, 100);")
        
        # 사진만보기 필터 클릭
        try:
            filter_element = driver.find_element(By.CSS_SELECTOR, '.place_section_header_extra a')
            print("사진만보기 필터 찾음")
            filter_element.click()
            print("사진만보기 필터 클릭 완료")
            time.sleep(1)
        except Exception as e:
            print(f"사진만보기 필터 클릭 실패: {e}")
        
        # 리뷰 데이터 수집 (10개까지)
        collected_count = 0
        while collected_count < 10:
                    try:
                        # 첫 번째 리뷰 요소 찾기 (여러 선택자 시도)
                        review_selectors = [
                            'li.place_apply_pui.EjjAW',
                            '.place_apply_pui',
                            '.EjjAW',
                            '[data-testid="review-item"]',
                            '.review_item'
                        ]
                        
                        review_elements = []
                        for selector in review_selectors:
                            review_elements = driver.find_elements(By.CSS_SELECTOR, selector)
                            if review_elements:
                                print(f"리뷰 요소 찾음: {selector} - {len(review_elements)}개")
                                break
                        
                        if not review_elements:
                            print("리뷰 요소를 찾을 수 없습니다. 다음 키워드로 넘어갑니다.")
                            return reviews
                        
                        # 첫 번째 리뷰 데이터 수집
                        first_review = review_elements[0]
                        
                        # 작성자 수집
                        author = ""
                        try:
                            author_element = first_review.find_element(By.CSS_SELECTOR, '.pui__NMi-Dp')
                            author = author_element.text.strip()
                        except:
                            author = "작성자 없음"
                        
                        # 리뷰 내용 수집
                        content = ""
                        try:
                            content_element = first_review.find_element(By.CSS_SELECTOR, '.pui__vn15t2 a')
                            content = content_element.text.strip()
                        except:
                            content = "내용 없음"
                        
                        # 리뷰 사진 링크 수집
                        image_url = ""
                        try:
                            # 먼저 .HH5sZ.qkWAy img (한 장일 때) 시도
                            image_element = first_review.find_element(By.CSS_SELECTOR, '.HH5sZ.qkWAy img')
                            image_url = image_element.get_attribute('src')
                        except:
                            try:
                                # .HH5sZ.qkWAy를 찾을 수 없으면 .HH5sZ의 첫 번째 img 시도
                                image_element = first_review.find_element(By.CSS_SELECTOR, '.HH5sZ img')
                                image_url = image_element.get_attribute('src')
                            except:
                                image_url = "사진 없음"
                        
                        # 수집된 데이터 추가
                        reviews.append({
                            'author': author,
                            'content': content,
                            'image_url': image_url,
                            'collected_at': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                        })
                        
                        collected_count += 1
                        print(f"리뷰 {collected_count}개 수집 완료: {author[:10]}...")
                        
                        # 첫 번째 리뷰 요소 제거 (이미 수집했으므로)
                        driver.execute_script("arguments[0].remove();", first_review)
                        
                        # 스크롤을 200px 내리기
                        driver.execute_script("window.scrollBy(0, 150);")
                        time.sleep(0.5)
                        
                    except Exception as e:
                        print(f"리뷰 {collected_count + 1} 수집 중 오류: {e}")
                        break
                
        print(f"총 {len(reviews)}개의 리뷰를 수집했습니다.")
        
    except Exception as e:
        print(f"리뷰 수집 오류: {e}")
    
    return reviews

def get_service_area_list():
    """데이터베이스에서 휴게소 리스트를 가져옵니다."""
    try:
        # MySQL 연결 (환경변수에서 로드)
        conn = mysql.connector.connect(
            host=os.getenv("DB_HOST"),
            port=int(os.getenv("DB_PORT", "3306")),
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASSWORD"),
            database=os.getenv("DB_NAME"),
            charset=os.getenv("DB_CHARSET", "utf8")
        )
        
        cursor = conn.cursor()
        
        # 휴게소 idx, 이름과 방향 정보 조회
        cursor.execute("SELECT idx, SAname, SADirection FROM ServiceArea")
        rows = cursor.fetchall()
        
        # 휴게소명 변경 매핑 딕셔너리 (이미지의 모든 매핑 포함)
        name_mapping = {
        "거창휴게소(대구방향)": "거창한휴게소(옥포방향)",
        "거창휴게소(광주방향)": "거창한휴게소(고서방향)",
        "함평천지휴게소(서울방향)": "함평천지휴게소(시흥방향)",
        "이천휴게소(남이방향)": "이천휴게소(통영방향)",
        "오창휴게소(남이방향)": "오창휴게소(통영방향)",
        "금산인삼랜드휴게소(대전방향)": "인삼랜드휴게소(하남방향)",
        "선산휴게소(창원방향)" : "선산휴게소(마산방향)",
        "산청휴게소(대전방향)": "산청휴게소(하남방향)",
        "강릉휴게소(강릉방향)": "강릉대관령휴게소(강릉방향)",
        "강릉휴게소(인천방향)": "강릉대관령휴게소(인천방향)",
        "동해휴게소(삼척방향)": "동해휴게소",
        "장유휴게소(서부산방향)": "장유휴게소(부산방향)",
        "영천휴게소(대구방향)": "영천휴게소(익산방향)",
        "구정휴게소(삼척방향)": "구정휴게소(동해방향)",
        "속리산휴게소(청주방향)": "속리산휴게소",
        "화서휴게소(영덕방향)": "화서휴게소(상주)",
        "고성공룡나라휴게소(대전방향)": "고성공룡나라휴게소대전방향",
        "청통휴게소(대구방향)": "청통휴게소(익산방향)",
        "괴산휴게소(창원방향)": "괴산휴게소(마산방향)",
        "양양휴게소(속초방향)": "양양임시휴게소",
        "오수휴게소(완주방향)": "오수휴게소(전주방향)",
        "오수휴게소(순천방향)": "오수휴게소(광양방향)",
        "황전휴게소(완주방향)": "황전휴게소(전주방향)",
        "구리휴게소(일산방향)": "구리휴게소(퇴계원방향)",
        "신풍휴게소(대전방향)": "신풍휴게소(상주방향)",
        "면천휴게소(대전방향)": "면천휴게소(상주방향)",
        "청양휴게소(서천방향)": "청양임시휴게소(서천방향)",
        "청양휴게소(공주방향)": "청양임시휴게소(공주방향)",
        "상주휴게소(청원방향)": "상주휴게소(청주방향)",
        "상주휴게소(영덕방향)": "상주휴게소(상주방향)",
        "완주휴게소(장수방향)": "완주휴게소(포항방향)",
        "보성녹차휴게소(순천방향)": "보성녹차휴게소(광양방향)",
        "보성녹차휴게소(영암방향)": "보성녹차휴게소(목포방향)",
        "영암휴게소(광양방향)": "영암휴게소(부산방향)",
        "금왕휴게소(평택방향)": "금왕휴게소(평택방면)",
        "금왕휴게소(제천방향)": "금왕휴게소(제천방면)",
        "천등산휴게소(평택방향)": "천등산휴게소평택방향",
        "외동휴게소(부산방향)": "외동휴게소(울산방향)",
        "오산휴게소(봉담방향)": "오산휴게소(과천방향)",
        "정안알밤휴게소(논산방향)": "정안알밤휴게소(순천방향)",
        "탄천휴게소(논산방향)": "탄천휴게소(순천방향)",
        "양북임시휴게소(상방향)": "양북휴게소(포항방향)",
        "양북임시휴게소(하방향)": "양북휴게소(울산방향)",
        "내린천휴게소": "내린천휴게소(양양방향)",
        "별내휴게소(포천방향)": "구리포천남양주별내휴게소",
        "서부산휴게소(순천방향)": "서부산휴게소"
        }
        service_areas = []
        for row in rows:
            sa_idx = row[0]
            sa_name = row[1]
            sa_direction = row[2]
            
            # SADirection에서 방향 정보 추출 및 변환
            if sa_direction and len(sa_direction) >= 3 and sa_direction[2] == '(':
                # '(' 이후의 내용을 찾아서 ')'를 '방향)'으로 교체
                start_idx = sa_direction.find('(')
                end_idx = sa_direction.find(')')
                
                if start_idx != -1 and end_idx != -1:
                    direction_content = sa_direction[start_idx + 1:end_idx]
                    # '(' 이후의 내용만 가져와서 ')'를 '방향)'으로 교체
                    direction_suffix = f"({direction_content}방향)"
                    # 최종 휴게소명 생성: SAname + 방향정보 (하행 제외)
                    final_name = f"{sa_name}{direction_suffix}"
                    
                    # 매핑 테이블에서 변경값 확인
                    if final_name in name_mapping:
                        final_name = name_mapping[final_name]
                        print(f"휴게소명 변경: {sa_name}{direction_suffix} → {final_name}")
                    
                    service_areas.append({
                        'idx': sa_idx,
                        'name': final_name
                    })
                else:
                    # 매핑 테이블에서 변경값 확인 (방향 정보가 없는 경우)
                    if sa_name in name_mapping:
                        final_name = name_mapping[sa_name]
                        print(f"휴게소명 변경: {sa_name} → {final_name}")
                        service_areas.append({
                            'idx': sa_idx,
                            'name': final_name
                        })
                    else:
                        service_areas.append({
                            'idx': sa_idx,
                            'name': sa_name
                        })
            else:
                # 매핑 테이블에서 변경값 확인 (방향 정보가 없는 경우)
                if sa_name in name_mapping:
                    final_name = name_mapping[sa_name]
                    print(f"휴게소명 변경: {sa_name} → {final_name}")
                    service_areas.append({
                        'idx': sa_idx,
                        'name': final_name
                    })
                else:
                    service_areas.append({
                        'idx': sa_idx,
                        'name': sa_name
                    })
        
        cursor.close()
        conn.close()
        
        print(f"데이터베이스에서 {len(service_areas)}개의 휴게소를 가져왔습니다.")
        return service_areas
        
    except Exception as e:
        print(f"데이터베이스 연결 오류: {e}")
        # 오류 발생 시 기본 키워드 반환
        return ["첫번째는 날리기","정안알밤휴게소(천안방향)", "하남드림휴게소", "시흥하늘휴게소", "가평휴게소(춘천)", "홍성휴게소(서울)"]

def save_failed_items(failed_items, filename=None):
    """실패한 항목들을 JSON 파일로 저장합니다."""
    if filename is None:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"failed_items_{timestamp}.json"
    
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(failed_items, f, ensure_ascii=False, indent=2)
    
    print(f"실패한 항목 {len(failed_items)}개를 {filename}에 저장했습니다.")
    return filename

def load_failed_items(filename):
    """저장된 실패 항목들을 불러옵니다."""
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            failed_items = json.load(f)
        print(f"{filename}에서 실패한 항목 {len(failed_items)}개를 불러왔습니다.")
        return failed_items
    except FileNotFoundError:
        print(f"파일 {filename}을 찾을 수 없습니다.")
        return []
    except Exception as e:
        print(f"파일 읽기 오류: {e}")
        return []

def main(retry_failed=False, failed_file=None):
    """메인 함수: 휴게소 정보 수집을 실행합니다."""
    # Chrome 옵션 설정 (백그라운드 실행 + 속도 최적화)
    options = webdriver.ChromeOptions()
    # options.add_argument('--headless')  # 백그라운드 실행
    options.add_argument('user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3')
    options.add_argument('window-size=1380,900')
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
    options.add_argument("--disable-extensions")
    options.add_argument("--disable-images")
    options.add_argument("--disable-plugins")
    options.add_argument("--disable-web-security")
    options.add_argument("--disable-features=VizDisplayCompositor")

    # Chrome 드라이버 생성
    driver = webdriver.Chrome(options=options)

    # 대기 시간 설정 (더 빠르게)
    driver.implicitly_wait(time_to_wait=1)

    # 실패한 항목 재실행인지 확인
    if retry_failed and failed_file:
        service_areas = load_failed_items(failed_file)
        if not service_areas:
            print("재실행할 실패 항목이 없습니다.")
            return
        print(f"실패한 항목 {len(service_areas)}개를 재실행합니다.")
    else:
        # 데이터베이스에서 휴게소 리스트 가져오기
        service_areas = get_service_area_list()
        # service_areas = [{'idx': 1, 'name': '보성녹차휴게소(목포방향)'}]  # 테스트용
    
    # 데이터 저장을 위한 리스트
    all_data = []
    all_reviews = []  # 모든 리뷰를 저장할 리스트
    failed_items = []  # 실패한 항목들을 저장할 리스트

    try:
        # 각 휴게소에 대해 반복 처리
        for i, service_area in enumerate(service_areas):
            keyword = service_area['name']
            sa_idx = service_area['idx']
            
            try:
                print(f"\n{'='*60}")
                print(f"검색 키워드: {keyword} ({i+1}/{len(service_areas)})")
                print(f"{'='*60}")
                
                if i == 0:  # 첫 번째 키워드일 때 URL로 직접 접속
                    # 네이버 지도 검색 URL로 직접 접속
                    search_url = f"https://map.naver.com/p/search/{keyword}"
                    driver.get(url=search_url)
                    print(f"현재 URL: {driver.current_url}")
                    time.sleep(2)  # 첫 번째 키워드일 때 2초 대기
                else:  # 두 번째부터는 검색창에 입력
                    try:
                        # 메인 페이지로 돌아가기 (iframe에서 빠져나오기)
                        driver.switch_to.default_content()
                        time.sleep(0.5)
                        
                        # 검색창 찾기 및 클릭
                        search_input = driver.find_element(By.CSS_SELECTOR, '.input_search')
                        search_input.click()
                        time.sleep(0.5)
                        
                        # 기존 검색어 삭제
                        search_input.clear()
                        time.sleep(0.2)
                        
                        # 새로운 검색어 입력
                        search_input.send_keys(keyword)
                        time.sleep(0.5)
                        
                        # 검색 결과 박스에서 첫 번째 item_place 클릭
                        result_box = driver.find_element(By.CSS_SELECTOR, '.result_box')
                        first_item = result_box.find_element(By.CSS_SELECTOR, 'li.item_place')
                        first_item.click()
                        time.sleep(0.5)
                        
                        print(f"검색창을 통해 '{keyword}' 검색 완료")
                    except Exception as e:
                        print(f"검색창 검색 중 오류: {e}")
                        # 검색창 검색이 실패하면 URL로 접속 시도
                        search_url = f"https://map.naver.com/p/search/{keyword}"
                        driver.get(url=search_url)
                        time.sleep(1)
                
                # entryIframe으로 직접 전환 시도
                try:
                    switch_frame(driver, 'entryIframe')
                except:
                    # entryIframe을 못 찾았을 때만 searchIframe과 링크 클릭 로직 실행
                    print("entryIframe을 찾을 수 없어 searchIframe을 통해 접근합니다.")
                    try:
                        time.sleep(1)
                        switch_frame(driver, 'searchIframe')
                        time.sleep(1)
                        store_list = driver.find_elements(By.CSS_SELECTOR, 'li.VLTHu')
                        time.sleep(1)
                        
                        # place_bluelink 클래스를 가진 링크 찾기
                        place_links = driver.find_elements(By.CSS_SELECTOR, 'a.place_bluelink')
                        
                        if place_links:
                            first_link = place_links[0]
                            
                            # JavaScript를 사용해서 링크 클릭 (iframe 충돌 방지)
                            try:
                                driver.execute_script("arguments[0].click();", first_link)
                                print("링크를 클릭했습니다.")
                            except:
                                # JavaScript 클릭이 실패하면 일반 클릭 시도
                                first_link.click()
                                print("링크를 클릭했습니다.")
                            time.sleep(0.3)
                            
                            # 링크 클릭 후 다시 entryIframe으로 전환 시도
                            try:
                                switch_frame(driver, 'entryIframe')
                            except:
                                print("링크 클릭 후에도 entryIframe을 찾을 수 없습니다.")
                                raise Exception("entryIframe 접근 실패")
                        else:
                            print("place_bluelink 클래스를 가진 링크를 찾을 수 없습니다.")
                            raise Exception("검색 결과 링크 없음")
                    except Exception as e:
                        print(f"searchIframe 처리 중 오류: {e}")
                        raise e
                
                # entryIframe에 진입한 후 데이터 수집
                try:
                    facility_info = "시설정보 없음"
                    try:
                        facility_element = driver.find_element(By.CSS_SELECTOR, '.lnJFt')
                        facility_info = facility_element.text.strip()
                        print(f"시설정보: {facility_info}")
                    except:
                        print("시설정보를 찾을 수 없습니다.")
                    # 전화번호 정보 추출
                    phone = "전화번호 정보 없음"
                    try:
                        number_element = driver.find_element(By.CSS_SELECTOR, '.xlx7Q')
                        phone = number_element.text
                        print(f"전화번호: {phone}")
                    except:
                        print("전화번호를 찾을 수 없습니다.")

                    # 별점 정보 추출
                    rating = "4.0"
                    try:
                        rating_element = driver.find_element(By.CSS_SELECTOR, '.PXMot.LXIwF')
                        text = rating_element.text.strip()
                        rating = text.replace("별점", "").strip()
                        print(f"별점: {rating}")
                    except:
                        print("별점 정보를 찾을 수 없습니다.")
                 
                    scroll_down_a_bit(driver,600)
                    time.sleep(0.25)
                    
                    # 편의시설 정보 추출 (여러 개가 있을 수 있음)
                    convenience_facilities = []
                    try:
                        # .tZ4t9 클래스를 가진 요소가 여러 개 있을 경우:
                        # find_elements()는 모든 해당 요소들을 리스트로 반환합니다.
                        # 예: [<element1>, <element2>, <element3>, ...]
                        # 만약 요소가 없다면 빈 리스트 []를 반환합니다.
                        facility_elements = driver.find_elements(By.CSS_SELECTOR, '.tZ4t9')
                        for facility_element in facility_elements:
                            facility_text = facility_element.text.strip()
                            if facility_text:  # 빈 텍스트가 아닌 경우만 추가
                                convenience_facilities.append(facility_text)
                        
                        # 편의시설이 없다면 스크롤 후 다시 시도
                        if not convenience_facilities:
                            scroll_down_a_bit(driver, 400)
                            time.sleep(0.25)
                            facility_elements = driver.find_elements(By.CSS_SELECTOR, '.tZ4t9')
                            for facility_element in facility_elements:
                                facility_text = facility_element.text.strip()
                                if facility_text:  # 빈 텍스트가 아닌 경우만 추가
                                    convenience_facilities.append(facility_text)
                    except:
                        print("편의시설을 찾을 수 없습니다.")
                    if convenience_facilities:
                        convenience_str = ', '.join(convenience_facilities)
                        print(f"편의시설: {convenience_str}")
                    else:
                        convenience_str = "편의시설 없음"
                        print("편의시설을 찾을 수 없습니다.")
                    
                    # 리뷰 데이터 수집
                    print(f"리뷰 수집 시작: {keyword}")
                    reviews = collect_reviews(driver)
                    
                    # 데이터를 리스트에 추가 (idx 포함)
                    all_data.append({
                        'idx': sa_idx,
                        '휴게소명': keyword,
                        '전화번호': phone,
                        '별점': rating,
                        '시설정보': facility_info,
                        '편의시설': convenience_str,
                        '수집된_리뷰_수': len(reviews),
                        '수집시간': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                    })
                    print(f"데이터 수집 완료: {keyword}")
                    
                    # 리뷰 데이터를 전체 리스트에 추가
                    if reviews:
                        for review in reviews:
                            # idx를 첫 번째로, 휴게소명을 두 번째로 배치
                            review_data = {
                                'idx': sa_idx,
                                '휴게소명': keyword,
                                'author': review['author'],
                                'content': review['content'],
                                'image_url': review['image_url'],
                                'collected_at': review['collected_at']
                            }
                            all_reviews.append(review_data)
                            
                except Exception as e:
                    print(f"entryIframe 처리 중 오류: {e}")
                    # 오류가 발생해도 기본 데이터는 저장
                    all_data.append({
                        'idx': sa_idx,
                        '휴게소명': keyword,
                        '전화번호': '오류 발생',
                        '별점': '오류 발생',
                        '시설정보': '오류 발생',
                        '편의시설': '오류 발생',
                        '수집된_리뷰_수': 0,
                        '수집시간': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                    })
                    
                # 다음 키워드로 넘어가기 전에 잠시 대기 (더 빠르게)
                time.sleep(0.3)
                
            except Exception as e:
                print(f"키워드 '{keyword}' 처리 중 오류 발생: {e}")
                                # 예외가 발생해도 기본 데이터는 저장
                all_data.append({
                    'idx': sa_idx,
                    '휴게소명': keyword,
                    '전화번호': '예외 발생',
                    '별점': '예외 발생',
                    '시설정보': '예외 발생',
                    '편의시설': '예외 발생',
                    '수집된_리뷰_수': 0,
                    '수집시간': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                })
                # 실패한 항목 저장
                failed_items.append({
                    'idx': sa_idx,
                    'name': keyword,
                    'error': str(e),
                    'timestamp': datetime.now().isoformat()
                })
                continue

    except Exception as e:
        print(f"전체 처리 중 오류 발생: {e}")
    finally:
        driver.quit()
        
        # 실패한 항목이 있으면 저장
        if failed_items:
            failed_filename = save_failed_items(failed_items)
            print(f"\n실패한 항목 {len(failed_items)}개가 {failed_filename}에 저장되었습니다.")
            print("재실행하려면: main(retry_failed=True, failed_file='{failed_filename}')")
        
        # 성공한 데이터 저장 (기존 로직)
        if all_data:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            df = pd.DataFrame(all_data)
            filename = f"가게정보_데이터_{timestamp}.xlsx"
            df.to_excel(filename, index=False)
            print(f"✅ 가게 정보 데이터가 {filename}에 저장되었습니다.")
        
        if all_reviews:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            df_reviews = pd.DataFrame(all_reviews)
            filename = f"휴게소_리뷰_전체_{timestamp}.xlsx"
            df_reviews.to_excel(filename, index=False)
            print(f"✅ 리뷰 데이터가 {filename}에 저장되었습니다.")

# 재실행을 위한 편의 함수
def retry_failed_crawling(failed_file):
    """실패한 항목들을 재실행합니다."""
    main(retry_failed=True, failed_file=failed_file)

if __name__ == "__main__":
    # 일반 실행
    main()
    
    # 실패한 항목 재실행 예시 (주석 처리)
    # retry_failed_crawling("failed_items_20241201_143022.json")
    

