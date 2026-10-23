<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Quản lý người dùng | ALOUTE Admin</title>

  <!-- Bootstrap 5 CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <!-- Bootstrap Icons -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
  <!-- SweetAlert2 CSS -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">

  <style>
    body {
      background-color: #f4f6f9;
      font-family: system-ui, -apple-system, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    }
    .page-link {
      border-radius: 8px;
      margin: 0 2px;
      color: #0d6efd;
    }
    .page-item.active .page-link {
      background-color: #0d6efd;
      border-color: #0d6efd;
    }
  </style>
</head>
<body>

<div class="container py-4">
  <!-- Tiêu đề và nút quay lại Dashboard -->
  <div class="d-flex justify-content-between align-items-center mb-4">
    <div>
      <h3 class="fw-bold mb-1"><i class="bi bi-people text-primary me-2"></i>Quản lý người dùng</h3>
      <span class="text-muted small">
        Tổng số: <strong><c:out value="${empty totalElements ? fn:length(users) : totalElements}"/></strong> thành viên
      </span>
    </div>
    <a href="<c:url value='/admin'/>" class="btn btn-outline-secondary btn-sm rounded-pill px-3 shadow-sm">
      <i class="bi bi-arrow-left me-1"></i> Dashboard
    </a>
  </div>

  <!-- Thanh tìm kiếm (Search Box) -->
  <div class="card border-0 shadow-sm rounded-4 mb-4">
    <div class="card-body p-3">
      <form method="get" action="<c:url value='/admin/users'/>" class="row g-2 align-items-center">
        <div class="col-md-5 col-12">
          <div class="input-group">
            <span class="input-group-text bg-white border-end-0 text-muted">
              <i class="bi bi-search"></i>
            </span>
            <input type="text" name="keyword" value="<c:out value='${keyword}'/>" class="form-control border-start-0" 
                   placeholder="Tìm theo tên, username hoặc email...">
          </div>
        </div>
        <div class="col-auto">
          <button type="submit" class="btn btn-primary rounded-pill px-4">
            <i class="bi bi-funnel me-1"></i>Tìm kiếm
          </button>
          <c:if test="${not empty keyword}">
            <a href="<c:url value='/admin/users'/>" class="btn btn-light rounded-pill px-3 border ms-1">
              Xóa bộ lọc
            </a>
          </c:if>
        </div>
      </form>
    </div>
  </div>

  <!-- Thông báo phản hồi nếu có chuyển hướng -->
  <c:if test="${not empty msg}">
    <div class="alert alert-success alert-dismissible fade show rounded-3 py-2 px-3 shadow-sm mb-3" role="alert">
      <i class="bi bi-check-circle-fill me-2"></i>${msg}
      <button type="button" class="btn-close py-2" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
  </c:if>
  <c:if test="${not empty err}">
    <div class="alert alert-danger alert-dismissible fade show rounded-3 py-2 px-3 shadow-sm mb-3" role="alert">
      <i class="bi bi-exclamation-triangle-fill me-2"></i>${err}
      <button type="button" class="btn-close py-2" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
  </c:if>

  <!-- Bảng danh sách thành viên -->
  <div class="card border-0 shadow-sm rounded-4 overflow-hidden mb-4">
    <div class="card-body p-0">
      <div class="table-responsive">
        <table class="table table-hover align-middle mb-0">
          <thead class="table-light">
            <tr>
              <th class="ps-3 py-3">ID</th>
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
              <!-- Kiểm tra tài khoản có trực tuyến hay không -->
              <c:set var="isUserOnline" value="false" />
              <c:forEach var="onId" items="${onlineUserIds}">
                <c:if test="${onId == u.id}">
                  <c:set var="isUserOnline" value="true" />
                </c:if>
              </c:forEach>

              <tr id="user-row-${u.id}">
                <td class="ps-3 fw-bold text-muted">#${u.id}</td>
                <td>
                  <div class="d-flex align-items-center gap-2">
                    <img src="${empty u.avatar ? 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg' : u.avatar}"
                         class="rounded-circle border" width="38" height="38" style="object-fit: cover;">
                    <div>
                      <div class="fw-semibold text-dark"><c:out value="${u.fullName}"/></div>
                      <small class="text-muted">@<c:out value="${u.username}"/></small>
                    </div>
                  </div>
                </td>
                <td><c:out value="${u.email}"/></td>
                <td class="text-center fw-bold text-primary">${u.totalPosts}</td>
                <td class="text-center fw-bold text-success">${u.totalFriends}</td>
                
                <!-- Huy hiệu trạng thái -->
                <td id="status-badge-${u.id}" data-online="${isUserOnline}">
                  <c:choose>
                    <c:when test="${!u.active}">
                      <span class="badge bg-danger-subtle text-danger border border-danger-subtle rounded-pill px-2 py-1">
                        <i class="bi bi-slash-circle me-1"></i>Bị khóa
                      </span>
                    </c:when>
                    <c:when test="${isUserOnline}">
                      <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-2 py-1">
                        <i class="bi bi-circle-fill me-1 small"></i>Trực tuyến
                      </span>
                    </c:when>
                    <c:otherwise>
                      <span class="badge bg-secondary-subtle text-secondary border border-secondary-subtle rounded-pill px-2 py-1">
                        <i class="bi bi-moon-fill me-1 small"></i>Ngoại tuyến
                      </span>
                    </c:otherwise>
                  </c:choose>
                </td>

                <td class="text-muted small">
                  ${fn:replace(fn:substring(u.createdAt, 0, 10), '-', '/')}
                </td>
                
                <!-- Các nút thao tác -->
                <td class="text-end pe-3">
                  <div class="d-inline-flex gap-1">
                    <a href="<c:url value='/profile?userId=${u.id}'/>" 
                       class="btn btn-sm btn-outline-primary rounded-pill px-2" title="Xem trang cá nhân" target="_blank">
                      <i class="bi bi-eye"></i>
                    </a>
                    
                    <button type="button" 
                            id="btn-lock-${u.id}"
                            data-active="${u.active}"
                            data-name="<c:out value='${u.fullName}'/>"
                            onclick="handleToggleLock(${u.id})"
                            class="btn btn-sm ${u.active ? 'btn-outline-danger' : 'btn-outline-success'} rounded-pill px-2"
                            title="${u.active ? 'Khóa tài khoản' : 'Mở khóa tài khoản'}">
                      <i class="bi ${u.active ? 'bi-lock-fill' : 'bi-unlock-fill'}"></i>
                    </button>
                  </div>
                </td>
              </tr>
            </c:forEach>

            <c:if test="${empty users}">
              <tr>
                <td colspan="8" class="text-center py-5 text-muted">
                  <i class="bi bi-search fs-1 d-block mb-2 opacity-50"></i>
                  Không tìm thấy người dùng phù hợp.
                </td>
              </tr>
            </c:if>
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- Phân trang (Pagination) -->
  <c:if test="${not empty totalPages && totalPages > 1}">
    <nav class="d-flex justify-content-center">
      <ul class="pagination pagination-sm shadow-sm">
        <li class="page-item ${currentPage == 0 ? 'disabled' : ''}">
          <a class="page-link" href="<c:url value='/admin/users?page=${currentPage - 1}&keyword=${keyword}'/>">&laquo; Trước</a>
        </li>
        <c:forEach var="i" begin="0" end="${totalPages - 1}">
          <li class="page-item ${currentPage == i ? 'active' : ''}">
            <a class="page-link" href="<c:url value='/admin/users?page=${i}&keyword=${keyword}'/>">${i + 1}</a>
          </li>
        </c:forEach>
        <li class="page-item ${currentPage == totalPages - 1 ? 'disabled' : ''}">
          <a class="page-link" href="<c:url value='/admin/users?page=${currentPage + 1}&keyword=${keyword}'/>">Sau &raquo;</a>
        </li>
      </ul>
    </nav>
  </c:if>
