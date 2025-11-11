<%--
  Created by IntelliJ IDEA.
  User: js
  Date: 25. 8. 19.
  Time: 오전 11:02
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<style>
    /* 공통 스타일은 manage.jsp에서 처리하므로 제거 */

    .manage-content {
        display: grid;
        grid-template-columns: 1fr 1fr 1fr;
        gap: 2rem;
        margin-bottom: 3rem;
    }

    .chart-section {
        background: white;
        border-radius: 16px;
        padding: 2rem;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
        text-align: center;
    }

    .chart-title {
        font-size: 1.3rem;
        font-weight: 600;
        color: #222;
        margin-bottom: 1.5rem;
    }

    .chart-container {
        display: flex;
        justify-content: center;
        margin-bottom: 1rem;
    }

    .chart-legend {
        display: flex;
        justify-content: center;
        gap: 1.5rem;
        flex-wrap: wrap;
    }

    .legend-item {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        font-size: 0.9rem;
        color: #666;
    }

    .legend-color {
        width: 16px;
        height: 16px;
        border-radius: 50%;
    }

    .button-section {
        background: white;
        border-radius: 16px;
        padding: 2rem;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
    }

    .button-title {
        font-size: 1.3rem;
        font-weight: 600;
        color: #222;
        margin-bottom: 1.5rem;
    }

    .update-button {
        width: 100%;
        padding: 1rem 2rem;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border: none;
        border-radius: 12px;
        font-size: 1rem;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 0.5rem;
    }

    .update-button:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
    }

    .update-button:active {
        transform: translateY(0);
    }

    .button-description {
        margin-top: 1rem;
        padding: 1rem;
        background: #f8f9fa;
        border-radius: 8px;
        color: #666;
        font-size: 0.9rem;
        line-height: 1.5;
    }

    @media (max-width: 768px) {
        .manage-content {
            grid-template-columns: 1fr;
            gap: 2rem;
        }

        .manage-container {
            padding: 100px 1rem 2rem;
        }
    }

    @media (max-width: 1200px) {
        .manage-content {
            grid-template-columns: 1fr 1fr;
            gap: 2rem;
        }
    }

    /* 도넛 차트 텍스트 스타일 */
    .chart-text {
        font-family: 'Arial', sans-serif;
        text-align: center;
        text-baseline: middle;
    }

    .chart-percentage {
        font-weight: bold;
        font-size: 12px;
        color: #333;
    }

    .chart-total {
        font-weight: bold;
        font-size: 20px;
        color: #333;
    }

    /* 막대그래프 범례 스타일 */
    .chart-legend {
        margin-top: 1rem;
        display: flex;
        flex-wrap: wrap;
        gap: 0.5rem;
        justify-content: center;
    }

    .legend-item {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        padding: 0.25rem 0.5rem;
        background: rgba(255, 255, 255, 0.8);
        border-radius: 4px;
        font-size: 0.875rem;
        color: #333;
    }

    .legend-color {
        width: 16px;
        height: 16px;
        border-radius: 50%;  /* 동그라미 모양 */
        border: 1px solid #ddd;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);  /* 도넛차트와 비슷한 그림자 */
    }

    .legend-text {
        font-weight: 500;
    }
