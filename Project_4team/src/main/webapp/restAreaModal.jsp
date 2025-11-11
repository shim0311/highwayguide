<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<div id="restAreaModal" class="modal">
  <div class="modal-content">

    <div class="modal-header">
      <div class="modal-title">
        <i class="fas fa-utensils"></i>
        <span id="modalTitle">휴게소 정보</span>
      </div>
      <div class="header-icons">
        <div id="modalStarRating" class="star-rating">
          <span id="starIconContainer"></span>
          <span id="starText"></span>
        </div>
        <span id="bookmarkIcon" class="bookmark-icon">
  <i class="far fa-heart"></i>
  <span class="tooltip-text">즐겨찾기 추가</span>
  </span>
      </div>
      <span class="close">&times;</span>
    </div>

    <div class="modal-body">
      <div class="info-section">
        <div class="info-label">
          <i class="fas fa-map-marker-alt"></i>
          위치
        </div>
        <div class="info-value" id="modalLocation">
          정보를 불러오는 중...
        </div>
      </div>

      <div class="info-section">
        <div class="info-label">
          <i class="fas fa-phone"></i>
          연락처
        </div>
        <div class="info-value" id="modalPhone">
          정보를 불러오는 중...
        </div>
      </div>

      <div class="info-section ai-comment-section">
        <div class="info-label">
          <i class="fas fa-robot"></i>
          AI 추천 코멘트
        </div>
        <div class="ai-comment-box" id="modalAiComment">
          AI 코멘트를 불러오는 중...
        </div>
      </div>

      <div class="info-section">
        <div class="info-label">
          <i class="fas fa-parking"></i>
          주차 정보
        </div>
        <div class="parking-info-grid">
          <div class="parking-item">
            <span class="parking-label">소형차</span>
            <span class="parking-value" id="modalCompactParking">-</span>
          </div>
          <div class="parking-item">
            <span class="parking-label">대형차</span>
            <span class="parking-value" id="modalLargeParking">-</span>
          </div>
          <div class="parking-item">
            <span class="parking-label">장애인</span>
            <span class="parking-value" id="modalDisabledParking">-</span>
          </div>
        </div>
      </div>

      <div class="info-section">
        <div class="info-label">
          <i class="fas fa-gas-pump"></i>
          주유 가격
        </div>
        <div class="gas-info-grid">
          <div class="gas-item">
            <span class="gas-label">휘발유</span>
            <span class="gas-value" id="modalGasoline">-</span>
          </div>
          <div class="gas-item">
            <span class="gas-label">경유</span>
            <span class="gas-value" id="modalDiesel">-</span>
          </div>
          <div class="gas-item">
            <span class="gas-label">LPG</span>
            <span class="gas-value" id="modalLpg">-</span>
          </div>
        </div>
      </div>

      <div class="info-section">
        <div class="info-label">
          <i class="fas fa-clock"></i>
          운영시간
        </div>
        <div class="info-value" id="modalHours">
          24시간 운영
        </div>
      </div>

      <div class="info-section">
        <div class="info-label">
          <i class="fas fa-list"></i>
          편의시설
        </div>
        <div class="facilities-list" id="modalFacilities">
        </div>
      </div>

      <div class="info-section">
        <div class="info-label">
          <i class="fas fa-info-circle"></i>
          안내사항
        </div>
        <div class="info-value">
          • 안전한 운전을 위해 충분한 휴식을 취하세요<br>
          • 긴급상황 시 1588-2504로 연락하세요<br>
          • 휴게소 내에서는 안전수칙을 준수해주세요
        </div>
        <div class="modal-button-container">
          <button id="showStoresBtn" class="modal-btn">
            <i class="fas fa-store"></i>
            매장 정보 확인
          </button>
        </div>
      </div>
    </div>
    <%-- ▲▲▲ 모달 바디 종료 ▲▲▲ --%>

  </div> <%-- modal-content 종료 --%>
</div> <%-- restAreaModal 종료 --%>


<%-- ========================================================== --%>
<%-- =============== 두 번째 모달: 매장 정보 =============== --%>
<%-- ========================================================== --%>
<div id="storesModal" class="modal" style="display: none;">
  <div class="modal-content">
    <div class="modal-header">
      <div class="modal-title">
        <i class="fas fa-store"></i>
        <span id="storesModalTitle"></span>
      </div>
      <span class="close">&times;</span>
    </div>
    <div class="modal-body">
      <div class="search-and-list-container">
        <div class="store-search-container">
          <input type="text" id="storeSearchInput" placeholder="매장 이름 검색">
          <button id="storeSearchBtn">검색</button>
        </div>
        <div class="store-list" id="storeList">
        </div>
      </div>
    </div>
  </div>
</div>