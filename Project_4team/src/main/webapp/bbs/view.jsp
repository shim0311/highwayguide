<%@ page import="mybatis.vo.BbsVO" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="java.util.Properties" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>공지사항 상세 - HighwayGuide</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100..900;1,100..900&display=swap"
          rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/indexStyle.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/footerStyle.css" rel="stylesheet">
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.14.1/themes/base/jquery-ui.css">
    <style>
        /* Toss 스타일 공지사항 상세 */
        body {
            font-family: 'PretendardVariable', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #ffffff;
            color: #191f28;
            line-height: 1.6;
            margin: 0;
            padding-top: 80px;
        }

        .view-container {
            max-width: 768px;
            margin: 0 auto;
            padding: 0 20px;
        }

        .article-header {
            padding: 40px 0 32px 0;
            border-bottom: 1px solid #f2f4f6;
        }

        .article-title {
            font-size: 28px;
            font-weight: 700;
            color: #191f28;
            line-height: 1.3;
            margin: 0; /* 이 부분을 0으로 수정 */
            letter-spacing: -0.6px;
        }

        /* notice.jsp와 동일한 카테고리 디자인 */
        .notice-category {
            display: inline-block;
            font-size: 12px;
            font-weight: 600;
            color: #3182f6;
            background-color: #eaf1ff;
            padding: 4px 8px;
            border-radius: 4px;
        }

        .notice-title-wrap {
            display: flex;
            align-items: center;
            gap: 8px; /* 카테고리와 제목 사이 간격 추가 */
            margin-bottom: 20px; /* 제목과 메타 정보 사이 간격 유지 */
        }


        .article-meta {
            display: flex;
            align-items: center;
            gap: 16px;
            font-size: 14px;
            color: #8b95a1;
        }

        .article-meta span:not(:last-child)::after {
            content: "·";
            margin-left: 8px;
            color: #d0d5dd;
        }


        .article-content {
            padding: 40px 0;
            border-bottom: 1px solid #f2f4f6;
        }

        .content-text {
            font-size: 16px;
            line-height: 1.7;
            color: #191f28;
            word-break: break-word;
        }

        /* 이미지 반응형 처리 */
        .content-text img {
            max-width: 100%;
            height: auto;
            display: block;
            margin: 20px auto;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .content-text img:hover {
            transform: scale(1.02);
            transition: transform 0.3s ease;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
        }

        .attachment-section {
            padding: 24px 0;
            border-bottom: 1px solid #f2f4f6;
        }

        .attachment-item {
            display: flex;
            align-items: center;
            padding: 16px;
            background: #f8fafc;
            border: 1px solid #e5e8eb;
            border-radius: 8px;
            gap: 12px;
            transition: all 0.2s;
        }

        .attachment-item:hover {
            background: #f2f4f6;
            border-color: #d0d5dd;
        }

        .attachment-icon {
            color: #3182f6;
            font-size: 18px;
        }

        .attachment-info {
            display: flex;
            flex-direction: column;
            flex-grow: 1;
        }

        .attachment-link {
            font-size: 15px;
            font-weight: 500;
            color: #191f28;
            text-decoration: none;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .attachment-size {
            font-size: 12px;
            color: #8b95a1;
            margin-top: 2px;
        }

        .reaction-section {
            padding: 24px 0;
            text-align: center;
            border-bottom: 1px solid #f2f4f6;
        }

        .reaction-buttons {
            display: flex;
            justify-content: center;
            gap: 16px;
        }

        .reaction-btn {
            display: flex;
            align-items: center;
            gap: 6px;
            padding: 8px 16px;
            background: #ffffff;
            border: 1px solid #e5e8eb;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s ease;
            min-width: 80px;
            justify-content: center;
        }

        .reaction-btn:hover:not(:disabled) {
            background: #f8f9fa;
            border-color: #d0d5dd;
        }

        .reaction-btn:disabled {
            background: #f8fafc;
            color: #8b95a1;
            cursor: not-allowed;
            border-color: #e5e8eb;
        }

        .reaction-btn.like {
            color: #3182f6;
            border-color: #3182f6;
        }

        .reaction-btn.like:hover:not(:disabled) {
            background: #eaf1ff;
            border-color: #3182f6;
        }

        .reaction-btn.hate {
            color: #f04452;
            border-color: #f04452;
        }

        .reaction-btn.hate:hover:not(:disabled) {
            background: #fef2f2;
            border-color: #f04452;
        }

        .reaction-btn i {
            font-size: 14px;
        }

        .reaction-btn span {
            font-weight: 600;
            font-size: 14px;
        }

        .action-buttons {
            padding: 32px 0;
            display: flex;
            justify-content: center;
            gap: 12px;
            border-bottom: 1px solid #f2f4f6;
        }

        .action-btn {
            padding: 12px 20px;
            border: 1px solid #e5e8eb;
            border-radius: 8px;
            background: #ffffff;
            color: #4e5968;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
        }

        .action-btn:hover {
            background: #f8fafc;
            border-color: #d0d5dd;
        }

        .action-btn.primary {
            background: #3182f6;
            color: #ffffff;
            border-color: #3182f6;
        }

        .action-btn.primary:hover {
            background: #1b64da;
            border-color: #1b64da;
        }

        .action-btn.danger {
            color: #f04452;
            border-color: #f04452;
        }

        .action-btn.danger:hover {
            background: #fef2f2;
        }

        /* 삭제 다이얼로그 스타일 */
        .ui-dialog {
            border-radius: 12px !important;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3) !important;
        }

        .ui-dialog-titlebar {
            background: #f04452 !important;
            color: #ffffff !important;
            border: none !important;
            border-radius: 12px 12px 0 0 !important;
            padding: 16px 20px !important;
        }

        .ui-dialog-content {
            padding: 24px !important;
            font-size: 16px !important;
            color: #191f28 !important;
        }

        /* 반응형 디자인 */
        @media (max-width: 768px) {
            .view-container {
                padding: 0 16px;
            }

            .article-title {
                font-size: 24px;
            }

            .reaction-buttons {
                flex-direction: column;
                align-items: center;
            }

            .action-buttons {
                flex-wrap: wrap;
                gap: 8px;
            }

            .action-btn {
                flex: 1;
                min-width: 0;
            }

            /* 모바일에서 이미지 처리 */
            .content-text img {
                max-width: 100%;
                height: auto;
                margin: 15px auto;
                border-radius: 6px;
            }

            .content-text img:hover {
                transform: none; /* 모바일에서는 호버 효과 제거 */
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

<%
    // application.properties에서 S3 버킷 URL을 읽어옵니다.
    Properties prop = new Properties();
    try (InputStream is = application.getClassLoader().getResourceAsStream("application.properties")) {
        if (is != null) {
            prop.load(is);
        }
    }
    String s3BaseUrl = prop.getProperty("aws.s3.bucketUrl", "");
    request.setAttribute("s3BaseUrl", s3BaseUrl);
%>

<jsp:include page="/header.jsp"/>

<main>
    <c:if test="${requestScope.vo ne null}">
        <c:set var="vo" value="${requestScope.vo}"/>
        <div class="view-container">
            <div class="article-header">
                    <%-- notice.jsp와 동일한 카테고리/제목 디자인 --%>
                <div class="notice-title-wrap">
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
                    <h1 class="article-title">${vo.subject}</h1>
                </div>

                <div class="article-meta">
                    <span>작성자: ${vo.writer}</span>
                    <span>작성일: ${vo.writeDate}</span>
                    <c:if test="${not empty vo.modDate && fn:trim(vo.modDate) ne ''}">
                        <span>수정일: ${fn:trim(vo.modDate)}</span>
                    </c:if>
                </div>
            </div>

            <c:if test="${vo.fileName ne null && fn:length(vo.fileName) > 4}">
                <div class="attachment-section">
                    <div class="attachment-item">
                        <i class="fas fa-paperclip attachment-icon"></i>
                        <div class="attachment-info">
                                <%-- S3 URL로 직접 링크를 변경합니다. --%>
                            <a href="Controller?type=download&fileName=${vo.fileName}"
                               class="attachment-link">
                                    ${vo.fileName}
                            </a>
                                <%-- BbsDAO에 getFileSize(fileName) 메서드가 있다고 가정 --%>
                                <%--<span class="attachment-size">(${BbsDAO.getFileSize(vo.fileName)})</span>--%>
                        </div>
                    </div>
                </div>
            </c:if>

            <div class="article-content">
                <div class="content-text">${vo.content}</div>
            </div>

            <div class="reaction-section">
                <div class="reaction-buttons">
                    <button type="button" id="btn-like" class="reaction-btn like" onclick="sendReaction('like')"
                            <c:if test="${hasReacted}">disabled</c:if>>
                        <i class="fas fa-thumbs-up"></i>
                        <span id="likeCount">${likeCount}</span>
                    </button>
                    <button type="button" id="btn-hate" class="reaction-btn hate" onclick="sendReaction('hate')"
                            <c:if test="${hasReacted}">disabled</c:if>>
                        <i class="fas fa-thumbs-down"></i>
                        <span id="hateCount">${hateCount}</span>
                    </button>
                </div>
            </div>

            <div class="action-buttons">
                <button type="button" class="action-btn primary" onclick="goList()">목록</button>
                    <%--관리자일 경우에만 수정/삭제 버튼 표시--%>
                <c:if test="${not empty sessionScope.loginUser and sessionScope.loginUser.authority
                      ne null and sessionScope.loginUser.authority eq '1'}">
                    <button type="button" class="action-btn" onclick="goEdit()">수정</button>
                    <button type="button" class="action-btn danger" onclick="goDel()">삭제</button>
                </c:if>
            </div>

            <form name="ff" method="post">
                <input type="hidden" name="type"/>
                <input type="hidden" name="FileName"/>
                <input type="hidden" name="PostNum" value="${vo.postNum}"/>
                <input type="hidden" name="cPage" value="${param.cPage}"/>
                    <%-- ***** 추가된 부분: 카테고리 정보 전달을 위한 hidden 필드 추가 ***** --%>
                <input type="hidden" name="category" value="${vo.category}"/>
            </form>

        </div>
    </c:if>
</main>

<jsp:include page="../footer.jsp"/>

<%-- 표현할 vo객체가 존재하지 않는다면 원래 있던 목록 페이지로 이동한다.--%>
<c:if test="${requestScope.vo eq null}"> <%--eq는 '==' 와 같다--%>
    <c:redirect url="Controller">
        <c:param name="type" value="notice"/>
        <c:param name="cPage" value="${param.cPage}"/>
    </c:redirect>
</c:if>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"
        integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
<script src="https://code.jquery.com/ui/1.14.1/jquery-ui.js"></script>

<script>
    // jQuery UI 다이얼로그 관련 코드는 이제 필요 없으므로 삭제했습니다.

    function goList() {
        const category = document.forms["ff"]["category"].value;
        const cPage = document.forms["ff"]["cPage"].value;

        // 카테고리에 따라 다른 페이지로 이동
        if (category === 'Faq') {
            location.href = "Controller?type=faq&cPage=" + cPage;
        } else {
            location.href = "Controller?type=notice&cPage=" + cPage;
        }
    }

    // 수정된 부분: goDel() 함수
    function goDel() {
        if (confirm('정말로 이 게시글을 삭제하시겠습니까?')) {
            const postNum = document.forms["ff"]["PostNum"].value;
            const cPage = document.forms["ff"]["cPage"].value;

            // 1. 현재 게시글의 카테고리 값을 가져옵니다.
            const category = document.forms["ff"]["category"].value;

            // 2. 카테고리 값에 따라 리다이렉트할 페이지를 결정합니다.
            let returnTo;
            if (category === 'Faq') {
                returnTo = 'faq'; // FAQ 게시판이면 'faq'로 보냅니다.
            } else {
                returnTo = 'notice'; // 그 외(공지사항)면 'notice'로 보냅니다.
            }

            // 3. 결정된 returnTo 값을 URL에 담아 요청을 보냅니다.
            location.href = "Controller?type=del&PostNum=" + postNum + "&cPage=" + cPage + "&returnTo=" + returnTo;
        }
    }

    // 기존의 del(frm) 함수는 goDel() 함수에 병합되어 삭제되었습니다.

    function goEdit() {
        const postNum = document.forms["ff"]["PostNum"].value;
        const cPage = document.forms["ff"]["cPage"].value;
        const category = document.forms["ff"]["category"].value;

        // 카테고리 값에 따라 returnTo 값을 결정
        let returnTo;
        if (category === 'Faq') {
            returnTo = 'faq';
        } else {
            returnTo = 'notice';
        }

        // 수정 페이지로 이동할 때 returnTo 파라미터를 함께 전달
        location.href = "Controller?type=edit&PostNum=" + postNum + "&cPage=" + cPage + "&returnTo=" + returnTo;
    }

    function sendReaction(type) {
        $("#btn-like").prop("disabled", true);
        $("#btn-hate").prop("disabled", true);

        if (type === 'like') {
            const countSpan = $("#likeCount");
            const currentCount = parseInt(countSpan.text(), 10);
            countSpan.text(currentCount + 1);
        } else {
            const countSpan = $("#hateCount");
            const currentCount = parseInt(countSpan.text(), 10);
            countSpan.text(currentCount + 1);
        }

        $.ajax({
            url: 'Controller',
            type: 'POST',
            data: {
                type: type,
                PostNum: '${vo.postNum}'
            }
        })
            .fail(function () {
                alert("데이터 저장 중 오류가 발생했습니다. 페이지를 새로고침합니다.");
                location.reload();
            });
    }
</script>
</body>
</html>