<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>네이버 맵 API 테스트</title>
    <style>
        /* CSS 스타일 정의 (디자인 요소) */
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        .input-group {
            margin-bottom: 15px;
        }

        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #333;
        }

        input[type="text"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            box-sizing: border-box;
        }

        .button-group {
            margin: 20px 0;
        }

        button {
            background-color: #4CAF50;
            color: white;
            padding: 12px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin-right: 10px;
            font-size: 14px;
        }

        button:hover {
            background-color: #45a049;
        }

        .result-area {
            margin-top: 20px;
            padding: 15px;
            background-color: #f9f9f9;
            border-radius: 4px;
            border-left: 4px solid #4CAF50;
        }

        .error-area {
            margin-top: 20px;
            padding: 15px;
            background-color: #ffebee;
            border-radius: 4px;
            border-left: 4px solid #f44336;
        }

        .warning {
            background-color: #fff3cd;
            border: 1px solid #ffeaa7;
            color: #856404;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 20px;
        }

        #map {
            width: 100%;
            height: 400px;
            border-radius: 4px;
            border: 1px solid #ddd;
        }
    </style>
    <!-- 네이버 맵 API JavaScript 라이브러리 로드 -->
    <!-- ncpKeyId: NAVER Cloud Platform에서 발급받은 API 키 ID -->
    <!-- submodules=geocoder: 주소-좌표 변환 기능 포함 -->
    <script type="text/javascript"
            src="https://oapi.map.naver.com/openapi/v3/maps.js?ncpKeyId=a3kqiwwu0n&submodules=geocoder"></script>
</head>
<body>
<div class="container">
    <h1>네이버 맵 API 테스트</h1>

    <!-- API 키 입력 필드 -->
    <div class="input-group">
        <label for="accessKey">Access Key ID:</label>
        <input type="text" id="accessKey" value="a3kqiwwu0n" placeholder="Access Key ID를 입력하세요">
    </div>

    <div class="input-group">
        <label for="secretKey">Secret Access Key:</label>
        <input type="text" id="secretKey" value="Q4FikPxcG6mAoJmGC76bm80e6SXzYfYFlhvdrVNc"
               placeholder="Secret Access Key를 입력하세요">
    </div>

    <!-- 주소 검색 입력 필드 -->
    <div class="input-group">
        <label for="query">검색어 (정확한 주소 입력):</label>
        <input type="text" id="query" value="서울특별시 강남구 강남대로 396" placeholder="정확한 주소를 입력하세요 (예: 서울특별시 강남구 강남대로 396)">
        <small style="color: #666; font-size: 12px;">
            💡 팁: "강남역" 대신 "서울특별시 강남구 강남대로 396" 같은 정확한 주소를 입력하세요
        </small>
    </div>

    <!-- 경로 찾기용 출발지/목적지 입력 필드 -->
    <div class="input-group">
        <label for="startAddress">출발지:</label>
        <input type="text" id="startAddress" value="서울특별시 강남구 강남대로 396" placeholder="출발지를 입력하세요">
    </div>

    <div class="input-group">
        <label for="endAddress">목적지:</label>
        <input type="text" id="endAddress" value="서울특별시 중구 세종대로 110" placeholder="목적지를 입력하세요">
    </div>

    <!-- 좌표 입력 필드 (역지오코딩 테스트용) -->
    <div class="input-group">
        <label for="lat">위도:</label>
        <input type="text" id="lat" value="37.5665" placeholder="위도를 입력하세요">
    </div>

    <div class="input-group">
        <label for="lng">경도:</label>
        <input type="text" id="lng" value="126.9780" placeholder="경도를 입력하세요">
    </div>

    <!-- API 테스트 버튼들 -->
    <div class="button-group">
        <button onclick="testGeocoding()">지오코딩 API 테스트</button>
        <button onclick="testReverseGeocoding()">역지오코딩 API 테스트</button>
        <button onclick="testSearchAPI()">검색 API 테스트</button>
        <button onclick="testMapAPI()">지도 API 테스트</button>
        <button onclick="testWithSampleAddresses()">샘플 주소로 테스트</button>
        <button onclick="testRouteFinding()" style="background-color: #2196F3;">경로 찾기 테스트</button>
        <button onclick="testSectionOnly()" style="background-color: #FF9800;">Section만 출력</button>
        <button onclick="testRestAreaSearch()" style="background-color: #4CAF50;">휴게소 검색</button>
    </div>

    <!-- 결과 표시 영역 -->
    <div id="result" class="result-area" style="display: none;">
        <h3>✅ 성공 결과:</h3>
        <pre id="resultContent"></pre>
    </div>

    <div id="error" class="error-area" style="display: none;">
        <h3>❌ 에러 결과:</h3>
        <pre id="errorContent"></pre>
    </div>

    <!-- 네이버 지도 표시 영역 -->
    <div id="map"></div>
</div>

