<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<head><title>Quản lý người dùng</title></head>

<div class="py-3">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h3 class="fw-bold mb-0">Quản lý người dùng</h3>
    <a href="<c:url value='/admin'/>" class="btn btn-outline-secondary btn-sm">&larr; Dashboard</a>
  </div>

  <c:if test="${not empty msg}"><div class="alert alert-success">${msg}</div></c:if>
  <c:if test="${not empty err}"><div class="alert alert-danger">${err}</div></c:if>

  <div class="card border-0 shadow-sm"><div class="card-body">
    <table class="table table-hover align-middle mb-0">
      <thead><tr><th>ID</th><th>Username</th><th>Họ tên</th><th>Email</th><th>Quyền</th><th>Trạng thái</th><th></th></tr></thead>
      <tbody>
      <c:forEach var="u" items="${users}">
        <c:set var="rowAdmin" value="false"/>
        <c:forEach var="r" items="${u.roles}">
          <c:if test="${r.name == 'ROLE_ADMIN'}"><c:set var="rowAdmin" value="true"/></c:if>
        </c:forEach>
        <tr>
          <td>${u.id}</td>
          <td><c:out value="${u.username}"/></td>
          <td><c:out value="${u.fullName}"/></td>
          <td><c:out value="${u.email}"/></td>
          <td><c:choose>
            <c:when test="${rowAdmin}"><span class="badge bg-danger">ADMIN</span></c:when>
            <c:otherwise><span class="badge bg-secondary">USER</span></c:otherwise>
          </c:choose></td>
          <td><c:choose>
            <c:when test="${u.active}"><span class="badge bg-success">Hoạt động</span></c:when>
            <c:otherwise><span class="badge bg-danger">Đã khóa</span></c:otherwise>
          </c:choose></td>
          <td>
            <c:if test="${not rowAdmin}">
              <form method="post" action="<c:url value='/admin/users/${u.id}/toggle-lock'/>"
                    onsubmit="return confirm('Xác nhận thay đổi trạng thái tài khoản này?');">
                <c:choose>
                  <c:when test="${u.active}"><button class="btn btn-sm btn-danger">Khóa</button></c:when>
                  <c:otherwise><button class="btn btn-sm btn-success">Mở khóa</button></c:otherwise>
                </c:choose>
              </form>
            </c:if>
          </td>
        </tr>
      </c:forEach>
      </tbody>
    </table>
  </div></div>
</div>
