<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%--한글 인코딩 삭제했는데 이상이 다음 버전까지 이상없으면 삭제한 상태 유지--%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>휴게소 정보</title>

    <!-- 폰트 및 아이콘 -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/restareaStyle.css">

    <jsp:include page="restAreaModal.jsp"/>


    <!-- CSS 파일 링크 -->
    <link href="${pageContext.request.contextPath}/css/restareaStyle.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/indexStyle.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/footerStyle.css" rel="stylesheet">

    <!-- cctv 비디오 재생기능 -->
    <link href="https://vjs.zencdn.net/8.6.1/video-js.css" rel="stylesheet"/>
    <script src="https://vjs.zencdn.net/8.6.1/video.min.js"></script>
    <script src="https://unpkg.com/@videojs/http-streaming@3.5.0/dist/videojs-http-streaming.min.js"></script>
    <!-- jQuery 추가 -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

    <style>
        /* 모달 창을 위한 CSS - 공통 스타일 */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgb(0,0,0);
            background-color: rgba(0,0,0,0.4);
        }
        .close {
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
        }
        .close:hover,
        .close:focus {
            color: black;
            text-decoration: none;
            cursor: pointer;
        }

        /* 휴게소 상세 정보 모달 스타일 */
        #restAreaModal .modal-content {
            background-color: #fefefe;
            margin: 15% auto;
            padding: 20px;
            border: 1px solid #888;
            width: 80% !important;
            max-width: 500px !important;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            box-sizing: border-box;
        }

        /* CCTV 영상 모달 스타일 */
        #cctvModal .modal-content {
            background-color: #fefefe;
            margin: 15% auto;
            padding: 20px;
            border: 1px solid #888;
            width: 80% !important;
            max-width: 1800px !important;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            box-sizing: border-box;
        }

        .cctv-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 15px;
            margin-top: 20px;
        }
        @media (min-width: 1170px) {
            .cctv-grid {
                grid-template-columns: repeat(3, 1fr);
            }
        }
        .video-container {
            border: 1px solid #ddd;
            border-radius: 8px;
            overflow: hidden;
            background-color: #000;
            position: relative;
            height: 390px;
        }
        .video-container video, .video-container .video-error {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .video-container span {
            position: absolute;
            bottom: 0;
            left: 0;
            width: 100%;
            background: rgba(0, 0, 0, 0.5);
            color: white;
            padding: 5px;
            text-align: center;
            font-size: 0.8em;
            word-break: break-all;
        }
        .video-error {
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            background-color: #333;
            text-align: center;
        }
        .no-rest-areas {
            text-align: center;
            margin-top: 50px;
            color: #666;
            font-size: 1.2em;
        }
    </style>

</head>
<body>
<%@ include file="header.jsp" %>
<div class="main-container"> <%-- 메인 --%>
    <div class="page-title fade-in"> <%-- 제목  --%>
        <h1><i class="fas fa-map-marked-alt"></i> 경로상 휴게시설 정보</h1>
        <p>휴게소와 졸음쉼터 정보를 확인하세요</p>
    </div>


    <!-- 경로 정보 표시 -->
    <c:if test="${not empty origin and not empty destination}">
        <div class="route-info">
            <div class="route-item">
                <i class="fas fa-map-marker-alt start-icon"></i>
                <span class="route-label">출발지:</span>
                <span class="route-value">${origin}</span>
            </div>
            <div class="route-item">
                <i class="fas fa-map-marker-alt end-icon"></i>
                <span class="route-label">목적지:</span>
                <span class="route-value">${destination}</span>
            </div>
            <div class="route-item">
                <i class="fas fa-road detail-icon"></i>
                <span class="route-label">전체거리:</span>
                <span class="route-value">
                        <c:choose>
                            <c:when test="${not empty distance}">
                                <fmt:formatNumber value="${distance / 1000}" pattern="#,##0.0"/>km
                            </c:when>
                            <c:otherwise>정보 없음</c:otherwise>
                        </c:choose>
                    </span>
            </div>
            <div class="route-item">
                <i class="fas fa-clock detail-icon"></i>
                <span class="route-label">소요시간:</span>
                <span class="route-value">
                        <c:choose>
                            <c:when test="${not empty duration}">
                                <c:set var="totalHours" value="${duration / 3600}"/>
                                <c:set var="hours" value="${totalHours.intValue()}"/>
                                <c:set var="totalMinutes" value="${(duration % 3600) / 60}"/>
                                <c:set var="minutes" value="${totalMinutes.intValue()}"/>
                                <c:if test="${hours > 0}">${hours}시간</c:if>
                                <c:if test="${minutes > 0}">${minutes}분</c:if>
                            </c:when>
                            <c:otherwise>정보 없음</c:otherwise>
                        </c:choose>
                    </span>
            </div>
            <div class="route-item">
                <i class="fas fa-money-bill-wave detail-icon"></i>
                <span class="route-label">통행료:</span>
                <span class="route-value">
                        <c:choose>
                            <c:when test="${not empty tollFare and tollFare > 0}">
                                <fmt:formatNumber value="${tollFare}" pattern="#,##0"/>원
                            </c:when>
                            <c:otherwise>무료</c:otherwise>
                        </c:choose>
                    </span>
            </div>
        </div> <%--  요약정보  --%>
    </c:if>
    <!-- 휴게시설 목록 -->
    <div class="info-card slide-up">
        <div class="card-header">
            <div class="card-icon">
                <i class="fas fa-route"></i>
            </div>
            <div class="card-title">휴게시설</div>
            <button class="only-sa" onclick="toggleRestStops(this)">
                <i class="fas fa-bed button-icon"></i>
                <span class="button-text">졸음쉼터 표시</span>
            </button>
        </div> <!-- 카드헤더 -->
        <c:choose>
            <c:when test="${not empty allRestAreas}">
                <div class="rest-areas-list">
                    <c:forEach var="restArea" items="${allRestAreas}" varStatus="status">
                        <c:set var="serviceAreaVO" value="${serviceAreaVOs[restArea]}"/>
                        <c:set var="currentSaKey" value="${serviceAreaVO.idx}"/>
                        <div class="rest-area-card clickable ${restArea.contains('휴게소') ? 'service-area' : 'rest-stop'}"
                             data-sakey="${currentSaKey}">
                            <div class="rest-area-info-row">
                                <!-- 휴게시설명 섹션 -->
                                <div class="rest-area-name-section">
                                    <div class="rest-area-name">
                                        <span class="facility-name"><c:out value="${restArea}"/></span>
                                        <c:if test="${restArea.contains('휴게소')}">
                                            <c:choose>
                                                <c:when test="${not empty sessionScope.loginUser}">
                                                    <!-- 로그인된 사용자: 즐겨찾기 기능 활성화 -->
                                                    <c:set var="isBookmarked" value="false"/>
                                                    <c:if test="${not empty sessionScope.bookmarkedSaKeys}">
                                                        <c:forEach var="bookmarkedSaKey"
                                                                   items="${sessionScope.bookmarkedSaKeys}">
                                                            <c:if test="${bookmarkedSaKey eq currentSaKey}">
                                                                <c:set var="isBookmarked" value="true"/>
                                                            </c:if>
                                                        </c:forEach>
                                                    </c:if>

                                                    <i class="fas fa-heart bookmark-heart heart-icon ${isBookmarked ? 'bookmarked' : ''}"
                                                       onclick="toggleBookmark('${currentSaKey}', this)"
                                                       title="즐겨찾기 추가/제거"></i>
                                                </c:when>
                                                <c:otherwise>
                                                    <!-- 로그인되지 않은 사용자: 로그인 페이지로 이동 -->
                                                    <i class="fas fa-heart bookmark-heart not-logged-in"
                                                       onclick="redirectToLogin()"
                                                       title="로그인이 필요합니다"></i>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:if>
                                    </div>
                                    <c:if test="${restArea.contains('휴게소')}">
                                        <div class="icon-item cctv-icon"
                                             onclick="openCctvModal('${serviceAreaVO.lat}', '${serviceAreaVO.lng}')"
                                             title="CCTV">
                                            <i class="fas fa-video"></i>
                                            <span>CCTV</span>
                                        </div>
                                        <div class="icon-item review-icon"
                                             onclick="location.href='${pageContext.request.contextPath}/Controller?type=review&search=${serviceAreaVO.SAName}'"
                                             title="리뷰보기">
                                            <i class="fas fa-comments"></i>
                                            <span>리뷰</span>
                                        </div>
                                    </c:if>
                                    <c:if test="${restArea.contains('휴게소')}">
                                        <div class="rest-area-rating">
                                            <span class="rating-label">별점</span>
                                            <div class="stars">
                                                <c:choose>
                                                    <c:when test="${not empty serviceAreaVO and not empty serviceAreaVO.star and serviceAreaVO.star != '0' and serviceAreaVO.star != '0.0'}">
                                                        <!-- 노란별 하나만 표시 -->
                                                        <i class="fas fa-star star filled"></i>
                                                        <!-- 소수점 2자리까지 점수 표시 -->
                                                        <span class="rating-score"><fmt:formatNumber
                                                                value="${serviceAreaVO.star}" pattern="#.##"/></span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <!-- 평가 없을 때는 회색 별 -->
                                                        <i class="fas fa-star star"></i>
                                                        <span class="rating-score">평가 없음</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </c:if>


                                    <!-- 소요시간 표시 -->
                                    <c:if test="${restArea.contains('휴게소')}">
                                        <c:set var="serviceAreaIndex" value="0"/>
                                        <c:forEach var="restAreaItem" items="${allRestAreas}" varStatus="itemStatus">
                                            <c:if test="${restAreaItem.contains('휴게소') and restAreaItem eq restArea}">
                                                <c:if test="${not empty serviceAreaOnlyDurations and serviceAreaIndex < serviceAreaOnlyDurations.size()}">
                                                    <div class="duration-info">
                                                        <i class="fas fa-clock duration-icon"></i>
                                                        <span class="duration-text">
                                                            <c:set var="duration"
                                                                   value="${serviceAreaOnlyDurations[serviceAreaIndex]}"/>
                                                            <c:set var="totalHours" value="${duration / 3600}"/>
                                                            <c:set var="hours" value="${totalHours.intValue()}"/>
                                                            <c:set var="totalMinutes"
                                                                   value="${(duration % 3600) / 60}"/>
                                                            <c:set var="minutes"
                                                                   value="${totalMinutes.intValue()}"/>
                                                            <c:choose>
                                                                <c:when test="${serviceAreaIndex == 0}">
                                                                    출발지부터 <c:if
                                                                        test="${hours > 0}">${hours}시간</c:if><c:if
                                                                        test="${minutes > 0}">${minutes}분</c:if>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    이전 휴게소부터 <c:if
                                                                        test="${hours > 0}">${hours}시간</c:if><c:if
                                                                        test="${minutes > 0}">${minutes}분</c:if>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </span>
                                                    </div>
                                                </c:if>
                                            </c:if>
                                            <c:if test="${restAreaItem.contains('휴게소')}">
                                                <c:set var="serviceAreaIndex" value="${serviceAreaIndex + 1}"/>
                                            </c:if>
                                        </c:forEach>
                                    </c:if>


                                    <!-- 졸음쉼터 소요시간 표시 -->
                                    <c:if test="${restArea.contains('졸음쉼터')}">
                                        <c:if test="${not empty allRestAreaDurations and status.index < allRestAreaDurations.size()}">
                                            <div class="duration-info">
                                                <i class="fas fa-clock duration-icon"></i>
                                                <span class="duration-text">
                                                    <c:set var="duration"
                                                           value="${allRestAreaDurations[status.index]}"/>
                                                    <c:set var="totalHours" value="${duration / 3600}"/>
                                                    <c:set var="hours" value="${totalHours.intValue()}"/>
                                                    <c:set var="totalMinutes"
                                                           value="${(duration % 3600) / 60}"/>
                                                    <c:set var="minutes"
                                                           value="${totalMinutes.intValue()}"/>
                                                    <c:choose>
                                                        <c:when test="${status.index == 0}">
                                                            출발지부터 <c:if
                                                                test="${hours > 0}">${hours}시간</c:if><c:if
                                                                test="${minutes > 0}">${minutes}분</c:if>
                                                        </c:when>
                                                        <c:otherwise>
                                                            이전 휴게시설부터 <c:if
                                                                test="${hours > 0}">${hours}시간</c:if><c:if
                                                                test="${minutes > 0}">${minutes}분</c:if>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </div>
                                        </c:if>
                                    </c:if>
                                </div>

                                <!-- 정보 섹션들 - 휴게소일 때만 표시 -->
                                <c:if test="${restArea.contains('휴게소')}">
                                    <div class="info-sections-row">
                                        <!-- 편의시설 섹션 -->
                                        <div class="content-section">
                                            <div class="section-title">
                                                <i class="fas fa-list"></i>
                                                편의시설
                                            </div>
                                            <div class="facilities-grid">
                                                <c:if test="${not empty serviceAreaVO and not empty serviceAreaVO.convenience}">
                                                    <c:forEach var="facility"
                                                               items="${serviceAreaVO.convenience.split(',')}"
                                                               varStatus="facilityStatus">
                                                        <c:choose>
                                                            <c:when test="${facility.contains('수유실')}">
                                                                <div class="facility-item">
                                                                    <i class="fas fa-baby facility-icon"></i>
                                                                    <span>수유실</span>
                                                                </div>
                                                            </c:when>
                                                            <c:when test="${facility.contains('약국')}">
                                                                <div class="facility-item">
                                                                    <i class="fas fa-first-aid facility-icon"></i>
                                                                    <span>약국</span>
                                                                </div>
                                                            </c:when>
                                                            <c:when test="${facility.contains('버스')}">
                                                                <div class="facility-item">
                                                                    <i class="fas fa-bus facility-icon"></i>
                                                                    <span>버스환승</span>
                                                                </div>
                                                            </c:when>
                                                            <c:when test="${facility.contains('ATM')}">
                                                                <div class="facility-item">
                                                                    <i class="fas fa-credit-card facility-icon"></i>
                                                                    <span>ATM</span>
                                                                </div>
                                                            </c:when>
                                                            <c:when test="${facility.contains('주유소')}">
                                                                <div class="facility-item">
                                                                    <i class="fas fa-gas-pump facility-icon"></i>
                                                                    <span>주유소</span>
                                                                </div>
                                                            </c:when>
                                                            <c:when test="${facility.contains('충전소')}">
                                                                <div class="facility-item">
                                                                    <i class="fas fa-charging-station facility-icon"></i>
                                                                    <span>충전소</span>
                                                                </div>
                                                            </c:when>
                                                            <c:when test="${facility.contains('음식점')}">
                                                                <div class="facility-item">
                                                                    <i class="fas fa-utensils facility-icon"></i>
                                                                    <span>음식점</span>
                                                                </div>
                                                            </c:when>
                                                            <c:when test="${facility.contains('편의점')}">
                                                                <div class="facility-item">
                                                                    <i class="fas fa-store facility-icon"></i>
                                                                    <span>편의점</span>
                                                                </div>
                                                            </c:when>
                                                            <c:when test="${facility.contains('수면실')}">
                                                                <div class="facility-item">
                                                                    <i class="fas fa-bed facility-icon"></i>
                                                                    <span>수면실</span>
                                                                </div>
                                                            </c:when>
                                                            <c:when test="${facility.contains('샤워실')}">
                                                                <div class="facility-item">
                                                                    <i class="fas fa-shower facility-icon"></i>
                                                                    <span>샤워실</span>
                                                                </div>
                                                            </c:when>
                                                            <c:when test="${facility.contains('세탁실')}">
                                                                <div class="facility-item">
                                                                    <i class="fas fa-tshirt facility-icon"></i>
                                                                    <span>세탁실</span>
                                                                </div>
                                                            </c:when>
                                                            <c:when test="${facility.contains('쉼터')}">
                                                                <div class="facility-item">
                                                                    <i class="fas fa-couch facility-icon"></i>
                                                                    <span>쉼터</span>
                                                                </div>
                                                            </c:when>
                                                            <c:when test="${facility.contains('화물차라운지')}">
                                                                <div class="facility-item">
                                                                    <i class="fas fa-truck facility-icon"></i>
                                                                    <span>화물차라운지</span>
                                                                </div>
                                                            </c:when>
                                                            <c:when test="${facility.contains('내고장특산물')}">
                                                                <div class="facility-item">
                                                                    <i class="fas fa-gift facility-icon"></i>
                                                                    <span>내고장특산물</span>
                                                                </div>
                                                            </c:when>
                                                            <c:when test="${facility.contains('화장실')}">
                                                                <div class="facility-item">
                                                                    <i class="fas fa-restroom facility-icon"></i>
                                                                    <span>화장실</span>
                                                                </div>
                                                            </c:when>
                                                            <c:when test="${facility.contains('휴게실')}">
                                                                <div class="facility-item">
                                                                    <i class="fas fa-couch facility-icon"></i>
                                                                    <span>휴게실</span>
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="facility-item">
                                                                    <i class="fas fa-check facility-icon"></i>
                                                                    <span>${facility.trim()}</span>
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:forEach>
                                                </c:if>
                                                <c:if test="${empty serviceAreaVO or empty serviceAreaVO.convenience}">
                                                    <div class="facility-item">
                                                        <i class="fas fa-info-circle facility-icon"></i>
                                                        <span>편의시설 정보 없음</span>
                                                    </div>
                                                </c:if>
                                            </div>
                                        </div>

                                        <!-- 주유비/운영시간 섹션 -->
                                        <div class="content-section">

                                            <div class="section-title-with-date">
                                                <div class="section-title-left">
                                                    <i class="fas fa-gas-pump"></i>
                                                    주유비
                                                </div>
                                                <div class="section-title-date">
                                                    <jsp:useBean id="now" class="java.util.Date"/>
                                                    <fmt:formatDate value="${now}" pattern="yyyy.MM.dd"/>
                                                </div>
                                            </div>
                                            <div class="fuel-info">
                                                <c:if test="${not empty serviceAreaVO and not empty serviceAreaVO.gasInfo}">
                                                    <c:if test="${not empty serviceAreaVO.gasInfo.gasoline}">
                                                        <div class="fuel-price">
                                                            휘발유: ${serviceAreaVO.gasInfo.gasoline}</div>
                                                    </c:if>
                                                    <c:if test="${not empty serviceAreaVO.gasInfo.disel}">
                                                        <div class="fuel-price">
                                                            경유: ${serviceAreaVO.gasInfo.disel}</div>
                                                    </c:if>
                                                    <c:if test="${not empty serviceAreaVO.gasInfo.LPG}">
                                                        <div class="fuel-price">
                                                            LPG: ${serviceAreaVO.gasInfo.LPG}</div>
                                                    </c:if>
                                                    <c:if test="${empty serviceAreaVO.gasInfo.gasoline and empty serviceAreaVO.gasInfo.disel and empty serviceAreaVO.gasInfo.LPG}">
                                                        <div class="fuel-price">주유소 정보 없음</div>
                                                    </c:if>
                                                </c:if>
                                                <c:if test="${empty serviceAreaVO or empty serviceAreaVO.gasInfo}">
                                                    <div class="fuel-price">주유소 정보 없음</div>
                                                </c:if>
                                            </div>
                                        </div>

                                        <!-- 대표메뉴/안전수칙 섹션 -->
                                        <div class="content-section">
                                            <div class="section-title">
                                                <i class="fas fa-utensils"></i>
                                                대표메뉴
                                            </div>
                                            <div class="menu-items">
                                                <c:if test="${not empty serviceAreaVO and not empty serviceAreaVO.menulist}">
                                                    <c:set var="menuCount" value="0"/>
                                                    <c:set var="bestMenu" value=""/>
                                                    <c:set var="recommendMenu" value=""/>
                                                    <c:set var="firstMenu" value=""/>
                                                    <c:set var="secondMenu" value=""/>
                                                    
                                                    <!-- 메뉴 정보 수집 -->
                                                    <c:forEach var="menu" items="${serviceAreaVO.menulist}" varStatus="menuStatus">
                                                        <c:choose>
                                                            <c:when test="${menu.best eq 'Y' and empty bestMenu}">
                                                                <c:set var="bestMenu" value="${menu}"/>
                                                            </c:when>
                                                            <c:when test="${menu.recommend eq 'Y' and empty recommendMenu and menu.best ne 'Y'}">
                                                                <c:set var="recommendMenu" value="${menu}"/>
                                                            </c:when>
                                                            <c:when test="${menuStatus.index == 0}">
                                                                <c:set var="firstMenu" value="${menu}"/>
                                                            </c:when>
                                                            <c:when test="${menuStatus.index == 1}">
                                                                <c:set var="secondMenu" value="${menu}"/>
                                                            </c:when>
                                                        </c:choose>
                                                    </c:forEach>
                                                    
                                                    <!-- 메뉴 표시 (우선순위: Best > Recommend > 첫번째 > 두번째) -->
                                                    <c:choose>
                                                        <c:when test="${not empty bestMenu}">
                                                            <div class="menu-item best-menu">
                                                                <i class="fas fa-star menu-icon"></i>
                                                                <span class="menu-name">${bestMenu.foodName}</span>
                                                                <c:if test="${not empty bestMenu.price}">
                                                                    <span class="menu-price">${bestMenu.price}원</span>
                                                </c:if>
                                                            </div>
                                                            <c:set var="menuCount" value="${menuCount + 1}"/>
                                                        </c:when>
                                                    </c:choose>
                                                    
                                                    <c:choose>
                                                        <c:when test="${not empty recommendMenu and menuCount < 2 and bestMenu ne recommendMenu}">
                                                            <div class="menu-item recommend-menu">
                                                                <i class="fas fa-thumbs-up menu-icon"></i>
                                                                <span class="menu-name">${recommendMenu.foodName}</span>
                                                                <c:if test="${not empty recommendMenu.price}">
                                                                    <span class="menu-price">${recommendMenu.price}원</span>
                                                                </c:if>
                                                            </div>
                                                            <c:set var="menuCount" value="${menuCount + 1}"/>
                                                        </c:when>
                                                        <c:when test="${not empty firstMenu and menuCount < 2}">
                                                            <div class="menu-item">
                                                                <i class="fas fa-utensils menu-icon"></i>
                                                                <span class="menu-name">${firstMenu.foodName}</span>
                                                                <c:if test="${not empty firstMenu.price}">
                                                                    <span class="menu-price">${firstMenu.price}원</span>
                                                                </c:if>
                                                            </div>
                                                            <c:set var="menuCount" value="${menuCount + 1}"/>
                                                        </c:when>
                                                    </c:choose>
                                                    
                                                    <c:choose>
                                                        <c:when test="${not empty secondMenu and menuCount < 2}">
                                                            <div class="menu-item">
                                                                <i class="fas fa-utensils menu-icon"></i>
                                                                <span class="menu-name">${secondMenu.foodName}</span>
                                                                <c:if test="${not empty secondMenu.price}">
                                                                    <span class="menu-price">${secondMenu.price}원</span>
                                                                </c:if>
                                                            </div>
                                                        </c:when>
                                                        <c:when test="${not empty recommendMenu and menuCount < 2 and empty bestMenu}">
                                                            <div class="menu-item recommend-menu">
                                                                <i class="fas fa-thumbs-up menu-icon"></i>
                                                                <span class="menu-name">${recommendMenu.foodName}</span>
                                                                <c:if test="${not empty recommendMenu.price}">
                                                                    <span class="menu-price">${recommendMenu.price}원</span>
                                                                </c:if>
                                                            </div>
                                                        </c:when>
                                                        <c:when test="${not empty firstMenu and menuCount < 2 and empty bestMenu and empty recommendMenu}">
                                                            <div class="menu-item">
                                                                <i class="fas fa-utensils menu-icon"></i>
                                                                <span class="menu-name">${firstMenu.foodName}</span>
                                                                <c:if test="${not empty firstMenu.price}">
                                                                    <span class="menu-price">${firstMenu.price}원</span>
                                                                </c:if>
                                                            </div>
                                                        </c:when>
                                                    </c:choose>
                                                    
                                                    <c:if test="${menuCount == 0}">
                                                        <div class="menu-item no-menu">
                                                            <i class="fas fa-info-circle menu-icon"></i>
                                                            <span class="menu-name">메뉴 정보 없음</span>
                                                        </div>
                                                    </c:if>
                                                </c:if>
                                                <c:if test="${empty serviceAreaVO or empty serviceAreaVO.menulist}">
                                                    <div class="menu-item no-menu">
                                                        <i class="fas fa-info-circle menu-icon"></i>
                                                        <span class="menu-name">메뉴 정보 없음</span>
                                                    </div>
                                                </c:if>
                                            </div>
                                        </div>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="empty-message">
                    <div class="empty-icon">
                        <i class="fas fa-info-circle"></i>
                    </div>
                    <p>경로상 휴게시설이 발견되지 않았습니다.</p>
                    <p style="font-size: 0.9rem; color: #999; margin-top: 0.5rem;">
                        다른 경로를 시도해보세요.
                    </p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<!-- 추가 정보 섹션 -->
<c:if test="${not empty allRestAreas}">
    <div class="info-card slide-up" style="margin-top: 2rem;">
        <div class="card-header">
            <div class="card-icon">
                <i class="fas fa-info-circle"></i>
            </div>
            <div class="card-title">정보 안내</div>
        </div>
        <div style="color: #666; line-height: 1.6;">
            <p><strong>휴게소:</strong> 주유소, 충전소, 음식점, 화장실 등 편의시설이 구비된 휴게공간</p>
            <p><strong>졸음쉼터:</strong> 운전 중 졸음 방지를 위한 임시 휴식 공간</p>
            <p style="margin-top: 1rem; font-size: 0.9rem; color: #999;">
                <i class="fas fa-lightbulb"></i> 안전한 운전을 위해 정기적인 휴식을 취하세요.
            </p>
        </div>
    </div>
</c:if>
</div>

<script>

    // 🚩 전역 변수를 추가하여 현재 Video.js 플레이어 인스턴스를 관리합니다.
    let currentCctvVideoPlayer = null;

    // JSP 변수를 JavaScript 변수로 선언

    var allRestAreaDurations = ${allRestAreaDurations != null ? allRestAreaDurations : '[]'};
    var serviceAreaOnlyDurations = ${serviceAreaOnlyDurations != null ? serviceAreaOnlyDurations : '[]'};

    // 전역 변수로 설정
    window.allRestAreaDurations = allRestAreaDurations;
    window.serviceAreaOnlyDurations = serviceAreaOnlyDurations;

    // 세션의 북마크 리스트를 JavaScript 변수로 받기
    var sessionBookmarkedSaKeys = [];
    <c:if test="${not empty sessionScope.bookmarkedSaKeys}">
    sessionBookmarkedSaKeys = ${sessionScope.bookmarkedSaKeys};
    </c:if>


    // DOM이 완전히 로드된 후에 스크립트 실행
    document.addEventListener('DOMContentLoaded', function () {
        $(document).ready(function () {
            let currentRestAreaId = null; // 현재 열려있는 휴게소 모달의 ID

            // ======================================================================
            // 1. 휴게소 카드 클릭 이벤트
            // ======================================================================
            $('.rest-area-card.service-area').on('click', function (e) {
                // 카드 안의 아이콘(즐겨찾기, CCTV, 리뷰) 클릭 시에는 모달 열지 않음
                if ($(e.target).closest('.bookmark-heart, .cctv-icon, .review-icon').length > 0) {
                    return;
                }

                const saKey = $(this).data('sakey'); // 1단계에서 추가한 data-sakey 값 가져오기
                currentRestAreaId = saKey;

                // 서버에 휴게소 상세 정보 요청 (AJAX)
                $.ajax({
                    type: 'POST',
                    url: '${pageContext.request.contextPath}/Controller',
                    data: {type: 'getRestAreaDetails', saKey: saKey},
                    dataType: 'json',
                    success: function (response) {
                        // 서버로부터 받은 데이터로 모달 내용을 채우고 보여줌
                        if (response && (response.idx || response.Idx)) {
                            populateAndShowModal(response);
                        } else {
                            alert('휴게소 정보를 찾을 수 없습니다.');
                        }
                    },
                    error: function () {
                        alert('상세 정보를 불러오는 중 오류가 발생했습니다.');
                    }
                });
            });

            // ======================================================================
            // 2. 서버 데이터로 모달 내용을 채우고 보여주는 함수
            // (mypage.jsp의 함수를 기반으로 일부 수정)
            // ======================================================================
            function populateAndShowModal(data) {
                if (!data) return;

                // 기본 정보
                $('#modalTitle').text(data.SAName || '정보 없음');
                $('#modalLocation').text(data.Address || '정보 없음');
                let formattedPhone = '정보 없음';
                if (data.Tel) {
                    formattedPhone = data.Tel.replace(/(\d{2,3})(\d{3,4})(\d{4})/, '$1-$2-$3');
                }
                $('#modalPhone').text(formattedPhone);

                // AI 코멘트 (필드 이름이 두 가지 경우 모두 처리)
                $('#modalAiComment').text(data.AIComment || data.AiComment || '제공되는 추천 코멘트가 없습니다.');

                // 주차 정보
                $('#modalCompactParking').text((data.CompactParking || 0) + '대');
                $('#modalLargeParking').text((data.LargeParking || 0) + '대');
                $('#modalDisabledParking').text((data.DisabledParking || 0) + '대');

                // 주유 가격 정보
                const gasInfo = data.gasInfo;
                if (gasInfo) {
                    $('#modalGasoline').text((gasInfo.Gasoline && gasInfo.Gasoline !== 'X') ? gasInfo.Gasoline : '주유불가');
                    $('#modalDiesel').text((gasInfo.Disel && gasInfo.Disel !== 'X') ? gasInfo.Disel : '주유불가');
                    $('#modalLpg').text((gasInfo.LPG && gasInfo.LPG !== 'X') ? gasInfo.LPG : '주유불가');
                } else {
                    $('#modalGasoline, #modalDiesel, #modalLpg').text('조회 불가');
                }

                // 편의시설 정보
                const facilitiesList = $('#modalFacilities');
                facilitiesList.empty();
                if (data.Convenience) {
                    data.Convenience.split(',').forEach(facility => {
                        if (facility.trim()) {
                            facilitiesList.append($('<span>').addClass('facility-tag').text(facility.trim()));
                        }
                    });
                } else {
                    facilitiesList.html('<span class="info-value">제공되는 편의시설 정보가 없습니다.</span>');
                }

                // 별점 정보
                const starValue = parseFloat(data.Star);
                const starIconContainer = $('#starIconContainer');
                const starText = $('#starText');
                starIconContainer.empty();
                starText.empty();
                if (isNaN(starValue) || !data.Star || data.Star === '0' || data.Star === '0.0') {
                    starIconContainer.html('<i class="far fa-star"></i>');
                    starText.text('평점 없음');
                } else {
                    starIconContainer.html('<i class="fas fa-star" style="color: #ffc107;"></i>');
                    starText.text(starValue.toFixed(1));
                }

                // 모달 내 즐겨찾기 아이콘 상태 업데이트
                // 서버 응답에 isBookmarked: true/false 같은 필드가 있다고 가정합니다.
                const bookmarkIcon = $('#bookmarkIcon');
                const iconElement = bookmarkIcon.find('i');
                bookmarkIcon.data('sakey', data.idx || data.Idx); // 모달 아이콘에도 ID 저장

                if (data.isBookmarked) {
                    iconElement.removeClass('far').addClass('fas'); // 채워진 하트
                    bookmarkIcon.addClass('bookmarked');
                } else {
                    iconElement.removeClass('fas').addClass('far'); // 빈 하트
                    bookmarkIcon.removeClass('bookmarked');
                }

                // 모달창 표시
                $('#restAreaModal').css('display', 'flex');
            }

            // ======================================================================
            // 3. 모달 닫기 및 기타 이벤트 핸들러
            // ======================================================================
            $('#restAreaModal .close').on('click', function () {
                $('#restAreaModal').hide();
            });
            $('#storesModal .close').on('click', function () {
                $('#storesModal').hide();
                $('#restAreaModal').css('display', 'flex');
            });

            $('.modal').on('click', function (e) {
                if (e.target === this) {
                    if ($(this).is('#storesModal')) {
                        $(this).hide();
                        $('#restAreaModal').css('display', 'flex');
                    } else {
                        $(this).hide();
                    }
                }
            });

            // ======================================================================
            // 4. 모달 내 매장 정보, 즐겨찾기 버튼 이벤트 핸들러
            // ======================================================================

            // '매장 정보 확인' 버튼 클릭
            $('#showStoresBtn').on('click', function () {
                $('#restAreaModal').hide();
                $('#storesModal').css('display', 'flex');
                const restAreaName = $('#modalTitle').text();
                $('#storesModalTitle').text(restAreaName + ' 매장 정보');
                $('#storeSearchInput').val('');
                if (currentRestAreaId) {
                    loadAndRenderStores(currentRestAreaId, '');
                }
            });

            // 매장 검색 버튼
            $('#storeSearchBtn').on('click', function () {
                const searchText = $('#storeSearchInput').val();
                if (currentRestAreaId) {
                    loadAndRenderStores(currentRestAreaId, searchText);
                }
            });

            // 검색창 엔터키 이벤트
            $('#storeSearchInput').on('keypress', function (e) {
                if (e.which === 13) {
                    $('#storeSearchBtn').click();
                }
            });

            // 모달 내 즐겨찾기 아이콘 클릭 이벤트
            $(document).on('click', '#bookmarkIcon', function () {
                if (${empty sessionScope.loginUser}) {
                    alert('로그인이 필요합니다.');
                    window.location.href = '${pageContext.request.contextPath}/login.jsp';
                    return;
                }

                const saKey = $(this).data('sakey');
                const icon = $(this).find('i');
                const isBookmarked = icon.hasClass('fas');

                // 서버에 보낼 action 결정
                const action = isBookmarked ? 'delete' : 'add';

                // 화면 먼저 optimistic하게 변경
                icon.toggleClass('fas far');
                $(this).toggleClass('bookmarked');

                // 목록에 있는 하트 아이콘도 찾아서 동기화
                const listIcon = $(`.rest-area-card[data-sakey='${saKey}']`).find('.bookmark-heart');
                if (listIcon) {
                    listIcon.toggleClass('bookmarked', !isBookmarked);
                }

                // 서버에 즐겨찾기 변경 요청
                $.ajax({
                    type: 'POST',
                    url: '${pageContext.request.contextPath}/Controller',
                    data: {type: 'Heartbookmark', saKey: saKey, action: action},
                    dataType: 'json',
                    success: function (response) {
                        if (!response.success) {
                            // 실패 시 화면 원상 복구
                            alert(response.message || '즐겨찾기 처리에 실패했습니다.');
                            icon.toggleClass('fas far');
                            $(this).toggleClass('bookmarked');
                            if (listIcon) {
                                listIcon.toggleClass('bookmarked', isBookmarked);
                            }
                        }
                    },
                    error: function () {
                        alert('즐겨찾기 처리 중 오류가 발생했습니다.');
                        // 실패 시 화면 원상 복구
                        icon.toggleClass('fas far');
                        $(this).toggleClass('bookmarked');
                        if (listIcon) {
                            listIcon.toggleClass('bookmarked', isBookmarked);
                        }
                    }
                });
            });

            // 매장 정보 로드 함수 (mypage.jsp와 동일)
            function loadAndRenderStores(saKey, searchText = '') {
                const $storeList = $('#storeList');
                $storeList.empty().html('<p class="store-empty">매장 정보를 불러오는 중...</p>');

                $.ajax({
                    type: 'POST',
                    url: '${pageContext.request.contextPath}/Controller',
                    data: {type: 'getStores', saKey: saKey, searchText: searchText},
                    dataType: 'json',
                    success: function (response) {
                        $storeList.empty();
                        if (response && response.length > 0) {
                            response.forEach(store => {
                                $storeList.append($("<div>").addClass("store-item").text(store.ShopName));
                            });
                        } else {
                            $storeList.html('<p class="store-empty">' + (searchText ? '검색 결과가 없습니다.' : '등록된 매장 정보가 없습니다.') + '</p>');
                        }
                    },
                    error: function () {
                        $storeList.html('<p class="store-empty">매장 정보를 불러오는 중 오류가 발생했습니다.</p>');
                    }
                });
            }

        }); // End of $(document).ready


        // 기존 탭 기능 구현
        const tabButtons = document.querySelectorAll('.tab-btn');
        const tabPanes = document.querySelectorAll('.tab-pane');

        tabButtons.forEach(button => {
            button.addEventListener('click', function () {
                const targetTab = this.getAttribute('data-tab');

                // 모든 탭 버튼에서 active 클래스 제거
                tabButtons.forEach(btn => btn.classList.remove('active'));

                // 모든 탭 패널에서 active 클래스 제거
                tabPanes.forEach(pane => pane.classList.remove('active'));

                // 클릭된 버튼에 active 클래스 추가
                this.classList.add('active');

                // 해당 탭 패널에 active 클래스 추가
                const targetPane = document.getElementById(targetTab);
                if (targetPane) {
                    targetPane.classList.add('active');
                }
            });
        });

        // 카드 애니메이션 효과
        const cards = document.querySelectorAll('.info-card');
        cards.forEach((card, index) => {
            card.style.animationDelay = `${index * 0.1}s`;
        });

        // 리스트 아이템 호버 효과
        const listItems = document.querySelectorAll('.info-item');
        listItems.forEach(item => {
            item.addEventListener('mouseenter', function () {
                this.style.transform = 'translateX(5px)';
            });

            item.addEventListener('mouseleave', function () {
                this.style.transform = 'translateX(0)';
            });
        });

        // 페이지 로드 시 졸음쉼터 카드들을 기본적으로 숨김
        const restStopCards = document.querySelectorAll('.rest-area-card.rest-stop');
        restStopCards.forEach(card => {
            card.style.display = 'none';
        });
    });// document


    // 🚩 openCctvModal 함수를 수정하여 모달을 열기 전에 기존 플레이어를 제거합니다.
    function openCctvModal(lat, lng) {
        if (currentCctvVideoPlayer) {
            currentCctvVideoPlayer.dispose();
            currentCctvVideoPlayer = null;
        }
        document.getElementById('cctvModal').style.display = 'block';
        fetchCctvData(lat, lng);
    }

    // 모달 닫기
    function closeModal(modalId) {
        const modal = document.getElementById(modalId);
        modal.style.display = 'none';

        // CCTV 모달 닫을 때 영상 중지
        if (modalId === 'cctvModal') {
            videojs.getPlayers().forEach(player => {
                if (player) {
                    player.dispose();
                }
            });
            document.getElementById('cctv-grid').innerHTML = '';
        }

        // restAreaModal을 닫을 때도 동일하게 처리합니다.
        if (modalId === 'restAreaModal') {
            // 다른 모달이 닫힐 때 필요한 정리 로직을 여기에 추가할 수 있습니다.
        }
    }

    // 주어진 위/경도 주변의 CCTV 데이터를 서버에서 가져옵니다.
    // 🚩 fetchCctvData 함수를 수정하여 Video.js 플레이어를 동적으로 생성합니다.
    function fetchCctvData(lat, lng) {
        const loading = document.getElementById('cctv-loading');
        const errorMsg = document.getElementById('cctv-error');
        const cctvGrid = document.getElementById('cctv-grid');
        loading.style.display = 'block';
        errorMsg.style.display = 'none';
        cctvGrid.innerHTML = '';

        const minX = parseFloat(lng) - 0.005;
        const minY = parseFloat(lat) - 0.005;
        const maxX = parseFloat(lng) + 0.005;
        const maxY = parseFloat(lat) + 0.005;

        fetch('${pageContext.request.contextPath}/Controller?type=Cctv&minX=' + minX + '&minY=' + minY + '&maxX=' + maxX + '&maxY=' + maxY)
            .then(response => {
                if (!response.ok) {
                    throw new Error('서버 오류: ' + response.status);
                }
                return response.json();
            })
            .then(data => {
                loading.style.display = 'none';
                let cctvList = [];
                if (data.response && data.response.data) {
                    if (!Array.isArray(data.response.data)) {
                        cctvList.push(data.response.data);
                    } else {
                        cctvList = data.response.data;
                    }
                }

                if (cctvList.length > 0) {
                    cctvList.forEach((cctv, index) => {
                        const videoContainer = document.createElement('div');
                        videoContainer.className = 'video-container';
                        cctvGrid.appendChild(videoContainer);

                        const videoId = cctv.cctvid || 'fallback-cctv-' + index;

                        fetch('${pageContext.request.contextPath}/Controller?type=getVideoUrl&temporaryUrl=' + encodeURIComponent(cctv.cctvurl))
                            .then(res => res.text())
                            .then(finalUrl => {
                                if (finalUrl) {
                                    const videoElement = document.createElement('video');
                                    videoElement.id = videoId;
                                    videoElement.className = 'video-js vjs-default-skin';
                                    videoElement.controls = true;
                                    videoElement.autoplay = true;
                                    videoElement.muted = true;
                                    videoElement.playsinline = true;
                                    const titleSpan = document.createElement('span');
                                    titleSpan.textContent = cctv.cctvname || '이름 없음';

                                    videoContainer.appendChild(videoElement);
                                    videoContainer.appendChild(titleSpan);

                                    // 💡 Video.js를 사용해 동적으로 플레이어를 초기화합니다.
                                    const player = videojs(videoId, {autoplay: true, controls: true, muted: true});
                                    player.src({src: finalUrl, type: 'application/x-mpegURL'});
                                    // 💡 새롭게 생성된 플레이어 인스턴스를 전역 변수에 저장합니다.
                                    currentCctvVideoPlayer = player;
                                } else {
                                    videoContainer.innerHTML = `<div class="video-error">영상 로드 실패</div><span>${cctv.cctvname || '이름 없음'}</span>`;
                                }
                            })
                            .catch(err => {
                                console.error('Video URL fetch error:', err);
                                videoContainer.innerHTML = `<div class="video-error">영상 로드 오류</div><span>${cctv.cctvname || '이름 없음'}</span>`;
                            });
                    });
                } else {
                    errorMsg.textContent = '주변 CCTV 영상이 없습니다.';
                    errorMsg.style.display = 'block';
                }
            })
            .catch(error => {
                console.error('CCTV 데이터 로드 실패:', error);
                loading.style.display = 'none';
                errorMsg.textContent = 'CCTV 정보를 불러오는 중 오류가 발생했습니다.';
                errorMsg.style.display = 'block';
            });
    }

    // 졸음쉼터 정보 모달 표시
    function showRestStopInfo(name, index) {
        const modal = document.getElementById('restStopModal');
        const title = document.getElementById('modalTitle2');
        const location = document.getElementById('modalLocation2');

        title.textContent = name;
        location.textContent = `졸음쉼터 #${index + 1} - ${name}`;

        modal.style.display = 'block';
    }

    // 졸음쉼터 표시 토글 기능
    function toggleRestStops(button) {
        const restStopCards = document.querySelectorAll('.rest-area-card.rest-stop');
        const serviceAreaCards = document.querySelectorAll('.rest-area-card.service-area');
        const buttonText = button.querySelector('.button-text');
        const buttonIcon = button.querySelector('.button-icon');
        const isActive = button.classList.contains('active');

        if (isActive) {
            // 졸음쉼터 숨기기 - 소요시간 먼저 변경, 그 다음 리스트 변경
            buttonText.textContent = '졸음쉼터 표시';
            buttonIcon.className = 'fas fa-bed button-icon';
            button.classList.remove('active');

            // 1단계: 소요시간 먼저 업데이트 (300ms)
            updateServiceAreaDurations(serviceAreaCards, window.serviceAreaOnlyDurations);

            // 2단계: 소요시간 업데이트 완료 후 리스트 애니메이션 시작 (600ms 대기)
            setTimeout(() => {
                // 콜랩스 애니메이션으로 사라지기 (빈 공간 채우기)
                restStopCards.forEach((card, index) => {
                    setTimeout(() => {
                        // 1단계: 페이드아웃과 스케일 다운 (더 부드럽게)
                        card.classList.add('animating-out');

                        setTimeout(() => {
                            // 2단계: 콜랩스 (높이와 마진 줄이기) - 더 긴 시간
                            card.classList.remove('animating-out');
                            card.classList.add('collapsing');

                            setTimeout(() => {
                                // 3단계: 완전히 숨기기
                                card.style.display = 'none';
                                card.classList.remove('collapsing');
                                // 스타일 정리
                                card.style.maxHeight = '';
                                card.style.marginBottom = '';
                                card.style.padding = '';
                            }, 800); // 콜랩스 애니메이션 시간 증가
                        }, 300); // 페이드아웃 후 콜랩스 시작 - 더 여유롭게
                    }, index * 120); // 순차적 사라짐 - 더 여유로운 간격
                });
            }, 600); // 소요시간 업데이트 완료 후 대기
        } else {
            // 졸음쉼터 표시 - 소요시간 먼저 복원, 그 다음 리스트 표시
            buttonText.textContent = '졸음쉼터 숨기기';
            buttonIcon.className = 'fas fa-eye-slash button-icon';
            button.classList.add('active');

            // 1단계: 소요시간 먼저 복원
            restoreOriginalDurations(serviceAreaCards, window.allRestAreaDurations);

            // 2단계: 소요시간 복원 완료 후 리스트 나타나기 애니메이션
            setTimeout(() => {
                // 확장 애니메이션으로 나타나기 (공간 채우며 등장)
                restStopCards.forEach((card, index) => {
                    // 스택드 애니메이션으로 순차적 등장
                    setTimeout(() => {
                        card.style.display = 'block';

                        // 1단계: 확장 시작 (높이 0에서 시작)
                        card.classList.add('expanding');

                        // 더 부드러운 타이밍으로 애니메이션 시작
                        setTimeout(() => {
                            // 2단계: 확장과 페이드인
                            card.classList.remove('expanding');
                            card.classList.add('visible');

                            // 완료 후 클래스 정리
                            setTimeout(() => {
                                card.classList.remove('visible');
                                // 원래 스타일로 복원
                                card.style.maxHeight = '';
                                card.style.marginBottom = '';
                                card.style.padding = '';
                            }, 700); // 더 긴 시간
                        }, 50); // 약간의 딜레이로 더 자연스럽게
                    }, index * 150); // 더 여유로운 순차적 딜레이
                });
            }, 500); // 소요시간 복원 완료 후 대기
        }
    }

    // 휴게소끼리 소요시간으로 업데이트 (부드러운 애니메이션)
    function updateServiceAreaDurations(serviceAreaCards, serviceAreaOnlyDurations) {

        if (!window.originalDurations) {
            // 원본 소요시간 저장
            window.originalDurations = [];
            const allCards = document.querySelectorAll('.rest-area-card');
            allCards.forEach(card => {
                const durationElement = card.querySelector('.duration-text');
                if (durationElement) {
                    window.originalDurations.push({
                        element: durationElement,
                        originalText: durationElement.innerHTML
                    });
                }
            });
        }

        let serviceAreaIndex = 0;
        serviceAreaCards.forEach((card, index) => {
            const durationElement = card.querySelector('.duration-text');
            if (durationElement && serviceAreaIndex < serviceAreaOnlyDurations.length) {
                const duration = serviceAreaOnlyDurations[serviceAreaIndex];
                const hours = Math.floor(duration / 3600);
                const minutes = Math.floor((duration % 3600) / 60);

                let newTimeText = '';
                if (serviceAreaIndex === 0) {
                    newTimeText = '출발지부터 ';
                } else {
                    newTimeText = '이전 휴게소부터 ';
                }

                if (hours > 0) newTimeText += hours + '시간';
                if (minutes > 0) newTimeText += minutes + '분';

                // 부드러운 텍스트 변경 애니메이션 (더 자연스럽게)
                setTimeout(() => {
                    durationElement.classList.add('updating');

                    setTimeout(() => {
                        durationElement.innerHTML = newTimeText;

                        setTimeout(() => {
                            durationElement.classList.remove('updating');
                        }, 250); // 더 긴 시간
                    }, 200); // 더 여유로운 타이밍
                }, index * 150); // 순차적 업데이트 - 더 여유로운 간격

                serviceAreaIndex++;
            }
        });
    }

    // 원래 소요시간으로 복원 (부드러운 애니메이션)
    function restoreOriginalDurations(serviceAreaCards, allRestAreaDurations) {
        // 모든 휴게시설 카드들을 가져와서 휴게소 인덱스 매핑
        const allCards = document.querySelectorAll('.rest-area-card');
        const serviceAreaIndices = [];

        let serviceAreaIndex = 0;
        allCards.forEach((card, index) => {
            if (card.classList.contains('service-area')) {
                serviceAreaIndices.push(index);
            }
        });

        serviceAreaCards.forEach((card, cardIndex) => {
            const durationElement = card.querySelector('.duration-text');
            if (durationElement) {
                // 해당 휴게소의 전체 휴게시설 인덱스 찾기
                const allRestAreaIndex = serviceAreaIndices[cardIndex];

                if (allRestAreaIndex !== undefined && allRestAreaIndex < allRestAreaDurations.length) {
                    const duration = allRestAreaDurations[allRestAreaIndex];
                    const hours = Math.floor(duration / 3600);
                    const minutes = Math.floor((duration % 3600) / 60);

                    let newTimeText = '';
                    if (allRestAreaIndex === 0) {
                        newTimeText = '출발지부터 ';
                    } else {
                        newTimeText = '이전 휴게시설부터 ';
                    }

                    if (hours > 0) newTimeText += hours + '시간';
                    if (minutes > 0) newTimeText += minutes + '분';

                    setTimeout(() => {
                        durationElement.classList.add('updating');

                        setTimeout(() => {
                            durationElement.innerHTML = newTimeText;

                            setTimeout(() => {
                                durationElement.classList.remove('updating');
                            }, 250);
                        }, 200);
                    }, cardIndex * 120);
                }
            }
        });
    }

    // 즐겨찾기 토글 기능

    // 공통: JSON 응답 헬퍼
    function handleJson(res) {
        if (!res.ok) throw new Error('HTTP ' + res.status);
        return res.json();
    }

    function toggleBookmark(idx, heartIcon) {
        // 낙관적 UI
        heartIcon.classList.toggle('bookmarked');
        heartIcon.style.pointerEvents = 'none';

        // 로직 수정: 현재 상태를 기준으로 action 결정
        const isCurrentlyBookmarked = heartIcon.classList.contains('bookmarked');
        const action = isCurrentlyBookmarked ? 'add' : 'delete';

        fetch(
            `${pageContext.request.contextPath}/Controller?type=Heartbookmark`,
            {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
                body: new URLSearchParams({saKey: idx, action})
            }
        )
            .then(handleJson)
            .then(data => {
                if (!data.success) {
                    // 실패 시 UI 되돌리기
                    heartIcon.classList.toggle('bookmarked');
                    alert(data.message || '즐겨찾기 처리 실패');
                }
            })
            .catch(err => {
                // 오류 시 UI 되돌리기
                heartIcon.classList.toggle('bookmarked');
                console.error(err);
                alert('서버 통신 오류');
            })
            .finally(() => {
                heartIcon.style.pointerEvents = 'auto';
            });
    }


    // 로그인 페이지로 이동하는 함수
    function redirectToLogin() {
        // 현재 페이지 URL을 세션스토리지에 저장
        sessionStorage.setItem('returnUrl', window.location.href);
        alert('즐겨찾기 기능을 사용하려면 로그인이 필요합니다.');
        // Login 페이지로 직접 이동 (Controller 거치지 않음)
        window.location.href = 'login.jsp?returnUrl=' + encodeURIComponent(window.location.href);
    }

</script>

<!-- Footer Include -->
<jsp:include page="footer.jsp"/>

<!-- cctv 모달 -->
<div id="cctvModal" class="modal">
    <div class="modal-content">
        <span class="close" onclick="closeModal('cctvModal')">&times;</span>
        <h2>주변 CCTV 영상</h2>
        <p id="cctv-loading">CCTV 정보를 불러오는 중...</p>
        <p id="cctv-error" style="display: none;"></p>
        <div id="cctv-grid" class="cctv-grid"></div>
    </div>
</div>
</body>
</html>
