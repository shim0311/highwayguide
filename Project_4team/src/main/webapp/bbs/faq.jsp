<%@ page import="mybatis.vo.BbsVO" %>
<%@ page import="bbs.util.Paging" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>자주 묻는 질문 (FAQ) - HighwayGuide</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100..900;1,100..900&display=swap"
          rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/indexStyle.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/footerStyle.css" rel="stylesheet">
    <style>
        /* 심플하고 컴팩트한 FAQ 스타일 */
        body {
            font-family: 'PretendardVariable', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #f8f9fa;
            color: #191f28;
            line-height: 1.6;
            margin: 0;
            padding-top: 80px;
        }

        .faq-container {
            max-width: 800px;
            margin: 0 auto;
            padding: 0 20px 40px 20px;
        }

        .page-header {
            padding: 40px 0 30px 0;
            text-align: center;
        }

        .page-title {
            font-size: 36px;
            font-weight: 700;
            color: #191f28;
            margin: 0 0 12px 0;
        }

        .page-subtitle {
            font-size: 16px;
            color: #8b95a1;
            margin: 0;
        }

        .faq-list {
            background: #ffffff;
            border-radius: 8px;
            border: 1px solid #e5e8eb;
            overflow: hidden;
            margin-bottom: 60px;
        }

        .faq-item {
            border-bottom: 1px solid #f2f4f6;
        }

        .faq-item:last-child {
            border-bottom: none;
        }

        .faq-item:first-child {
            border-top: 1px solid #f2f4f6;
        }

        .faq-question {
            background: #ffffff;
            padding: 20px 24px;
            cursor: pointer;
            transition: background-color 0.2s;
            display: flex;
            align-items: center;
            border: none;
            width: 100%;
            text-align: left;
            border-bottom: 1px solid #e5e8eb;
        }

        .faq-question:hover {
            background-color: #f8f9fa;
        }

        .faq-question.active {
            background-color: #f8f9fa;
            border-left: 3px solid #667eea;
            padding-left: 21px; /* 24px - 3px border */
        }

        .faq-question-icon {
            width: 24px;
            height: 24px;
            background: #667eea;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #ffffff;
            font-weight: bold;
            font-size: 12px;
            margin-right: 16px;
            flex-shrink: 0;
        }

        .faq-title {
            font-size: 16px;
            font-weight: 500;
            color: #191f28;
            margin: 0;
            flex: 1;
            text-align: left;
        }

        .faq-toggle-icon {
            color: #8b95a1;
            font-size: 14px;
            transition: transform 0.2s ease;
            margin-left: 12px;
            flex-shrink: 0;
        }

        .faq-question.active .faq-toggle-icon {
            transform: rotate(180deg);
            color: #667eea;
        }

        .faq-answer {
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.3s ease, padding 0.3s ease;
            background: #ffffff;
        }

        .faq-answer.active {
            max-height: 500px;
            padding: 20px 24px 20px 48px;
        }

        .faq-answer-content {
            display: flex;
            align-items: flex-start;
        }

        .faq-answer-icon {
            width: 24px;
            height: 24px;
            background: #4caf50;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #ffffff;
            font-weight: bold;
            font-size: 12px;
            margin-right: 16px;
            flex-shrink: 0;
        }

        .faq-content {
            color: #4e5968;
            line-height: 1.6;
            margin: 0;
            overflow: hidden;
            flex: 1;
            font-size: 15px;
        }

        .faq-meta {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 12px;
            color: #8b95a1;
            margin-top: 12px;
            padding-top: 12px;
            border-top: 1px solid #e5e8eb;
        }

        .faq-date {
            font-weight: 400;
        }

        .faq-author {
            font-weight: 400;
        }

        .admin-actions {
            margin-left: auto;
        }

        .delete-btn {
            padding: 6px 12px;
            background: #ffffff;
            color: #dc3545;
            border: 1px solid #dc3545;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 500;
            cursor: pointer;
            transition: background-color 0.2s;
        }

        .delete-btn:hover {
            background: #dc3545;
            color: #ffffff;
        }



        .write-btn-container {
            padding: 20px 0;
            text-align: right;
        }

        .write-btn {
            padding: 12px 20px;
            background: #667eea;
            color: #ffffff;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: background-color 0.2s;
        }

        .write-btn:hover {
            background: #5a67d8;
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #8b95a1;
        }

        .empty-state i {
            font-size: 48px;
            color: #d0d5dd;
            margin-bottom: 16px;
        }

        .empty-state h3 {
            font-size: 18px;
            font-weight: 600;
            color: #4e5968;
            margin: 0 0 8px 0;
        }

        .empty-state p {
            font-size: 14px;
            color: #8b95a1;
            margin: 0;
        }

        /* 반응형 디자인 */
        @media (max-width: 768px) {
            .faq-container {
                padding: 0 16px;
            }

            .page-header {
                padding: 30px 0 20px 0;
            }

            .page-title {
                font-size: 28px;
            }

            .page-subtitle {
                font-size: 14px;
            }

            .faq-question {
                padding: 16px 20px;
            }

            .faq-question.active {
                padding-left: 17px; /* 20px - 3px border */
            }

            .faq-answer.active {
                padding: 16px 20px 16px 36px;
            }

            .faq-title {
                font-size: 15px;
            }

            .faq-question-icon,
            .faq-answer-icon {
                width: 20px;
                height: 20px;
                font-size: 10px;
                margin-right: 12px;
            }

            .faq-meta {
                flex-direction: column;
                align-items: flex-start;
                gap: 4px;
            }

            .admin-actions {
                margin-left: 0;
                margin-top: 8px;
            }



            .write-btn {
                padding: 10px 16px;
                font-size: 13px;
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
    <div class="faq-container">
        <div class="page-header">
            <h1 class="page-title">자주 묻는 질문 (FAQ)</h1>
            <p class="page-subtitle">고속도로 휴게소 정보 서비스에 대해 궁금한 점을 해결해드립니다</p>
        </div>

        <c:if test="${not empty sessionScope.loginUser and sessionScope.loginUser.authority
                      ne null and sessionScope.loginUser.authority == 1}">
            <div class="write-btn-container">
                <button type="button" class="write-btn"
                        onclick="location.href='Controller?type=write&category=Faq&returnTo=faq'">
                    글쓰기
                </button>
            </div>
        </c:if>

        <div class="faq-list">
            <c:set var="ar" value="${requestScope.ar}"/>
            <c:set var="p" value="${requestScope.page}" scope="page"/>

            <c:choose>
                <c:when test="${empty ar}">
                    <div class="empty-state">
                        <i class="fas fa-inbox"></i>
                        <h3>등록된 FAQ가 없습니다</h3>
                        <p>궁금한 점이 해결되면 이곳에 표시됩니다.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach items="${ar}" var="vo" varStatus="vs">
                        <div class="faq-item">
                            <button class="faq-question" onclick="toggleFaq(${vs.index})">
                                <div class="faq-question-icon">Q</div>
                                <h3 class="faq-title">${vo.subject}</h3>
                                <i class="fas fa-chevron-up faq-toggle-icon"></i>
                            </button>
                            <div class="faq-answer" id="faq-answer-${vs.index}">
                                <div class="faq-answer-content">
                                    <div class="faq-answer-icon">A</div>
                                    <div class="faq-content">
                                        ${vo.content}
                                    </div>
                                </div>
                                <div class="faq-meta">
                                    <span class="faq-date">${vo.writeDate}</span>
                                    <span class="faq-author">${vo.writer}</span>
                                    <%--관리자일 경우 삭제 버튼 추가--%>
                                    <c:if test="${not empty sessionScope.loginUser and sessionScope.loginUser.authority
                            ne null and sessionScope.loginUser.authority == 1}">
                                        <div class="admin-actions">
                                            <button type="button" class="delete-btn"
                                                    onclick="delPost('${vo.postNum}', '${p.nowPage}')">
                                                삭제
                                            </button>
                                        </div>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</main>
