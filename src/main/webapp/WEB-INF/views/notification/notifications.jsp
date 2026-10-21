<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<head><title>Thông báo</title></head>

<div class="py-3" style="max-width:760px">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h3 class="fw-bold mb-0">Thông báo</h3>
    <form method="post" action="<c:url value='/notifications/read-all'/>">
      <button class="btn btn-sm btn-outline-primary">Đánh dấu tất cả đã đọc</button>
    </form>
  </div>

  <c:if test="${empty notifications}"><p class="text-muted">Chưa có thông báo nào.</p></c:if>
  <div class="list-group shadow-sm">
    <c:forEach var="n" items="${notifications}">
      <a href="<c:url value='/notifications/${n.id}/open'/>"
         class="list-group-item list-group-item-action ${n.isRead ? '' : 'bg-primary-subtle fw-semibold'}">
        <c:out value="${n.content}"/>
        <div><small class="text-muted">${fn:replace(fn:substring(n.createdAt, 0, 16), 'T', ' ')}</small></div>
      </a>
    </c:forEach>
  </div>
</div>
