<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<head><title>Quản trị</title></head>

<div class="py-3">
  <h3 class="fw-bold mb-4"><i class="bi bi-shield-lock-fill text-danger me-2"></i>Trang quản trị</h3>

  <div class="row g-3 mb-4">
    <div class="col-md-4"><div class="card border-0 shadow-sm text-bg-primary"><div class="card-body">
      <div>Tổng thành viên</div><h2 class="mb-0">${totalUsers}</h2></div></div></div>
    <div class="col-md-4"><div class="card border-0 shadow-sm text-bg-success"><div class="card-body">
      <div>Bài viết hôm nay</div><h2 class="mb-0">${postsToday}</h2></div></div></div>
    <div class="col-md-4"><div class="card border-0 shadow-sm text-bg-secondary"><div class="card-body">
      <div>Tổng bài viết</div><h2 class="mb-0">${totalPosts}</h2></div></div></div>
  </div>

  <div class="card border-0 shadow-sm mb-4"><div class="card-body">
    <div class="d-flex justify-content-between align-items-center mb-2">
      <h5 class="mb-0">Thành viên mới</h5>
      <a href="<c:url value='/admin/users'/>" class="btn btn-sm btn-outline-primary">Quản lý người dùng</a>
    </div>
    <table class="table table-hover align-middle mb-0">
      <thead><tr><th>ID</th><th>Username</th><th>Họ tên</th><th>Email</th><th>Trạng thái</th></tr></thead>
      <tbody>
      <c:forEach var="u" items="${recentUsers}">
        <tr>
          <td>${u.id}</td>
          <td><c:out value="${u.username}"/></td>
          <td><c:out value="${u.fullName}"/></td>
          <td><c:out value="${u.email}"/></td>
          <td><c:choose>
            <c:when test="${u.active}"><span class="badge bg-success">Hoạt động</span></c:when>
            <c:otherwise><span class="badge bg-danger">Khóa / chưa kích hoạt</span></c:otherwise>
          </c:choose></td>
        </tr>
      </c:forEach>
      </tbody>
    </table>
  </div></div>

  <div class="card border-0 shadow-sm"><div class="card-body">
    <div class="d-flex justify-content-between align-items-center mb-2">
      <h5 class="mb-0">Bài viết mới</h5>
      <a href="<c:url value='/admin/posts'/>" class="btn btn-sm btn-outline-primary">Quản lý bài viết</a>
    </div>
    <table class="table table-hover align-middle mb-0">
      <thead><tr><th>ID</th><th>Tác giả</th><th>Nội dung</th><th>Thời gian</th></tr></thead>
      <tbody>
      <c:forEach var="p" items="${recentPosts}">
        <tr>
          <td>${p.id}</td>
          <td><c:out value="${p.user.fullName}"/></td>
          <td class="text-truncate" style="max-width:360px"><c:out value="${p.content}"/></td>
          <td>${fn:replace(fn:substring(p.createdAt, 0, 16), 'T', ' ')}</td>
        </tr>
      </c:forEach>
      </tbody>
    </table>
  </div></div>
</div>
