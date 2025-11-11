<%--
  Created by IntelliJ IDEA.
  User: js
  Date: 25. 8. 21.
  Time: 오전 11:33
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HighwayGuide - 비밀번호 재설정</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100..900;1,100..900&display=swap"
        rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
  <link href="${pageContext.request.contextPath}/css/indexStyle.css" rel="stylesheet">
  <link href="${pageContext.request.contextPath}/css/footerStyle.css" rel="stylesheet">

    <!-- 비밀번호 재설정 전용 스타일 -->
    <style>
        .reset-pw-container {
            min-height: calc(100vh - 200px);
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 2rem 1rem;
            margin-top: 80px; /* 헤더 높이만큼 여백 추가 */
            margin-bottom: 80px; /* 푸터 높이만큼 여백 추가 */
        }

        .reset-pw-content {
            background: white;
            border-radius: 20px;
            padding: 3rem;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 450px;
            text-align: center;
        }

        .reset-pw-header h1 {
            color: #333;
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 1rem;
            font-family: 'Roboto', sans-serif;
        }

        .reset-pw-header p {
            color: #666;
            font-size: 1rem;
            margin-bottom: 2rem;
            line-height: 1.5;
        }

        .reset-pw-form {
            margin-bottom: 2rem;
        }

        .form-group {
            margin-bottom: 1.5rem;
            text-align: left;
        }

        .form-group label {
            display: block;
            color: #333;
            font-weight: 600;
            margin-bottom: 0.5rem;
            font-size: 0.9rem;
        }

        .password-input-container {
            position: relative;
            display: flex;
            align-items: center;
            flex-direction: column;
            align-items: stretch;
        }

        .password-input {
            width: 100%;
            padding: 1rem;
            border: 2px solid #e1e5e9;
            border-radius: 10px;
            font-size: 1rem;
            transition: all 0.3s ease;
            box-sizing: border-box;
            padding-right: 3rem; /* 토글 버튼 공간 확보 */
        }

        .password-input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .password-toggle {
            position: absolute;
            right: 1rem;
            top: 1rem; /* top: 50% 대신 고정 위치 사용 */
            transform: none; /* transform 제거 */
            background: none;
            border: none;
            color: #666;
            cursor: pointer;
            padding: 0.5rem;
            transition: color 0.3s ease;
            z-index: 10; /* 에러 메시지보다 위에 표시 */
        }

        .password-toggle:hover {
            color: #667eea;
        }

        .submit-btn {
            width: 100%;
            padding: 1rem;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
        }

        .submit-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
        }

        .submit-btn:active {
            transform: translateY(0);
        }

        .submit-btn i {
            font-size: 0.9rem;
        }

        .reset-pw-footer {
            border-top: 1px solid #f0f0f0;
            padding-top: 1.5rem;
        }

        .back-to-login {
            color: #667eea;
            text-decoration: none;
            font-weight: 500;
            transition: color 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }

        .back-to-login:hover {
            color: #5a6fd8;
            text-decoration: underline;
        }

        .back-to-login i {
            font-size: 0.8rem;
        }

        /* 에러 메시지 스타일 */
        .error-message {
            color: #e74c3c;
            font-size: 0.8rem;
            margin-top: 0.5rem;
            text-align: left;
            background: #fdf2f2;
            border: 1px solid #fecaca;
            border-radius: 6px;
            padding: 0.5rem 0.75rem;
            font-weight: 500;
            line-height: 1.4;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            margin-bottom: 0.5rem;
            position: relative;
            z-index: 5; /* 토글 버튼보다 아래에 표시 */
        }

        /* 반응형 디자인 */
        @media (max-width: 768px) {
            .reset-pw-content {
                padding: 2rem 1.5rem;
                margin: 1rem;
            }

            .reset-pw-header h1 {
                font-size: 1.75rem;
            }

            .reset-pw-header p {
                font-size: 0.9rem;
            }
        }
    </style>

</head>
<body>
<%@ include file="../../header.jsp" %>

<!-- 비밀번호 재설정 섹션 -->
<div class="reset-pw-container">
    <div class="reset-pw-content">
        <div class="reset-pw-header">
            <h1>비밀번호 재설정</h1>
            <p>새로운 비밀번호를 입력해주세요.</p>
        </div>
        
        <form class="reset-pw-form" id="resetPwForm" method="post" action="Controller">
            <input type="hidden" name="type" value="forgotPassword">
            <input type="hidden" name="todo" value="savePassword">
            <input type="hidden" name="Idx" value="${sessionScope.Idx}">

            <div class="form-group">
                <label for="password">새 비밀번호</label>
                <div class="password-input-container">
                    <input 
                        type="password" 
                        id="password" 
                        name="password" 
                        placeholder="영문, 숫자, 특수문자가 모두 들어간 8자 이상" 
                        class="password-input"
                        required
                    >
                    <button type="button" class="password-toggle" id="passwordToggle">
                        <i class="fas fa-eye"></i>
                    </button>
                </div>
            </div>
            
            <div class="form-group">
                <label for="password2">새 비밀번호 확인</label>
                <div class="password-input-container">
                    <input 
                        type="password" 
                        id="password2" 
                        name="password2" 
                        placeholder="비밀번호를 한번 더 입력해 주세요" 
                        class="password-input"
                        required
                    >
                    <button type="button" class="password-toggle" id="password2Toggle">
                        <i class="fas fa-eye"></i>
                    </button>
                </div>
            </div>
            
            <button type="submit" class="submit-btn">
                <i class="fas fa-key"></i>
                비밀번호 변경 완료
            </button>
        </form>
        
        <div class="reset-pw-footer">
            <a href="Controller?type=Login" class="back-to-login">
                <i class="fas fa-arrow-left"></i>
                로그인으로 돌아가기
            </a>
        </div>
    </div>
