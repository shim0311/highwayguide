<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HighwayGuide - 고속도로의 모든 것</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100..900;1,100..900&display=swap"
          rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/indexStyle.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/footerStyle.css" rel="stylesheet">


</head>
<body>
<%@ include file="header.jsp" %>


<!-- Hero Section -->
<main>
    <section class="hero">
        <!-- Search Section -->
        <section class="search-section slide-up">
            <div class="search-decoration">
                <div class="decoration-line decoration-line-1"></div>
                <div class="decoration-line decoration-line-2"></div>
            </div>

            <h2 class="section-title">경로내 휴게시설 검색</h2>
            <p class="search-description">출발지와 목적지를 입력하여 최적의 경로와 휴게시설을 찾아보세요</p>
            <div class="search-container">
                <form action="Controller?type=kakaoMap" method="post" id="routeForm">
                    <!-- 출발지 입력 섹션 -->
                    <div class="input-wrapper">
                        <input type="text" name="origin" id="origin" class="search-input" placeholder="출발지를 입력하세요"
                               value="<c:out value='${origin}'/>" required autocomplete="off">
                        <div id="origin-suggestions" class="suggestions-dropdown"></div>
                    </div>

                    <!-- 목적지 입력 섹션 -->
                    <div class="input-wrapper">
                        <input type="text" name="destination" id="destination" class="search-input"
                               placeholder="목적지를 입력하세요"
                               value="<c:out value='${destination}'/>" required autocomplete="off">
                        <div id="destination-suggestions" class="suggestions-dropdown"></div>
                    </div>

                    <!-- 폼 제출 후 KakaoMapAction에서 경로 계산 완료 후 RestAreaAction으로 자동 포워딩하도록 지시하는 숨겨진 필드 -->
                    <input type="hidden" name="forwardTo" value="restArea">
                    <button type="submit" class="search-btn" id="searchRouteBtn"><i class="fas fa-search"></i> 길찾기
                    </button>

                    <!-- 에러 메시지 표시 -->
                    <c:if test="${not empty error}">
                        <div class="error-text">
                            <i class="fas fa-exclamation-circle"></i>
                            올바른 주소를 입력해주세요
                        </div>
                    </c:if>
                </form>
            </div>
            <div class="search-tags">
            </div>
        </section>
    </section>

    <!-- 섹션 구분선 -->
    <div class="section-divider" id="sectionDivider"></div>

    <div style="height: 50px;"></div>

    <!-- Features Section -->
    <section class="features" id="featuresSection">
        <h2 class="features-title">고속도로 관리</h2>
        <p class="features-subtitle">지출부터 똑똑하게 똑똑하게</p>
        <div class="feature-grid">
            <div class="feature-card">
                <div class="feature-icon">
                    <i class="fas fa-route"></i>
                </div>
                <h3>실시간 교통정보</h3>
                <p>고속도로의 실시간 교통상황을 확인하고 최적의 경로를 찾아보세요.</p>
            </div>
            <a href="Controller?type=mapinfo" class="card-link">
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-gas-pump"></i>
                    </div>
                    <h3>휴게소 정보</h3>
                    <p>주유소, 충전소, 음식점, 화장실 등 휴게소의 모든 정보를 한눈에 확인하세요.</p>
                </div>
            </a>
            <a href="Controller?type=review" class="card-link">
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-comments"></i>
                    </div>
                    <h3>휴게소 리뷰</h3>
                    <p>실제 이용자들의 생생한 휴게소 후기와 평가를 확인해보세요.</p>
                </div>
            </a>
            <div class="feature-card">
                <div class="feature-icon">
                    <i class="fas fa-clock"></i>
                </div>
                <h3>운행시간 관리</h3>
                <p>운전시간과 휴식시간을 체계적으로 관리하여 안전한 운전을 도와드립니다.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">
                    <i class="fas fa-exclamation-triangle"></i>
                </div>
                <h3>긴급상황 알림</h3>
                <p>사고, 공사, 기상상황 등 긴급한 정보를 실시간으로 알려드립니다.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">
                    <i class="fas fa-star"></i>
                </div>
                <h3>즐겨찾기</h3>
                <p>자주 이용하는 휴게소나 경로를 저장하고 빠르게 찾아보세요.</p>
            </div>
        </div>
    </section>
</main>


