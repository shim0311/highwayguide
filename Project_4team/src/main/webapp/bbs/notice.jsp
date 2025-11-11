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
    <title>공지사항 - HighwayGuide</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100..900;1,100..900&display=swap"
          rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/indexStyle.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/footerStyle.css" rel="stylesheet">
    <style>
        /* Toss 스타일 공지사항 */
        body {
            font-family: 'PretendardVariable', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #ffffff;
            color: #191f28;
            line-height: 1.6;
            margin: 0;
            padding-top: 80px;
        }

        .notice-container {
            max-width: 768px;
            margin: 0 auto;
            padding: 0 20px;
        }

        .page-header {
            padding: 60px 0 40px 0;
            border-bottom: 1px solid #f2f4f6;
        }

        .page-title {
            font-size: 40px;
            font-weight: 700;
            color: #191f28;
            margin: 0;
            letter-spacing: -0.8px;
        }

        .notice-list {
            background: #ffffff;
        }

        .notice-item {
            padding: 32px 0;
            border-bottom: 1px solid #f2f4f6;
            transition: background-color 0.2s;
        }

        .notice-item:hover {
            background-color: #fafbfc;
            margin: 0 -20px;
            padding: 32px 20px;
        }

        .notice-item:last-child {
            border-bottom: none;
        }

        /* 카테고리 스타일 */
        .notice-category {
            display: inline-block;
            font-size: 12px;
            font-weight: 600;
            color: #3182f6;
            background-color: #eaf1ff;
            padding: 4px 8px;
            border-radius: 4px;
        }

        .notice-title {
            display: block;
            color: #191f28;
            text-decoration: none;
            font-size: 18px;
            font-weight: 600;
            line-height: 1.4;
            margin: 0;
            letter-spacing: -0.4px;
        }

        .notice-title:hover {
            color: #3182f6;
        }

        .notice-title-wrap {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 12px;
        }


        .notice-meta {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 14px;
            color: #8b95a1;
        }

        .notice-date {
            font-weight: 400;
        }

        .notice-author {
            font-weight: 400;
        }

        .admin-actions {
            margin-left: auto;
        }

        .delete-btn {
            padding: 6px 12px;
            background: #ffffff;
            color: #f04452;
            border: 1px solid #f04452;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
        }

        .delete-btn:hover {
            background: #f04452;
            color: #ffffff;
        }

        .pagination-container {
            padding: 60px 0 40px 0;
            display: flex;
            justify-content: center;
        }

        .pagination {
            display: flex;
            list-style: none;
            gap: 4px;
            margin: 0;
            padding: 0;
            align-items: center;
        }

        .pagination li {
            display: flex;
        }

        .pagination a,
        .pagination .disable,
        .pagination .now {
            display: flex;
            align-items: center;
            justify-content: center;
            min-width: 32px;
            height: 32px;
            padding: 0 8px;
            border-radius: 6px;
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
            transition: all 0.2s;
        }

        .pagination a {
            background: #ffffff;
            color: #4e5968;
            border: 1px solid #e5e8eb;
        }

        .pagination a:hover {
            background: #f2f4f6;
            color: #191f28;
        }

        .pagination .now {
            background: #3182f6;
            color: #ffffff;
            border: 1px solid #3182f6;
        }

        .pagination .disable {
            background: #ffffff;
            color: #d0d5dd;
            border: 1px solid #e5e8eb;
            cursor: not-allowed;
        }

        .write-btn-container {
            padding: 20px 0;
            text-align: right;
            border-bottom: 1px solid #f2f4f6;
        }

        .write-btn {
            padding: 12px 20px;
            background: #3182f6;
            color: #ffffff;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: background-color 0.2s;
        }

        .write-btn:hover {
            background: #1b64da;
        }

        .empty-state {
            text-align: center;
            padding: 80px 20px;
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
            .notice-container {
                padding: 0 16px;
            }

            .page-header {
                padding: 40px 0 32px 0;
            }

            .page-title {
                font-size: 32px;
            }

            .notice-item {
                padding: 28px 0;
            }

            .notice-item:hover {
                margin: 0 -16px;
                padding: 28px 16px;
            }

            .notice-meta {
                flex-direction: column;
                align-items: flex-start;
                gap: 4px;
            }

            .admin-actions {
                margin-left: 0;
                margin-top: 8px;
            }

            .pagination-container {
                padding: 40px 0 32px 0;
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
<!-- Header -->
<%@ include file="/header.jsp" %>
<!-- Main Content -->
<main>
    <div class="notice-container">
        <!-- Page Header -->
        <div class="page-header">
            <h1 class="page-title">공지사항</h1>
        </div>

        <!-- Write Button (관리자만) -->
        <c:if test="${not empty sessionScope.loginUser and sessionScope.loginUser.authority
                      ne null and sessionScope.loginUser.authority == 1}">
            <div class="write-btn-container">
                <button type="button" class="write-btn"
                        onclick="location.href='Controller?type=write&returnTo=notice'">
                    글쓰기
                </button>
            </div>
        </c:if>

        <!-- Notice List -->
        <div class="notice-list">
            <c:set var="ar" value="${requestScope.ar}"/>
            <c:set var="p" value="${requestScope.page}" scope="page"/>

            <c:choose>
                <c:when test="${empty ar}">
                    <div class="empty-state">
                        <i class="fas fa-inbox"></i>
                        <h3>등록된 공지사항이 없습니다</h3>
                        <p>새로운 공지사항이 등록되면 이곳에 표시됩니다.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach items="${ar}" var="vo" varStatus="vs">
                        <div class="notice-item">
                            <div class="notice-title-wrap">
                                    <%-- 카테고리 표시 --%>
                                <span class="notice-category">
                                    <c:choose>
                                        <c:when test="${vo.category eq 'HighWay'}">
                                            고속도로
                                        </c:when>
                                        <c:when test="${vo.category eq 'RestArea'}">
                                            졸음쉼터
                                        </c:when>
                                        <c:when test="${vo.category eq 'ServiceArea'}">
                                            휴게소
                                        </c:when>
                                        <c:when test="${vo.category eq 'Shop'}">
                                            매장
                                        </c:when>
                                        <c:when test="${vo.category eq 'Guide'}">
                                            이용안내
                                        </c:when>
                                        <c:when test="${vo.category eq 'Faq'}">
                                            FAQ
                                        </c:when>
                                        <c:when test="${vo.category eq 'Other'}">
                                            기타
                                        </c:when>
                                        <c:otherwise>
                                            기타
                                        </c:otherwise>
                                    </c:choose>
                                </span>
                                <a href="Controller?type=view&PostNum=${vo.postNum}&cPage=${p.nowPage}"
                                   class="notice-title">
                                        ${vo.subject}
                                </a>
                            </div>
                            <div class="notice-meta">
                                <span class="notice-date">${vo.writeDate}</span>
                                <span class="notice-author">${vo.writer}</span>
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
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Pagination -->
        <div class="pagination-container">
            <ol class="pagination">
                <c:if test="${p.startPage < p.pagePerBlock}">
                    <li><span class="disable">&lt;</span></li>
                </c:if>
                <c:if test="${p.startPage >= p.pagePerBlock}">
                    <li><a href="Controller?type=notice&cPage=${p.nowPage-p.pagePerBlock}">&lt;</a></li>
                </c:if>

                <c:forEach begin="${p.startPage}" end="${p.endPage}" var="pageNum">
                    <c:if test="${p.nowPage == pageNum}">
                        <li><span class="now">${pageNum}</span></li>
                    </c:if>
                    <c:if test="${p.nowPage != pageNum}">
                        <li><a href="Controller?type=notice&cPage=${pageNum}">${pageNum}</a></li>
                    </c:if>
                </c:forEach>

                <c:if test="${p.endPage < p.totalPage}">
                    <li><a href="Controller?type=notice&cPage=${p.nowPage+p.pagePerBlock}">&gt;</a></li>
                </c:if>
                <c:if test="${p.endPage >= p.totalPage}">
                    <li><span class="disable">&gt;</span></li>
                </c:if>
            </ol>
        </div>
    </div>
</main>
<jsp:include page="../footer.jsp"/>

<script>
    function delPost(postNum, cPage) {
        if (confirm("정말로 이 공지사항을 삭제하시겠습니까?")) {
            // 삭제 버튼 비활성화
            const deleteBtn = event.target;
            deleteBtn.textContent = '삭제 중...';
            deleteBtn.disabled = true;

            // 삭제 요청
            location.href = "Controller?type=del&PostNum=" + postNum + "&cPage=" + cPage;
        }
    }

    // 페이지 로드 시 부드러운 등장 효과
    document.addEventListener('DOMContentLoaded', function () {
        const noticeItems = document.querySelectorAll('.notice-item');
        noticeItems.forEach((item, index) => {
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