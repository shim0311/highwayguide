<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>고객센터 - HighwayGuide</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Pretendard:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/indexStyle.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/footerStyle.css" rel="stylesheet">
    <style>
        body {
            font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #f8f9fa;
            color: #191f28;
            line-height: 1.6;
            margin: 0;
            padding-top: 80px;
        }

        .customer-service-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }

        .page-header {
            text-align: center;
            padding: 60px 0 40px 0;
        }

        .page-title {
            font-size: 48px;
            font-weight: 700;
            color: #191f28;
            margin: 0 0 16px 0;
        }

        .page-subtitle {
            font-size: 18px;
            color: #8b95a1;
            margin: 0;
        }

        .main-content {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 40px;
            margin-bottom: 60px;
        }

        .help-section {
            background: #ffffff;
            border-radius: 16px;
            padding: 40px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }

        .section-title {
            font-size: 24px;
            font-weight: 600;
            color: #191f28;
            margin: 0 0 24px 0;
        }

        .help-grid {
            display: grid;
            gap: 16px;
        }

        .help-item {
            display: flex;
            align-items: center;
            padding: 16px 20px;
            background: #f8f9fa;
            border-radius: 12px;
            text-decoration: none;
            color: #191f28;
            transition: all 0.2s;
            border: 1px solid transparent;
        }

        .help-item:hover {
            background: #e9ecef;
            border-color: #dee2e6;
            transform: translateY(-1px);
        }

        .help-icon {
            width: 40px;
            height: 40px;
            background: #667eea;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #ffffff;
            font-size: 18px;
            margin-right: 16px;
            flex-shrink: 0;
        }

        .help-text {
            font-size: 16px;
            font-weight: 500;
            margin: 0;
        }

        .contact-section {
            background: #ffffff;
            border-radius: 16px;
            padding: 40px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }

        .contact-info {
            margin-bottom: 32px;
        }

        .contact-item {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
        }

        .contact-icon {
            width: 48px;
            height: 48px;
            background: #667eea;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #ffffff;
            font-size: 20px;
            margin-right: 16px;
            flex-shrink: 0;
        }

        .contact-details h3 {
            font-size: 18px;
            font-weight: 600;
            color: #191f28;
            margin: 0 0 4px 0;
        }

        .contact-details p {
            font-size: 16px;
            color: #8b95a1;
            margin: 0;
        }

        .service-hours {
            background: #f8f9fa;
            border-radius: 12px;
            padding: 20px;
            margin-top: 24px;
        }

        .service-hours h4 {
            font-size: 16px;
            font-weight: 600;
            color: #191f28;
            margin: 0 0 8px 0;
        }

        .service-hours p {
            font-size: 14px;
            color: #8b95a1;
            margin: 0;
        }

        .quick-links {
            background: #ffffff;
            border-radius: 16px;
            padding: 40px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            margin-bottom: 40px;
        }

        .quick-links-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
        }

        .quick-link-item {
            display: flex;
            align-items: center;
            padding: 16px;
            background: #f8f9fa;
            border-radius: 12px;
            text-decoration: none;
            color: #191f28;
            transition: all 0.2s;
        }

        .quick-link-item:hover {
            background: #e9ecef;
            transform: translateY(-1px);
        }

        .quick-link-icon {
            width: 32px;
            height: 32px;
            background: #667eea;
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #ffffff;
            font-size: 14px;
            margin-right: 12px;
            flex-shrink: 0;
        }

        .quick-link-text {
            font-size: 14px;
            font-weight: 500;
            margin: 0;
        }

        .emergency-section {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 16px;
            padding: 40px;
            color: #ffffff;
            text-align: center;
            margin-bottom: 40px;
        }

        .emergency-title {
            font-size: 28px;
            font-weight: 700;
            margin: 0 0 16px 0;
        }

        .emergency-description {
            font-size: 16px;
            margin: 0 0 24px 0;
            opacity: 0.9;
        }

        .emergency-button {
            display: inline-flex;
            align-items: center;
            padding: 16px 32px;
            background: rgba(255, 255, 255, 0.2);
            border: 2px solid rgba(255, 255, 255, 0.3);
            border-radius: 12px;
            color: #ffffff;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.2s;
        }

        .emergency-button:hover {
            background: rgba(255, 255, 255, 0.3);
            border-color: rgba(255, 255, 255, 0.5);
            transform: translateY(-2px);
        }

        .emergency-button i {
            margin-right: 8px;
        }

        /* 반응형 디자인 */
        @media (max-width: 768px) {
            .customer-service-container {
                padding: 0 16px;
            }

            .page-header {
                padding: 40px 0 30px 0;
            }

            .page-title {
                font-size: 36px;
            }

            .page-subtitle {
                font-size: 16px;
            }

            .main-content {
                grid-template-columns: 1fr;
                gap: 24px;
            }

            .help-section,
            .contact-section,
            .quick-links {
                padding: 24px;
            }

            .quick-links-grid {
                grid-template-columns: 1fr;
            }

            .emergency-section {
                padding: 30px 20px;
            }

            .emergency-title {
                font-size: 24px;
            }
        }

        /* 헤더 스타일 오버라이드 */
        .header {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-bottom: 1px solid #f2f4f6;
        }
    </style>
