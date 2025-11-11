<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!-- Header -->
<header class="header">
    <div class="nav-container">
        <a href="Controller" class="logo">
            <div class="logo-icon">
                <i class="fas fa-road"></i>
            </div>
            HighwayGuide
        </a>
        <nav class="main-nav">
            <ul class="nav-links">
                <li><a href="Controller?type=notice" class="nav-link">공지사항</a></li>
                <li><a href="Controller?type=mapinfo" class="nav-link">휴게소 정보</a></li>
                <li><a href="Controller?type=review" class="nav-link">휴게소 리뷰</a></li>
                <li><a href="Controller?type=customerService" class="nav-link">고객센터</a></li>
                <li><a href="Controller?type=faq">자주 묻는 질문</a></li>
            </ul>
        </nav>
        <div class="auth-buttons">
            <%--***** 로그인 되지 않은 경우 --%>
            <c:if test="${empty sessionScope.loginUser}">
                <a href="Controller?type=login" class="btn btn-login">로그인</a>
                <a href="Controller?type=register" class="btn btn-register">회원가입</a>
            </c:if>

            <%--***** 로그인된 경우 --%>
            <c:if test="${not empty sessionScope.loginUser}">
                <a href="Controller?type=logout" class="btn btn-logout">로그아웃</a>
                <a href="Controller?type=mypage" class="btn btn-register">마이페이지</a>
            </c:if>
            <c:if test="${sessionScope.loginUser ne null and sessionScope.loginUser.authority eq 1}">
                <%--관리자일 경우--%>
                <%--관리자 페이지로 돌아가게 함--%>
                <a href="Controller?type=manage" class="btn btn-register">관리자화면</a>
            </c:if>
        </div>
    </div>
</header>
