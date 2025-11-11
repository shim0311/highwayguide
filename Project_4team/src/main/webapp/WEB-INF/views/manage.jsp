<%--
  Created by IntelliJ IDEA.
  User: js
  Date: 25. 7. 31.
  Time: 오전 9:38
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HighwayGuide - 관리 페이지</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100..900;1,100..900&display=swap"
          rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/indexStyle.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/footerStyle.css" rel="stylesheet">
    <style>
        /* 공통 관리 페이지 스타일 */
        .manage-container {
            max-width: 1200px !important;
            margin: 0 auto !important;
            padding: 120px 2rem 4rem !important;
        }
        
        .manage-header {
            text-align: center !important;
            margin-bottom: 3rem !important;
        }
        
        .manage-title {
            font-size: 2.5rem !important;
            font-weight: 700 !important;
            color: #222 !important;
            margin-bottom: 1rem !important;
        }
        
        .manage-subtitle {
            font-size: 1.1rem !important;
            color: #666 !important;
            margin-bottom: 2rem !important;
        }
    </style>

</head>
<body>
<c:set var="vo" value="${sessionScope.loginUser}" scope="page"/>
<c:set var="content" value="${param.content}" scope="page"/>
    <!-- Header -->
    <header class="header">
        <div class="nav-container">
            <a href="Controller" class="logo">
                <div class="logo-icon">
                    <i class="fas fa-road"></i>
                </div>
                HighwayGuide
            </a>
            <nav>
                <ul class="nav-links">
                    <li><a href="Controller?type=manage&content=dashBoard">대시보드&업데이트</a></li>
                    <li><a href="Controller?type=notice">공지사항 수정</a></li>
                    <li><a href="Controller?type=manage&content=member">회원조회</a></li>
                    <li><a href="Controller?type=faq">자주 묻는 질문 수정</a></li>
                </ul>
            </nav>
            <div class="auth-buttons">
                <a href="#" class="btn btn-login">KOR</a>
                <a href="#" class="btn btn-login">ENG</a>

                <c:if test="${vo eq null or vo.authority eq 0}"> <%--로그인이 안되어있거나 일반사용자일 경우--%>
<%--                    메인 페이지로 돌아가게 함--%>
                    <c:redirect url="Controller">
                        <c:param name="type" value="mainpage"/>
                    </c:redirect>
                </c:if>
                <c:if test="${vo ne null and vo.authority eq 1}"> <%--관리자일 경우만--%>
                    <a href="Controller?type=logout" class="btn btn-logout">로그아웃</a>
                </c:if>
            </div>
        </div>
    </header>

<c:if test="${content eq null or content eq 'dashBoard'}">
    <div style="margin-top: 0">
        <jsp:include page="../../dashBoard.jsp"/>
    </div>
</c:if>

<c:if test="${content eq 'member'}">
    <div style="margin-top: 0;">
        <jsp:include page="../../member.jsp"/>
    </div>
</c:if>

    <!-- Footer Include -->
    <jsp:include page="../../footer.jsp" />
</body>
</html>
