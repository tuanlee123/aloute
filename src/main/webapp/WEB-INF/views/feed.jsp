<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bảng tin ALOUTE</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
</head>
<body class="bg-light">

<div class="container my-4" style="max-width: 680px;">
    
    <!-- KHUNG ĐĂNG BÀI VIẾT -->
    <div class="card shadow-sm border-0 mb-4 rounded-3">
        <div class="card-header bg-white fw-bold py-3 border-0">
            <i class="bi bi-pencil-square me-2 text-primary"></i>Tạo bài viết mới
        </div>
        <div class="card-body pt-0">
            <form action="${pageContext.request.contextPath}/post/create" method="post" enctype="multipart/form-data">
                <div class="mb-3">
                    <textarea class="form-control border-light-subtle" name="content" rows="3" 
                              placeholder="Bạn đang nghĩ gì thế?..." required></textarea>
                </div>
                
                <!-- Vùng xem trước hình ảnh trước khi upload -->
                <div id="imagePreviewContainer" class="mb-3 text-center d-none">
                    <img id="imagePreview" src="#" alt="Xem trước ảnh" class="img-fluid rounded border" style="max-height: 250px;">
                </div>

                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <label class="btn btn-outline-secondary btn-sm rounded-pill" for="postImage">
                            <i class="bi bi-image text-success me-1"></i>Thêm ảnh
                        </label>
                        <input class="d-none" type="file" id="postImage" name="image" accept="image/*" onchange="previewSelectedImage(this)">
                    </div>
                    <button type="submit" class="btn btn-primary px-4 rounded-pill fw-semibold">Đăng bài</button>
                </div>
            </form>
        </div>
    </div>

    <!-- DANH SÁCH BÀI VIẾT TỪ DATABASE -->
    <div class="d-flex flex-column gap-3">
        <c:forEach var="p" items="${posts}">
            <div class="card shadow-sm border-0 rounded-3">
                <div class="card-body">
                    <!-- Thông tin người đăng -->
                    <div class="d-flex align-items-center mb-3">
                        <img src="${empty p.user.avatar ? 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg' : p.user.avatar}" 
                             class="rounded-circle me-3 border" width="45" height="45" style="object-fit: cover;">
                        <div>
                            <div class="fw-bold text-dark">${p.user.fullName != null ? p.user.fullName : p.user.username}</div>
                            <small class="text-muted"><i class="bi bi-clock me-1"></i>${p.createdAt}</small>
                        </div>
                    </div>

                    <!-- Nội dung bài viết (giữ định dạng xuống dòng) -->
                    <p class="card-text text-dark mb-3" style="white-space: pre-line;">${p.content}</p>

                    <!-- Danh sách hình ảnh bài viết lưu từ Cloudinary -->
                    <c:if test="${not empty p.images}">
                        <div class="text-center rounded overflow-hidden">
                            <c:forEach var="img" items="${p.images}">
                                <img src="${img.imageUrl}" class="img-fluid rounded border mb-2 w-100" style="max-height: 480px; object-fit: cover;">
                            </c:forEach>
                        </div>
                    </c:if>
                </div>
            </div>
        </c:forEach>

        <c:if test="${empty posts}">
            <div class="alert alert-white shadow-sm text-center py-5 rounded-3">
                <i class="bi bi-chat-square-dots display-6 text-muted mb-3 d-block"></i>
                <span class="text-muted">Chưa có bài viết nào trên bảng tin. Hãy là người đầu tiên chia sẻ trạng thái!</span>
            </div>
        </c:if>
    </div>

</div>

<!-- Bootstrap 5 JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<!-- Script xem trước ảnh khi chọn -->
<script>
function previewSelectedImage(input) {
    const previewContainer = document.getElementById('imagePreviewContainer');
    const previewImg = document.getElementById('imagePreview');
    
    if (input.files && input.files[0]) {
        const reader = new FileReader();
        reader.onload = function(e) {
            previewImg.src = e.target.result;
            previewContainer.classList.remove('d-none');
        }
        reader.readAsDataURL(input.files[0]);
    } else {
        previewContainer.classList.add('d-none');
    }
}
</script>

</body>
</html>