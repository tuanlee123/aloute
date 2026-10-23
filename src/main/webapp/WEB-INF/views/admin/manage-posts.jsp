<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Quản lý bài viết | ALOUTE Admin</title>

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
    .preview-img-item {
      max-height: 280px;
      object-fit: cover;
      width: 100%;
      border-radius: 10px;
    }
  </style>
</head>
<body>

<div class="container py-4">
  <!-- Tiêu đề & Nút về Dashboard -->
  <div class="d-flex justify-content-between align-items-center mb-4">
    <div>
      <h3 class="fw-bold mb-1"><i class="bi bi-file-earmark-post text-primary me-2"></i>Quản lý bài viết</h3>
      <span class="text-muted small">
        Tổng số: <strong><c:out value="${empty totalElements ? fn:length(posts) : totalElements}"/></strong> bài viết
      </span>
    </div>
    <a href="<c:url value='/admin'/>" class="btn btn-outline-secondary btn-sm rounded-pill px-3 shadow-sm">
      <i class="bi bi-arrow-left me-1"></i> Dashboard
    </a>
  </div>

  <!-- Thanh tìm kiếm (Search Box) -->
  <div class="card border-0 shadow-sm rounded-4 mb-4">
    <div class="card-body p-3">
      <form method="get" action="<c:url value='/admin/posts'/>" class="row g-2 align-items-center">
        <div class="col-md-5 col-12">
          <div class="input-group">
            <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-search"></i></span>
            <input type="text" name="keyword" value="<c:out value='${keyword}'/>" class="form-control border-start-0" 
                   placeholder="Tìm kiếm nội dung bài viết, người đăng...">
          </div>
        </div>
        <div class="col-auto">
          <button type="submit" class="btn btn-primary rounded-pill px-4">
            <i class="bi bi-funnel me-1"></i>Tìm kiếm
          </button>
          <c:if test="${not empty keyword}">
            <a href="<c:url value='/admin/posts'/>" class="btn btn-light rounded-pill px-3 border ms-1">Xóa bộ lọc</a>
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

  <!-- Bảng danh sách bài viết -->
  <div class="card border-0 shadow-sm rounded-4 overflow-hidden mb-4">
    <div class="card-body p-0">
      <div class="table-responsive">
        <table class="table table-hover align-middle mb-0">
          <thead class="table-light">
            <tr>
              <th class="ps-3 py-3">ID</th>
              <th>Tác giả</th>
              <th>Nội dung</th>
              <th>Hình ảnh</th>
              <th>Quyền riêng tư</th>
              <th>Thời gian</th>
              <th class="text-end pe-3">Thao tác</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="p" items="${posts}">
              <!-- Gom danh sách URL ảnh thành chuỗi JSON an toàn -->
              <c:set var="imgListJson" value="[" />
              <c:forEach var="img" items="${p.images}" varStatus="status">
                <c:set var="imgUrlVal" value="${not empty img.imageUrl ? img.imageUrl : (not empty img.url ? img.url : img)}" />
                <c:set var="imgListJson" value="${imgListJson}&quot;${imgUrlVal}&quot;${status.last ? '' : ','}" />
              </c:forEach>
              <c:set var="imgListJson" value="${imgListJson}]" />

              <tr id="post-row-${p.id}">
                <td class="ps-3 fw-bold text-muted">#${p.id}</td>
                <td>
                  <div class="d-flex align-items-center gap-2">
                    <img src="${empty p.user.avatar ? 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg' : p.user.avatar}"
                         class="rounded-circle border" width="34" height="34" style="object-fit: cover;">
                    <div>
                      <div class="fw-semibold text-dark">
                        <c:out value="${empty p.user.fullName ? p.user.username : p.user.fullName}"/>
                      </div>
                      <small class="text-muted">@<c:out value="${p.user.username}"/></small>
                    </div>
                  </div>
                </td>
                <td style="max-width: 320px;">
                  <div class="text-truncate text-secondary">
                    <c:out value="${p.content}"/>
                  </div>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${not empty p.images && fn:length(p.images) > 0}">
                      <span class="badge bg-info-subtle text-info border border-info-subtle rounded-pill px-2 py-1">
                        <i class="bi bi-images me-1"></i>${fn:length(p.images)} ảnh
                      </span>
                    </c:when>
                    <c:otherwise>
                      <span class="text-muted small">Không có</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <span class="badge ${p.privacy == 'PUBLIC' ? 'bg-primary-subtle text-primary border border-primary-subtle' : (p.privacy == 'FRIENDS' ? 'bg-success-subtle text-success border border-success-subtle' : 'bg-secondary-subtle text-secondary border border-secondary-subtle')} rounded-pill px-2 py-1">
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
                    <!-- Nút xem nhanh bật Modal có hình ảnh -->
                    <button type="button" 
                            class="btn btn-sm btn-outline-info rounded-pill px-2"
                            title="Xem nhanh bài viết"
                            data-images='${imgListJson}'
                            onclick="previewPost('${p.id}', '<c:out value="${empty p.user.fullName ? p.user.username : p.user.fullName}"/>', '<c:out value="${p.user.username}"/>', '${empty p.user.avatar ? 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg' : p.user.avatar}', '${p.privacy}', '${fn:replace(fn:substring(p.createdAt, 0, 16), 'T', ' ')}', '<c:out value="${fn:escapeXml(p.content)}"/>', this)">
                      <i class="bi bi-eye"></i>
                    </button>

                    <!-- Link mở trang chi tiết bài viết tab mới -->
                    <a href="<c:url value='/post/${p.id}'/>" target="_blank" 
                       class="btn btn-sm btn-outline-primary rounded-pill px-2" title="Mở trang chi tiết">
                      <i class="bi bi-box-arrow-up-right"></i>
                    </a>
                    
                    <!-- Nút xóa kích hoạt SweetAlert2 -->
                    <button type="button" 
                            onclick="handleDeletePost(${p.id})"
                            class="btn btn-sm btn-outline-danger rounded-pill px-2" 
                            title="Xóa bài viết vi phạm">
                      <i class="bi bi-trash3-fill"></i>
                    </button>
                  </div>
                </td>
              </tr>
            </c:forEach>
            <c:if test="${empty posts}">
              <tr>
                <td colspan="7" class="text-center py-5 text-muted">
                  <i class="bi bi-inbox fs-1 d-block mb-2 opacity-50"></i>
                  Không có bài viết nào phù hợp.
                </td>
              </tr>
            </c:if>
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- Thanh phân trang (Pagination) -->
  <c:if test="${not empty totalPages && totalPages > 1}">
    <nav class="d-flex justify-content-center">
      <ul class="pagination pagination-sm shadow-sm">
        <li class="page-item ${currentPage == 0 ? 'disabled' : ''}">
          <a class="page-link" href="<c:url value='/admin/posts?page=${currentPage - 1}&keyword=${keyword}'/>">&laquo; Trước</a>
        </li>
        <c:forEach var="i" begin="0" end="${totalPages - 1}">
          <li class="page-item ${currentPage == i ? 'active' : ''}">
            <a class="page-link" href="<c:url value='/admin/posts?page=${i}&keyword=${keyword}'/>">${i + 1}</a>
          </li>
        </c:forEach>
        <li class="page-item ${currentPage == totalPages - 1 ? 'disabled' : ''}">
          <a class="page-link" href="<c:url value='/admin/posts?page=${currentPage + 1}&keyword=${keyword}'/>">Sau &raquo;</a>
        </li>
      </ul>
    </nav>
  </c:if>
