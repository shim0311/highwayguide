<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>휴게소 혼잡도 조회</title>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
      <link href="${pageContext.request.contextPath}/css/footerStyle.css" rel="stylesheet">
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    .container { max-width: 800px; margin: auto; }
    .rest-area-item { padding: 10px; border-bottom: 1px solid #ddd; }
    .congestion-status { font-weight: bold; }
    .search-form { margin-bottom: 20px; }
  </style>
</head>
<body>
<div class="container">
  <h1>휴게소 혼잡도 조회 서비스</h1>

  <form action="search" method="get" class="search-form">
    <input type="text" name="keyword" placeholder="검색할 휴게소 키워드" />
    <button type="submit">검색</button>
  </form>

  <c:if test="${not empty restAreas}">
    <h2>검색 결과</h2>
    <c:forEach var="restArea" items="${restAreas}" varStatus="status">
      <div class="rest-area-item">
          ${status.index + 1}. **${restArea.name}**
        <span class="congestion-status">[${restArea.congestionStatus}]</span>
        <br/>
        도로명: ${restArea.roadName}
      </div>
    </c:forEach>
  </c:if>

  <c:if test="${empty restAreas && param.keyword ne null}">
    <h2>검색 결과가 없습니다.</h2>
  </c:if>

</div>

<!-- Footer Include -->
<jsp:include page="footer.jsp" />

</body>
</html>