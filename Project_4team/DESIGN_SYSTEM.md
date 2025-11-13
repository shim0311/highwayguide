# 🎨 HighwayGuide 디자인 시스템

> 모든 페이지에서 일관된 디자인을 유지하기 위한 디자인 시스템 가이드

## 📚 목차

- [시작하기](#시작하기)
- [컬러 팔레트](#컬러-팔레트)
- [타이포그래피](#타이포그래피)
- [간격 시스템](#간격-시스템)
- [컴포넌트](#컴포넌트)
- [유틸리티 클래스](#유틸리티-클래스)
- [접근성](#접근성)
- [예제 페이지](#예제-페이지)

---

## 🚀 시작하기

### 1. CSS 파일 추가

JSP 파일의 `<head>` 섹션에 디자인 시스템 CSS를 추가하세요:

```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>페이지 제목</title>

    <!-- Font Awesome 아이콘 (선택사항) -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

    <!-- 디자인 시스템 CSS (필수) -->
    <link href="${pageContext.request.contextPath}/css/design-system.css" rel="stylesheet">
</head>
<body>
    <!-- 페이지 내용 -->
</body>
</html>
```

### 2. 기존 페이지에 적용하기

기존 CSS 파일이 있는 경우, 디자인 시스템을 **먼저** 로드한 후 기존 CSS를 로드하세요:

```jsp
<!-- 1. 디자인 시스템 (기본 스타일) -->
<link href="${pageContext.request.contextPath}/css/design-system.css" rel="stylesheet">

<!-- 2. 기존 커스텀 CSS (오버라이드) -->
<link href="${pageContext.request.contextPath}/css/custom-style.css" rel="stylesheet">
```

---

## 🎨 컬러 팔레트

### Primary Colors (브랜드 컬러)

```css
/* 메인 브랜드 컬러 */
var(--color-primary-500)    /* #667eea - 메인 */
var(--color-primary-600)    /* #5a67d8 - 호버 */
var(--color-secondary-500)  /* #764ba2 - 보조 */
```

### Semantic Colors (의미적 컬러)

```css
/* 성공 */
var(--color-success-500)    /* #22c55e - 녹색 */

/* 에러 */
var(--color-error-500)      /* #e53e3e - 빨강 */

/* 경고 */
var(--color-warning-500)    /* #f59e0b - 주황 */

/* 정보 */
var(--color-info-500)       /* #3b82f6 - 파랑 */
```

### Neutral Colors (회색 스케일)

```css
var(--color-neutral-50)     /* #f8fafc - 매우 밝음 */
var(--color-neutral-200)    /* #e5e8eb - 밝음 */
var(--color-neutral-600)    /* #555 - 중간 */
var(--color-neutral-800)    /* #222 - 어두움 */
var(--color-white)          /* #ffffff */
var(--color-black)          /* #000000 */
```

### 사용 예시

```css
.my-button {
    background: var(--color-primary-500);
    color: var(--color-white);
}

.my-button:hover {
    background: var(--color-primary-600);
}

.error-message {
    color: var(--color-error-500);
    background: var(--color-error-50);
}
```

---

## 📝 타이포그래피

### Font Family

```css
var(--font-primary)   /* 'PretendardVariable', sans-serif */
var(--font-secondary) /* 'Roboto', sans-serif */
var(--font-code)      /* 'Monaco', 'Courier New', monospace */
```

### Font Sizes

| 변수 | 크기 | 사용처 |
|------|------|--------|
| `--font-size-xs` | 12px | 작은 텍스트, 힌트 |
| `--font-size-sm` | 14px | 부제목, 설명 |
| `--font-size-base` | 16px | 본문 |
| `--font-size-lg` | 18px | 큰 본문 |
| `--font-size-xl` | 20px | 소제목 |
| `--font-size-2xl` | 24px | 제목 |
| `--font-size-3xl` | 30px | 큰 제목 |
| `--font-size-4xl` | 36px | 메인 제목 |
| `--font-size-6xl` | 56px | 히어로 제목 |

### Font Weights

```css
var(--font-weight-light)      /* 300 */
var(--font-weight-regular)    /* 400 */
var(--font-weight-medium)     /* 500 */
var(--font-weight-semibold)   /* 600 */
var(--font-weight-bold)       /* 700 */
var(--font-weight-extrabold)  /* 800 */
```

### 사용 예시

```html
<h1 style="font-size: var(--font-size-4xl); font-weight: var(--font-weight-bold);">
    메인 제목
</h1>

<p style="font-size: var(--font-size-base); line-height: var(--line-height-relaxed);">
    본문 내용...
</p>
```

---

## 📏 간격 시스템

### Spacing Scale

| 변수 | 크기 | 픽셀 |
|------|------|------|
| `--spacing-1` | 0.25rem | 4px |
| `--spacing-2` | 0.5rem | 8px |
| `--spacing-3` | 0.75rem | 12px |
| `--spacing-4` | 1rem | 16px |
| `--spacing-6` | 1.5rem | 24px |
| `--spacing-8` | 2rem | 32px |
| `--spacing-12` | 3rem | 48px |
| `--spacing-16` | 4rem | 64px |

### 사용 예시

```css
.my-container {
    padding: var(--spacing-8);
    margin-bottom: var(--spacing-4);
    gap: var(--spacing-3);
}
```

### 유틸리티 클래스

```html
<!-- Margin -->
<div class="mt-4">margin-top: 1rem</div>
<div class="mb-6">margin-bottom: 1.5rem</div>
<div class="m-8">margin: 2rem</div>

<!-- Padding -->
<div class="p-4">padding: 1rem</div>
<div class="pt-2">padding-top: 0.5rem</div>
```

---

## 🔧 컴포넌트

### 1. 버튼 (Buttons)

#### 기본 버튼

```html
<!-- Primary 버튼 -->
<button class="btn btn-primary">
    <i class="fas fa-check"></i> 확인
</button>

<!-- Secondary 버튼 -->
<button class="btn btn-secondary">
    <i class="fas fa-star"></i> 즐겨찾기
</button>

<!-- Outline 버튼 -->
<button class="btn btn-outline">
    취소
</button>

<!-- Danger 버튼 -->
<button class="btn btn-danger">
    <i class="fas fa-trash"></i> 삭제
</button>
```

#### 버튼 크기

```html
<button class="btn btn-primary btn-sm">Small</button>
<button class="btn btn-primary">Default</button>
<button class="btn btn-primary btn-lg">Large</button>
```

#### 아이콘 버튼

```html
<button class="btn btn-primary btn-icon">
    <i class="fas fa-heart"></i>
</button>
```

#### 비활성화 상태

```html
<button class="btn btn-primary" disabled>
    <i class="fas fa-spinner fa-spin"></i> 로딩 중...
</button>
```

---

### 2. 카드 (Cards)

```html
<div class="card">
    <div class="card-header">
        <h3 class="card-title">카드 제목</h3>
        <p class="card-subtitle">카드 부제목</p>
    </div>
    <div class="card-body">
        <p>카드 본문 내용입니다.</p>
    </div>
    <div class="card-footer">
        <button class="btn btn-primary btn-sm">자세히</button>
        <button class="btn btn-outline btn-sm">공유</button>
    </div>
</div>
```

#### 휴게소 카드 예시

```html
<div class="card">
    <div class="card-header">
        <h3 class="card-title">
            <i class="fas fa-map-marker-alt text-primary"></i>
            안성휴게소 (서울방향)
        </h3>
    </div>
    <div class="card-body">
        <p class="text-sm text-neutral-600">
            <i class="fas fa-phone"></i> 031-123-4567<br>
            <i class="fas fa-gas-pump"></i> 주유소 운영 중<br>
            <i class="fas fa-utensils"></i> 식당 24시간
        </p>
    </div>
    <div class="card-footer">
        <span class="text-sm text-neutral-500">1.2km</span>
        <button class="btn btn-icon btn-primary btn-sm">
            <i class="fas fa-heart"></i>
        </button>
    </div>
</div>
```

---

### 3. 입력 필드 (Form Inputs)

```html
<!-- 기본 입력 -->
<div class="form-group">
    <label class="form-label">이메일</label>
    <input type="email" class="form-input" placeholder="example@email.com">
    <div class="form-helper-text">이메일 주소를 입력해주세요</div>
</div>

<!-- 필수 입력 -->
<div class="form-group">
    <label class="form-label form-label-required">비밀번호</label>
    <input type="password" class="form-input" required>
</div>

<!-- 에러 상태 -->
<div class="form-group">
    <label class="form-label">이름</label>
    <input type="text" class="form-input error" value="잘못된 값">
    <div class="form-error-text">
        <i class="fas fa-exclamation-circle"></i>
        올바른 형식이 아닙니다
    </div>
</div>

<!-- Textarea -->
<div class="form-group">
    <label class="form-label">메시지</label>
    <textarea class="form-textarea" placeholder="내용을 입력하세요"></textarea>
</div>

<!-- Select -->
<div class="form-group">
    <label class="form-label">지역 선택</label>
    <select class="form-select">
        <option>서울</option>
        <option>경기</option>
        <option>인천</option>
    </select>
</div>
```

---

### 4. 모달 (Modal)

```html
<!-- 모달 트리거 버튼 -->
<button class="btn btn-primary" onclick="openModal('myModal')">
    모달 열기
</button>

<!-- 모달 컴포넌트 -->
<div class="modal-overlay" id="myModal">
    <div class="modal-container" style="max-width: 500px;">
        <div class="modal-header">
            <h3 class="modal-title">모달 제목</h3>
            <button class="modal-close" onclick="closeModal('myModal')">
                <i class="fas fa-times"></i>
            </button>
        </div>
        <div class="modal-body">
            <p>모달 내용...</p>
        </div>
        <div class="modal-footer">
            <button class="btn btn-outline" onclick="closeModal('myModal')">
                취소
            </button>
            <button class="btn btn-primary">
                확인
            </button>
        </div>
    </div>
</div>

<script>
function openModal(id) {
    document.getElementById(id).classList.add('active');
}

function closeModal(id) {
    document.getElementById(id).classList.remove('active');
}

// 오버레이 클릭 시 닫기
document.getElementById('myModal').addEventListener('click', function(e) {
    if (e.target === this) closeModal('myModal');
});
</script>
```

---

### 5. Toast 알림 (Toast Notifications)

```javascript
// JavaScript 함수로 Toast 생성
function showToast(type, title, message) {
    const icons = {
        success: 'fa-check-circle',
        error: 'fa-exclamation-circle',
        warning: 'fa-exclamation-triangle',
        info: 'fa-info-circle'
    };

    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.innerHTML = `
        <div class="toast-icon">
            <i class="fas ${icons[type]}"></i>
        </div>
        <div class="toast-content">
            <div class="toast-title">${title}</div>
            <div class="toast-message">${message}</div>
        </div>
        <button class="toast-close" onclick="this.parentElement.remove()">
            <i class="fas fa-times"></i>
        </button>
    `;

    document.body.appendChild(toast);

    // 3초 후 자동 제거
    setTimeout(() => toast.remove(), 3000);
}

// 사용 예시
showToast('success', '성공!', '저장되었습니다.');
showToast('error', '오류', '네트워크 오류가 발생했습니다.');
showToast('warning', '경고', '입력값을 확인해주세요.');
showToast('info', '알림', '새로운 메시지가 있습니다.');
```

---

### 6. 스켈레톤 로딩 (Skeleton Loading)

```html
<!-- 로딩 중 표시 -->
<div class="card">
    <div class="skeleton skeleton-title"></div>
    <div class="skeleton skeleton-text"></div>
    <div class="skeleton skeleton-text"></div>
    <div class="skeleton skeleton-text" style="width: 60%;"></div>
</div>

<!-- 아바타 로딩 -->
<div class="skeleton skeleton-avatar"></div>

<!-- 카드 로딩 -->
<div class="skeleton skeleton-card"></div>
```

---

### 7. 빈 상태 (Empty State)

```html
<div class="empty-state">
    <div class="empty-state-icon">
        <i class="fas fa-inbox"></i>
    </div>
    <h3 class="empty-state-title">데이터가 없습니다</h3>
    <p class="empty-state-description">
        아직 등록된 항목이 없습니다. 새로운 항목을 추가해보세요.
    </p>
    <button class="btn btn-primary">
        <i class="fas fa-plus"></i> 새 항목 추가
    </button>
</div>
```

---

## 🛠️ 유틸리티 클래스

### 텍스트 크기

```html
<p class="text-xs">Extra Small (12px)</p>
<p class="text-sm">Small (14px)</p>
<p class="text-base">Base (16px)</p>
<p class="text-lg">Large (18px)</p>
<p class="text-xl">Extra Large (20px)</p>
<p class="text-2xl">2XL (24px)</p>
<p class="text-3xl">3XL (30px)</p>
```

### 폰트 두께

```html
<p class="font-light">Light (300)</p>
<p class="font-regular">Regular (400)</p>
<p class="font-medium">Medium (500)</p>
<p class="font-semibold">Semibold (600)</p>
<p class="font-bold">Bold (700)</p>
```

### 텍스트 정렬

```html
<p class="text-left">왼쪽 정렬</p>
<p class="text-center">가운데 정렬</p>
<p class="text-right">오른쪽 정렬</p>
```

### 색상

```html
<p class="text-primary">Primary 색상</p>
<p class="text-success">Success 색상</p>
<p class="text-error">Error 색상</p>
<p class="text-warning">Warning 색상</p>
```

### Flexbox

```html
<!-- 기본 Flex -->
<div class="d-flex gap-4">
    <div>항목 1</div>
    <div>항목 2</div>
</div>

<!-- 가운데 정렬 -->
<div class="d-flex justify-center align-center">
    <div>가운데 정렬</div>
</div>

<!-- 양쪽 정렬 -->
<div class="d-flex justify-between align-center">
    <div>왼쪽</div>
    <div>오른쪽</div>
</div>

<!-- 세로 정렬 -->
<div class="d-flex flex-column gap-2">
    <div>위</div>
    <div>아래</div>
</div>
```

### Border Radius

```html
<div class="rounded-sm">Small (6px)</div>
<div class="rounded-md">Medium (8px)</div>
<div class="rounded-lg">Large (12px)</div>
<div class="rounded-xl">Extra Large (16px)</div>
<div class="rounded-2xl">2XL (20px)</div>
<div class="rounded-full">Full (9999px)</div>
```

### 그림자

```html
<div class="shadow-sm">Small Shadow</div>
<div class="shadow-md">Medium Shadow</div>
<div class="shadow-lg">Large Shadow</div>
<div class="shadow-xl">Extra Large Shadow</div>
<div class="shadow-2xl">2XL Shadow</div>
```

---

## ♿ 접근성 (Accessibility)

### 1. 스크린 리더 전용 텍스트

```html
<button class="btn btn-primary">
    <i class="fas fa-heart"></i>
    <span class="sr-only">즐겨찾기 추가</span>
</button>
```

### 2. 키보드 네비게이션

모든 인터랙티브 요소는 키보드로 접근 가능합니다:

- **Tab**: 다음 요소로 이동
- **Shift + Tab**: 이전 요소로 이동
- **Enter/Space**: 버튼 클릭
- **Esc**: 모달/드롭다운 닫기

### 3. 포커스 표시

`:focus-visible` 사용으로 키보드 사용자를 위한 포커스 표시가 자동으로 적용됩니다.

### 4. ARIA 레이블

```html
<!-- 버튼에 설명 추가 -->
<button class="btn btn-primary" aria-label="검색 시작">
    <i class="fas fa-search"></i>
</button>

<!-- 모달 -->
<div class="modal-overlay" role="dialog" aria-labelledby="modal-title" aria-modal="true">
    <div class="modal-container">
        <h3 id="modal-title" class="modal-title">모달 제목</h3>
        <!-- 모달 내용 -->
    </div>
</div>

<!-- 로딩 상태 -->
<button class="btn btn-primary" disabled aria-busy="true">
    <i class="fas fa-spinner fa-spin"></i>
    로딩 중...
</button>
```

---

## 📖 예제 페이지

전체 컴포넌트를 확인하려면 다음 페이지를 방문하세요:

```
http://localhost:8080/Project_4team/design-system-demo.html
```

또는 프로젝트에서:

```
/Project_4team/src/main/webapp/design-system-demo.html
```

---

## 💡 모범 사례 (Best Practices)

### 1. CSS Variables 우선 사용

❌ **나쁜 예:**
```css
.my-button {
    background: #667eea;
    padding: 16px;
    border-radius: 12px;
}
```

✅ **좋은 예:**
```css
.my-button {
    background: var(--color-primary-500);
    padding: var(--spacing-4);
    border-radius: var(--radius-lg);
}
```

### 2. 유틸리티 클래스 활용

❌ **나쁜 예:**
```html
<div style="display: flex; gap: 16px; margin-top: 24px;">
    <!-- 내용 -->
</div>
```

✅ **좋은 예:**
```html
<div class="d-flex gap-4 mt-6">
    <!-- 내용 -->
</div>
```

### 3. 시맨틱 컬러 사용

❌ **나쁜 예:**
```html
<button style="background: green;">저장</button>
<button style="background: red;">삭제</button>
```

✅ **좋은 예:**
```html
<button class="btn btn-success">저장</button>
<button class="btn btn-danger">삭제</button>
```

### 4. 접근성 고려

✅ **항상 포함:**
- 버튼에 명확한 텍스트나 `aria-label`
- 입력 필드에 `<label>` 연결
- 모달에 `role="dialog"` 속성
- 키보드 네비게이션 지원

---

## 🔄 기존 페이지 마이그레이션

### 단계별 마이그레이션

#### 1단계: CSS 추가
```jsp
<link href="${pageContext.request.contextPath}/css/design-system.css" rel="stylesheet">
```

#### 2단계: 버튼 교체
```html
<!-- Before -->
<button style="background: #667eea; color: white; padding: 10px 20px; border-radius: 8px;">
    클릭
</button>

<!-- After -->
<button class="btn btn-primary">
    클릭
</button>
```

#### 3단계: 카드 교체
```html
<!-- Before -->
<div style="background: white; padding: 20px; border-radius: 16px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
    <!-- 내용 -->
</div>

<!-- After -->
<div class="card">
    <div class="card-body">
        <!-- 내용 -->
    </div>
</div>
```

#### 4단계: 간격 조정
```html
<!-- Before -->
<div style="margin-top: 24px; padding: 16px;">
    <!-- 내용 -->
</div>

<!-- After -->
<div class="mt-6 p-4">
    <!-- 내용 -->
</div>
```

---

## 🤝 기여하기

디자인 시스템 개선 아이디어가 있다면:

1. 새로운 컴포넌트 제안
2. 버그 리포트
3. 접근성 개선 제안
4. 문서 업데이트

---

## 📞 지원

문제가 발생하거나 질문이 있으면:

- 프로젝트 이슈 트래커
- 팀 Slack 채널
- 개발 문서 참고

---

**Made with ❤️ by HighwayGuide Team**

마지막 업데이트: 2025-11-13
