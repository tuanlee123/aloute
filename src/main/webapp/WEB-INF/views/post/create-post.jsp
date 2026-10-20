<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tạo bài viết mới - ALOUTE</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
</head>
<body class="bg-light">

<div class="container my-5" style="max-width: 620px;">
    <div class="card shadow-sm border-0 rounded-3">
        <div class="card-header bg-white py-3 border-0 d-flex justify-content-between align-items-center">
            <span class="fw-bold fs-5 text-dark">
                <i class="bi bi-pencil-square text-primary me-2"></i>Tạo bài viết mới
            </span>
            <a href="${pageContext.request.contextPath}/post/feed" class="btn btn-close"></a>
        </div>
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/post/create" method="post" enctype="multipart/form-data">
                <div class="mb-3">
                    <label class="form-label fw-semibold">Nội dung trạng thái:</label>
                    <textarea class="form-control" name="content" rows="4" 
                              placeholder="Bạn đang nghĩ gì thế?..." required></textarea>
                </div>

                <div class="mb-3">
                    <label class="form-label fw-semibold">Quyền riêng tư:</label>
                    <select class="form-select" name="privacy">
                        <option value="PUBLIC" selected>Công khai (PUBLIC)</option>
                        <option value="FRIENDS">Bạn bè (FRIENDS)</option>
                        <option value="PRIVATE">Chỉ mình tôi (PRIVATE)</option>
                    </select>
                </div>

                <div class="mb-3">
                    <label class="form-label fw-semibold">Chọn hình ảnh tải lên:</label>
                    <input class="form-control" type="file" id="postImages" name="images" accept="image/*" multiple onchange="previewSelectedImages(this)">
                    <div class="form-text text-muted">Có thể chọn cùng lúc một hoặc nhiều bức ảnh.</div>
                </div>

                <!-- Preview ảnh -->
                <div id="imagePreviewContainer" class="d-flex flex-wrap gap-2 mb-4 d-none"></div>

                <div class="d-flex justify-content-end gap-2 pt-2 border-top">
                    <a href="${pageContext.request.contextPath}/post/feed" class="btn btn-outline-secondary px-3 rounded-pill">Hủy bỏ</a>
                    <button type="submit" class="btn btn-primary px-4 rounded-pill fw-semibold">Đăng ngay</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
function previewSelectedImages(input) {
    const container = document.getElementById('imagePreviewContainer');
    container.innerHTML = '';
    if (input.files && input.files.length > 0) {
        container.classList.remove('d-none');
        Array.from(input.files).forEach(file => {
            const reader = new FileReader();
            reader.onload = function(e) {
                const img = document.createElement('img');
                img.src = e.target.result;
                img.className = 'img-thumbnail';
                img.style.height = '110px';
                img.style.objectFit = 'cover';
                container.appendChild(img);
            }
            reader.readAsDataURL(file);
        });
    } else {
        container.classList.add('d-none');
    }
}
</script>
</body>
</html>