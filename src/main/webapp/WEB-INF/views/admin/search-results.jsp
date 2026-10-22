<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<head>
  <title>Kết quả tìm kiếm | ALOUTE</title>
</head>

<div class="py-3" style="max-width: 760px; margin: 0 auto;">
  <div class="d-flex align-items-center mb-4 pb-2 border-bottom">
    <h4 class="fw-bold mb-0">
      <i class="bi bi-search text-primary me-2"></i>Kết quả cho: "<c:out value="${keyword}"/>"
    </h4>
  </div>

  <!-- 1. Bảng người dùng tìm thấy -->
  <div class="d-flex justify-content-between align-items-center mb-2">
    <h5 class="fw-bold mb-0 text-dark">
      <i class="bi bi-people-fill text-success me-1"></i>Người dùng
    </h5>
    <span class="badge bg-light text-muted border rounded-pill px-3">${fn:length(users)} kết quả</span>
  </div>

  <c:if test="${empty users}">
    <div class="card border-0 shadow-sm rounded-4 mb-4">
      <div class="card-body text-center py-4 text-muted small">
        <i class="bi bi-person-x fs-2 d-block mb-1 opacity-50"></i>
        Không tìm thấy người dùng phù hợp.
      </div>
    </div>
  </c:if>

  <c:if test="${not empty users}">
    <div class="list-group shadow-sm rounded-4 mb-4 overflow-hidden border-0">
      <c:forEach var="u" items="${users}">
        <a href="<c:url value='/profile'><c:param name='userId' value='${u.id}'/></c:url>"
           class="list-group-item list-group-item-action d-flex align-items-center p-3 border-bottom border-light">
          <img src="${empty u.avatar ? 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg' : u.avatar}"
               class="rounded-circle me-3 border" width="48" height="48" style="object-fit:cover" alt="">
          <div class="flex-grow-1">
            <div class="fw-bold text-dark fs-6"><c:out value="${empty u.fullName ? u.username : u.fullName}"/></div>
            <small class="text-muted">@<c:out value="${u.username}"/></small>
          </div>
          <span class="btn btn-sm btn-outline-primary rounded-pill px-3">Xem hồ sơ</span>
        </a>
      </c:forEach>
    </div>
  </c:if>

  <!-- 2. Bảng bài viết tìm thấy -->
  <div class="d-flex justify-content-between align-items-center mb-2 mt-4">
    <h5 class="fw-bold mb-0 text-dark">
      <i class="bi bi-file-earmark-text-fill text-warning me-1"></i>Bài viết
    </h5>
    <span class="badge bg-light text-muted border rounded-pill px-3">${fn:length(posts)} kết quả</span>
  </div>

  <c:if test="${empty posts}">
    <div class="card border-0 shadow-sm rounded-4">
      <div class="card-body text-center py-4 text-muted small">
        <i class="bi bi-file-earmark-x fs-2 d-block mb-1 opacity-50"></i>
        Không tìm thấy bài viết phù hợp.
      </div>
    </div>
  </c:if>

  <c:forEach var="p" items="${posts}">
    <div class="card border-0 shadow-sm rounded-4 mb-3">
      <div class="card-body p-3">
        <div class="d-flex justify-content-between align-items-center mb-2">
          <div class="d-flex align-items-center gap-2">
            <img src="${empty p.user.avatar ? 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg' : p.user.avatar}"
                 class="rounded-circle border" width="36" height="36" style="object-fit:cover" alt="">
            <div>
              <div class="fw-semibold text-dark"><c:out value="${empty p.user.fullName ? p.user.username : p.user.fullName}"/></div>
              <small class="text-muted" style="font-size: 0.75rem;">
                ${fn:replace(fn:substring(p.createdAt, 0, 16), 'T', ' ')}
              </small>
            </div>
          </div>

          <!-- Hiển thị nhãn quyền riêng tư -->
          <span class="badge ${p.privacy == 'PUBLIC' ? 'bg-primary-subtle text-primary border border-primary-subtle' : (p.privacy == 'FRIENDS' ? 'bg-success-subtle text-success border border-success-subtle' : 'bg-secondary-subtle text-secondary border border-secondary-subtle')} rounded-pill px-2 small">
            <c:choose>
              <c:when test="${p.privacy == 'PUBLIC'}">🌐 Công khai</c:when>
              <c:when test="${p.privacy == 'FRIENDS'}">👥 Bạn bè</c:when>
              <c:otherwise>🔒 Riêng tư</c:otherwise>
            </c:choose>
          </span>
        </div>

        <div class="my-2 text-dark" style="white-space: pre-line; word-break: break-word;">
          <c:out value="${p.content}"/>
        </div>

        <div class="pt-2 border-top mt-2 d-flex justify-content-end gap-2 align-items-center">
          <!-- Xem chi tiết bài viết -->
          <a href="<c:url value='/post/${p.id}'/>" class="btn btn-sm btn-outline-primary rounded-pill px-3">
            <i class="bi bi-box-arrow-up-right me-1"></i>Xem bài viết
          </a>

          <!-- Nút xóa bài viết cho Quản trị viên hoặc tác giả bài viết -->
          <c:if test="${sessionScope.currentUser != null && (sessionScope.currentUser.id == p.user.id || sessionScope.isAdminUser == true)}">
            <form action="<c:url value='/post/delete/${p.id}'/>" method="post" class="m-0"
                  onsubmit="return confirm('Bạn có chắc chắn muốn xóa bài viết này không?');">
              <input type="hidden" name="redirectUrl" value="/search?q=${keyword}">
              <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill px-3">
                <i class="bi bi-trash3 me-1"></i>Xóa
              </button>
            </form>
          </c:if>
        </div>
      </div>
    </div>
  </c:forEach>
</div>