</head>
<body>
<%@ include file="/header.jsp" %>

<main>
    <div class="customer-service-container">
        <div class="page-header">
            <h1 class="page-title">고객센터</h1>
            <p class="page-subtitle">고속도로 휴게소 정보 서비스에 대해 궁금한 점이 있으신가요?</p>
        </div>

        <div class="emergency-section">
            <h2 class="emergency-title">긴급 상황이신가요?</h2>
            <p class="emergency-description">고속도로 휴게소 관련 긴급 문의사항이 있으시면 즉시 연락해주세요.</p>
            <a href="tel:1661-7654" class="emergency-button">
                <i class="fas fa-phone"></i>
                긴급 연락처: 1661-7654
            </a>
        </div>

        <div class="main-content">
            <div class="help-section">
                <h2 class="section-title">무엇을 도와드릴까요?</h2>
                <div class="help-grid">
                    <a href="Controller?type=faq" class="help-item">
                        <div class="help-icon">
                            <i class="fas fa-question-circle"></i>
                        </div>
                        <p class="help-text">자주 묻는 질문</p>
                    </a>
                    <a href="#" class="help-item" onclick="showServiceGuide()">
                        <div class="help-icon">
                            <i class="fas fa-map-marked-alt"></i>
                        </div>
                        <p class="help-text">휴게소 검색 방법</p>
                    </a>
                    <a href="#" class="help-item" onclick="showRatingGuide()">
                        <div class="help-icon">
                            <i class="fas fa-star"></i>
                        </div>
                        <p class="help-text">별점 및 리뷰 안내</p>
                    </a>
                    <a href="#" class="help-item" onclick="showCctvGuide()">
                        <div class="help-icon">
                            <i class="fas fa-video"></i>
                        </div>
                        <p class="help-text">CCTV 실시간 확인</p>
                    </a>
                    <a href="#" class="help-item" onclick="showAiGuide()">
                        <div class="help-icon">
                            <i class="fas fa-robot"></i>
                        </div>
                        <p class="help-text">AI 요약 정보</p>
                    </a>
                    <a href="#" class="help-item" onclick="showCongestionGuide()">
                        <div class="help-icon">
                            <i class="fas fa-traffic-light"></i>
                        </div>
                        <p class="help-text">혼잡도 확인 방법</p>
                    </a>
                </div>
            </div>

            <div class="contact-section">
                <h2 class="section-title">연락처</h2>
                <div class="contact-info">
                    <div class="contact-item">
                        <div class="contact-icon">
                            <i class="fas fa-phone"></i>
                        </div>
                        <div class="contact-details">
                            <h3>고객센터</h3>
                            <p>1599-4905 (24시간 연중무휴)</p>
                        </div>
                    </div>
                    <div class="contact-item">
                        <div class="contact-icon">
                            <i class="fas fa-envelope"></i>
                        </div>
                        <div class="contact-details">
                            <h3>이메일</h3>
                            <p>support@highwayguide.kr</p>
                        </div>
                    </div>
                    <div class="contact-item">
                        <div class="contact-icon">
                            <i class="fas fa-comments"></i>
                        </div>
                        <div class="contact-details">
                            <h3>실시간 채팅</h3>
                            <p>평일 09:00 - 18:00</p>
                        </div>
                    </div>
                </div>
                <div class="service-hours">
                    <h4>서비스 운영시간</h4>
                    <p>평일: 09:00 - 18:00<br>
                    주말/공휴일: 10:00 - 17:00<br>
                    긴급상황: 24시간 대응</p>
                </div>
            </div>
        </div>

        <div class="quick-links">
            <h2 class="section-title">빠른 링크</h2>
            <div class="quick-links-grid">
                <a href="Controller?type=notice" class="quick-link-item">
                    <div class="quick-link-icon">
                        <i class="fas fa-bullhorn"></i>
                    </div>
                    <p class="quick-link-text">공지사항</p>
                </a>
                <a href="#" class="quick-link-item" onclick="showPrivacyPolicy()">
                    <div class="quick-link-icon">
                        <i class="fas fa-shield-alt"></i>
                    </div>
                    <p class="quick-link-text">개인정보처리방침</p>
                </a>
                <a href="#" class="quick-link-item" onclick="showTerms()">
                    <div class="quick-link-icon">
                        <i class="fas fa-file-contract"></i>
                    </div>
                    <p class="quick-link-text">이용약관</p>
                </a>
                <a href="#" class="quick-link-item" onclick="showAbout()">
                    <div class="quick-link-icon">
                        <i class="fas fa-info-circle"></i>
                    </div>
                    <p class="quick-link-text">서비스 소개</p>
                </a>
                <a href="#" class="quick-link-item" onclick="showFeedback()">
                    <div class="quick-link-icon">
                        <i class="fas fa-comment-dots"></i>
                    </div>
                    <p class="quick-link-text">의견 보내기</p>
                </a>
                <a href="#" class="quick-link-item" onclick="showBugReport()">
                    <div class="quick-link-icon">
                        <i class="fas fa-bug"></i>
                    </div>
                    <p class="quick-link-text">버그 신고</p>
                </a>
            </div>
        </div>
    </div>
