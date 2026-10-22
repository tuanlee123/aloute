<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<head>
  <title>Quản lý bài viết | ALOUTE</title>
</head>

<div class="py-3">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h3 class="fw-bold mb-0"><i class="bi bi-file-earmark-post text-primary me-2"></i>Quản lý bài viết</h3>
    <a href="<c:url value='/admin'/>" class="btn btn-outline-secondary btn-sm rounded-pill px-3">&larr; Dashboard</a>
  </div>

  <c:if test="${not empty msg}">
    <div class="alert alert-success rounded-3 py-2 px-3 shadow-sm">${msg}</div>
  </c:if>
  <c:if test="${not empty err}">
    <div class="alert alert-danger rounded-3 py-2 px-3 shadow-sm">${err}</div>
  </c:if>

  <div class="card border-0 shadow-sm rounded-4">
    <div class="card-body p-0">
      <div class="table-responsive">
        <table class="table table-hover align-middle mb-0">
          <thead class="table-light">
            <tr>
              <th class="ps-3">ID</th>
              <th>Tác giả</th>
              <th>Nội dung</th>
              <th>Quyền riêng tư</th>
              <th>Thời gian</th>
              <th class="text-end pe-3">Thao tác</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="p" items="${posts}">
              <tr>
                <td class="ps-3 fw-bold text-muted">#${p.id}</td>
                <td>
                  <div class="d-flex align-items-center gap-2">
                    <img src="${empty p.user.avatar ? 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg' : p.user.avatar}"
                         class="rounded-circle border" width="32" height="32" style="object-fit: cover;">
                    <div class="fw-semibold text-dark">
                      <c:out value="${empty p.user.fullName ? p.user.username : p.user.fullName}"/>
                    </div>
                  </div>
                </td>
                <td style="max-width: 380px;">
                  <div class="text-truncate text-secondary">
                    <c:out value="${p.content}"/>
                  </div>
                </td>
                <td>
                  <span class="badge ${p.privacy == 'PUBLIC' ? 'bg-primary-subtle text-primary border border-primary-subtle' : (p.privacy == 'FRIENDS' ? 'bg-success-subtle text-success border border-success-subtle' : 'bg-secondary-subtle text-secondary border border-secondary-subtle')} rounded-pill px-2">
                    <c:choose>
                      <c:when test="${p.privacy == 'PUBLIC'}">🌐 Công khai</c:when>
                      <c:when test="${p.privacy == 'FRIENDS'}">👥 Bạn bè</c:when>
                      <c:otherwise>🔒 Riêng tư</c:otherwise>
                    </c:choose>
                  </span>
                </td>
                <td class="text-muted small">
                  ${fn:replace(fn:substring(p.createdAt, 0, 16), 'T', ' ')}
                </td>
                <td class="text-end pe-3">
                  <div class="d-inline-flex gap-1">
                    <!-- Mở xem trực tiếp trang chi tiết bài viết qua PostController -->
                    <a href="<c:url value='/post/${p.id}'/>" target="_blank" 
                       class="btn btn-sm btn-outline-primary rounded-pill px-2" title="Xem chi tiết bài viết">
                      <i class="bi bi-box-arrow-up-right"></i>
                    </a>
                    
                    <!-- Nút xóa bài viết vi phạm -->
                    <form method="post" action="<c:url value='/admin/posts/${p.id}/delete'/>" class="d-inline m-0"
                          onsubmit="return confirm('Xác nhận xóa bài viết vi phạm này? Thao tác này không thể hoàn tác.');">
                      <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill px-2" title="Xóa bài viết">
                        <i class="bi bi-trash3-fill"></i>
                      </button>
                    </form>
                  </div>
                </td>
              </tr>
            </c:forEach>
            <c:if test="${empty posts}">
              <tr>
                <td colspan="6" class="text-center py-4 text-muted">
                  <i class="bi bi-inbox fs-2 d-block mb-1 opacity-50"></i>
                  Hiện chưa có bài viết nào trên hệ thống.
                </td>
              </tr>
            </c:if>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>