</style>
<!-- Main Content -->
<div class="manage-container">
    <div class="manage-header">
        <h1 class="manage-title">관리 페이지</h1>
        <p class="manage-subtitle">시스템 현황을 한눈에 확인하고 관리하세요</p>
    </div>

    <div class="manage-content">
        <!-- 도넛 차트 섹션 -->
        <div class="chart-section">
            <h2 class="chart-title">회원 가입 플랫폼 현황</h2>
            <div class="chart-container">
                <canvas id="donutChart" width="250" height="250"></canvas>
            </div>
            <div class="chart-legend">
                <div class="legend-item">
                    <div class="legend-color" style="background: #FEE500;"></div>
                    <span>카카오 회원</span>
                </div>
                <div class="legend-item">
                    <div class="legend-color" style="background: #03C75A;"></div>
                    <span>네이버 회원</span>
                </div>
                <div class="legend-item">
                    <div class="legend-color" style="background: linear-gradient(to bottom, #8B5CF6, #667eea);"></div>
                    <span>자사 계정 회원</span>
                </div>
            </div>
        </div>

        <!-- 즐겨찾기 휴게소 TOP 5 막대그래프 섹션 -->
        <div class="chart-section">
            <h2 class="chart-title">즐겨찾기 휴게소 TOP 5</h2>
            <div class="chart-container">
                <canvas id="barChart" width="250" height="250"></canvas>
            </div>
            <div class="chart-legend" id="barChartLegend">
                <!-- 범례가 동적으로 생성됩니다 -->
            </div>
            <%--                <div class="chart-description">--%>
            <%--                    <i class="fas fa-heart"></i>--%>
            <%--                    사용자들이 가장 많이 즐겨찾기한 휴게소 순위입니다.--%>
            <%--                </div>--%>
        </div>

        <!-- 버튼 섹션 -->
        <div class="button-section">
            <h2 class="button-title">데이터 업데이트</h2>
            <form method="post" action="Controller">
                <input type="hidden" name="type" value="initSARA">
                <button type="submit" class="update-button">
                    <i class="fas fa-sync-alt"></i>
                    휴게소, 입점업체 목록 업데이트
                </button>
            </form>
            <div class="button-description">
                <i class="fas fa-info-circle"></i>
                최신 휴게소 정보와 입점업체 정보를 데이터베이스에 반영합니다.
                업데이트는 수 분 정도 소요될 수 있습니다.
            </div>

            <%--** 음식메뉴 정보 버튼 추가 **--%>
            <form id= "updateFoodForm" method="post" action="Controller" style="margin-top: 1rem;">
                <input type="hidden" name="type" value="updateFoodMenu">
                <button type="submit" class="update-button">
                    <i class="fas fa-sync-alt"></i>
                    음식메뉴 정보 업데이트
                </button>
            </form>
            <div class="button-description">
                <i class="fas fa-info-circle"></i>
                최신 음식메뉴 정보를 데이터베이스에 반영합니다.
                업데이트는 수 분 정도 소요될 수 있습니다.
            </div>
        </div>
    </div>
</div>


