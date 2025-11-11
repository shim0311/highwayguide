from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import pandas as pd
from datetime import datetime
import sys


def create_driver() -> webdriver.Chrome:
    """Create and return a configured Chrome WebDriver instance.

    - Uses a generic user-agent and sane defaults used in the main crawler
    - Keeps sandbox/dev-shm flags for Docker/Linux compatibility
    """
    options = webdriver.ChromeOptions()
    options.add_argument(
        "user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"
    )
    options.add_argument("window-size=1380,900")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")

    driver = webdriver.Chrome(options=options)
    driver.implicitly_wait(3)
    return driver


def switch_frame(driver: webdriver.Chrome, frame_name: str) -> None:
    """Helper to switch into an iframe safely."""
    driver.switch_to.default_content()
    driver.switch_to.frame(frame_name)


def wait_css(driver: webdriver.Chrome, timeout: int, css_selector: str):
    """Wait for an element to be present by CSS selector."""
    return WebDriverWait(driver, timeout).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, css_selector))
    )


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


def open_first_place_from_search(driver: webdriver.Chrome, keyword: str) -> bool:
    """Open the first place page for the given keyword in Naver Map search.

    Returns True if succeeded, False if no place was found.
    """
    search_url = f"https://map.naver.com/p/search/{keyword}"
    driver.get(search_url)
    # Allow initial load (increased by +1s as requested)
    time.sleep(3)

    try:
        switch_frame(driver, "searchIframe")
        # First try to find the primary place links
        place_links = driver.find_elements(By.CSS_SELECTOR, "a.place_bluelink")
        if not place_links:
            return False

        place_links[0].click()
        # Give entry iframe a bit more time to appear (+1s)
        time.sleep(2)
        return True
    except Exception:
        return False

def go_to_reviews_tab(driver: webdriver.Chrome) -> None:
    """Click the Reviews tab. The tab index differs by place types.

    Heuristic used in the existing crawler:
    - If there are 4 tab menus -> review tab data-index is "1"
    - Else -> data-index is "2"
    """
    # Tabs exist on entry iframe
    tab_menus = driver.find_elements(By.CSS_SELECTOR, ".tpj9w._tab-menu")
    review_index = "1" if len(tab_menus) == 4 else "2"
    review_button = driver.find_element(
        By.CSS_SELECTOR, f'.tpj9w._tab-menu[data-index="{review_index}"]'
    )
    review_button.click()
    time.sleep(1)


def scrape_reviews_for_keyword(driver: webdriver.Chrome, keyword: str) -> list[dict]:
    """Scrape all reviews for a single keyword.

    Returns a list of dictionaries with columns:
    - 휴게소명, 리뷰번호, 작성자, 리뷰내용, 리뷰사진URL, 작성날짜, 별점
    """
    results: list[dict] = []

    if not open_first_place_from_search(driver, keyword):
        print(f"[WARN] '{keyword}'에 대한 장소를 찾지 못했습니다.")
        return results

    try:
        # Move to place entry page
        switch_frame(driver, "entryIframe")

        # Move to reviews tab then fully load all reviews
        go_to_reviews_tab(driver)
        scroll_to_bottom(driver)

        review_list = driver.find_elements(By.CSS_SELECTOR, "#_review_list > li")
        print(f"[INFO] '{keyword}' 리뷰 {len(review_list)}건 수집 예정")

        for index, review in enumerate(review_list, start=1):
            try:
                author = "작성자 정보 없음"
                review_text = "리뷰 내용 없음"
                review_image = "리뷰 사진 없음"
                date_text = "작성 날짜 없음"

                try:
                    author_element = review.find_element(By.CSS_SELECTOR, ".pui__NMi-Dp")
                    author = author_element.text
                except Exception:
                    pass

                try:
                    review_text_element = review.find_element(By.CSS_SELECTOR, ".pui__vn15t2 a")
                    review_text = review_text_element.text
                except Exception:
                    pass

                try:
                    img_element = review.find_element(By.CSS_SELECTOR, 'img[alt="방문자리뷰사진"]')
                    src = img_element.get_attribute("src")
                    if src and "pup-review-phinf.pstatic.net" in src:
                        review_image = src
                except Exception:
                    pass

                try:
                    date_elements = review.find_elements(By.CSS_SELECTOR, ".pui__gfuUIT .pui__blind")
                    date_text = date_elements[1].text if len(date_elements) > 1 else "날짜 정보 없음"
                except Exception:
                    pass

                results.append(
                    {
                        "휴게소명": keyword,
                        "리뷰번호": index,
                        "작성자": author,
                        "리뷰내용": review_text,
                        "리뷰사진URL": review_image,
                        "작성날짜": date_text,
                        "수집시간": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                    }
                )
            except Exception as e:
                print(f"[WARN] 리뷰 {index} 파싱 실패: {e}")
                continue

    except Exception as e:
        print(f"[ERROR] '{keyword}' 리뷰 수집 중 오류: {e}")

    return results


def main():
    # CLI 인자로 키워드를 받습니다. 없으면 예시 키워드를 사용합니다.
    if len(sys.argv) > 1:
        keywords = sys.argv[1:]
    else:
        keywords = [
            "날려",
            "정안알밤휴게소(천안방향)",
            "하남드림휴게소",
            "시흥하늘휴게소",
            "가평휴게소(춘천)",
            "홍성휴게소(서울)",
        ]

    driver = create_driver()

    all_rows: list[dict] = []
    try:
        for keyword in keywords:
            print("=" * 60)
            print(f"키워드: {keyword}")
            print("=" * 60)
            rows = scrape_reviews_for_keyword(driver, keyword)
            all_rows.extend(rows)
            time.sleep(1)
    finally:
        # 드라이버는 반드시 종료합니다.
        try:
            driver.quit()
        except Exception:
            pass

    if not all_rows:
        print("수집된 리뷰가 없습니다.")
        return

    df = pd.DataFrame(all_rows)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"휴게소_리뷰_데이터_{timestamp}.xlsx"
    df.to_excel(filename, index=False, engine="openpyxl")
    print(f"\n리뷰 데이터가 '{filename}' 파일로 저장되었습니다. 총 {len(all_rows)}건.")


if __name__ == "__main__":
    main()