</main>

<jsp:include page="footer.jsp"/>

<script>
    function showServiceGuide() {
        alert('휴게소 검색 방법:\n\n1. 출발지와 목적지를 입력하세요\n2. 검색 버튼을 클릭하세요\n3. 해당 구간의 휴게소 목록을 확인하세요\n4. 휴게소를 클릭하여 상세 정보를 보세요');
    }

    function showRatingGuide() {
        alert('별점 및 리뷰 안내:\n\n• 별점: 사용자들이 평가한 평균 별점\n• 리뷰: 실제 방문자들의 생생한 후기\n• 평가 기준: 청결도, 편의성, 음식 품질 등');
    }

    function showCctvGuide() {
        alert('CCTV 실시간 확인:\n\n• 휴게소 내부 실시간 영상 제공\n• 주차장 혼잡도 실시간 확인\n• 안전한 휴게소 이용을 위한 정보');
    }

    function showAiGuide() {
        alert('AI 요약 정보:\n\n• 사용자 리뷰를 AI가 분석하여 요약\n• 휴게소의 주요 특징과 장점 제공\n• 방문 전 참고할 수 있는 핵심 정보');
    }

    function showCongestionGuide() {
        alert('혼잡도 확인 방법:\n\n• 실시간: CCTV 영상으로 실시간 확인\n• 예측: 시간대별 혼잡도 예측 정보\n• 피크 시간: 주말, 공휴일, 점심시간 등');
    }

    function showPrivacyPolicy() {
        alert('개인정보처리방침 페이지로 이동합니다.');
        // 실제 페이지로 이동하는 코드 추가
    }

    function showTerms() {
        alert('이용약관 페이지로 이동합니다.');
        // 실제 페이지로 이동하는 코드 추가
    }

    function showAbout() {
        alert('서비스 소개 페이지로 이동합니다.');
        // 실제 페이지로 이동하는 코드 추가
    }

    function showFeedback() {
        alert('의견 보내기 기능을 준비 중입니다.');
        // 실제 기능 구현
    }

    function showBugReport() {
        alert('버그 신고 기능을 준비 중입니다.');
        // 실제 기능 구현
    }

    // 페이지 로드 시 부드러운 등장 효과
    document.addEventListener('DOMContentLoaded', function () {
        const sections = document.querySelectorAll('.help-section, .contact-section, .quick-links, .emergency-section');
        sections.forEach((section, index) => {
            section.style.opacity = '0';
            section.style.transform = 'translateY(20px)';

            setTimeout(() => {
                section.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
                section.style.opacity = '1';
                section.style.transform = 'translateY(0)';
            }, index * 200);
        });
    });
</script>
</body>
</html>