<jsp:include page="../footer.jsp"/>

<script>
    function delPost(postNum, cPage) {
        if (confirm("정말로 이 FAQ를 삭제하시겠습니까?")) {
            // 삭제 버튼 비활성화
            const deleteBtn = event.target;
            deleteBtn.textContent = '삭제 중...';
            deleteBtn.disabled = true;

            // 삭제 요청
            location.href = "Controller?type=del&PostNum=" + postNum + "&cPage=" + cPage + "&returnTo=faq";
        }
    }

    // FAQ 아코디언 토글 함수
    function toggleFaq(index) {
        const question = event.currentTarget;
        const answer = document.getElementById('faq-answer-' + index);
        const icon = question.querySelector('.faq-toggle-icon');
        
        // 현재 활성화된 다른 FAQ 닫기
        const allQuestions = document.querySelectorAll('.faq-question');
        const allAnswers = document.querySelectorAll('.faq-answer');
        const allIcons = document.querySelectorAll('.faq-toggle-icon');
        
        allQuestions.forEach((q, i) => {
            if (i !== index) {
                q.classList.remove('active');
                allAnswers[i].classList.remove('active');
                allIcons[i].style.transform = 'rotate(0deg)';
            }
        });
        
        // 현재 FAQ 토글
        question.classList.toggle('active');
        answer.classList.toggle('active');
        
        if (question.classList.contains('active')) {
            icon.style.transform = 'rotate(180deg)';
        } else {
            icon.style.transform = 'rotate(0deg)';
        }
    }

    // 페이지 로드 시 부드러운 등장 효과
    document.addEventListener('DOMContentLoaded', function () {
        const faqItems = document.querySelectorAll('.faq-item');
        faqItems.forEach((item, index) => {
            item.style.opacity = '0';
            item.style.transform = 'translateY(10px)';

            setTimeout(() => {
                item.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
                item.style.opacity = '1';
                item.style.transform = 'translateY(0)';
            }, index * 50);
        });
    });
</script>
</body>
</html>