<script>
    document.addEventListener('DOMContentLoaded', function () {
        // 스크롤 애니메이션 초기화
        initializeScrollAnimation();

        // 길찾기 폼 초기화
        initializeRouteForm();

        // 자동완성 초기화
        initializeAutocomplete();
    });

    // 스크롤 애니메이션 초기화
    function initializeScrollAnimation() {
        const observerOptions = {
            threshold: 0.2,
            rootMargin: '0px 0px -100px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    if (entry.target.id === 'featuresSection') {
                        entry.target.classList.add('visible');
                    } else if (entry.target.id === 'sectionDivider') {
                        entry.target.classList.add('visible');
                    } else {
                        // 기존 feature-card 애니메이션
                        entry.target.style.opacity = '1';
                        entry.target.style.transform = 'translateY(0)';
                    }
                }
            });
        }, observerOptions);

        // 기능 섹션 관찰
        const featuresSection = document.getElementById('featuresSection');
        if (featuresSection) {
            observer.observe(featuresSection);
        }

        // 구분선 관찰
        const sectionDivider = document.getElementById('sectionDivider');
        if (sectionDivider) {
            observer.observe(sectionDivider);
        }

        // 기존 feature-card 애니메이션
        document.querySelectorAll('.feature-card').forEach(card => {
            card.style.opacity = '0';
            card.style.transform = 'translateY(30px)';
            card.style.transition = 'all 0.6s ease-out';
            observer.observe(card);
        });
    }

    // 길찾기 폼 초기화
    function initializeRouteForm() {
        const routeForm = document.getElementById('routeForm');
        const searchBtn = document.getElementById('searchRouteBtn');

        if (routeForm && searchBtn) {
            // 폼 제출 이벤트 처리
            routeForm.addEventListener('submit', function (e) {
                const originInput = document.getElementById('origin');
                const destinationInput = document.getElementById('destination');

                // 입력값 검증
                if (!originInput.value.trim() || !destinationInput.value.trim()) {
                    e.preventDefault();
                    alert('출발지와 목적지를 모두 입력해주세요.');
                    return false;
                }

                // 로딩 상태 표시
                setLoadingState(searchBtn, true);

                // 폼 제출을 계속 진행
                return true;
            });
        }


    }

    // 자동완성 초기화
    function initializeAutocomplete() {
        // 출발지 자동완성 설정
        setupAutocomplete('origin', 'origin-suggestions');

        // 목적지 자동완성 설정
        setupAutocomplete('destination', 'destination-suggestions');
    }

    // 자동완성 설정
    function setupAutocomplete(inputId, dropdownId) {
        const input = document.getElementById(inputId);
        const dropdown = document.getElementById(dropdownId);

        if (!input || !dropdown) {
            return;
        }

        let currentSelection = -1;
        let searchTimeout;

        // 입력 이벤트
        input.addEventListener('input', function (e) {
            const query = e.target.value.trim();

            // 디바운싱: 300ms 후에 검색
            clearTimeout(searchTimeout);

            if (query.length < 2) {
                hideDropdown(dropdown);
                return;
            }

            searchTimeout = setTimeout(() => {
                searchPlaces(query, dropdown);
            }, 300);
        });

        // 포커스 이벤트
        input.addEventListener('focus', function () {
            if (input.value.trim().length >= 2) {
                showDropdown(dropdown);
            }
        });

        // 블러 이벤트 (약간의 지연을 두어 클릭 이벤트가 먼저 실행되도록)
        input.addEventListener('blur', function () {
            setTimeout(() => {
                hideDropdown(dropdown);
            }, 200);
        });

        // 키보드 네비게이션
        input.addEventListener('keydown', function (e) {
            const items = dropdown.querySelectorAll('.suggestion-item');

            if (e.key === 'ArrowDown') {
                e.preventDefault();
                currentSelection = Math.min(currentSelection + 1, items.length - 1);
                updateSelection(items, currentSelection);
            } else if (e.key === 'ArrowUp') {
                e.preventDefault();
                currentSelection = Math.max(currentSelection - 1, -1);
                updateSelection(items, currentSelection);
            } else if (e.key === 'Enter') {
                e.preventDefault();
                if (currentSelection >= 0 && items[currentSelection]) {
                    selectSuggestion(input, dropdown, items[currentSelection]);
                }
            } else if (e.key === 'Escape') {
                hideDropdown(dropdown);
                currentSelection = -1;
            }
        });
    }

    // 장소 검색 (카카오 API 연결)
    function searchPlaces(query, dropdown) {
        // 로딩 표시
        showLoading(dropdown);

        // SearchAddress API 호출
        fetch('Controller?type=searchAddress&keyword=' + encodeURIComponent(query))
            .then(response => {
                if (!response.ok) {
                    throw new Error('서버 응답 오류: ' + response.status);
                }
                return response.json();
            })
            .then(data => {
                // 카카오 API 응답 구조에 맞게 처리
                if (data.documents && Array.isArray(data.documents)) {
                    displaySuggestions(dropdown, data.documents);
                } else if (data.error) {
                    showError(dropdown, 'API 오류가 발생했습니다.');
                } else {
                    displaySuggestions(dropdown, []);
                }
            })
            .catch(error => {
                showError(dropdown, '검색 중 오류가 발생했습니다.');
            });
    }

    // 드롭다운 표시
    function showDropdown(dropdown) {
        dropdown.classList.add('show');
    }

    // 드롭다운 숨김
    function hideDropdown(dropdown) {
        dropdown.classList.remove('show');
    }

    // 로딩 표시
    function showLoading(dropdown) {
        dropdown.innerHTML = '<div class="suggestions-loading"><i class="fas fa-spinner fa-spin"></i> 검색 중...</div>';
        showDropdown(dropdown);
    }

    // 에러 표시
    function showError(dropdown, message) {
        dropdown.innerHTML = '<div class="suggestions-empty"><i class="fas fa-exclamation-triangle"></i> ' + message + '</div>';
        showDropdown(dropdown);
    }

    // 제안 목록 표시
    function displaySuggestions(dropdown, suggestions) {
        if (!suggestions || suggestions.length === 0) {
            dropdown.innerHTML = '<div class="suggestions-empty">검색 결과가 없습니다.</div>';
            showDropdown(dropdown);
            return;
        }

        let html = '';
        suggestions.forEach((item, index) => {
            const placeName = escapeHtml(item.place_name);
            const placeAddress = escapeHtml(item.road_address_name || item.address_name);

            html += '<div class="suggestion-item" data-index="' + index + '" onclick="selectSuggestionByClick(this)">' +
                '<div class="place-name">' + placeName + '</div>' +
                '<div class="place-address">' + placeAddress + '</div>' +
                '</div>';
        });

        dropdown.innerHTML = html;
        dropdown.dataset.suggestions = JSON.stringify(suggestions);
        showDropdown(dropdown);
    }

    // 선택 상태 업데이트
    function updateSelection(items, selectedIndex) {
        items.forEach((item, index) => {
            if (index === selectedIndex) {
                item.classList.add('selected');
            } else {
                item.classList.remove('selected');
            }
        });
    }

    // 제안 선택 (클릭)
    function selectSuggestionByClick(element) {
        // closest() 메서드: 현재 요소부터 시작해서 부모 요소들을 차례로 올라가며
        // 지정된 CSS 선택자와 일치하는 첫 번째 요소를 찾는 메서드

        // 클릭된 제안 항목(element)에서 부모 요소들을 거슬러 올라가며
        // 'suggestions-dropdown' 클래스를 가진 드롭다운 컨테이너를 찾음
        const dropdown = element.closest('.suggestions-dropdown');

        // 찾은 드롭다운에서 다시 부모 요소들을 거슬러 올라가며
        // 'input-wrapper' 클래스를 가진 입력 필드 래퍼를 찾음
        const inputWrapper = dropdown.closest('.input-wrapper');

        // 래퍼 내에서 'search-input' 클래스를 가진 실제 검색 입력 필드를 찾음
        // querySelector()는 해당 요소의 자식 요소들 중에서 선택자와 일치하는 첫 번째 요소를 찾음
        const input = inputWrapper.querySelector('.search-input');

        selectSuggestion(input, dropdown, element);
    }

    // 제안 선택
    function selectSuggestion(input, dropdown, selectedElement) {
        const suggestions = JSON.parse(dropdown.dataset.suggestions || '[]');
        const index = parseInt(selectedElement.dataset.index);
        const selectedItem = suggestions[index];

        if (selectedItem) {
            // 도로명 주소 우선, 없으면 지번 주소
            const address = selectedItem.road_address_name || selectedItem.address_name;
            input.value = address;
        }

        hideDropdown(dropdown);
    }

    // HTML 이스케이프
    function escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    // 로딩 상태 설정
    function setLoadingState(button, isLoading) {
        if (isLoading) {
            button.disabled = true;
            button.innerHTML = '<i class="fas fa-spinner fa-spin"></i> 검색 중...';
            button.style.opacity = '0.7';
        } else {
            button.disabled = false;
            button.innerHTML = '<i class="fas fa-search"></i> 길찾기';
            button.style.opacity = '1';
        }
    }


</script>

<!-- Footer Include -->
<jsp:include page="footer.jsp"/>

</body>
</html>