</div>

<!-- 비밀번호 재설정 JavaScript -->
<script>
    // ========================================
    // 비밀번호 재설정 페이지 JavaScript
    // ========================================
    
    document.addEventListener('DOMContentLoaded', function() {
        // ========================================
        // 1. 페이지 로드 시 초기화 및 이벤트 리스너 설정
        // ========================================
        
        // 폼 요소들 가져오기
        const resetPwForm = document.getElementById('resetPwForm');
        const passwordInput = document.getElementById('password');
        const password2Input = document.getElementById('password2');
        const passwordToggle = document.getElementById('passwordToggle');
        const password2Toggle = document.getElementById('password2Toggle');
        
        // ========================================
        // 1-1. 비밀번호 표시/숨김 토글 이벤트 리스너
        // ========================================
        
        // 새 비밀번호 토글
        passwordToggle.addEventListener('click', function() {
            const type = passwordInput.type === 'password' ? 'text' : 'password';
            passwordInput.type = type;
            this.innerHTML = type === 'password' ? '<i class="fas fa-eye"></i>' : '<i class="fas fa-eye-slash"></i>';
        });
        
        // 새 비밀번호 확인 토글
        password2Toggle.addEventListener('click', function() {
            const type = password2Input.type === 'password' ? 'text' : 'password';
            password2Input.type = type;
            this.innerHTML = type === 'password' ? '<i class="fas fa-eye"></i>' : '<i class="fas fa-eye-slash"></i>';
        });
        
        // ========================================
        // 1-2. 폼 제출 이벤트 리스너
        // ========================================
        
        resetPwForm.addEventListener('submit', function(e) {
            // ========================================
            // 1-2-1. 입력값 검증
            // ========================================
            
            const password = passwordInput.value.trim();
            const password2 = password2Input.value.trim();
            
            // 기존 에러 메시지 제거
            clearErrors();
            
            // 비밀번호 유효성 검사
            if (!password || password.length < 8 || !isValidPassword(password)) {
                e.preventDefault(); // 검증 실패 시 폼 제출 방지
                showError(passwordInput, '비밀번호는 영문, 숫자, 특수문자가 모두 들어간 8자 이상이어야 합니다.');
                return;
            }
            
            // 비밀번호 확인 검사
            if (password !== password2) {
                e.preventDefault(); // 검증 실패 시 폼 제출 방지
                showError(password2Input, '비밀번호가 일치하지 않습니다.');
                return;
            }
            
            // ========================================
            // 1-2-2. 검증 통과 시 폼 제출 허용
            // ========================================
            
            // 검증 통과 시 e.preventDefault()를 호출하지 않음
            // 폼이 자동으로 Controller로 제출됨
        });
    });
    
    // ========================================
    // 2. 유틸리티 함수들
    // ========================================
    
    // ========================================
    // 2-1. 비밀번호 유효성 검사 함수
    // ========================================
    function isValidPassword(password) {
        const hasLetter = /[a-zA-Z]/.test(password);
        const hasNumber = /\d/.test(password);
        const hasSpecial = /[!@#$%^&*(),.?":{}|<>]/.test(password);
        return hasLetter && hasNumber && hasSpecial;
    }
    
    // ========================================
    // 2-2. 에러 메시지 표시 함수
    // ========================================
    function showError(input, message) {
        const existingError = input.parentNode.querySelector('.error-message');
        if (existingError) existingError.remove();

        const errorDiv = document.createElement('div');
        errorDiv.className = 'error-message';
        errorDiv.textContent = message;
        
        input.parentNode.appendChild(errorDiv);
        input.style.borderColor = '#e74c3c';
    }
    
    // ========================================
    // 2-3. 에러 메시지 제거 함수
    // ========================================
    function clearErrors() {
        const errorMessages = document.querySelectorAll('.error-message');
        errorMessages.forEach(error => error.remove());
        
        // 입력 필드 테두리 색상 복원 - 직접 요소를 찾아서 처리
        const passwordInput = document.getElementById('password');
        const password2Input = document.getElementById('password2');
        
        if (passwordInput) passwordInput.style.borderColor = '#e1e5e9';
        if (password2Input) password2Input.style.borderColor = '#e1e5e9';
    }
</script>

<%@ include file="../../footer.jsp" %>
</body>
</html>
