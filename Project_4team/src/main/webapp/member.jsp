<%--
  Created by IntelliJ IDEA.
  User: js
  Date: 25. 8. 19.
  Time: 오전 11:02
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>

<!-- Main Content -->
<div class="manage-container">
    <div class="manage-header">
        <h1 class="manage-title">회원 관리</h1>
        <p class="manage-subtitle">전체 회원 목록을 확인하고 관리하세요</p>
    </div>
    
    <div class="manage-content">
        <!-- 검색 섹션 -->
        <div class="search-section">
            <div class="search-container">
                <input type="text" id="searchInput" placeholder="이름 또는 ID로 검색..." class="search-input">
                <div class="search-info">
                    <span id="memberCount">0</span>명의 회원이 있습니다.
                </div>
            </div>
        </div>
        
        <!-- 회원 목록 테이블 -->
        <div class="member-list-section">
            <table class="member-table" id="memberTable">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>닉네임</th>
                        <th>이름</th>
                        <th>주소</th>
                        <th>관심사</th>
                        <th>가입경로</th>
                        <th>관리</th>
                    </tr>
                </thead>
                <tbody id="memberTableBody">
                    <!-- 회원 목록이 동적으로 생성됩니다 -->
                </tbody>
            </table>
        </div>
    </div>
</div>

<style>
    /* manage-content 스타일 오버라이드 - 1열 레이아웃으로 변경 */
    .manage-content {
        display: block !important;
        grid-template-columns: 1fr !important;
        gap: 2rem !important;
        margin-bottom: 3rem !important;
    }
    
    /* 검색 섹션 */
    .search-section {
        background: white;
        border-radius: 16px;
        padding: 2rem;
        margin-bottom: 2rem;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
    }
    
    .search-container {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 2rem;
    }
    
    .search-input {
        flex: 1;
        max-width: 400px;
        padding: 0.75rem 1rem;
        border: 2px solid #e1e5e9;
        border-radius: 8px;
        font-size: 1rem;
        transition: border-color 0.3s ease;
    }
    
    .search-input:focus {
        outline: none;
        border-color: #667eea;
    }
    
    .search-info {
        font-size: 0.9rem;
        color: #666;
    }
    
    /* 회원 테이블 */
    .member-list-section {
        background: white;
        border-radius: 16px;
        padding: 2rem;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
        overflow-x: auto;
    }
    
    .member-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 0.9rem;
    }
    
    .member-table th,
    .member-table td {
        padding: 1rem;
        text-align: left;
        border-bottom: 1px solid #f0f0f0;
    }
    
    .member-table th {
        background: #f8f9fa;
        font-weight: 600;
        color: #333;
        position: sticky;
        top: 0;
    }
    
    .member-table tbody tr:hover {
        background: #f8f9fa;
    }
    
    .member-table tbody tr {
        cursor: pointer;
        transition: background-color 0.2s ease;
    }
    
    /* 플랫폼 태그 */
    .platform-tag {
        display: inline-block;
        padding: 0.25rem 0.75rem;
        border-radius: 20px;
        font-size: 0.8rem;
        font-weight: 500;
        color: white;
    }
    
    .platform-kakao {
        background: #FEE500;
        color: #333;
    }
    
    .platform-naver {
        background: #03C75A;
    }
    
    .platform-origin {
        background: linear-gradient(135deg, #8B5CF6, #667eea);
    }
    
    /* 삭제 버튼 */
    .delete-btn {
        padding: 0.5rem 1rem;
        background: #e74c3c;
        color: white;
        border: none;
        border-radius: 6px;
        cursor: pointer;
        font-size: 0.8rem;
        transition: background-color 0.2s ease;
    }
    
    .delete-btn:hover {
        background: #c0392b;
    }
    
    /* 로딩 상태 */
    .loading {
        text-align: center;
        padding: 2rem;
        color: #666;
    }
    
    .loading::after {
        content: '';
        display: inline-block;
        width: 20px;
        height: 20px;
        border: 2px solid #f3f3f3;
        border-top: 2px solid #667eea;
        border-radius: 50%;
        animation: spin 1s linear infinite;
        margin-left: 0.5rem;
    }
    
    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }
    
    /* 반응형 디자인 */
    @media (max-width: 768px) {
        .search-container {
            flex-direction: column;
            align-items: stretch;
        }
        
        .search-input {
            max-width: none;
        }
        
        .member-table {
            font-size: 0.8rem;
        }
        
        .member-table th,
        .member-table td {
            padding: 0.5rem;
        }
    }
</style>

