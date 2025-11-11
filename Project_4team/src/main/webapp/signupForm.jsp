<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HighwayGuide - 회원가입</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100..900;1,100..900&display=swap"
          rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/RegisterStyle.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/footerStyle.css" rel="stylesheet">
    <style>
        @font-face {
            font-family: 'PretendardVariable';
            src: url('fonts/PretendardVariable.woff2') format('woff2-variations');
            font-weight: 45 920;
            font-style: normal;
            font-display: swap;
        }

        .email-verification-container {
            position: relative;
        }

        .email-input-group {
            display: flex;
            gap: 0.5rem;
            align-items: flex-end;
        }

        .email-input-group .form-input {
            flex: 1;
        }

        .verify-btn {
            padding: 1rem 1.5rem;
            background: #667eea;
            color: #fff;
            border: none;
            border-radius: 8px;
            font-size: 0.9rem;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
            font-family: 'PretendardVariable', 'Roboto', sans-serif;
            white-space: nowrap;
        }

        .verify-btn:hover {
            background: #5a67d8;
            transform: translateY(-1px);
        }

        .verify-btn:disabled {
            background: #ccc;
            cursor: not-allowed;
            transform: none;
        }

        .verification-code-container {
            display: none;
            margin-top: 1rem;
            padding: 1rem;
            background: #f8fafc;
            border: 1.5px solid #e5e8eb;
            border-radius: 8px;
        }

        .verification-code-container.show {
            display: block;
            animation: fadeIn 0.3s ease-out;
        }

        .verification-input-group {
            display: flex;
            gap: 0.5rem;
            align-items: flex-end;
        }

        .verification-input-group .form-input {
            flex: 1;
        }

        .confirm-btn {
            padding: 1rem 1.5rem;
            background: #03C75A;
            color: #fff;
            border: none;
            border-radius: 8px;
            font-size: 0.9rem;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
            font-family: 'PretendardVariable', 'Roboto', sans-serif;
            white-space: nowrap;
        }

        .confirm-btn:hover {
            background: #02B351;
            transform: translateY(-1px);
        }


        .confirm-btn:disabled {
            background: #ccc;
            cursor: not-allowed;
            transform: none;
        }

        .verification-message {
            margin-top: 0.5rem;
            font-size: 0.8rem;
            color: #666;
        }

        .verification-success {
            color: #03C75A;
        }

        .verification-error {
            color: #e74c3c;
        }

        /* 이메일 오류 메시지 스타일 */
        .email-error-message {
            color: #e74c3c;
            font-size: 0.8rem;
            margin-top: 0.5rem;
            font-family: 'PretendardVariable', 'Roboto', sans-serif;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
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

<!-- Register Container -->
<div class="register-container fade-in-up">
    <!-- Header -->
    <div class="register-header">
        <div class="logo-container">
            <div class="logo-icon">
                <i class="fas fa-cube"></i>
            </div>
            <h1>HighWayGuide</h1>
            <div class="star-icon">
                <i class="fas fa-star"></i>
            </div>
        </div>
        <div class="login-link-top">
            이미 계정이 있으신가요? <a href="login.jsp">로그인하기</a>
        </div>
    </div>


    <!-- Register Form -->
    <form class="register-form" id="registerForm" method="post" action="Controller?type=signUp">

        <div class="form-group">
            <label for="name" class="form-label">닉네임</label>
            <input type="text" id="name" name="name" class="form-input" placeholder="이름을 입력해 주세요" required>
        </div>

        <div class="form-group">
            <label for="email" class="form-label">이메일</label>
            <div class="email-verification-container">
                <div class="email-input-group">
                    <input type="email" id="email" name="email" class="form-input" placeholder="이메일을 입력해 주세요" required>
                    <button type="button" class="verify-btn" id="verifyBtn">
                        인증하기
                    </button>
                </div>
                <div class="verification-code-container" id="verificationContainer">
                    <div class="verification-input-group">
                        <input type="text" id="verificationCode" name="verificationCode" class="form-input"
                               placeholder="인증번호 6자리를 입력하세요" maxlength="6">

                        <%--타이머 추가--%>

                        <button type="button" class="confirm-btn" id="confirmBtn">
                            확인
                        </button>
                    </div>
                    <div class="verification-message" id="verificationMessage"></div>
                </div>
            </div>
        </div>

        <div class="form-group">
            <label for="password" class="form-label">비밀번호</label>
            <div class="password-input-container">
                <input type="password" id="password" name="password" class="form-input"
                       placeholder="영문, 숫자, 특수문자가 모두 들어간 8자 이상" required>
                <button type="button" class="password-toggle" id="passwordToggle">
                    <i class="fas fa-eye"></i>
                </button>
            </div>
        </div>

        <div class="form-group">
            <label for="password2" class="form-label">비밀번호 확인</label>
            <div class="password-input-container">
                <input type="password" id="password2" name="password2" class="form-input"
                       placeholder="비밀번호를 한번 더 입력해 주세요" required>
                <button type="button" class="password-toggle" id="password2Toggle">
                    <i class="fas fa-eye"></i>
                </button>
            </div>
        </div>

        <!-- Terms Agreement -->
        <div class="terms-container">
            <div class="terms-header">
                <label class="checkbox-container">
                    <input type="checkbox" id="allAgree" class="checkbox-input">
                    <span class="checkmark"></span>
                    모두 동의합니다.
                </label>
            </div>
            <div class="terms-list">
                <label class="checkbox-container">
                    <input type="checkbox" id="ageAgree" class="checkbox-input" required>
                    <span class="checkmark"></span>
                    만 14세 이상입니다.
                </label>
                <label class="checkbox-container">
                    <input type="checkbox" id="serviceAgree" class="checkbox-input" required>
                    <span class="checkmark"></span>
                    서비스 이용약관에 동의합니다.
                </label>
                <label class="checkbox-container">
                    <input type="checkbox" id="privacyAgree" class="checkbox-input" required>
                    <span class="checkmark"></span>
                    개인정보 수집 이용에 동의합니다.
                </label>
                <label class="checkbox-container">
                    <input type="checkbox" id="marketingAgree" class="checkbox-input">
                    <span class="checkmark"></span>
                    마케팅 수신 홍보목적의 개인정보 수집 및 이용에 동의합니다.(선택)
                </label>
            </div>
        </div>

        <button type="submit" class="register-btn">
            가입완료
        </button>
    </form>
</div>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        const registerForm = document.getElementById('registerForm');
        const emailInput = document.getElementById('email');
        const nameInput = document.getElementById("name");
        const passwordInput = document.getElementById('password');
        const password2Input = document.getElementById('password2');
        const passwordToggle = document.getElementById('passwordToggle');
        const password2Toggle = document.getElementById('password2Toggle');
        const allAgree = document.getElementById('allAgree');
        const ageAgree = document.getElementById('ageAgree');
        const serviceAgree = document.getElementById('serviceAgree');
        const privacyAgree = document.getElementById('privacyAgree');
        const marketingAgree = document.getElementById('marketingAgree');

        // 이메일 인증 관련 요소들
        const verifyBtn = document.getElementById('verifyBtn');
        const verificationContainer = document.getElementById('verificationContainer');
        const verificationCode = document.getElementById('verificationCode');
        const confirmBtn = document.getElementById('confirmBtn');
        const verificationMessage = document.getElementById('verificationMessage');

        let isEmailVerified = false;

        // 스크롤 애니메이션
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }
            });
        }, observerOptions);

        // 관찰할 요소들
        document.querySelectorAll('.form-group, .terms-container, .register-btn').forEach(element => {
            element.style.opacity = '0';
            element.style.transform = 'translateY(30px)';
            element.style.transition = 'all 0.6s ease-out';
            observer.observe(element);
        });

        // '인증하기' 버튼 이벤트 리스너 (최종 수정본)************************************
        verifyBtn.addEventListener('click', async function () {
            const email = emailInput.value.trim();
            if (!isValidEmail(email)) {
                showError(emailInput, '올바른 이메일 형식을 입력해주세요.');
                return;
            }

            verifyBtn.disabled = true;
            verifyBtn.textContent = '인증번호 발송 중...';

            // 1. 전송할 데이터를 URLSearchParams로 만듭니다.
            const params = new URLSearchParams();
            params.append('email', email);

            // 2. POST 방식으로 fetch 요청을 보냅니다.
            // URL에서는 email 파라미터를 제거합니다.
            const response = await fetch('Controller?type=emailSend', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: params
            });

            if (response.ok) {
                verificationContainer.classList.add('show');
                verificationCode.focus();
                showVerificationMessage('인증번호가 발송되었습니다.', 'success');
            } else {
                showVerificationMessage('인증번호 발송에 실패했습니다. 잠시 후 다시 시도해주세요.', 'error');
            }
            verifyBtn.textContent = '재발송';
            verifyBtn.disabled = false;
        });

        // '인증번호 확인' 버튼 이벤트 리스너 (최종 수정본)******************************
        confirmBtn.addEventListener('click', async function () {
            const code = verificationCode.value.trim();
            if (code.length !== 6) {
                showVerificationMessage('인증번호는 6자리입니다.', 'error');
                return;
            }

            confirmBtn.disabled = true;
            confirmBtn.textContent = '확인 중...';

            try {
                const params = new URLSearchParams();
                params.append('code', code);

                const response = await fetch('Controller?type=emailConfirm', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: params
                });

                if (response.ok) {
                    isEmailVerified = true;

                    // 인증 성공 UI 처리 (성공 시에는 버튼 상태를 되돌리지 않음)
                    confirmBtn.textContent = '인증완료';
                    confirmBtn.style.background = '#03C75A';
                    emailInput.disabled = true;
                    verificationCode.disabled = true;
                    verifyBtn.disabled = true;
                    verifyBtn.textContent = '인증완료';
                    verifyBtn.style.background = '#03C75A';
                } else {
                    isEmailVerified = false;
                    showVerificationMessage('인증번호가 일치하지 않습니다.', 'error');
                    // 실패 시 버튼 상태 복구
                    confirmBtn.disabled = false;
                    confirmBtn.textContent = '확인';
                }
            } catch (error) {
                console.error('Fetch Error:', error);
                showVerificationMessage('인증 확인 중 오류가 발생했습니다.', 'error');
                // 에러 발생 시 버튼 상태 복구
                confirmBtn.disabled = false;
                confirmBtn.textContent = '확인';

            }
        });

        // 인증번호 입력 필드에서 엔터 키 이벤트
        verificationCode.addEventListener('keypress', function (e) {
            if (e.key === 'Enter') {
                confirmBtn.click();
            }
        });

        // 이메일 입력 필드 변경 시 오류 메시지 제거
        emailInput.addEventListener('input', function () {
            const emailContainer = this.closest('.email-verification-container');
            const existingError = emailContainer.querySelector('.error-message');
            if (existingError) {
                existingError.remove();
            }
            this.style.borderColor = '#e5e8eb';
        });

        // 인증번호 입력 필드 변경 시 오류 메시지 제거
        verificationCode.addEventListener('input', function () {
            const existingMessage = verificationMessage.textContent;
            if (existingMessage && !existingMessage.includes('완료')) {
                verificationMessage.textContent = '';
                verificationMessage.className = 'verification-message';
            }
        });

        // 인증 메시지 표시 함수
        function showVerificationMessage(message, type) {
            verificationMessage.textContent = message;
            verificationMessage.className = `verification-message verification-${type}`;

            // 3초 후 메시지 제거
            setTimeout(() => {
                verificationMessage.textContent = '';
                verificationMessage.className = 'verification-message';
            }, 3000);
        }

        // 재윤 -- 아래 표시************ 표시까지 수정함 데이터action으로 전송위함.
        registerForm.addEventListener('submit', async function (e) {
            // 1. 폼의 기본 제출 기능은 막습니다.
            e.preventDefault();

            // 2. 모든 유효성 검사는 그대로 유지합니다.
            const email = emailInput.value.trim();
            const password = passwordInput.value.trim();
            const password2 = password2Input.value.trim();
            const name = nameInput.value.trim();

            if (name.length < 1) {
                showError(nameInput, "닉네임을 입력해주세요")
                return
            }
            if (!isValidEmail(email)) {
                showError(emailInput, '올바른 이메일 형식을 입력해주세요.');
                return;
            }
            if (!isEmailVerified) {
                showError(emailInput, '이메일 인증을 완료해주세요.');
                return;
            }
            if (!password || password.length < 8 || !isValidPassword(password)) {
                showError(passwordInput, '비밀번호는 영문, 숫자, 특수문자가 모두 들어간 8자 이상이어야 합니다.');
                return;
            }
            if (password !== password2) {
                showError(password2Input, '비밀번호가 일치하지 않습니다.');
                return;
            }
            if (!ageAgree.checked || !serviceAgree.checked || !privacyAgree.checked) {
                alert('필수 약관에 동의해주세요.');
                return;
            }

            // 3. (핵심) setTimeout 대신 fetch를 사용해 서버에 데이터를 전송합니다.
            try {
                const submitBtn = document.querySelector('.register-btn');
                submitBtn.disabled = true;
                submitBtn.textContent = '가입 처리 중...';

                emailInput.disabled = false;
                // 2. FormData 객체를 다시 사용합니다.
                const formData = new FormData(registerForm);
                // 3. 다시 비활성화합니다.
                emailInput.disabled = true;

                // fetch API로 서버에 데이터 전송
                const response = await fetch(registerForm.action, {
                    method: 'POST',
                    headers: {

                        'Content-Type': 'application/x-www-form-urlencoded',
                    },

                    body: new URLSearchParams(formData)
                });

                // 서버 응답 확인
                if (response.ok) {
                    alert('회원가입이 완료되었습니다!');
                    window.location.href = 'login.jsp'; // 성공 시 로그인 페이지로 이동
                } else {
                    // 서버 측에서 문제가 발생했을 경우 (예: 중복된 이메일)
                    alert('회원가입에 실패했습니다. 입력 정보를 확인해주세요. or 가입한 이메일 입니다. 비밀번호를 찾아주세요');
                    submitBtn.disabled = false;
                    submitBtn.textContent = '가입완료';
                }
            } catch (error) {
                // 네트워크 문제 등 fetch 자체가 실패한 경우
                console.error('Fetch Error:', error);
                alert('서버와 통신 중 오류가 발생했습니다.');
                const submitBtn = document.querySelector('.register-btn');
                submitBtn.disabled = false;
                submitBtn.textContent = '가입완료';
            }
        });

        //********************************************************************************

        function isValidEmail(email) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            return emailRegex.test(email);
        }

        function isValidPassword(password) {
            const hasLetter = /[a-zA-Z]/.test(password);
            const hasNumber = /\d/.test(password);
            const hasSpecial = /[!@#$%^&*(),.?":{}|<>]/.test(password);
            return hasLetter && hasNumber && hasSpecial;
        }

        function showError(input, message) {
            const existingError = input.parentNode.querySelector('.error-message');
            if (existingError) existingError.remove();

            const errorDiv = document.createElement('div');
            errorDiv.className = 'error-message email-error-message';
            errorDiv.textContent = message;

            // 이메일 입력 필드인 경우 부모 컨테이너에 추가
            if (input.id === 'email') {
                const emailContainer = input.closest('.email-verification-container');
                emailContainer.appendChild(errorDiv);
            } else {
                input.parentNode.appendChild(errorDiv);
            }

            input.style.borderColor = '#e74c3c';
            setTimeout(() => {
                if (errorDiv.parentNode) {
                    errorDiv.remove();
                    input.style.borderColor = '#e5e8eb';
                }
            }, 3000);
        }

        function showSuccess(message) {
            const successDiv = document.createElement('div');
            successDiv.style.position = 'fixed';
            successDiv.style.top = '20px';
            successDiv.style.right = '20px';
            successDiv.style.background = '#667eea';
            successDiv.style.color = '#fff';
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

        // 비밀번호 토글 기능
        passwordToggle.addEventListener('click', function () {
            const type = passwordInput.type === 'password' ? 'text' : 'password';
            passwordInput.type = type;
            this.innerHTML = type === 'password' ? '<i class="fas fa-eye"></i>' : '<i class="fas fa-eye-slash"></i>';
        });

        password2Toggle.addEventListener('click', function () {
            const type = password2Input.type === 'password' ? 'text' : 'password';
            password2Input.type = type;
            this.innerHTML = type === 'password' ? '<i class="fas fa-eye"></i>' : '<i class="fas fa-eye-slash"></i>';
        });

        // 모두 동의하기 기능
        allAgree.addEventListener('change', function () {
            const checkboxes = [ageAgree, serviceAgree, privacyAgree, marketingAgree];
            checkboxes.forEach(checkbox => {
                checkbox.checked = this.checked;
            });
        });

        // 개별 체크박스 변경 시 모두 동의 상태 업데이트
        [ageAgree, serviceAgree, privacyAgree, marketingAgree].forEach(checkbox => {
            checkbox.addEventListener('change', function () {
                const requiredCheckboxes = [ageAgree, serviceAgree, privacyAgree];
                const allChecked = requiredCheckboxes.every(cb => cb.checked) && marketingAgree.checked;
                allAgree.checked = allChecked;
            });
        });

    });
</script>


</body>
</html>
