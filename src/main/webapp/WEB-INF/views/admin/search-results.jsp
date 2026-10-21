<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<head><title>Tìm kiếm</title></head>

<div class="py-3" style="max-width:760px">
  <h4 class="fw-bold mb-3">Kết quả cho: "<c:out value="${keyword}"/>"</h4>

  <h5 class="mt-3">Người dùng (${fn:length(users)})</h5>
  <c:if test="${empty users}"><p class="text-muted">Không tìm thấy người dùng phù hợp.</p></c:if>
  <div class="list-group shadow-sm mb-4">
    <c:forEach var="u" items="${users}">
      <a href="<c:url value='/profile'><c:param name='userId' value='${u.id}'/></c:url>"
         class="list-group-item list-group-item-action d-flex align-items-center">
        <img src="${empty u.avatar ? 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg' : u.avatar}"
             class="rounded-circle me-3 border" width="44" height="44" style="object-fit:cover" alt="">
        <div>
          <div class="fw-semibold"><c:out value="${u.fullName}"/></div>
          <small class="text-muted">@<c:out value="${u.username}"/></small>
        </div>
      </a>
    </c:forEach>
  </div>

  <h5>Bài viết (${fn:length(posts)})</h5>
  <c:if test="${empty posts}"><p class="text-muted">Không tìm thấy bài viết phù hợp.</p></c:if>
  <c:forEach var="p" items="${posts}">
    <div class="card border-0 shadow-sm mb-2"><div class="card-body">
      <div class="fw-semibold"><c:out value="${p.user.fullName}"/></div>
      <div class="my-1"><c:out value="${p.content}"/></div>
      <small class="text-muted">${fn:replace(fn:substring(p.createdAt, 0, 16), 'T', ' ')}</small>
      <div><a href="<c:url value='/post/feed'/>#post-card-${p.id}">Xem trên bảng tin</a></div>
    </div></div>
  </c:forEach>
</div>