</div>

<!-- Thư viện Javascript -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<!-- Script xử lý SweetAlert2 và AJAX Toggle Lock -->
<script>
const Toast = Swal.mixin({
  toast: true,
  position: 'top-end',
  showConfirmButton: false,
  timer: 3000,
  timerProgressBar: true
});

function handleToggleLock(userId) {
  const btn = document.getElementById('btn-lock-' + userId);
  const currentActive = btn.getAttribute('data-active') === 'true';
  const userName = btn.getAttribute('data-name');
  const actionText = currentActive ? 'khóa' : 'mở khóa';

  Swal.fire({
    title: 'Xác nhận thay đổi',
    html: `Bạn có chắc chắn muốn <b>` + actionText + `</b> tài khoản <strong>` + userName + `</strong>?`,
    icon: currentActive ? 'warning' : 'question',
    showCancelButton: true,
    confirmButtonColor: currentActive ? '#dc3545' : '#198754',
    cancelButtonColor: '#6c757d',
    confirmButtonText: currentActive ? 'Khóa tài khoản' : 'Mở khóa tài khoản',
    cancelButtonText: 'Hủy bỏ',
    reverseButtons: true,
    customClass: {
      popup: 'rounded-4 shadow',
      confirmButton: 'rounded-pill px-3',
      cancelButton: 'rounded-pill px-3'
    }
  }).then((result) => {
    if (result.isConfirmed) {
      const endpointUrl = '<c:url value="/admin/api/users/" />' + userId + '/toggle-lock';

      fetch(endpointUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        }
      })
      .then(response => {
        if (!response.ok) {
          throw new Error('Máy chủ phản hồi không thành công!');
        }
        return response.json();
      })
      .then(data => {
        if (data.success) {
          const badgeContainer = document.getElementById('status-badge-' + userId);
          const isOnline = badgeContainer.getAttribute('data-online') === 'true';

          btn.setAttribute('data-active', data.active);

          if (data.active) {
            // Mở khóa tài khoản thành công
            if (isOnline) {
              badgeContainer.innerHTML = '<span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-2 py-1"><i class="bi bi-circle-fill me-1 small"></i>Trực tuyến</span>';
            } else {
              badgeContainer.innerHTML = '<span class="badge bg-secondary-subtle text-secondary border border-secondary-subtle rounded-pill px-2 py-1"><i class="bi bi-moon-fill me-1 small"></i>Ngoại tuyến</span>';
            }
            btn.className = 'btn btn-sm btn-outline-danger rounded-pill px-2';
            btn.title = 'Khóa tài khoản';
            btn.innerHTML = '<i class="bi bi-lock-fill"></i>';
          } else {
            // Khóa tài khoản thành công
            badgeContainer.innerHTML = '<span class="badge bg-danger-subtle text-danger border border-danger-subtle rounded-pill px-2 py-1"><i class="bi bi-slash-circle me-1"></i>Bị khóa</span>';
            btn.className = 'btn btn-sm btn-outline-success rounded-pill px-2';
            btn.title = 'Mở khóa tài khoản';
            btn.innerHTML = '<i class="bi bi-unlock-fill"></i>';
          }

          // Hiển thị thông báo Toast trượt ở góc phải trên
          Toast.fire({
            icon: 'success',
            title: data.message
          });
        } else {
          Swal.fire('Lỗi', data.message || 'Đã xảy ra lỗi!', 'error');
        }
      })
      .catch(error => {
        console.error('Lỗi fetch:', error);
        Swal.fire('Lỗi kết nối', 'Không thể kết nối đến máy chủ!', 'error');
      });
    }
  });
}
</script>
</body>
</html>