<script>
    // ========================================
    // 회원 관리 페이지 JavaScript (새로운 컬럼 구조)
    // ========================================
    
    // 전역 변수
    let allMembers = [];  // 전체 회원 데이터
    let filteredMembers = [];  // 필터링된 회원 데이터
    
    // ========================================
    // 1. 페이지 로드 시 초기화
    // ========================================
    document.addEventListener('DOMContentLoaded', function() {
        loadMembers();        // 회원 데이터 로드
        setupEventListeners(); // 이벤트 리스너 설정
    });
    
    // ========================================
    // 2. 이벤트 리스너 설정
    // ========================================
    function setupEventListeners() {
        // 검색 입력 필드에 실시간 검색 이벤트 추가
        const searchInput = document.getElementById('searchInput');
        if (searchInput) {
            searchInput.addEventListener('input', function() {
                filterMembers(this.value); // 타이핑할 때마다 검색 실행
            });
        }
    }
    
    // ========================================
    // 3. 회원 데이터 로드 (AJAX)
    // ========================================
    async function loadMembers() {
        try {
            showLoading(); // 로딩 상태 표시
            
            // 서버에서 회원 데이터 요청
            const response = await fetch('Controller', {
                method: 'POST',
                body: new URLSearchParams({
                    type: 'Members',
                    method: 'getAll'
                })
            });
            
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            
            // 응답 내용 확인
            const responseText = await response.text();
            console.log('서버 응답:', responseText);
            
            // JSON 파싱 시도
            const data = JSON.parse(responseText);
            console.log('파싱된 데이터:', data);

            allMembers = data.members || [];           // 전체 회원 데이터 저장
            filteredMembers = [...allMembers];         // 필터링용 데이터 복사
            
            updateMemberTable();  // 테이블 업데이트
            updateMemberCount();  // 회원 수 업데이트
            
        } catch (error) {
            console.error('회원 데이터 로드 실패:', error);
            loadTempData(); // 에러 시 임시 데이터로 표시
        }
    }
    
    // ========================================
    // 4. 임시 데이터 로드 (테스트용)
    // ========================================
    function loadTempData() {
        // 서버 연결 실패 시 사용할 샘플 데이터
        allMembers = [
            {
                ID: 'user001',
                NickName: '철수킹',
                Name: '김철수',
                Home: '서울시 강남구',
                Interest: '운동, 여행',
                platform: 'KAKAO'
            },
            {
                ID: 'user002',
                NickName: '영희공주',
                Name: '이영희',
                Home: '부산시 해운대구',
                Interest: '독서, 영화감상',
                platform: 'NAVER'
            },
            {
                ID: 'user003',
                NickName: '민수맨',
                Name: '박민수',
                Home: '대구시 수성구',
                Interest: '게임, 음악',
                platform: 'ORIGIN'
            },
            {
                ID: 'user004',
                NickName: '수진이',
                Name: '정수진',
                Home: '인천시 연수구',
                Interest: '요리, 베이킹',
                platform: 'KAKAO'
            },
            {
                ID: 'user005',
                NickName: '동현이',
                Name: '최동현',
                Home: '광주시 서구',
                Interest: '축구, 농구',
                platform: 'NAVER'
            },
            {
                ID: 'user006',
                NickName: '지민이',
                Name: '한지민',
                Home: '대전시 유성구',
                Interest: '등산, 캠핑',
                platform: 'ORIGIN'
            }
        ];
        
        filteredMembers = [...allMembers];
        updateMemberTable();  // 테이블 업데이트
        updateMemberCount();  // 회원 수 업데이트
    }
    
    // ========================================
    // 5. 회원 목록 필터링 (이름과 ID로만 검색)
    // ========================================
    function filterMembers(searchTerm) {
        if (!searchTerm.trim()) {
            // 검색어가 없으면 전체 회원 표시
            filteredMembers = [...allMembers];
        } else {
            // 검색어가 있으면 이름 또는 ID에 포함된 회원만 필터링
            const term = searchTerm.toLowerCase();
            filteredMembers = allMembers.filter(member => 
                member.Name.toLowerCase().includes(term) ||
                member.ID.toLowerCase().includes(term)
            );
        }
        
        updateMemberTable();  // 필터링된 결과로 테이블 업데이트
        updateMemberCount();  // 필터링된 회원 수 업데이트
    }
    
    // ========================================
    // 6. 회원 테이블 업데이트
    // ========================================
    function updateMemberTable() {
        const tableBody = document.getElementById('memberTableBody');
        if (!tableBody) return;
        
        if (filteredMembers.length === 0) {
            // 검색 결과가 없을 때 메시지 표시
            tableBody.innerHTML = `
                <tr>
                    <td colspan="7" style="text-align: center; padding: 2rem; color: #666;">
                        검색 결과가 없습니다.
                    </td>
                </tr>
            `;
            return;
        }
        
        tableBody.innerHTML = ''; // 기존 테이블 내용 초기화
        
        // 필터링된 회원 목록으로 테이블 행 생성
        filteredMembers.forEach((member, index) => {
            const row = document.createElement('tr');
            row.onclick = () => confirmDelete(member); // 행 클릭 시 삭제 확인
            
            // 플랫폼별 스타일 클래스와 라벨 가져오기
            const platformClass = getPlatformClass(member.platform);
            const platformLabel = getPlatformLabel(member.platform);
            
            // 테이블 행 HTML 생성 - 실제 DB 필드명과 올바른 문법 사용
            row.innerHTML = 
                '<td>' + (member.ID || '') + '</td>' +
                '<td>' + (member.NickName || '') + '</td>' +
                '<td>' + (member.Name || '') + '</td>' +
                '<td>' + (member.Home || '주소 정보 없음') + '</td>' +
                '<td>' + (member.Interest || ' 관심사 정보 없음') + '</td>' +
                '<td><span class="platform-tag ' + platformClass + '">' + platformLabel + '</span></td>' +
                '<td>' +
                    '<button class="delete-btn" data-member-id="' + (member.ID || '') + '">' +
                        '삭제' +
                    '</button>' +
                '</td>';
            
            // 삭제 버튼에 개별 이벤트 리스너 추가 (행 클릭과 분리)
            const deleteBtn = row.querySelector('.delete-btn');
            if (deleteBtn) {  // null 체크 추가
            deleteBtn.addEventListener('click', (e) => {
                e.stopPropagation();
                confirmDelete(member);
            });
        } else {
            console.error('삭제 버튼을 찾을 수 없습니다:', member);
        }
            
            tableBody.appendChild(row); // 테이블에 행 추가
        });
    }
    
    // ========================================
    // 7. 회원 수 업데이트
    // ========================================
    function updateMemberCount() {
        const memberCount = document.getElementById('memberCount');
        if (memberCount) {
            memberCount.textContent = filteredMembers.length; // 현재 표시되는 회원 수 업데이트
        }
    }
    
    // ========================================
    // 8. 로딩 상태 표시
    // ========================================
    function showLoading() {
        const tableBody = document.getElementById('memberTableBody');
        if (tableBody) {
            // 로딩 중일 때 스피너와 메시지 표시
            tableBody.innerHTML = `
                <tr>
                    <td colspan="7" class="loading">
                        회원 데이터를 불러오는 중...
                    </td>
                </tr>
            `;
        }
    }
    
    // ========================================
    // 9. 플랫폼별 스타일 클래스 반환
    // ========================================
    function getPlatformClass(platform) {
        // 플랫폼에 따른 CSS 클래스 반환 (색상 구분용)
        switch(platform) {
            case 'KAKAO': return 'platform-kakao';    // 노란색 배경
            case 'NAVER': return 'platform-naver';    // 초록색 배경
            case 'ORIGIN': return 'platform-origin';  // 보라색 그라데이션
            default: return 'platform-origin';
        }
    }
    
    function getPlatformLabel(platform) {
        // 플랫폼에 따른 한글 라벨 반환
        switch(platform) {
            case 'KAKAO': return '카카오';
            case 'NAVER': return '네이버';
            case 'ORIGIN': return '자사계정';
            default: return '자사계정';
        }
    }
    
    // ========================================
    // 10. 삭제 확인 및 처리
    // ========================================
    function confirmDelete(member) {
        // 사용자에게 삭제 확인 대화상자 표시
        if (!confirm('정말로 ' + member.Name + '(' + member.NickName + ') 회원을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.')) {
            return; // 취소 시 함수 종료
        }
        
        deleteMember(member.NickName); // 확인 시 삭제 함수 호출
    }
    
    // ========================================
    // 11. 회원 삭제 (AJAX)
    // ========================================
    async function deleteMember(NickName) {
        try {
            // 서버에 회원 삭제 요청
            const response = await fetch('Controller', {
                method: 'POST',
                body: new URLSearchParams({
                    type: 'Members',
                    method: 'delete',
                    NickName: NickName
                })
            });
            
            console.log('응답 상태:', response.status);
            console.log('응답 헤더:', response.headers);
            
            // 응답 텍스트 먼저 확인
            const responseText = await response.text();
            console.log('응답 내용:', responseText);

            if (!response.ok) {
                throw new Error('Network response was not ok');
            }

             // JSON 파싱 시도
            let result;
            try {
                result = JSON.parse(responseText);
                console.log('파싱된 결과:', result);
            } catch (parseError) {
                console.error('JSON 파싱 실패:', parseError);
                throw new Error('응답 파싱 실패: ' + responseText);
            }
            
            if (result.success) {
                // 삭제 성공 시
                alert('회원이 성공적으로 삭제되었습니다.');
                // 로컬 데이터에서도 삭제된 회원 제거
                allMembers = allMembers.filter(member => member.NickName !== NickName);
                filteredMembers = filteredMembers.filter(member => member.NickName !== NickName);
                updateMemberTable();  // 테이블 새로고침
                updateMemberCount();  // 회원 수 업데이트
            } else {
                // 삭제 실패 시
                alert('회원 삭제에 실패했습니다: ' + (result.message || '알 수 없는 오류'));
            }
            
        } catch (error) {
            console.error('회원 삭제 실패:', error);
            alert('회원 삭제 중 오류가 발생했습니다.');
        }
    }
</script>
