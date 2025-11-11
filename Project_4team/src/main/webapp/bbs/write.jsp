<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>공지사항 작성</title>
    <style type="text/css">
        #bbs table {
            width:80%;
            margin-left:10px;
            border:1px solid black;
            border-collapse:collapse;
            font-size:14px;
        }

        #bbs table caption {
            font-size:20px;
            font-weight:bold;
            margin-bottom:10px;
        }

        #bbs table th {
            text-align:center;
            border:1px solid black;
            padding:4px 10px;
        }

        #bbs table td {
            text-align:left;
            border:1px solid black;
            padding:4px 10px;
        }
        /*CK에디터 크기 지정*/
        .ck-editor {
            width: 100%;
        }

        .no {width:15%}
        .subject {width:30%}
        .writer {width:20%}
        .reg {width:20%}
        .hit {width:15%}
        .title{background:lightsteelblue}

        .odd {background:silver}
    </style>
</head>
<body>
<div id="bbs">
    <form action="Controller?type=write" method="post"
          encType="multipart/form-data">
        <table summary="공지사항 작성하기">
            <caption>공지사항 작성하기</caption>
            <tbody>
            <tr>
                <th>제목:</th>
                <td><input type="text" name="subject" id="subject" size="45"/></td>
            </tr>
            <tr>
                <th>작성자:</th>
                <td><input type="text" name="writer" id="writer" size="12"/></td>
            </tr>
            <tr>
                <th>내용:</th>
                <td><textarea name="content" cols="80" id="content" rows="12"></textarea></td>
            </tr>
            <tr>
                <th>첨부파일:</th>
                <td><input type="file" id="file" name="file"/></td>
            </tr>
            <tr>
                <th>카테고리:</th>
                <td>
                    <select id="category" name="category">
                        <c:if test="${param.returnTo == 'faq'}">
                            <option value="Faq" selected>FAQ</option>
                        </c:if>
                        <c:if test="${param.returnTo != 'faq'}">
                            <option value="">::: 카테고리를 선택하세요 :::</option>
                            <option value="HighWay">고속도로</option>
                            <option value="RestArea">졸음쉼터</option>
                            <option value="ServiceArea">휴게소</option>
                            <option value="Shop">매장</option>
                            <option value="Guide">이용안내</option>
                        </c:if>
                    </select>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <input type="button" value="완료" onclick="sendData()"/>
                    <input type="button" value="목록" onclick="goList()"/>
                </td>
            </tr>
            </tbody>
        </table>
    </form>
</div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
<script src="https://cdn.ckeditor.com/ckeditor5/36.0.1/classic/ckeditor.js"></script>
<script>
    let myEditor;

    ClassicEditor
        .create(document.querySelector('#content'), {
            ckfinder: {
                // 이미지 업로드 URL은 서버의 Controller와 연결되어 있어야 합니다.
                uploadUrl: 'Controller?type=saveImg'
            }
        })
        .then(editor => {
            console.log('CKEditor가 성공적으로 로드되었습니다.', editor);
            myEditor = editor;
        })
        .catch(error => {
            console.error('CKEditor 로드 중 에러 발생:', error);
        });

    function sendData() {
        const contentData = myEditor.getData();
        document.getElementById('content').value = contentData;

        // 유효성 검사
        let subject = $("#subject").val();
        if(subject.trim().length < 1){
            alert("제목을 입력하세요");
            $("#subject").val("");
            $("#subject").focus();
            return;
        }

        let writer = $("#writer").val();
        if(writer.trim().length < 1){
            alert("이름을 입력하세요");
            $("#writer").val("");
            $("#writer").focus();
            return;
        }

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

        // 폼 전송 전에 카테고리 값을 확인하여 action URL을 동적으로 변경합니다.
        // 현재는 Controller?type=write 로 고정되어 있으므로, 서버 측에서 리다이렉트하는 것이 더 효율적입니다.
        // 여기서는 유효성 검사만 수행하고, 서버 측에서 처리한다고 가정하겠습니다.

        // 모든 유효성 검사를 통과하면 폼을 전송합니다.
        document.forms[0].submit();
    }

    // 수정된 부분: 목록 버튼을 위한 새로운 함수
    function goList() {
        // 1. URL에서 returnTo 파라미터 값을 가져옵니다.
        const urlParams = new URLSearchParams(window.location.search);
        const returnTo = urlParams.get('returnTo');

        // 2. returnTo 값에 따라 목록 페이지로 이동합니다.
        if (returnTo === 'faq') {
            location.href = "Controller?type=faq";
        } else {
            // returnTo가 없거나 다른 값이면 기본값으로 notice를 사용
            location.href = "Controller?type=notice";
        }
    }
</script>
</body>
</html>