</div>

<!-- Modal xem nhanh nội dung và hình ảnh bài viết -->
<div class="modal fade" id="previewPostModal" tabindex="-1" aria-labelledby="previewModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered modal-lg">
    <div class="modal-content border-0 shadow rounded-4 overflow-hidden">
      <div class="modal-header border-bottom-0 pb-0">
        <div class="d-flex align-items-center gap-2">
          <img id="modalAuthorAvatar" src="" class="rounded-circle border" width="44" height="44" style="object-fit: cover;">
          <div>
            <h6 class="modal-title fw-bold text-dark mb-0" id="modalAuthorName"></h6>
            <div class="d-flex align-items-center gap-2">
              <small class="text-muted" id="modalAuthorUsername"></small>
              <small class="text-muted">•</small>
              <small class="text-muted" id="modalPostTime"></small>
            </div>
          </div>
        </div>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body py-3">
        <div class="mb-3">
          <span id="modalPostPrivacy" class="badge rounded-pill px-2 py-1"></span>
          <span class="badge bg-light text-muted border ms-1" id="modalPostId"></span>
        </div>
        <p id="modalPostContent" class="text-dark mb-3" style="white-space: pre-wrap; font-size: 1rem; line-height: 1.5;"></p>
        
        <!-- Khung hiển thị danh sách hình ảnh bài viết -->
        <div id="modalImagesContainer" class="row g-2"></div>
      </div>
      <div class="modal-footer border-top-0 pt-0">
        <button type="button" class="btn btn-secondary rounded-pill px-4" data-bs-dismiss="modal">Đóng</button>
      </div>
    </div>
  </div>
