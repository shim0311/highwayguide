<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HighwayGuide - 로그인</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100..900;1,100..900&display=swap"
          rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="css/LoginStyle.css" rel="stylesheet">
    <link href="css/footerStyle.css" rel="stylesheet">

    <style>
        @font-face {
            font-family: 'PretendardVariable';
            src: url('fonts/PretendardVariable.woff2') format('woff2-variations');
            font-weight: 45 920;
            font-style: normal;
            font-display: swap;
        }

        /* index.jsp와 통일된 스타일 */
        body {
            font-family: 'PretendardVariable', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(180deg, #f0f8ff 0%, #ffffff 100%);
            margin: 0;
            padding: 0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .back-home {
            position: fixed;
            top: 20px;
            left: 20px;
            color: #4e5968;
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 8px;
            z-index: 1000;
            transition: opacity 0.2s;
        }

        .back-home:hover {
            opacity: 0.8;
        }

        .login-container {
            background: #ffffff;
            border-radius: 20px;
            border: 1px solid #e5e8eb;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
            padding: 40px;
            width: 100%;
            max-width: 400px;
            margin: 20px;
            position: relative;
            overflow: hidden;
        }

        .login-container::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        .login-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .language-selector {
            position: absolute;
            top: 20px;
            right: 20px;
            color: #8b95a1;
            cursor: pointer;
            font-size: 16px;
        }

        .logo-container {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
            margin-bottom: 20px;
        }

        .logo-icon {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #ffffff;
            font-size: 18px;
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
        }

        .logo-container h1 {
            font-size: 24px;
            font-weight: 700;
            color: #191f28;
            margin: 0;
        }

        .star-icon {
            color: #fbbf24;
            font-size: 16px;
        }

        .login-form {
            margin-bottom: 30px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .input-container {
            position: relative;
            display: flex;
            align-items: center;
        }

        .input-icon {
            position: absolute;
            left: 16px;
            color: #8b95a1;
            font-size: 16px;
            z-index: 1;
        }

        .form-input {
            width: 100%;
            padding: 16px 16px 16px 48px;
            border: 2px solid #e5e8eb;
            border-radius: 12px;
            font-size: 16px;
            font-family: inherit;
            background: #ffffff;
            transition: all 0.2s;
            box-sizing: border-box;
        }

        .form-input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .password-toggle {
            position: absolute;
            right: 16px;
            background: none;
            border: none;
            color: #8b95a1;
            cursor: pointer;
            font-size: 16px;
            z-index: 1;
        }

        .login-options {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
        }

        .auto-signin {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
            color: #4e5968;
            cursor: pointer;
        }

        .auto-signin input[type="checkbox"] {
            width: 16px;
            height: 16px;
            accent-color: #667eea;
        }

        .forgot-link {
            color: #667eea;
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
        }

        .forgot-link:hover {
            text-decoration: underline;
        }

        .login-btn {
            width: 100%;
            padding: 16px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #ffffff;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            margin-bottom: 20px;
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
        }

        .login-btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 16px rgba(102, 126, 234, 0.4);
        }

        .signup-link {
            text-align: center;
            margin-bottom: 30px;
            font-size: 14px;
            color: #4e5968;
        }

        .signup-link a {
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
        }

        .signup-link a:hover {
            text-decoration: underline;
        }

        .social-login-section {
            text-align: center;
        }

        .social-title {
            font-size: 14px;
            color: #8b95a1;
            margin-bottom: 16px;
            font-weight: 500;
        }

        .social-login {
            display: flex;
            justify-content: center;
            gap: 16px;
            flex-wrap: nowrap;
        }

        .social-icon {
            width: 44px;
            height: 44px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            text-decoration: none;
            color: #ffffff;
            font-size: 16px;
            transition: all 0.2s;
            flex-shrink: 0;
        }

        .social-icon:hover {
            transform: translateY(-1px);
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }

        .social-icon.google:hover {
            border-color: #4285f4;
            box-shadow: 0 2px 8px rgba(66, 133, 244, 0.2);
        }

        .social-icon.kakao {
            background: #fee500;
            color: #000000;
        }

        .social-icon.naver {
            background: #03c75a;
        }

        .social-icon.google {
            background: #ffffff;
            color: #4285f4;
            border: 1px solid #e5e8eb;
        }

        .social-icon.apple {
            background: #000000;
        }

        .social-icon.facebook {
            background: #1877f2;
        }

        .naver-n {
            font-weight: bold;
            font-size: 16px;
        }

        .error-message {
            color: #e74c3c;
            font-size: 12px;
            margin-top: 8px;
            font-weight: 500;
        }

        /* 애니메이션 */
        .fade-in-up {
            animation: fadeInUp 0.6s ease-out;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* 반응형 */
        @media (max-width: 480px) {
            .login-container {
                margin: 10px;
                padding: 30px 20px;
            }

            .logo-container h1 {
                font-size: 20px;
            }

            .form-input {
                padding: 14px 14px 14px 44px;
                font-size: 15px;
            }

            .login-btn {
                padding: 14px;
                font-size: 15px;
            }
        }
    </style>
</head>
<body>
<!-- Back to Home Link -->
<a href="Controller" class="back-home">
    <i class="fas fa-arrow-left"></i>
    홈으로 돌아가기
</a>

<!-- Login Container -->
<div class="login-container fade-in-up">
    <!-- Header -->
    <div class="login-header">
        <div class="language-selector">
            <i class="fas fa-globe"></i>
        </div>
        <div class="logo-container">
            <div class="logo-icon">
                <i class="fas fa-cube"></i>
            </div>
            <h1>HighwayGuide</h1>
            <div class="star-icon">
                <i class="fas fa-star"></i>
            </div>
        </div>
    </div>


    <!-- Login Form -->
    <form class="login-form" id="loginForm">
        <!-- returnUrl을 서버로 전송하기 위한 hidden input 추가 -->
        <input type="hidden" id="returnUrl" name="returnUrl">
        
        <div class="form-group">
            <div class="input-container">
                <i class="fas fa-user input-icon"></i>
                <input type="text" id="username" name="username" class="form-input"
                       placeholder="사용자명, 이메일 또는 전화번호" required>
            </div>
        </div>

        <div class="form-group">
            <div class="input-container">
                <i class="fas fa-lock input-icon"></i>
                <input type="password" id="password" name="password" class="form-input"
                       placeholder="비밀번호" required>
                <button type="button" class="password-toggle" id="passwordToggle">
                    <i class="fas fa-eye-slash"></i>
                </button>
            </div>
        </div>

        <div class="login-options">
            <label class="auto-signin">
                <input type="checkbox" name="autoSignin" id="autoSignin">
                <span class="checkmark"></span>
                자동 로그인
            </label>
            <a href="Controller?type=forgotPw" class="forgot-link">비밀번호를 잊으셨나요?</a>
        </div>

        <button type="submit" class="login-btn">
            로그인
        </button>
    </form>

    <!-- Sign Up Link -->
    <div class="signup-link">
        계정이 없으신가요? <a href="Controller?type=register" id="signupLink">회원가입</a>
    </div>

    <!-- Social Login -->
    <div class="social-login-section">
        <div class="social-title">SNS 간편 로그인</div>
        <div class="social-login">
            <a href="#" class="social-icon kakao" id="kakaoLogin">
                <i class="fas fa-comment"></i>
            </a>
            <a href="#" class="social-icon naver" id="naverLogin">
                <span class="naver-n">N</span>
            </a>
            <a href="#" class="social-icon google" id="googleLogin">
                <i class="fab fa-google"></i>
            </a>
            <a href="#" class="social-icon apple" id="appleLogin">
                <i class="fab fa-apple"></i>
            </a>
            <a href="#" class="social-icon facebook" id="facebookLogin">
                <i class="fab fa-facebook-f"></i>
            </a>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        const loginForm = document.getElementById('loginForm');
        const usernameInput = document.getElementById('username');
        const passwordInput = document.getElementById('password');
        const passwordToggle = document.getElementById('passwordToggle');
        const autoSignin = document.getElementById('autoSignin');
        const kakaoLogin = document.getElementById('kakaoLogin');
        const naverLogin = document.getElementById('naverLogin');
        const googleLogin = document.getElementById('googleLogin');
        const appleLogin = document.getElementById('appleLogin');
        const facebookLogin = document.getElementById('facebookLogin');
        const signupLink = document.getElementById('signupLink');
        const returnUrlInput = document.getElementById('returnUrl');

        //********* 한결: 뒤로가기 및 앞으로가기 시 입력필드 초기화
        usernameInput.value = '';
        passwordInput.value = '';

        // 페이지 로드 시 returnUrl을 가져와서 폼에 추가 (쿼리 파라미터 우선, sessionStorage 차선)
        let returnUrl = new URLSearchParams(window.location.search).get('returnUrl');
        if (!returnUrl) {
            returnUrl = sessionStorage.getItem('returnUrl');
            if (returnUrl) {
                sessionStorage.removeItem('returnUrl'); // 사용 후 제거
            }
        }
        if (returnUrl) {
            returnUrlInput.value = returnUrl;
        }

        //뒤로가기 / 앞으로가기로 페이지에 접근할 때 실행된다.
        window.addEventListener('pageshow', function (event) {
            if (event.persisted) { //캐시가 계속 남아있을경우 입력필드 값 초기화
                usernameInput.value = '';
                passwordInput.value = '';
            }
        });

        // Password toggle
        passwordToggle.addEventListener('click', function () {
            const type = passwordInput.type === 'password' ? 'text' : 'password';
            passwordInput.type = type;
            this.innerHTML = type === 'password' ? '<i class="fas fa-eye-slash"></i>' : '<i class="fas fa-eye"></i>';
        });

        // Form validation and submission
        loginForm.addEventListener('submit', function (e) {
            e.preventDefault();

            const formData = new FormData(loginForm);

            const username = usernameInput.value.trim();
            const password = passwordInput.value.trim();
            //유효성 검사
            if (!username) {
                showError(usernameInput, '사용자명, 이메일 또는 전화번호를 입력해주세요.');
                return;
            }

            if (!password) {
                showError(passwordInput, '비밀번호를 입력해주세요.');
                return;
            }

            if (password.length < 6) {
                showError(passwordInput, '비밀번호는 6자 이상이어야 합니다.');
                return;
            }

                // ****** fetch API를 사용해서 서버와 실제 통신 ******
                fetch('Controller?type=login', {
                    method: 'POST',
                    body: new URLSearchParams(formData)
                }).then(response => {
                    //서버 응답이 정상이 아닐때 에러처리
                    if (!response.ok) {
                        throw new Error('서버 응답 오류가 발생했습니다.');
                    }
                    return response.json(); //응답을 JSON 형태로 파싱한다.
                }).then(data => {
                    //서버로부터 받은 JSON 결과에 따라 처리
                    if (data.status === 'success') {
                        alert("로그인이 완료되었습니다!");

                        //서버가 알려준 redirectURL 값으로 페이지 이동
                        window.location.href = data.redirectURL; //성공시 index 화면으로 이동
                    } else {
                        alert(data.message || "로그인에 실패했습니다."); //실패시 서버가 보낸 메시지를 alert창으로 보여줌
                    }
                }).catch(error => {
                    // 통신 실패시 예외 처리
                    console.error("Login Error:", error);
                    alert("로그인 처리 중 오류가 발생했습니다.");
                });
            });

        // Email validation
        function isValidEmail(email) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            return emailRegex.test(email);
        }

        // Show error message
        function showError(input, message) {
            // Remove existing error
            const existingError = input.parentNode.querySelector('.error-message');
            if (existingError) {
                existingError.remove();
            }

            // Add error message
            const errorDiv = document.createElement('div');
            errorDiv.className = 'error-message';
            errorDiv.style.color = '#e74c3c';
            errorDiv.style.fontSize = '0.8rem';
            errorDiv.style.marginTop = '0.5rem';
            errorDiv.textContent = message;

            input.parentNode.appendChild(errorDiv);
            input.style.borderColor = '#e74c3c';

            // Remove error after 3 seconds
            setTimeout(() => {
                if (errorDiv.parentNode) {
                    errorDiv.remove();
                    input.style.borderColor = '#bdc3c7';
                }
            }, 3000);
        }

        // Show success message
        function showSuccess(message) {
            const successDiv = document.createElement('div');
            successDiv.style.position = 'fixed';
            successDiv.style.top = '20px';
            successDiv.style.right = '20px';
            successDiv.style.background = '#f39c12';
            successDiv.style.color = '#2c3e50';
            successDiv.style.padding = '1rem 2rem';
            successDiv.style.borderRadius = '8px';
            successDiv.style.zIndex = '1000';
            successDiv.style.fontWeight = '600';
            successDiv.textContent = message;

            document.body.appendChild(successDiv);

            setTimeout(() => {
                successDiv.remove();
            }, 2000);
        }

        // Social login handlers
        kakaoLogin.addEventListener('click', function (e) {
            e.preventDefault();
            alert('카카오 로그인 기능이 구현될 예정입니다.');
        });

        naverLogin.addEventListener('click', function (e) {
            e.preventDefault();
            alert('네이버 로그인 기능이 구현될 예정입니다.');
        });

        googleLogin.addEventListener('click', function (e) {
            e.preventDefault();
            alert('Google 로그인 기능이 구현될 예정입니다.');
        });

        appleLogin.addEventListener('click', function (e) {
            e.preventDefault();
            alert('Apple 로그인 기능이 구현될 예정입니다.');
        });

        facebookLogin.addEventListener('click', function (e) {
            e.preventDefault();
            alert('Facebook 로그인 기능이 구현될 예정입니다.');
        });

        // Auto sign in checkbox
        autoSignin.addEventListener('change', function () {
            if (this.checked) {
                console.log('자동 로그인이 활성화되었습니다.');
            }
        });
    });
</script>
</body>
</html>
