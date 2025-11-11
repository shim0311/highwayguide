<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>휴게소 리뷰 - HighwayGuide</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100..900;1,100..900&display=swap"
          rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/indexStyle.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/footerStyle.css" rel="stylesheet">
    <style>
        /* 리뷰 페이지 전용 스타일 */
        .review-container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 30px 15px;
            margin-top: 70px; /* 헤더 높이만큼 상단 여백 추가 */
        }

        .review-header {
            text-align: center;
            margin-bottom: 40px;
        }

        .review-title {
            font-size: 2.2rem;
            font-weight: 700;
            color: #2c3e50;
            margin-bottom: 8px;
        }

        .review-subtitle {
            font-size: 1rem;
            color: #7f8c8d;
            font-weight: 400;
        }

        .search-container {
            margin-top: 25px;
        }

        .search-form {
            display: flex;
            justify-content: center;
            margin-bottom: 15px;
        }

        .search-input-group {
            display: flex;
            max-width: 400px;
            width: 100%;
            border-radius: 25px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
        }

        .search-input {
            flex: 1;
            padding: 12px 20px;
            border: none;
            outline: none;
            font-size: 1rem;
            background: white;
        }

        .search-button {
            padding: 12px 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            color: white;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .search-button:hover {
            background: linear-gradient(135deg, #5a6fd8 0%, #6a4190 100%);
        }

        .search-result-info {
            text-align: center;
            color: #7f8c8d;
            font-size: 0.9rem;
        }

        .search-keyword {
            color: #667eea;
            font-weight: 600;
        }

        .result-count {
            color: #2c3e50;
            font-weight: 600;
        }

        .clear-search {
            margin-left: 15px;
            color: #667eea;
            text-decoration: none;
            font-weight: 500;
        }

        .clear-search:hover {
            text-decoration: underline;
        }

        .review-summary {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin: 20px 0;
            padding: 12px 16px;
            background: #f8f9fa;
            border-radius: 8px;
            border-left: 4px solid #667eea;
        }

        .review-count {
            color: #495057;
            font-size: 0.9rem;
            font-weight: 500;
        }

        .review-count i {
            color: #667eea;
            margin-right: 6px;
        }

        .search-highlight {
            color: #667eea;
            font-size: 0.85rem;
            font-weight: 600;
        }

        .search-highlight i {
            margin-right: 4px;
        }

        .review-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 25px;
            margin-top: 25px;
        }

        .review-card {
            background: white;
            border-radius: 16px;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            transition: all 0.3s ease;
            position: relative;
        }

        .review-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
        }

        .review-image {
            width: 100%;
            height: 180px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            position: relative;
            overflow: hidden;
        }

        .review-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.3s ease, opacity 0.3s ease;
        }

        .review-card:hover .review-image img {
            transform: scale(1.05);
        }

        .no-image {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 2.5rem;
            opacity: 0.6;
            height: 100%;
            background: rgba(0, 0, 0, 0.1);
        }

        .no-image span {
            font-size: 0.8rem;
            margin-top: 8px;
            opacity: 0.9;
            font-weight: 500;
            letter-spacing: 0.5px;
        }

        .review-content {
            padding: 20px;
        }

        .review-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }

        .review-sakey {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
        }

        .review-writer {
            color: #7f8c8d;
            font-size: 0.9rem;
            font-weight: 500;
        }

        .review-text {
            color: #2c3e50;
            line-height: 1.5;
            font-size: 0.9rem;
            margin-bottom: 12px;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }

        .review-text.expanded {
            -webkit-line-clamp: unset;
        }

        .review-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 20px;
            padding-top: 15px;
            border-top: 1px solid #ecf0f1;
        }

        .read-more {
            color: #667eea;
            font-size: 0.9rem;
            font-weight: 600;
            cursor: pointer;
            transition: color 0.3s ease;
        }

        .read-more:hover {
            color: #764ba2;
        }

        .review-date {
            color: #95a5a6;
            font-size: 0.8rem;
        }

        .service-area-info {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 12px;
            padding: 6px 10px;
            background: #f8f9fa;
            border-radius: 6px;
            font-size: 0.8rem;
        }

        .service-area-address {
            color: #495057;
            flex: 1;
        }

        .service-area-star {
            color: #ffc107;
            font-weight: 600;
        }

        .service-area-star i {
            margin-right: 3px;
        }

        .error-message {
            background: #f8d7da;
            color: #721c24;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            text-align: center;
            border: 1px solid #f5c6cb;
        }

        .error-message i {
            margin-right: 8px;
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #7f8c8d;
        }

        .empty-icon {
            font-size: 4rem;
            margin-bottom: 20px;
            opacity: 0.5;
        }

        .empty-text {
            font-size: 1.2rem;
            margin-bottom: 10px;
        }

        .empty-subtext {
            font-size: 0.9rem;
        }

        /* 반응형 디자인 */
        @media (max-width: 768px) {
            .review-container {
                padding: 15px 10px;
            }

            .review-title {
                font-size: 1.8rem;
            }

            .review-summary {
                flex-direction: column;
                gap: 8px;
                text-align: center;
            }

            .review-grid {
                grid-template-columns: 1fr;
                gap: 15px;
            }

            .review-card {
                margin: 0 5px;
            }
        }

        /* 로딩 애니메이션 */
        .loading {
            text-align: center;
            padding: 40px;
        }

        .loading-spinner {
            border: 3px solid #f3f3f3;
            border-top: 3px solid #667eea;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 0 auto 20px;
        }

        .loading-more {
            text-align: center;
            padding: 30px;
            color: #7f8c8d;
        }

        .loading-more p {
            margin-top: 10px;
            font-size: 0.9rem;
        }

        @keyframes spin {
            0% {
                transform: rotate(0deg);
            }
            100% {
                transform: rotate(360deg);
            }
        }

        /* 카드 애니메이션 */
        .review-card {
            opacity: 0;
            transform: translateY(30px);
            animation: fadeInUp 0.6s ease forwards;
        }

        .review-card:nth-child(1) {
            animation-delay: 0.1s;
        }

        .review-card:nth-child(2) {
            animation-delay: 0.2s;
        }

        .review-card:nth-child(3) {
            animation-delay: 0.3s;
        }

        .review-card:nth-child(4) {
            animation-delay: 0.4s;
        }

        .review-card:nth-child(5) {
            animation-delay: 0.5s;
        }

        .review-card:nth-child(6) {
            animation-delay: 0.6s;
        }

        @keyframes fadeInUp {
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>
</head>
<body>
<%@ include file="header.jsp" %>

<main>
    <div class="review-container">
        <!-- 헤더 섹션 -->
        <div class="review-header">
            <h1 class="review-title">휴게소 리뷰</h1>
            <p class="review-subtitle">실제 이용자들의 생생한 휴게소 후기를 확인해보세요</p>
            
                    <!-- 검색 기능 -->
        <div class="search-container">
            <form action="${pageContext.request.contextPath}/Controller" method="get" class="search-form">
                <input type="hidden" name="type" value="review">
                <div class="search-input-group">
                    <input type="text" name="search" placeholder="휴게소 이름을 입력하세요..." 
                           value="${searchKeyword}" class="search-input">
                    <button type="submit" class="search-button">
                        <i class="fas fa-search"></i>
                    </button>
                </div>
            </form>
        </div>
        </div>

        <!-- 간단한 통계 표시 -->
        <div class="review-summary">
            <span class="review-count">
                <i class="fas fa-comments"></i>
                총 ${stats.totalReviews}개의 리뷰
            </span>
            <c:if test="${isSearch}">
                <span class="search-highlight">
                    <i class="fas fa-search"></i>
                    "${searchKeyword}" 검색 결과
                </span>
            </c:if>
        </div>

        <!-- 에러 메시지 표시 -->
        <c:if test="${not empty error}">
            <div class="error-message">
                <i class="fas fa-exclamation-triangle"></i>
                ${error}
            </div>
        </c:if>

        <!-- 리뷰 그리드 -->
        <div class="review-grid" id="reviewGrid">
            <c:choose>
                <c:when test="${empty reviews}">
                    <div class="empty-state">
                        <div class="empty-icon">
                            <i class="fas fa-comments"></i>
                        </div>
                        <div class="empty-text">아직 리뷰가 없습니다</div>
                        <div class="empty-subtext">첫 번째 리뷰를 작성해보세요!</div>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="review" items="${reviews}" varStatus="status">
                        <div class="review-card">
                            <!-- 이미지 섹션 -->
                            <div class="review-image">
                                <c:choose>
                                    <c:when test="${not empty review.imageUrl and review.imageUrl != ''}">
                                        <img src="${review.imageUrl}" alt="휴게소 이미지"
                                             onerror="this.parentElement.innerHTML='<div class=\\'no-image\\'><i class=\\'fas fa-image\\'></i><span>이미지 없음</span></div>'">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="no-image">
                                            <i class="fas fa-image"></i>
                                            <span>이미지 없음</span>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <!-- 리뷰 내용 -->
                            <div class="review-content">
                                <div class="review-meta">
                                    <span class="review-sakey">
                                        <c:choose>
                                            <c:when test="${not empty review.serviceAreaName}">
                                                ${review.serviceAreaName}
                                            </c:when>
                                            <c:otherwise>
                                                ${review.saKey}
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                    <span class="review-writer">
                                        <i class="fas fa-user"></i> ${review.writer}
                                    </span>
                                </div>
                                
                                <!-- 휴게소 정보 추가 -->
                                <c:if test="${not empty review.serviceAreaAddress}">
                                    <div class="service-area-info">
                                        <i class="fas fa-map-marker-alt"></i>
                                        <span class="service-area-address">${review.serviceAreaAddress}</span>
                                        <c:if test="${not empty review.serviceAreaStar and review.serviceAreaStar != '0' and review.serviceAreaStar != '0.0'}">
                                            <span class="service-area-star">
                                                <i class="fas fa-star"></i> ${review.serviceAreaStar}
                                            </span>
                                        </c:if>
                                    </div>
                                </c:if>

                                <div class="review-text" id="review-text-${status.index}">
                                    <c:choose>
                                        <c:when test="${not empty review.content and review.content != ''}">
                                            ${review.content}
                                        </c:when>
                                        <c:otherwise>
                                            <em style="color: #95a5a6;">리뷰 내용이 없습니다.</em>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <div class="review-actions">
                                    <c:if test="${not empty review.content and review.content != '' and fn:length(review.content) > 100}">
                                            <span class="read-more" onclick="toggleReadMore(${status.index})">
                                                더보기
                                            </span>
                                    </c:if>
                                    <span class="review-date">
                                            <i class="fas fa-clock"></i> 
                                            <c:out value="${review.idx}"/>
                                        </span>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
        
        <!-- 무한 스크롤 로딩 표시 -->
        <div class="loading-more" id="loadingMore" style="display: none;">
            <div class="loading-spinner"></div>
            <p>더 많은 리뷰를 불러오는 중...</p>
        </div>
    </div>
</main>

<script>
    // 더보기 토글 기능
    function toggleReadMore(index) {
        const reviewText = document.getElementById('review-text-' + index);
        const readMoreBtn = reviewText.parentElement.querySelector('.read-more');

        if (reviewText.classList.contains('expanded')) {
            reviewText.classList.remove('expanded');
            readMoreBtn.textContent = '더보기';
        } else {
            reviewText.classList.add('expanded');
            readMoreBtn.textContent = '접기';
        }
    }

    // 페이지 로드 시 애니메이션
    document.addEventListener('DOMContentLoaded', function () {
        // 스크롤 애니메이션
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }
            });
        }, observerOptions);

        // 리뷰 카드들 관찰
        document.querySelectorAll('.review-card').forEach(card => {
            observer.observe(card);
        });
    });

    // 무한 스크롤 변수
    let currentPage = 1;
    let isLoading = false;
    let hasMore = true;
    let currentSearch = '${searchKeyword}';

    // 무한 스크롤 함수
    function loadMoreReviews() {
        if (isLoading || !hasMore) return;
        
        isLoading = true;
        document.getElementById('loadingMore').style.display = 'block';
        
        let url = '${pageContext.request.contextPath}/Controller?type=reviewLoadMore&page=' + currentPage;
        if (currentSearch) {
            url += '&search=' + encodeURIComponent(currentSearch);
        }
        
        fetch(url)
            .then(response => response.json())
            .then(data => {
                if (data.error) {
                    console.error('리뷰 로드 오류:', data.error);
                    return;
                }
                
                const reviewGrid = document.getElementById('reviewGrid');
                const reviews = data.reviews;
                
                reviews.forEach((review, index) => {
                    const reviewCard = createReviewCard(review, reviewGrid.children.length + index);
                    reviewGrid.appendChild(reviewCard);
                });
                
                hasMore = data.hasMore;
                currentPage++;
                
                // 새로 추가된 이미지들에 대한 이벤트 처리
                setTimeout(() => {
                    const newImages = reviewGrid.querySelectorAll('.review-image img');
                    newImages.forEach(img => {
                        setupImageHandling(img);
                    });
                }, 100);
            })
            .catch(error => {
                console.error('리뷰 로드 실패:', error);
            })
            .finally(() => {
                isLoading = false;
                document.getElementById('loadingMore').style.display = 'none';
            });
    }

    // 리뷰 카드 생성 함수
    function createReviewCard(review, index) {
        const card = document.createElement('div');
        card.className = 'review-card';
        card.style.opacity = '0';
        card.style.transform = 'translateY(30px)';
        
        const imageUrl = review.imageUrl || '';
        const hasImage = imageUrl && imageUrl.trim() !== '';
        
        let imageHtml = '';
        if (hasImage) {
            imageHtml = '<img src="' + imageUrl + '" alt="휴게소 이미지" onerror="this.parentElement.innerHTML=\'<div class=\\\'no-image\\\'><i class=\\\'fas fa-image\\\'></i><span>이미지 없음</span></div>\'">';
        } else {
            imageHtml = '<div class="no-image"><i class="fas fa-image"></i><span>이미지 없음</span></div>';
        }
        
        let serviceAreaHtml = '';
        if (review.serviceAreaAddress) {
            let starHtml = '';
            if (review.serviceAreaStar && review.serviceAreaStar !== '0' && review.serviceAreaStar !== '0.0') {
                starHtml = '<span class="service-area-star"><i class="fas fa-star"></i> ' + review.serviceAreaStar + '</span>';
            }
            serviceAreaHtml = '<div class="service-area-info"><i class="fas fa-map-marker-alt"></i><span class="service-area-address">' + review.serviceAreaAddress + '</span>' + starHtml + '</div>';
        }
        
        let contentHtml = review.content ? review.content : '<em style="color: #95a5a6;">리뷰 내용이 없습니다.</em>';
        
        let readMoreHtml = '';
        if (review.content && review.content.length > 100) {
            readMoreHtml = '<span class="read-more" onclick="toggleReadMore(' + index + ')">더보기</span>';
        }
        
        card.innerHTML = 
            '<div class="review-image">' + imageHtml + '</div>' +
            '<div class="review-content">' +
                '<div class="review-meta">' +
                    '<span class="review-sakey">' + (review.serviceAreaName || review.saKey) + '</span>' +
                    '<span class="review-writer"><i class="fas fa-user"></i> ' + review.writer + '</span>' +
                '</div>' +
                serviceAreaHtml +
                '<div class="review-text" id="review-text-' + index + '">' + contentHtml + '</div>' +
                '<div class="review-actions">' +
                    readMoreHtml +
                    '<span class="review-date"><i class="fas fa-clock"></i> ' + review.idx + '</span>' +
                '</div>' +
            '</div>';
        
        // 애니메이션 적용
        setTimeout(() => {
            card.style.opacity = '1';
            card.style.transform = 'translateY(0)';
        }, 100);
        
        return card;
    }

    // 이미지 처리 설정 함수
    function setupImageHandling(img) {
        img.addEventListener('error', function () {
            this.parentElement.innerHTML = '<div class="no-image"><i class="fas fa-image"></i><span>이미지 없음</span></div>';
        });
        
        img.addEventListener('load', function () {
            this.style.opacity = '1';
        });
        
        if (img.complete) {
            img.style.opacity = '1';
        } else {
            img.style.opacity = '0';
            img.style.transition = 'opacity 0.3s ease';
        }
    }

    // 스크롤 이벤트 리스너
    window.addEventListener('scroll', function() {
        if ((window.innerHeight + window.scrollY) >= document.body.offsetHeight - 1000) {
            loadMoreReviews();
        }
    });

    // 페이지 로드 시 초기 이미지 처리
    document.addEventListener('DOMContentLoaded', function () {
        const images = document.querySelectorAll('.review-image img');
        images.forEach(img => {
            setupImageHandling(img);
        });
    });
</script>

<%@ include file="footer.jsp" %>
</body>
</html>
