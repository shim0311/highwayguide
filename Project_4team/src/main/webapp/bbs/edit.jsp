<%@ page import="mybatis.vo.BbsVO" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>공지사항 수정</title>
    <style type="text/css">
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        #bbs {
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            width: 100%;
            max-width: 700px;
        }

        #bbs h2 {
            text-align: center;
            color: #333;
            margin-bottom: 20px;
        }

        .form-group {
            display: flex;
            align-items: center;
            margin-bottom: 15px;
        }

        .form-group label {
            width: 100px; /* 라벨 너비를 고정 */
            font-weight: bold;
            color: #555;
            flex-shrink: 0;
        }

        .form-group input[type="text"],
        .form-group select {
            flex-grow: 1; /* 입력 필드가 남은 공간을 채우도록 함 */
            padding: 8px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 14px;
        }

        /* CKEditor 컨테이너 */
        #content-container {
            margin-bottom: 15px;
        }

        /* 파일 입력 필드에 대한 스타일을 CKEditor와 유사하게 지정 */
        .file-upload-container {
            display: flex;
            align-items: center;
            flex-grow: 1;
        }

        /* 파일 입력 필드와 파일명을 감싸는 컨테이너 */
        .file-display-box {
            display: flex;
            align-items: center;
            flex-grow: 1;
            border: 1px solid #ccc; /* 카테고리와 동일한 테두리 색상 */
            border-radius: 4px;
            padding: 5px;
            gap: 10px; /* 파일 선택과 파일명 사이의 간격 */
        }

        .file-upload-container input[type="file"] {
            border: none;
            padding: 0;
            flex-grow: 1;
        }

        .file-upload-container span {
            /* span 태그에 별도 스타일링 */
            font-size: 14px;
            color: #333;
            white-space: nowrap; /* 줄바꿈 방지 */
            overflow: hidden; /* 넘치는 텍스트 숨기기 */
            text-overflow: ellipsis; /* ...으로 표시 */
        }

        /* CKEditor 테두리 정렬을 위한 스타일 */
        .ck-editor__main {
            border: 1px solid #000 !important;
            border-radius: 4px;
        }

        .button-group {
            text-align: center;
            margin-top: 20px;
        }

        .button-group input[type="button"] {
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            background-color: #007bff;
            color: white;
            cursor: pointer;
            font-size: 15px;
            margin: 0 5px;
        }

        .button-group input[type="button"]:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>
<%
    Object obj = request.getAttribute("vo");
    if(obj != null) {
        BbsVO vo = (BbsVO) obj;
%>
<div id="bbs">
    <h2>작성글 수정</h2>
    <form action="Controller?type=edit" method="post" encType="multipart/form-data">
        <input type="hidden" id="hidden_postNum" value="${vo.postNum}"/>
        <input type="hidden" id="hidden_cPage" value="${param.cPage}"/>
        <input type="hidden" name="PostNum" value="${vo.postNum}"/>
        <input type="hidden" name="cPage" value="${param.cPage}"/>
        <input type="hidden" name="oldFileName" value="${vo.fileName}"/>

        <!-- ***** 추가된 부분: 카테고리 정보를 hidden 필드로 추가 ***** -->
        <input type="hidden" id="hidden_category" value="${vo.category}"/>

        <div class="form-group">
            <label for="subject">제목:</label>
            <input type="text" name="subject" id="subject" value="${vo.subject}"/>
        </div>

        <div class="form-group">
            <label for="writer">이름:</label>
            <input type="text" name="writer" id="writer" value="${vo.writer}" readonly/>
        </div>

        <div class="form-group">
            <label for="category">카테고리:</label>
            <select id="category" name="category">
                <c:if test="${param.returnTo == 'faq'}">
                    <!-- faq 게시판에서 온 경우, FAQ만 선택 가능 -->
                    <option value="Faq" selected>FAQ</option>
                </c:if>
                <c:if test="${param.returnTo != 'faq'}">
                    <!-- 그 외 게시판에서 온 경우, 모든 카테고리 표시 -->
                    <option value="">::: 카테고리를 선택하세요 :::</option>
                    <option value="HighWay" <c:if test="${vo.category eq 'HighWay'}">selected</c:if>>고속도로</option>
                    <option value="RestArea" <c:if test="${vo.category eq 'RestArea'}">selected</c:if>>졸음쉼터</option>
                    <option value="ServiceArea" <c:if test="${vo.category eq 'ServiceArea'}">selected</c:if>>휴게소</option>
                    <option value="Shop" <c:if test="${vo.category eq 'Shop'}">selected</c:if>>매장</option>
                    <option value="Guide" <c:if test="${vo.category eq 'Guide'}">selected</c:if>>이용안내</option>
                    <option value="Faq" <c:if test="${vo.category eq 'Faq'}">selected</c:if>>FAQ</option>
                </c:if>
            </select>
        </div>

        <!-- 파일 첨부 위치 변경: CKEditor 위로 이동 -->
        <div class="form-group">
            <label for="file" style="cursor: default;">첨부파일:</label>
            <div class="file-display-box">
                <input type="file" id="file" name="file" style="cursor: pointer;"/>
                <%
                    if(vo.getFileName() != null){
                %>
                <span><%=vo.getFileName()%></span>
                <%
                    }
                %>
            </div>
        </div>

        <div id="content-container">
            <label for="content">내용:</label>
            <textarea name="content" id="content" rows="8"></textarea>
        </div>


        <div class="button-group">
            <input type="button" value="완료" onclick="sendData()"/>
            <input type="button" value="취소" onclick="goBack()"/>
        </div>
    </form>
</div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
<script src="${pageContext.request.contextPath}/ckeditor/ckeditor.js"></script>
<script>
    let myEditor;

    ClassicEditor
        .create(document.querySelector('#content'), {
            ckfinder: {
                uploadUrl: 'Controller?type=saveImg'
            }
        })
        .then(editor => {
            console.log('CKEditor가 성공적으로 로드되었습니다.', editor);
            myEditor = editor;
            // CKEditor에 데이터베이스의 내용을 로드
            const contentFromDB = '<c:out value="${vo.content}" escapeXml="false"/>';
            editor.setData(contentFromDB);
        })
        .catch(error => {
            console.error('CKEditor 로드 중 에러 발생:', error);
        });

    function sendData() {
        const contentData = myEditor.getData();
        document.getElementById('content').value = contentData;

        let subject = $("#subject").val();
        if(subject.trim().length < 1){
            alert("제목을 입력하세요");
            $("#subject").val("");
            $("#subject").focus();
            return;
        }

        let writer = $("#writer").val();
        if(writer.trim().length < 1){
            alert("이름을 입력하세요:");
            $("#writer").val("");
            $("#writer").focus();
            return;
        }

        // 카테고리 유효성 검사 추가
        let category = $("#category").val();
        if(category === ""){
            alert("카테고리를 선택하세요");
            $("#category").focus();
            return;
        }

        if(contentData.trim().length < 1){
            alert("내용을 입력하세요:");
            return;
        }

        document.forms[0].submit();
    }

    function goBack() {
        const cPage = document.getElementById('hidden_cPage').value;
        const category = document.getElementById('hidden_category').value;

        if (category === 'Faq') {
            // FAQ 게시판에서 온 경우 FAQ 목록으로 이동
            location.href = "Controller?type=faq&cPage=" + cPage;
        } else {
            // 그 외의 경우 (공지사항) 공지사항 목록으로 이동
            location.href = "Controller?type=notice&cPage=" + cPage;
        }
    }
</script>
<%
    }
%>
</body>
</html>