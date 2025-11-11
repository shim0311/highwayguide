<%-- src/main/webapp/searchResults.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="com.google.gson.JsonObject" %>
<%@ page import="com.google.gson.JsonArray" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>검색 결과</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; background-color: #f4f4f4; }
    .container { background-color: #fff; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); max-width: 800px; margin: 30px auto; }
    h1 { color: #0056b3; }
    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    th, td { padding: 12px; border: 1px solid #ddd; text-align: left; }
    th { background-color: #f2f2f2; }
    a { text-decoration: none; color: #0056b3; font-weight: bold; }
    a:hover { text-decoration: underline; }
    .error { color: #d9534f; font-weight: bold; }
  </style>
</head>
<body>
<div class="container">
  <h1>휴게소 검색 결과</h1>

  <%
    String searchResultsJson = (String) request.getAttribute("searchResults");
    Gson gson = new Gson();

    if (searchResultsJson != null && !searchResultsJson.trim().isEmpty()) {
      JsonObject data = gson.fromJson(searchResultsJson, JsonObject.class);

      if (data.has("searchPoiInfo") && !data.getAsJsonObject("searchPoiInfo").get("totalCount").getAsString().equals("0")) {
        JsonArray pois = data.getAsJsonObject("searchPoiInfo").getAsJsonObject("pois").getAsJsonArray("poi");
  %>
  <table>
    <thead>
    <tr>
      <th>이름</th>
      <th>주소</th>
      <th>POI ID</th>
      <th></th>
    </tr>
    </thead>
    <tbody>
    <%
      for (int i = 0; i < pois.size(); i++) {
        JsonObject poi = pois.get(i).getAsJsonObject();
        String id = poi.get("id").getAsString();
        String name = poi.get("name").getAsString();
        String address = poi.get("newAddressList").getAsJsonArray().get(0).getAsJsonObject().get("fullAddressRoad").getAsString();
    %>
    <tr>
      <td><%= name %></td>
      <td><%= address %></td>
      <td><%= id %></td>
      <td>
        <a href="Controller?type=congestion&poiId=<%= id %>">혼잡도 보기</a>
      </td>
    </tr>
    <%
      }
    %>
    </tbody>
  </table>
  <%
  } else {
  %>
  <h2 class="error">검색 결과가 없습니다.</h2>
  <p>다른 휴게소 이름으로 검색해보세요.</p>
  <%
    }
  } else {
  %>
  <h2 class="error">데이터를 가져오는 데 실패했습니다.</h2>
  <p>오류 메시지: <%= searchResultsJson %></p>
  <%
    }
  %>
</div>
</body>
</html>