</div>

<!-- Thư viện Javascript -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<script>
const Toast = Swal.mixin({
  toast: true,
  position: 'top-end',
  showConfirmButton: false,
  timer: 3000,
  timerProgressBar: true
});

const previewModal = new bootstrap.Modal(document.getElementById('previewPostModal'));

function previewPost(id, name, username, avatar, privacy, time, content, btnElement) {
  document.getElementById('modalPostId').innerText = '#' + id;
  document.getElementById('modalAuthorName').innerText = name;
  document.getElementById('modalAuthorUsername').innerText = '@' + username;
  document.getElementById('modalAuthorAvatar').src = avatar;
  document.getElementById('modalPostTime').innerText = time;
  document.getElementById('modalPostContent').innerText = content || '(Bài viết không có nội dung văn bản)';

  const privacyBadge = document.getElementById('modalPostPrivacy');
  if (privacy === 'PUBLIC') {
    privacyBadge.className = 'badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill px-2 py-1';
    privacyBadge.innerText = '🌐 Công khai';
  } else if (privacy === 'FRIENDS') {
    privacyBadge.className = 'badge bg-success-subtle text-success border border-success-subtle rounded-pill px-2 py-1';
    privacyBadge.innerText = '👥 Bạn bè';
  } else {
    privacyBadge.className = 'badge bg-secondary-subtle text-secondary border border-secondary-subtle rounded-pill px-2 py-1';
    privacyBadge.innerText = '🔒 Riêng tư';
  }

  // Nạp danh sách hình ảnh
  const container = document.getElementById('modalImagesContainer');
  container.innerHTML = '';
  
  try {
    const rawImages = btnElement.getAttribute('data-images');
    const images = JSON.parse(rawImages || '[]');
    
    if (images && images.length > 0) {
      images.forEach(imgUrl => {
        if (imgUrl && imgUrl.trim() !== '') {
          const colClass = images.length === 1 ? 'col-12 text-center' : 'col-6';
          const col = document.createElement('div');
          col.className = colClass;
          col.innerHTML = '<a href="' + imgUrl + '" target="_blank">' +
                          '<img src="' + imgUrl + '" class="preview-img-item border shadow-sm" alt="Hình ảnh bài đăng">' +
                          '</a>';
          container.appendChild(col);
        }
      });
    }
  } catch (err) {
    console.error('Lỗi phân tích hình ảnh:', err);
  }

  previewModal.show();
}

function handleDeletePost(postId) {
  Swal.fire({
    title: 'Xóa bài viết vi phạm?',
    text: 'Thao tác này sẽ xóa vĩnh viễn bài viết khỏi hệ thống và không thể hoàn tác.',
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Đồng ý xóa',
    cancelButtonText: 'Hủy bỏ',
    reverseButtons: true,
    customClass: {
      popup: 'rounded-4 shadow',
      confirmButton: 'rounded-pill px-3',
      cancelButton: 'rounded-pill px-3'
    }
  }).then((result) => {
    if (result.isConfirmed) {
      fetch('<c:url value="/admin/api/posts/" />' + postId + '/delete', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
      })
      .then(res => res.json())
      .then(data => {
        if (data.success) {
          const row = document.getElementById('post-row-' + postId);
          if (row) {
            row.style.transition = 'all 0.4s ease';
            row.style.opacity = '0';
            row.style.transform = 'translateX(20px)';
            setTimeout(() => row.remove(), 400);
          }
          Toast.fire({
            icon: 'success',
            title: data.message
          });
        } else {
          Swal.fire('Thất bại', data.message || 'Không thể xóa bài viết!', 'error');
        }
      })
      .catch(err => {
        console.error(err);
        Swal.fire('Lỗi', 'Không thể kết nối đến máy chủ!', 'error');
      });
    }
  });
}
</script>
</body>
</html>