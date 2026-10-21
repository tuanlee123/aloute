<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<head><title>Quản lý bài viết</title></head>

<div class="py-3">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h3 class="fw-bold mb-0">Quản lý bài viết</h3>
    <a href="<c:url value='/admin'/>" class="btn btn-outline-secondary btn-sm">&larr; Dashboard</a>
  </div>

  <c:if test="${not empty msg}"><div class="alert alert-success">${msg}</div></c:if>
  <c:if test="${not empty err}"><div class="alert alert-danger">${err}</div></c:if>

  <div class="card border-0 shadow-sm"><div class="card-body">
    <table class="table table-hover align-middle mb-0">
      <thead><tr><th>ID</th><th>Tác giả</th><th>Nội dung</th><th>Quyền riêng tư</th><th>Thời gian</th><th></th></tr></thead>
      <tbody>
      <c:forEach var="p" items="${posts}">
        <tr>
          <td>${p.id}</td>
          <td><c:out value="${p.user.fullName}"/></td>
          <td style="max-width:380px"><c:out value="${p.content}"/></td>
          <td>${p.privacy}</td>
          <td>${fn:replace(fn:substring(p.createdAt, 0, 16), 'T', ' ')}</td>
          <td>
            <form method="post" action="<c:url value='/admin/posts/${p.id}/delete'/>"
                  onsubmit="return confirm('Xóa bài viết vi phạm này? Không thể hoàn tác.');">
              <button class="btn btn-sm btn-danger">Xóa</button>
            </form>
          </td>
        </tr>
      </c:forEach>
      </tbody>
    </table>
  </div></div>
</div>