<script>
    // ========================================
    // 도넛 차트 그리기 함수 (순차적 애니메이션)
    // ========================================
    //
    // 호출 경로:
    // 1. 페이지 로드 → DOMContentLoaded 이벤트
    // 2. fetchMemberData() → AJAX로 데이터 가져옴
    // 3. drawDonutChartWithAnimation() → 차트 그리기 시작
    //
    // 매개변수:
    // - canvasId: HTML의 canvas 요소 ID ('donutChart')
    // - data: 서버에서 받아온 배열 [카카오수, 네이버수, 자사계정수]
    // - colors: 각 조각별 색상 배열 ['#FEE500', '#03C75A', '#8B5CF6']
    function drawDonutChartWithAnimation(canvasId, data, colors) {
        // ========================================
        // 1. 캔버스 초기화 및 기본 설정
        // ========================================
        const canvas = document.getElementById(canvasId);  // HTML의 canvas 요소 가져오기
        const ctx = canvas.getContext('2d');             // 2D 그리기 컨텍스트 생성
        const total = data.reduce((a, b) => a + b, 0);  // 전체 회원 수 계산 (예: 156)

        // 캔버스 중심점 계산 (250x250 캔버스 기준)
        const centerX = canvas.width / 2;   // 125
        const centerY = canvas.height / 2;  // 125

        // 도넛 차트 크기 설정
        const radius = 100;       // 바깥쪽 반지름 (도넛 두께의 바깥 경계)
        const innerRadius = 50;   // 안쪽 반지름 (도넛 두께의 안쪽 경계)

        // ========================================
        // 2. 애니메이션 타이밍 설정
        // ========================================
        const durationPerSlice = 800;                    // 각 조각당 애니메이션 시간 (밀리초)
        const startTime = performance.now();             // 애니메이션 시작 시점 (타임스탬프)

        // ========================================
        // 3. 각 조각의 각도 정보 미리 계산
        // ========================================
        const sliceAngles = [];                          // 각 조각의 시작/끝 각도를 저장할 배열
        let currentAngle = -Math.PI / 2;                 // 12시 방향에서 시작 (-90도)

        // 각 데이터 값에 따라 도넛 조각의 각도 계산
        for (let i = 0; i < data.length; i++) {
            // 현재 조각이 차지할 각도 계산 (라디안 단위)
            const sliceAngle = (data[i] / total) * 2 * Math.PI;

            // 조각 정보를 객체로 저장
            sliceAngles.push({
                start: currentAngle,                     // 조각 시작 각도
                end: currentAngle + sliceAngle           // 조각 끝 각도
            });

            currentAngle += sliceAngle;                  // 다음 조각 시작 각도로 이동
        }

        // 애니메이션 프레임 그리기
        function drawFrame() {
            const elapsed = performance.now() - startTime;

            // 캔버스 지우기
            ctx.clearRect(0, 0, canvas.width, canvas.height);

            // 각 조각 그리기
            for (let i = 0; i < sliceAngles.length; i++) {
                const slice = sliceAngles[i];

                // 현재 조각의 시작 시간과 진행률
                const sliceStartTime = i * durationPerSlice;
                const sliceElapsed = elapsed - sliceStartTime;
                const progress = Math.max(0, Math.min(sliceElapsed / durationPerSlice, 1));

                // 현재 그려야 할 끝 각도
                const currentEnd = slice.start + (slice.end - slice.start) * progress;

                // 도넛 조각 그리기
                ctx.beginPath();
                ctx.arc(centerX, centerY, radius, slice.start, currentEnd);
                ctx.arc(centerX, centerY, innerRadius, currentEnd, slice.start, true);
                ctx.closePath();

                // 색상 설정 (3번째 아이템만 그라데이션)
                if (i === 2) {
                    const grad = ctx.createLinearGradient(centerX, centerY - radius, centerX, centerY + radius);
                    grad.addColorStop(0, '#8B5CF6');   // 보라색
                    grad.addColorStop(1, '#667eea');   // 파란색
                    ctx.fillStyle = grad;
                } else {
                    ctx.fillStyle = colors[i];
                }

                ctx.fill();

                // 각 조각 안에 퍼센티지 텍스트 표시 (애니메이션 완료 후에만)
                if (progress >= 1) {
                    const sliceCenterAngle = slice.start + (slice.end - slice.start) / 2;
                    const textRadius = (radius + innerRadius) / 2; // 텍스트 위치 (중간 반지름)
                    const textX = centerX + textRadius * Math.cos(sliceCenterAngle);
                    const textY = centerY + textRadius * Math.sin(sliceCenterAngle);

                    // 텍스트 스타일 설정
                    ctx.fillStyle = '#333'; // 텍스트 색상
                    ctx.font = 'bold 12px Arial'; // 폰트
                    ctx.textAlign = 'center'; // 가운데 정렬
                    ctx.textBaseline = 'middle'; // 세로 가운데 정렬

                    // 퍼센티지 계산 및 표시
                    const percentage = Math.round((slice.end - slice.start) / (2 * Math.PI) * 100);
                    ctx.fillText(percentage + '%', textX, textY);
                }
            }

            // ========================================
            // 4-4. 애니메이션 완료 후 추가 요소 표시
            // ========================================

            // 전체 애니메이션 지속 시간 계산
            const totalDuration = sliceAngles.length * durationPerSlice;  // 3 * 800 = 2400ms

            // ========================================
            // 4-4-1. 가운데 빈 공간에 총 합계 표시
            // ========================================
            // 모든 조각의 애니메이션이 완료되었는지 확인
            const allCompleted = elapsed >= totalDuration;
            if (allCompleted) {
                console.log('애니메이션 완료! Total 표시:', total);

                // CSS 클래스 스타일 적용
                ctx.fillStyle = '#333';              // 텍스트 색상
                ctx.font = 'bold 20px Arial';       // 폰트 설정
                ctx.textAlign = 'center';           // 가로 가운데 정렬
                ctx.textBaseline = 'middle';        // 세로 가운데 정렬

                // "Total" 라벨과 총 회원 수를 가운데 표시
                ctx.fillText('Total', centerX, centerY - 10);      // 위쪽에 "Total"
                ctx.fillText(total.toString(), centerX, centerY + 10);  // 아래쪽에 숫자
            }

            // ========================================
            // 4-5. 다음 프레임 요청 여부 결정
            // ========================================
            // 애니메이션이 끝나지 않았다면 다음 프레임 요청
            if (elapsed < totalDuration) {
                requestAnimationFrame(drawFrame);  // 60fps로 부드러운 애니메이션
            }
        }

        // ========================================
        // 5. 애니메이션 시작
        // ========================================
        // requestAnimationFrame으로 첫 프레임 요청
        // 이후 drawFrame 함수 내에서 연쇄적으로 다음 프레임 요청
        requestAnimationFrame(drawFrame);
    }

    // ========================================
    // 6. AJAX로 서버에서 회원 데이터 가져오기
    // ========================================
    //
    // 호출 경로:
    // 1. DOMContentLoaded 이벤트 발생
    // 2. fetchMemberData() 함수 호출
    // 3. POST /Controller?type=getStatus 요청
    // 4. getStatusAction에서 DB 조회 후 JSON 응답
    // 5. 응답 데이터를 배열로 반환
    async function fetchMemberData() {
        try {
            // ========================================
            // 6-1. 서버에 HTTP POST 요청
            // ========================================
            const response = await fetch('Controller', {
                method: 'POST',
                // Content-Type은 기본값 application/x-www-form-urlencoded 사용
                // 별도 headers 설정 불필요

                // POST 데이터: type과 chartType을 URLSearchParams로 전송
                body: new URLSearchParams({
                    type: 'getStatus',        // Controller에서 getStatusAction 호출
                    chartType: 'donut'        // 향후 확장을 위한 구분자 (현재 미사용)
                })
            });

            // ========================================
            // 6-2. HTTP 응답 상태 확인
            // ========================================
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }

            // ========================================
            // 6-3. JSON 응답 데이터 파싱
            // ========================================
            const data = await response.json();  // [카카오수, 네이버수, 자사계정수]
            console.log('가져온 회원 데이터:', data);
            return data;

        } catch (error) {
            // ========================================
            // 6-4. 에러 처리 및 기본값 반환
            // ========================================
            console.error('데이터 가져오기 실패:', error);
            // 네트워크 오류 시 기본 데이터로 차트 표시
            return [1, 1, 1];
        }
    }

    // 막대그래프(즐겨찾기한 휴게소들) 데이터 가져오기
    async function fetchBookMarkData() {
        try {
            // ========================================
            // 6-1. 서버에 HTTP POST 요청
            // ========================================
            const response = await fetch('Controller', {
                method: 'POST',
                // Content-Type은 기본값 application/x-www-form-urlencoded 사용
                // 별도 headers 설정 불필요

                // POST 데이터: type과 chartType을 URLSearchParams로 전송
                body: new URLSearchParams({
                    type: 'getStatus',        // Controller에서 getStatusAction 호출
                    chartType: 'bar'        // 구분자 - 막대그래프
                })
            });

            // ========================================
            // 6-2. HTTP 응답 상태 확인
            // ========================================
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }

            // ========================================
            // 6-3. JSON 응답 데이터 파싱
            // ========================================
            const data = await response.json();  // [{name: '시흥', count: 10}, {},...]
            console.log('가져온 회원 데이터:', data);
            return data;

        } catch (error) {
            // ========================================
            // 6-4. 에러 처리 및 기본값 반환
            // ========================================
            console.error('데이터 가져오기 실패:', error);
            // 네트워크 오류 시 기본 데이터로 차트 표시
            return [
                {name: '휴게소A', count: 15},
                {name: '휴게소B', count: 15},  // 같은 즐겨찾기 수
                {name: '휴게소C', count: 15},
                {name: '휴게소D', count: 12},
                {name: '휴게소E', count: 11},
                {name: '휴게소F', count: 10}
            ];
        }
    }

    // ========================================
    // 7. 막대그래프 그리기 함수 (즐겨찾기 휴게소 TOP 5)
    // ========================================
    //
    // 매개변수:
    // - canvasId: HTML의 canvas 요소 ID ('barChart')
    // - data: 서버에서 받아온 배열 [{name: '휴게소A', count: 45}, {name: '휴게소B', count: 45}, ...]
    // - colors: 각 휴게소별 색상 배열
    function drawBarChart(canvasId, data, colors) {
        const canvas = document.getElementById(canvasId);
        const ctx = canvas.getContext('2d');

        // ========================================
        // 7-1. 캔버스 설정 및 기본 변수
        // ========================================
        const canvasWidth = canvas.width;
        const canvasHeight = canvas.height;
        const padding = 40;  // 여백
        const chartWidth = canvasWidth - (padding * 2);
        const chartHeight = canvasHeight - (padding * 2);

        // ========================================
        // 7-2. 데이터는 이미 그룹화되어 전달됨
        // ========================================
        // data는 이미 그룹화된 형태: [{count: 15, names: ['휴게소A', '휴게소B'], itemCount: 2}, ...]

        // ========================================
        // 7-3. 막대그래프 크기 계산
        // ========================================
        const maxValue = Math.max(...data.map(item => item.count));  // 최대값
        const barWidth = chartWidth / data.length;  // 막대 너비
        const barSpacing = 10;  // 막대 간격

        // ========================================
        // 7-4. 막대그래프 그리기
        // ========================================
        ctx.clearRect(0, 0, canvasWidth, canvasHeight);

        // 각 막대 그리기
        data.forEach((group, index) => {
            const barHeight = (group.count / maxValue) * chartHeight;
            const x = padding + (index * barWidth) + (barSpacing / 2);
            const y = canvasHeight - padding - barHeight;

            // 각 막대마다 고유한 색상 적용
            ctx.fillStyle = colors[index];
            ctx.fillRect(x, y, barWidth - barSpacing, barHeight);

            // 막대 위에 수치만 표시
            ctx.fillStyle = '#333';
            ctx.font = 'bold 12px Arial';
            ctx.textAlign = 'center';
            ctx.fillText(group.count.toString(), x + (barWidth - barSpacing) / 2, y - 10);
        });

        // Y축 눈금 그리기
        ctx.strokeStyle = '#ddd';
        ctx.lineWidth = 1;
        for (let i = 0; i <= 5; i++) {
            const y = padding + (i * chartHeight / 5);
            ctx.beginPath();
            ctx.moveTo(padding, y);
            ctx.lineTo(canvasWidth - padding, y);
            ctx.stroke();

            // Y축 값 표시
            const value = Math.round((maxValue / 5) * (5 - i));
            ctx.fillStyle = '#999';
            ctx.font = '10px Arial';
            ctx.textAlign = 'right';
            ctx.fillText(value.toString(), padding - 5, y + 3);
        }
    }

    // ========================================
    // 8. 막대별 고유 색상 생성 함수
    // ========================================
    // 막대그래프의 각 막대마다 고유한 색상을 생성
    // 매개변수:
    // - count: 필요한 색상 개수
    function generateColors(count) {
        // 5개 막대를 위한 고유한 색상 배열
        const baseColors = [
            '#667eea',  // 파란색
            '#8B5CF6',  // 보라색
            '#F59E0B',  // 주황색
            '#10B981',  // 초록색
            '#EF4444'   // 빨간색
        ];
        
        const colors = [];
        for (let i = 0; i < count; i++) {
            colors.push(baseColors[i % baseColors.length]);
        }

        console.log(count + '개의 고유 색상 생성:', colors);
        return colors;
    }

    // ========================================
    // 9. 범례 생성 함수 (색상별 그룹화)
    // ========================================
    function createBarChartLegend(data, colors) {
        const legendContainer = document.getElementById('barChartLegend');
        legendContainer.innerHTML = '';

        // 디버깅을 위한 로그
        console.log('범례 생성 데이터:', data);
        console.log('범례 생성 색상:', colors);

        // 색상별로 데이터 그룹화
        const colorGroups = {};
        data.forEach((group, index) => {
            const color = colors[index];
            if (!colorGroups[color]) {
                colorGroups[color] = [];
            }
            // group.names 배열의 모든 이름을 추가
            colorGroups[color].push(...group.names);
        });

        // 각 색상 그룹별로 범례 생성
        Object.keys(colorGroups).forEach(color => {
            const legendGroup = document.createElement('div');
            legendGroup.className = 'legend-group';
            legendGroup.style.marginBottom = '1rem';
            legendGroup.style.textAlign = 'center';

            // 색상 표시
            const colorIndicator = document.createElement('div');
            colorIndicator.className = 'legend-color';
            colorIndicator.style.background = color;
            colorIndicator.style.margin = '0 auto 0.5rem auto';
            legendGroup.appendChild(colorIndicator);

            // 해당 색상에 속하는 모든 레이블 표시
            colorGroups[color].forEach(name => {
                const label = document.createElement('div');
                label.className = 'legend-label';
                label.textContent = name;
                label.style.fontSize = '0.8rem';
                label.style.color = '#666';
                label.style.marginBottom = '0.25rem';
                legendGroup.appendChild(label);
            });

            legendContainer.appendChild(legendGroup);
        });
    }

    // ========================================
    // 9. 페이지 로드 시 메인 실행 로직
    // ========================================
    //
    // 실행 흐름:
    // 1. HTML 페이지 로드 완료
    // 2. DOMContentLoaded 이벤트 발생
    // 3. fetchMemberData() 호출하여 서버 데이터 가져오기
    // 4. 받은 데이터로 도넛 차트 애니메이션 시작
    // 5. 막대그래프 그리기 (임시 데이터로)
    // 6. 범례 생성
    document.addEventListener('DOMContentLoaded', async function() {
        // ========================================
        // 9-1. 서버에서 실제 회원 통계 데이터 가져오기
        // ========================================
        const memberData = await fetchMemberData();  // [카카오수, 네이버수, 자사계정수]

        // ========================================
        // 9-2. 각 조각별 색상 정의
        // ========================================
        const colors = [
            '#FEE500',  // 카카오 (노란색)
            '#03C75A',  // 네이버 (초록색)
            '#8B5CF6'   // 자사계정 (보라색, 그라데이션으로 처리됨)
        ];

        // ========================================
        // 9-3. 도넛 차트 애니메이션 시작
        // ========================================
        // canvas ID, 데이터 배열, 색상 배열을 전달하여 차트 그리기 시작
        drawDonutChartWithAnimation('donutChart', memberData, colors);

        // ========================================
        // 9-4. 막대그래프 그리기 (임시 데이터로)
        // ========================================
        // 나중에 DB에서 실제 데이터를 가져올 예정
        // 같은 즐겨찾기 수를 가진 휴게소들이 있을 수 있음
        // 임시 데이터로 막대그래프 테스트
        // const favoriteData = [
        //     {name: '휴게소A', count: 45},
        //     {name: '휴게소B', count: 45},  // 같은 즐겨찾기 수
        //     {name: '휴게소C', count: 38},
        //     {name: '휴게소D', count: 32},
        //     {name: '휴게소E', count: 28},
        //     {name: '휴게소F', count: 25}
        // ];
        const favoriteData = await fetchBookMarkData();

        // ========================================
        // 9-5. 막대그래프용 고유 색상 생성
        // ========================================
        // favoriteData로부터 그룹화된 데이터 생성
        const sortedData = [];
        const uniqueCounts = [...new Set(favoriteData.map(item => item.count))].sort((a, b) => b - a).slice(0, 5);
        
        uniqueCounts.forEach(count => {
            const itemsWithSameCount = favoriteData.filter(item => item.count === count);
            sortedData.push({
                count: count,
                names: itemsWithSameCount.map(item => item.name),
                itemCount: itemsWithSameCount.length
            });
        });

        // 그룹화된 데이터 개수만큼 고유한 색상을 생성
        const barChartColors = generateColors(sortedData.length);

        drawBarChart('barChart', sortedData, barChartColors);
        createBarChartLegend(sortedData, barChartColors);

        // **** 음식 메뉴 업데이트 후 페이지 이동 ****
        document.getElementById('updateFoodForm').addEventListener('submit', async function(e) {
            // 1. form의 기본 동작(페이지 새로고침)을 막습니다.
            e.preventDefault();

            // 간단한 확인창을 띄워 사용자에게 알림
            //alert('메뉴 업데이트를 시작합니다. 작업이 완료되면 페이지가 새로고침됩니다.');

            try {
                // 2. 서버에 비동기 요청을 보냅니다.
                const formData = new FormData(this);
                await fetch('Controller', {
                    method: 'POST',
                    body: new URLSearchParams(formData)
                });

                // 3. fetch 요청이 끝나면 (성공/실패 여부와 상관없이) 페이지를 이동시킵니다.
                location.href = 'Controller?type=manage'; // Controller를 통해 manage.jsp로 이동

            } catch (error) {
                // 4. 네트워크 에러 등 요청 자체가 실패한 경우
                alert('요청에 실패했습니다: ' + error.message);
            }
        }); // --- 음식 메뉴 업데이트 후 페이지 이동 처리 끝 ---
    });
</script>