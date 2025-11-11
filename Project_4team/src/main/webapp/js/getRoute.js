const clientId = "a3kqiwwu0n";
const clientSecret = "Q4FikPxcG6mAoJmGC76bm8Oe6SXzYfYFlhvdrVNc";

async function getCoordinates(query) {
    const url = `https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=${encodeURIComponent(query)}`;
    const res = await fetch(url, {
        headers: {
            "X-NCP-APIGW-API-KEY-ID": clientId,
            "X-NCP-APIGW-API-KEY": clientSecret
        }
    });
    const json = await res.json();
    if (json.addresses && json.addresses.length > 0) {
        const { x, y } = json.addresses[0];
        return { x, y };
    } else {
        throw new Error("주소를 찾을 수 없습니다: " + query);
    }
}

async function getRoute() {
    const startQuery = document.getElementById("start").value;
    const goalQuery = document.getElementById("goal").value;
    const resultBox = document.getElementById("resultBox");
    resultBox.innerText = "경로를 조회 중입니다...";

    try {
        const start = await getCoordinates(startQuery);
        const goal = await getCoordinates(goalQuery);

        const url = `https://naveropenapi.apigw.ntruss.com/map-direction/v1/driving?start=${start.x},${start.y}&goal=${goal.x},${goal.y}&option=trafast`;

        const res = await fetch(url, {
            headers: {
                "X-NCP-APIGW-API-KEY-ID": clientId,
                "X-NCP-APIGW-API-KEY": clientSecret
            }
        });

        const json = await res.json();
        const roadName = json.route.traoptimal[0].summary.roadName;
        resultBox.innerText = `이 경로에서 주요 도로: ${roadName}`;
    } catch (err) {
        resultBox.innerText = "에러 발생: " + err.message;
    }
}