<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<head>
  <title>Quản lý người dùng | ALOUTE</title>
</head>

<div class="py-3">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <div>
      <h3 class="fw-bold mb-1"><i class="bi bi-people text-primary me-2"></i>Quản lý người dùng</h3>
      <span class="text-muted small">Danh sách và phân quyền tài khoản thành viên hệ thống</span>
    </div>
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
              <th>Thành viên</th>
              <th>Email</th>
              <th class="text-center">Số bài đăng</th>
              <th class="text-center">Số bạn bè</th>
              <th>Trạng thái</th>
              <th>Ngày tạo</th>
              <th class="text-end pe-3">Thao tác</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="u" items="${users}">
              <!-- Kiểm tra User có trong danh sách OnlineIds không -->
              <c:set var="isUserOnline" value="false" />
              <c:forEach var="onId" items="${onlineUserIds}">
                <c:if test="${onId == u.id}">
                  <c:set var="isUserOnline" value="true" />
                </c:if>
              </c:forEach>

              <tr>
                <td class="ps-3 fw-bold text-muted">#${u.id}</td>
                <td>
                  <div class="d-flex align-items-center gap-2">
                    <img src="${empty u.avatar ? 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg' : u.avatar}"
                         class="rounded-circle border" width="36" height="36" style="object-fit: cover;">
                    <div>
                      <div class="fw-semibold text-dark"><c:out value="${u.fullName}"/></div>
                      <small class="text-muted">@<c:out value="${u.username}"/></small>
                    </div>
                  </div>
                </td>
                <td><c:out value="${u.email}"/></td>
                <td class="text-center fw-bold text-primary">${u.totalPosts}</td>
                <td class="text-center fw-bold text-success">${u.totalFriends}</td>
                <td>
                  <c:choose>
                    <c:when test="${!u.active}">
                      <span class="badge bg-danger-subtle text-danger border border-danger-subtle rounded-pill px-2">
                        <i class="bi bi-slash-circle me-1"></i>Bị khóa
                      </span>
                    </c:when>
                    <c:when test="${isUserOnline}">
                      <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-2">
                        <i class="bi bi-circle-fill me-1 small"></i>Trực tuyến
                      </span>
                    </c:when>
                    <c:otherwise>
                      <span class="badge bg-secondary-subtle text-secondary border border-secondary-subtle rounded-pill px-2">
                        <i class="bi bi-moon-fill me-1 small"></i>Ngoại tuyến
                      </span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td class="text-muted small">
                  ${fn:replace(fn:substring(u.createdAt, 0, 10), '-', '/')}
                </td>
                <td class="text-end pe-3">
                  <div class="d-inline-flex gap-1">
                    <a href="<c:url value='/profile?userId=${u.id}'/>" 
                       class="btn btn-sm btn-outline-primary rounded-pill px-2" title="Xem trang cá nhân" target="_blank">
                      <i class="bi bi-eye"></i>
                    </a>
                    
                    <form method="post" action="<c:url value='/admin/users/${u.id}/toggle-lock'/>" class="d-inline m-0"
                          onsubmit="return confirm('Xác nhận thay đổi trạng thái tài khoản này?');">
                      <button type="submit" 
                              class="btn btn-sm ${u.active ? 'btn-outline-danger' : 'btn-outline-success'} rounded-pill px-2"
                              title="${u.active ? 'Khóa tài khoản' : 'Mở khóa tài khoản'}">
                        <i class="bi ${u.active ? 'bi-lock-fill' : 'bi-unlock-fill'}"></i>
                      </button>
                    </form>
                  </div>
                </td>
              </tr>
            </c:forEach>

            <c:if test="${empty users}">
              <tr>
                <td colspan="8" class="text-center py-4 text-muted">
                  <i class="bi bi-people fs-2 d-block mb-1 opacity-50"></i>
                  Hiện chưa có người dùng nào trên hệ thống.
                </td>
              </tr>
            </c:if>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>