<script>
    /**
     * 네이버 맵 API 테스트 - 지도 표시 기능
     *
     * 기능:
     * 1. 네이버 지도를 생성하고 표시
     * 2. 지정된 좌표에 마커 추가
     * 3. 지도 API가 정상적으로 로드되었는지 확인
     */
    function testMapAPI() {
        try {
            // 지도 생성 옵션 설정
            var mapOptions = {
                center: new naver.maps.LatLng(37.5665, 126.9780), // 서울시청 좌표
                zoom: 10 // 줌 레벨 설정
            };

            // 네이버 지도 객체 생성
            var map = new naver.maps.Map('map', mapOptions);

            // 마커 생성 및 지도에 추가
            var marker = new naver.maps.Marker({
                position: new naver.maps.LatLng(37.5665, 126.9780), // 서울시청 좌표
                map: map
            });

            showResult("지도 API가 성공적으로 로드되었습니다!");

        } catch (error) {
            showError("지도 API 오류: " + error.message);
        }
    }

    /**
     * 샘플 주소로 테스트 - 랜덤 샘플 주소 설정
     *
     * 기능:
     * 1. 미리 정의된 샘플 주소 중 하나를 랜덤 선택
     * 2. 선택된 주소를 검색 필드에 설정
     * 3. 사용자가 쉽게 테스트할 수 있도록 도움
     */
    function testWithSampleAddresses() {
        // 테스트용 샘플 주소 배열
        var sampleAddresses = [
            "서울특별시 강남구 강남대로 396",
            "서울특별시 중구 세종대로 110",
            "서울특별시 용산구 한강대로 405",
            "서울특별시 마포구 와우산로 94"
        ];

        // 랜덤하게 샘플 주소 선택
        var randomAddress = sampleAddresses[Math.floor(Math.random() * sampleAddresses.length)];
        document.getElementById('query').value = randomAddress;

        showResult("샘플 주소로 설정되었습니다: " + randomAddress + "\n\n이제 '지오코딩 API 테스트' 버튼을 클릭해보세요!");
    }

    /**
     * 지오코딩 테스트 - 주소를 좌표로 변환
     *
     * 기능:
     * 1. 입력된 주소를 네이버 맵 API의 Geocoder 서비스로 전송
     * 2. 주소에 해당하는 좌표(경도, 위도) 정보를 받아옴
     * 3. 결과를 화면에 표시
     *
     * @example
     * 입력: "서울특별시 강남구 강남대로 396"
     * 출력: 좌표 (127.0283079, 37.4981647)
     */
    function testGeocoding() {
        try {
            var query = document.getElementById('query').value;

            // 네이버 맵 API의 Geocoder 서비스 사용
            if (naver.maps.Service && naver.maps.Service.geocode) {
                // Geocoder 서비스 호출
                naver.maps.Service.geocode({
                    query: query // 검색할 주소
                }, function (status, response) {
                    if (status === naver.maps.Service.Status.OK) {
                        var result = response.v2; // API 응답 데이터

                        // 결과 분석 및 표시용 문자열 구성
                        var analysis = "지오코딩 성공:\n";
                        analysis += "검색어: " + query + "\n";
                        analysis += "결과 수: " + result.addresses.length + "\n\n";

                        if (result.addresses.length > 0) {
                            analysis += "첫 번째 결과:\n";
                            var firstAddress = result.addresses[0];
                            analysis += "- 도로명주소: " + (firstAddress.roadAddress || "없음") + "\n";
                            analysis += "- 지번주소: " + (firstAddress.jibunAddress || "없음") + "\n";
                            analysis += "- 좌표: " + firstAddress.x + ", " + firstAddress.y + "\n\n";
                        }

                        analysis += "전체 응답:\n" + JSON.stringify(result, null, 2);
                        showResult(analysis);
                    } else {
                        showError("지오코딩 실패: " + status + "\n\n💡 팁: 더 정확한 주소를 입력해보세요. (예: '강남역' → '서울특별시 강남구 강남대로 396')");
                    }
                });
            } else {
                // Geocoder 서비스가 없는 경우 대안 방법
                showError("Geocoder 서비스를 사용할 수 없습니다. 네이버 맵 API 키를 확인해주세요.");
            }

        } catch (error) {
            showError("지오코딩 오류: " + error.message);
        }
    }

    /**
     * 역지오코딩 테스트 - 좌표를 주소로 변환
     *
     * 기능:
     * 1. 입력된 좌표(경도, 위도)를 네이버 맵 API의 Geocoder 서비스로 전송
     * 2. 좌표에 해당하는 주소 정보를 받아옴
     * 3. 결과를 화면에 표시
     *
     * @example
     * 입력: 좌표 (126.9780, 37.5665)
     * 출력: "서울특별시 중구 세종대로 110"
     */
    function testReverseGeocoding() {
        try {
            var lat = parseFloat(document.getElementById('lat').value); // 위도
            var lng = parseFloat(document.getElementById('lng').value); // 경도

            // 네이버 맵 API의 Geocoder 서비스 사용
            if (naver.maps.Service && naver.maps.Service.reverseGeocode) {
                // 역지오코딩 서비스 호출
                naver.maps.Service.reverseGeocode({
                    coords: new naver.maps.LatLng(lat, lng), // 좌표 객체 생성
                    orders: [naver.maps.Service.OrderType.ADDR, naver.maps.Service.OrderType.ROAD_ADDR].join(',') // 주소 타입 지정
                }, function (status, response) {
                    if (status === naver.maps.Service.Status.OK) {
                        var result = response.v2; // API 응답 데이터
                        showResult("역지오코딩 성공:\n" + JSON.stringify(result, null, 2));
                    } else {
                        showError("역지오코딩 실패: " + status);
                    }
                });
            } else {
                // Geocoder 서비스가 없는 경우 대안 방법
                showError("Geocoder 서비스를 사용할 수 없습니다. 네이버 맵 API 키를 확인해주세요.");
            }

        } catch (error) {
            showError("역지오코딩 오류: " + error.message);
        }
    }

    /**
     * 검색 API 테스트 - 주소 검색 기능
     *
     * 기능:
     * 1. 입력된 검색어로 주소 검색 수행
     * 2. 지오코딩과 동일한 API를 사용하지만 검색 목적으로 활용
     * 3. 결과를 화면에 표시
     */
    function testSearchAPI() {
        try {
            var query = document.getElementById('query').value;

            // 네이버 맵 API의 Geocoder 서비스 사용 (주소 검색)
            if (naver.maps.Service && naver.maps.Service.geocode) {
                // Geocoder 서비스 호출 (지오코딩과 동일)
                naver.maps.Service.geocode({
                    query: query // 검색할 주소
                }, function (status, response) {
                    if (status === naver.maps.Service.Status.OK) {
                        var result = response.v2; // API 응답 데이터
                        showResult("검색 성공:\n" + JSON.stringify(result, null, 2));
                    } else {
                        showError("검색 실패: " + status);
                    }
                });
            } else {
                // Geocoder 서비스가 없는 경우 대안 방법
                showError("Geocoder 서비스를 사용할 수 없습니다. 네이버 맵 API 키를 확인해주세요.");
            }

        } catch (error) {
            showError("검색 오류: " + error.message);
        }
    }

    /**
     * 경로 찾기 테스트 - Directions 5 API 호출
     *
     * 기능:
     * 1. 출발지와 목적지 주소를 좌표로 변환 (지오코딩)
     * 2. 변환된 좌표로 서버의 Directions 5 API 호출
     * 3. 경로 정보를 받아와서 화면에 표시
     *
     * 동작 흐름:
     * 주소 입력 → 지오코딩 → 서버 API 호출 → 경로 정보 표시
     */
    function testRouteFinding() {
        try {
            var startAddress = document.getElementById('startAddress').value; // 출발지 주소
            var endAddress = document.getElementById('endAddress').value;     // 목적지 주소

            // 입력값 검증
            if (!startAddress || !endAddress) {
                showError("출발지와 목적지를 모두 입력해주세요.");
                return;
            }

            showResult("경로 찾기 시작...\n출발지: " + startAddress + "\n목적지: " + endAddress + "\n\n지오코딩 중...");

            // 1단계: 출발지 지오코딩 (주소 → 좌표)
            naver.maps.Service.geocode({
                query: startAddress
            }, function (startStatus, startResponse) {
                if (startStatus === naver.maps.Service.Status.OK && startResponse.v2.addresses.length > 0) {
                    var startCoords = startResponse.v2.addresses[0]; // 출발지 좌표 정보

                    // 2단계: 목적지 지오코딩 (주소 → 좌표)
                    naver.maps.Service.geocode({
                        query: endAddress
                    }, function (endStatus, endResponse) {
                        if (endStatus === naver.maps.Service.Status.OK && endResponse.v2.addresses.length > 0) {
                            var endCoords = endResponse.v2.addresses[0]; // 목적지 좌표 정보

                            // 3단계: Directions 5 API 호출 (서버로 좌표 전송)
                            callDirectionsAPI(startCoords, endCoords);

                        } else {
                            showError("목적지 지오코딩 실패: " + endStatus + "\n\n💡 팁: 더 정확한 주소를 입력해보세요.");
                        }
                    });

                } else {
                    showError("출발지 지오코딩 실패: " + startStatus + "\n\n💡 팁: 더 정확한 주소를 입력해보세요.");
                }
            });

        } catch (error) {
            showError("경로 찾기 오류: " + error.message);
        }
    }

    /**
     * Directions 5 API 호출 - 서버로 경로 요청
     *
     * 기능:
     * 1. 지오코딩으로 얻은 좌표를 서버로 전송
     * 2. 서버에서 NAVER Cloud Platform Directions 5 API 호출
     * 3. 경로 정보를 받아와서 화면에 표시
     *
     * @param {Object} startCoords 출발지 좌표 정보 {x: 경도, y: 위도, roadAddress: 주소}
     * @param {Object} endCoords 목적지 좌표 정보 {x: 경도, y: 위도, roadAddress: 주소}
     */
    function callDirectionsAPI(startCoords, endCoords) {
        try {
            console.log("Directions API 호출 시작...");
            console.log("출발지 좌표:", startCoords.x, startCoords.y);
            console.log("목적지 좌표:", endCoords.x, endCoords.y);

            // URL-encoded 형식으로 데이터 준비 (서버로 전송할 파라미터)
            var params = new URLSearchParams();
            params.append('action', 'directions');           // 서버에서 처리할 액션
            params.append('startX', startCoords.x);         // 출발지 경도
            params.append('startY', startCoords.y);         // 출발지 위도
            params.append('endX', endCoords.x);             // 목적지 경도
            params.append('endY', endCoords.y);             // 목적지 위도
            params.append('startAddress', startCoords.roadAddress); // 출발지 주소
            params.append('endAddress', endCoords.roadAddress);     // 목적지 주소

            console.log("요청 URL:", window.location.href);
            console.log("요청 데이터:", params.toString());

            // 서버로 POST 요청 전송
            fetch(window.location.href, {
                method: 'POST', // HTTP 메서드
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded', // 폼 데이터 형식
                },
                body: params.toString() // URL-encoded 파라미터
            })
                .then(response => {
                    // 응답 상태 확인
                    console.log("응답 상태:", response.status);
                    console.log("응답 헤더:", response.headers);
                    return response.text(); // 응답을 텍스트로 변환
                })
                .then(data => {
                    console.log("서버 응답 (처음 500자):", data.substring(0, 500));

                    // HTML 응답인지 확인 (오류 처리)
                    if (data.trim().startsWith('<')) {
                        showError("서버에서 HTML 응답을 받았습니다. JSON이 아닙니다.\n\n응답 내용:\n" + data.substring(0, 1000));
                        return;
                    }

                    try {
                        var result = JSON.parse(data); // JSON 파싱
                        if (result.error) {
                            showError("Directions API 오류: " + result.error);
                        } else {
                            displayRouteResult(startCoords, endCoords, result); // 경로 결과 표시
                        }
                    } catch (e) {
                        showError("응답 파싱 오류: " + e.message + "\n\n응답 내용:\n" + data.substring(0, 1000));
                    }
                })
                .catch(error => {
                    console.error("Directions API 요청 오류:", error);
                    showError("Directions API 요청 오류: " + error.message);
                });

        } catch (error) {
            console.error("Directions API 호출 오류:", error);
            showError("Directions API 호출 오류: " + error.message);
        }
    }

    /**
     * 경로 결과 표시 - Directions 5 API 응답 처리
     *
     * 기능:
     * 1. 서버에서 받은 경로 정보를 분석
     * 2. 거리, 시간, 톨게이트 요금 등 주요 정보 추출
     * 3. 사용자 친화적인 형태로 화면에 표시
     * 4. 지도에 경로 시각화
     *
     * @param {Object} startCoords 출발지 좌표 정보
     * @param {Object} endCoords 목적지 좌표 정보
     * @param {Object} directionsResult 서버에서 받은 경로 정보
     */
    function displayRouteResult(startCoords, endCoords, directionsResult) {
        // 결과 표시용 문자열 구성
        var routeInfo = "🗺️ 경로 찾기 완료!\n\n";
        routeInfo += "📍 출발지:\n";
        routeInfo += "- 주소: " + startCoords.roadAddress + "\n";
        routeInfo += "- 좌표: " + startCoords.x + ", " + startCoords.y + "\n\n";

        routeInfo += "🎯 목적지:\n";
        routeInfo += "- 주소: " + endCoords.roadAddress + "\n";
        routeInfo += "- 좌표: " + endCoords.x + ", " + endCoords.y + "\n\n";

        // Directions API 결과 분석
        if (directionsResult.route && directionsResult.route.traoptimal && directionsResult.route.traoptimal.length > 0) {
            var route = directionsResult.route.traoptimal[0]; // 첫 번째 경로 선택

            // 1. 기본 경로 정보 추출
            routeInfo += "🚗 기본 경로 정보:\n";
            routeInfo += "- 총 거리: " + (route.summary.distance / 1000).toFixed(2) + " km\n"; // 미터를 킬로미터로 변환
            routeInfo += "- 예상 소요시간: " + Math.round(route.summary.duration / 60) + "분\n"; // 초를 분으로 변환
            routeInfo += "- 톨게이트 요금: " + route.summary.tollFare + "원\n";
            routeInfo += "- 연료비: " + route.summary.fuelPrice + "원\n";
            routeInfo += "- 택시 요금: " + route.summary.taxiFare + "원\n\n";

            // 2. 경로 상세 정보 (구간별 정보) - 원하는 구간만 추출 가능
            if (route.section && route.section.length > 0) {
                routeInfo += "🛣️ 경로 상세 (구간별):\n";
                for (var i = 0; i < route.section.length; i++) {
                    var section = route.section[i];
                    routeInfo += (i + 1) + ". " + section.name + "\n";
                    routeInfo += "   거리: " + (section.distance / 1000).toFixed(2) + " km\n";
                    routeInfo += "   시간: " + Math.round(section.duration / 60) + "분\n";
                    routeInfo += "   혼잡도: " + getCongestionText(section.congestion) + "\n";
                    routeInfo += "   평균 속도: " + section.speed + " km/h\n";
                    if (section.tollFare > 0) {
                        routeInfo += "   톨게이트: " + section.tollFare + "원\n";
                    }
                    routeInfo += "\n";
                }
            }

            // 3. 경로 안내 정보 (단계별 안내) - 원하는 단계만 추출 가능
            if (route.guide && route.guide.length > 0) {
                routeInfo += "🧭 경로 안내 (단계별):\n";
                for (var i = 0; i < route.guide.length; i++) {
                    var guide = route.guide[i];
                    routeInfo += (i + 1) + ". " + guide.instructions + "\n";
                    routeInfo += "   거리: " + (guide.distance / 1000).toFixed(2) + " km\n";
                    routeInfo += "   시간: " + Math.round(guide.duration / 60) + "분\n";
                    routeInfo += "   타입: " + getGuideTypeText(guide.type) + "\n\n";
                }
            }

            // 4. 경로 좌표 정보 (지도 표시용)
            if (route.path && route.path.length > 0) {
                routeInfo += "📍 경로 좌표 (처음 5개):\n";
                for (var i = 0; i < Math.min(5, route.path.length); i++) {
                    var point = route.path[i];
                    routeInfo += (i + 1) + ". 경도: " + point[0] + ", 위도: " + point[1] + "\n";
                }
                routeInfo += "... (총 " + route.path.length + "개 좌표)\n\n";
            }
        }

        // 5. section만 출력하는 함수 호출
        routeInfo += extractOnlySections(directionsResult);

        // 전체 응답 데이터도 표시 (디버깅용)
        routeInfo += "📋 전체 응답:\n" + JSON.stringify(directionsResult, null, 2);
        showResult(routeInfo);

        // 지도에 경로 표시
        displayRouteOnMap(startCoords, endCoords);
    }

    /**
     * 원하는 요소만 추출하는 함수
     *
     * @param {Object} directionsResult API 응답 데이터
     * @returns {string} 추출된 요소들의 문자열
     */
    function extractSpecificElements(directionsResult) {
        var extracted = "";

        if (directionsResult.route && directionsResult.route.traoptimal && directionsResult.route.traoptimal.length > 0) {
            var route = directionsResult.route.traoptimal[0];

            // 예시 1: 고속도로만 추출
            extracted += "고속도로 정보:\n";
            if (route.section) {
                var highways = route.section.filter(function (section) {
                    return section.name && section.name.includes('고속도로');
                });
                highways.forEach(function (highway, index) {
                    extracted += "- " + highway.name + " (" + (highway.distance / 1000).toFixed(2) + "km)\n";
                });
            }

            // 예시 2: 톨게이트가 있는 구간만 추출
            extracted += "\n톨게이트 구간:\n";
            if (route.section) {
                var tollSections = route.section.filter(function (section) {
                    return section.tollFare && section.tollFare > 0;
                });
                tollSections.forEach(function (section, index) {
                    extracted += "- " + section.name + " (" + section.tollFare + "원)\n";
                });
            }

            // 예시 3: 특정 거리 이상의 구간만 추출
            extracted += "\n긴 구간 (5km 이상):\n";
            if (route.section) {
                var longSections = route.section.filter(function (section) {
                    return section.distance >= 5000; // 5km 이상
                });
                longSections.forEach(function (section, index) {
                    extracted += "- " + section.name + " (" + (section.distance / 1000).toFixed(2) + "km)\n";
                });
            }
        }

        return extracted;
    }

    /**
     * section만 출력하는 함수
     *
     * @param {Object} directionsResult API 응답 데이터
     * @returns {string} section 정보만의 문자열
     */
    function extractOnlySections(directionsResult) {
        var sectionInfo = "📋 Section 정보만 출력:\n\n";

        if (directionsResult.route && directionsResult.route.traoptimal && directionsResult.route.traoptimal.length > 0) {
            var route = directionsResult.route.traoptimal[0];

            if (route.section && route.section.length > 0) {
                sectionInfo += "총 " + route.section.length + "개 구간\n\n";

                for (var i = 0; i < route.section.length; i++) {
                    var section = route.section[i];
                    sectionInfo += "구간 " + (i + 1) + ":\n";
                    sectionInfo += "- 도로명: " + section.name + "\n";
                    sectionInfo += "- 거리: " + (section.distance / 1000).toFixed(2) + " km\n";
                    sectionInfo += "- 시간: " + Math.round(section.duration / 60) + "분\n";
                    sectionInfo += "- 혼잡도: " + getCongestionText(section.congestion) + "\n";
                    sectionInfo += "- 평균 속도: " + section.speed + " km/h\n";

                    if (section.tollFare && section.tollFare > 0) {
                        sectionInfo += "- 톨게이트: " + section.tollFare + "원\n";
                    }

                    sectionInfo += "\n";
                }
            } else {
                sectionInfo += "Section 정보가 없습니다.\n";
            }
        } else {
            sectionInfo += "경로 정보가 없습니다.\n";
        }

        return sectionInfo;
    }

    /**
     * 혼잡도 텍스트 변환 함수
     *
     * @param {number} congestion 혼잡도 코드
     * @returns {string} 혼잡도 텍스트
     */
    function getCongestionText(congestion) {
        switch (congestion) {
            case 1:
                return "원활";
            case 2:
                return "서행";
            case 3:
                return "정체";
            case 4:
                return "매우 정체";
            default:
                return "알 수 없음";
        }
    }

    /**
     * 안내 타입 텍스트 변환 함수
     *
     * @param {number} type 안내 타입 코드
     * @returns {string} 안내 타입 텍스트
     */
    function getGuideTypeText(type) {
        switch (type) {
            case 1:
                return "직진";
            case 2:
                return "우회전";
            case 3:
                return "좌회전";
            case 6:
                return "유턴";
            case 88:
                return "목적지";
            default:
                return "기타 (" + type + ")";
        }
    }

    /**
     * Section만 출력하는 테스트 함수
     *
     * 기능:
     * 1. 출발지와 목적지 주소를 좌표로 변환
     * 2. Directions 5 API 호출
     * 3. Section 정보만 추출하여 표시
     */
    function testSectionOnly() {
        try {
            var startAddress = document.getElementById('startAddress').value;
            var endAddress = document.getElementById('endAddress').value;

            if (!startAddress || !endAddress) {
                showError("출발지와 목적지를 모두 입력해주세요.");
                return;
            }

            showResult("Section 정보 추출 시작...\n출발지: " + startAddress + "\n목적지: " + endAddress + "\n\n지오코딩 중...");

            // 출발지 지오코딩
            naver.maps.Service.geocode({
                query: startAddress
            }, function (startStatus, startResponse) {
                if (startStatus === naver.maps.Service.Status.OK && startResponse.v2.addresses.length > 0) {
                    var startCoords = startResponse.v2.addresses[0];

                    // 목적지 지오코딩
                    naver.maps.Service.geocode({
                        query: endAddress
                    }, function (endStatus, endResponse) {
                        if (endStatus === naver.maps.Service.Status.OK && endResponse.v2.addresses.length > 0) {
                            var endCoords = endResponse.v2.addresses[0];

                            // Directions 5 API 호출
                            callDirectionsAPIForSection(startCoords, endCoords);

                        } else {
                            showError("목적지 지오코딩 실패: " + endStatus);
                        }
                    });

                } else {
                    showError("출발지 지오코딩 실패: " + startStatus);
                }
            });

        } catch (error) {
            showError("Section 테스트 오류: " + error.message);
        }
    }

    /**
     * Section만 출력하는 Directions API 호출
     *
     * @param {Object} startCoords 출발지 좌표 정보
     * @param {Object} endCoords 목적지 좌표 정보
     */
    function callDirectionsAPIForSection(startCoords, endCoords) {
        try {
            console.log("Section 추출용 Directions API 호출 시작...");

            var params = new URLSearchParams();
            params.append('action', 'directions');
            params.append('startX', startCoords.x);
            params.append('startY', startCoords.y);
            params.append('endX', endCoords.x);
            params.append('endY', endCoords.y);
            params.append('startAddress', startCoords.roadAddress);
            params.append('endAddress', endCoords.roadAddress);

            fetch(window.location.href, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: params.toString()
            })
                .then(response => response.text())
                .then(data => {
                    if (data.trim().startsWith('<')) {
                        showError("서버에서 HTML 응답을 받았습니다.");
                        return;
                    }

                    try {
                        var result = JSON.parse(data);
                        if (result.error) {
                            showError("Directions API 오류: " + result.error);
                        } else {
                            // Section만 출력
                            showResult(extractOnlySections(result));
                        }
                    } catch (e) {
                        showError("응답 파싱 오류: " + e.message);
                    }
                })
                .catch(error => {
                    showError("Directions API 요청 오류: " + error.message);
                });

        } catch (error) {
            showError("Directions API 호출 오류: " + error.message);
        }
    }

    /**
     * 휴게소 검색 테스트 함수
     *
     * 기능:
     * 1. 출발지와 목적지 주소를 좌표로 변환
     * 2. 경로 중간 지점에서 휴게소 검색
     * 3. 휴게소 정보를 화면에 표시
     */
    function testRestAreaSearch() {
        try {
            var startAddress = document.getElementById('startAddress').value;
            var endAddress = document.getElementById('endAddress').value;

            if (!startAddress || !endAddress) {
                showError("출발지와 목적지를 모두 입력해주세요.");
                return;
            }

            showResult("휴게소 검색 시작...\n출발지: " + startAddress + "\n목적지: " + endAddress + "\n\n지오코딩 중...");

            // 출발지 지오코딩
            naver.maps.Service.geocode({
                query: startAddress
            }, function (startStatus, startResponse) {
                if (startStatus === naver.maps.Service.Status.OK && startResponse.v2.addresses.length > 0) {
                    var startCoords = startResponse.v2.addresses[0];

                    // 목적지 지오코딩
                    naver.maps.Service.geocode({
                        query: endAddress
                    }, function (endStatus, endResponse) {
                        if (endStatus === naver.maps.Service.Status.OK && endResponse.v2.addresses.length > 0) {
                            var endCoords = endResponse.v2.addresses[0];

                            // 경로 중간 지점 계산
                            var midX = (parseFloat(startCoords.x) + parseFloat(endCoords.x)) / 2;
                            var midY = (parseFloat(startCoords.y) + parseFloat(endCoords.y)) / 2;

                            // 휴게소 검색
                            searchRestAreas(midX, midY);

                        } else {
                            showError("목적지 지오코딩 실패: " + endStatus);
                        }
                    });

                } else {
                    showError("출발지 지오코딩 실패: " + startStatus);
                }
            });

        } catch (error) {
            showError("휴게소 검색 오류: " + error.message);
        }
    }

    /**
     * 휴게소 검색 함수
     *
     * @param {number} centerX 중심점 경도
     * @param {number} centerY 중심점 위도
     */
    function searchRestAreas(centerX, centerY) {
        try {
            console.log("휴게소 검색 시작...");
            console.log("검색 중심점: " + centerX + ", " + centerY);

            // NAVER Place API 호출을 위한 파라미터
            var params = new URLSearchParams();
            params.append('action', 'searchRestAreas');
            params.append('centerX', centerX);
            params.append('centerY', centerY);

            fetch(window.location.href, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: params.toString()
            })
                .then(response => response.text())
                .then(data => {
                    if (data.trim().startsWith('<')) {
                        showError("서버에서 HTML 응답을 받았습니다.");
                        return;
                    }

                    try {
                        var result = JSON.parse(data);
                        if (result.error) {
                            showError("휴게소 검색 오류: " + result.error);
                        } else {
                            displayRestAreaResult(result);
                        }
                    } catch (e) {
                        showError("응답 파싱 오류: " + e.message);
                    }
                })
                .catch(error => {
                    showError("휴게소 검색 요청 오류: " + error.message);
                });

        } catch (error) {
            showError("휴게소 검색 호출 오류: " + error.message);
        }
    }

    /**
     * 휴게소 검색 결과 표시 함수
     *
     * @param {Object} searchResult 검색 결과
     */
    function displayRestAreaResult(searchResult) {
        var resultInfo = "🏪 휴게소 검색 결과:\n\n";

        if (searchResult.places && searchResult.places.length > 0) {
            resultInfo += "총 " + searchResult.places.length + "개의 휴게소를 찾았습니다.\n\n";

            for (var i = 0; i < searchResult.places.length; i++) {
                var place = searchResult.places[i];
                resultInfo += "휴게소 " + (i + 1) + ":\n";
                resultInfo += "- 이름: " + place.name + "\n";
                resultInfo += "- 주소: " + place.address + "\n";
                resultInfo += "- 거리: " + (place.distance / 1000).toFixed(2) + " km\n";
                resultInfo += "- 카테고리: " + place.category + "\n";

                if (place.roadAddress) {
                    resultInfo += "- 도로명주소: " + place.roadAddress + "\n";
                }

                resultInfo += "\n";
            }
        } else {
            resultInfo += "주변에 휴게소를 찾을 수 없습니다.\n";
            resultInfo += "다른 키워드로 검색해보세요:\n";
            resultInfo += "- '휴게소'\n";
            resultInfo += "- '졸음쉼터'\n";
            resultInfo += "- '고속도로 휴게소'\n";
            resultInfo += "- '주유소'\n";
        }

        showResult(resultInfo);
    }

    /**
     * 거리 계산 함수 (Haversine 공식)
     *
     * 기능:
     * 1. 두 지점 간의 직선 거리를 계산
     * 2. 지구의 곡률을 고려한 정확한 거리 계산
     *
     * @param {number} lat1 첫 번째 지점의 위도
     * @param {number} lon1 첫 번째 지점의 경도
     * @param {number} lat2 두 번째 지점의 위도
     * @param {number} lon2 두 번째 지점의 경도
     * @returns {number} 두 지점 간의 거리 (킬로미터)
     */
    function calculateDistance(lat1, lon1, lat2, lon2) {
        var R = 6371; // 지구의 반지름 (킬로미터)
        var dLat = (lat2 - lat1) * Math.PI / 180; // 위도 차이를 라디안으로 변환
        var dLon = (lon2 - lon1) * Math.PI / 180; // 경도 차이를 라디안으로 변환
        var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
            Math.sin(dLon / 2) * Math.sin(dLon / 2);
        var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        var distance = R * c; // 최종 거리 계산
        return distance;
    }

    /**
     * 지도에 경로 표시 - 시각화 기능
     *
     * 기능:
     * 1. 출발지와 목적지 사이의 경로를 지도에 표시
     * 2. 출발지와 목적지에 마커 추가
     * 3. 경로를 선으로 연결
     * 4. 클릭 시 정보창 표시
     *
     * @param {Object} startCoords 출발지 좌표 정보
     * @param {Object} endCoords 목적지 좌표 정보
     */
    function displayRouteOnMap(startCoords, endCoords) {
        try {
            // 기존 지도 초기화 (중앙점을 출발지와 목적지의 중간으로 설정)
            var mapOptions = {
                center: new naver.maps.LatLng(
                    (parseFloat(startCoords.y) + parseFloat(endCoords.y)) / 2, // 중간 위도
                    (parseFloat(startCoords.x) + parseFloat(endCoords.x)) / 2   // 중간 경도
                ),
                zoom: 12 // 줌 레벨 설정
            };

            var map = new naver.maps.Map('map', mapOptions);

            // 출발지 마커 생성
            var startMarker = new naver.maps.Marker({
                position: new naver.maps.LatLng(startCoords.y, startCoords.x), // 위도, 경도 순서
                map: map,
                title: '출발지'
            });

            // 목적지 마커 생성
            var endMarker = new naver.maps.Marker({
                position: new naver.maps.LatLng(endCoords.y, endCoords.x), // 위도, 경도 순서
                map: map,
                title: '목적지'
            });

            // 경로 선 그리기 (직선 경로)
            var path = new naver.maps.Polyline({
                path: [
                    new naver.maps.LatLng(startCoords.y, startCoords.x), // 출발지 좌표
                    new naver.maps.LatLng(endCoords.y, endCoords.x)      // 목적지 좌표
                ],
                strokeColor: '#FF0000', // 빨간색 선
                strokeWeight: 3,        // 선 두께
                strokeOpacity: 0.8,     // 선 투명도
                map: map
            });

            // 출발지 정보창 생성
            var startInfo = new naver.maps.InfoWindow({
                content: '<div style="padding:10px;min-width:200px;text-align:center;">' +
                    '<h3>출발지</h3>' +
                    '<p>' + startCoords.roadAddress + '</p>' +
                    '</div>'
            });

            // 목적지 정보창 생성
            var endInfo = new naver.maps.InfoWindow({
                content: '<div style="padding:10px;min-width:200px;text-align:center;">' +
                    '<h3>목적지</h3>' +
                    '<p>' + endCoords.roadAddress + '</p>' +
                    '</div>'
            });

            // 마커 클릭 시 정보창 표시 이벤트 추가
            naver.maps.Event.addListener(startMarker, 'click', function () {
                startInfo.open(map, startMarker);
            });

            naver.maps.Event.addListener(endMarker, 'click', function () {
                endInfo.open(map, endMarker);
            });

        } catch (error) {
            console.error("지도 표시 오류:", error);
        }
    }

    /**
     * 성공 결과 표시 함수
     *
     * 기능:
     * 1. 성공 결과 영역을 보이게 설정
     * 2. 오류 결과 영역을 숨김
     * 3. 결과 내용을 화면에 표시
     *
     * @param {string} content 표시할 내용
     */
    function showResult(content) {
        document.getElementById('result').style.display = 'block'; // 성공 영역 표시
        document.getElementById('error').style.display = 'none';   // 오류 영역 숨김
        document.getElementById('resultContent').textContent = content; // 내용 설정
    }

    /**
     * 오류 결과 표시 함수
     *
     * 기능:
     * 1. 오류 결과 영역을 보이게 설정
     * 2. 성공 결과 영역을 숨김
     * 3. 오류 내용을 화면에 표시
     *
     * @param {string} content 표시할 오류 내용
     */
    function showError(content) {
        document.getElementById('error').style.display = 'block'; // 오류 영역 표시
        document.getElementById('result').style.display = 'none'; // 성공 영역 숨김
        document.getElementById('errorContent').textContent = content; // 내용 설정
    }

    /**
     * 페이지 로드 시 초기화 함수
     *
     * 기능:
     * 1. 네이버 맵 API가 정상적으로 로드되었는지 확인
     * 2. Geocoder 서비스 사용 가능 여부 확인
     * 3. 콘솔에 로드 상태 출력
     */
    window.onload = function () {
        // 지도 API가 로드되었는지 확인
        if (typeof naver !== 'undefined' && naver.maps) {
            console.log("네이버 맵 API가 성공적으로 로드되었습니다.");

            // Geocoder 서비스 확인
            if (naver.maps.Service) {
                console.log("Geocoder 서비스가 사용 가능합니다.");
                if (naver.maps.Service.geocode) {
                    console.log("지오코딩 서비스가 사용 가능합니다.");
                }
                if (naver.maps.Service.reverseGeocode) {
                    console.log("역지오코딩 서비스가 사용 가능합니다.");
                }
            } else {
                console.warn("Geocoder 서비스를 사용할 수 없습니다.");
            }
        } else {
            console.error("네이버 맵 API 로드 실패");
        }
    };
</script>
</body>
</html>
