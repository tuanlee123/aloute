<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chỉnh sửa bài viết - ALOUTE</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
</head>
<body class="bg-light">

<div class="container my-5" style="max-width: 600px;">
    <div class="card shadow-sm border-0 rounded-3">
        <div class="card-header bg-white py-3 border-0 d-flex justify-content-between align-items-center">
            <span class="fw-bold"><i class="bi bi-pencil-square me-2 text-warning"></i>Chỉnh sửa bài viết</span>
            <a href="${pageContext.request.contextPath}/post/feed" class="btn btn-close"></a>
        </div>
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/post/edit/${post.id}" method="post">
                <div class="mb-3">
                    <label class="form-label fw-semibold">Nội dung bài viết:</label>
                    <textarea class="form-control" name="content" rows="5" required>${post.content}</textarea>
                </div>

                <div class="mb-3">
                    <label class="form-label fw-semibold">Quyền riêng tư:</label>
                    <select class="form-select" name="privacy">
                        <option value="PUBLIC" ${post.privacy == 'PUBLIC' ? 'selected' : ''}>Công khai (PUBLIC)</option>
                        <option value="FRIENDS" ${post.privacy == 'FRIENDS' ? 'selected' : ''}>Bạn bè (FRIENDS)</option>
                        <option value="PRIVATE" ${post.privacy == 'PRIVATE' ? 'selected' : ''}>Chỉ mình tôi (PRIVATE)</option>
                    </select>
                </div>

                <!-- Hiển thị ảnh cũ của bài viết -->
                <c:if test="${not empty post.images}">
                    <div class="mb-3">
                        <label class="form-label fw-semibold text-muted">Hình ảnh hiện tại:</label>
                        <div class="d-flex flex-wrap gap-2">
                            <c:forEach var="img" items="${post.images}">
                                <img src="${img.imageUrl}" class="img-thumbnail" style="height: 100px; object-fit: cover;">
                            </c:forEach>
                        </div>
                    </div>
                </c:if>

                <div class="d-flex justify-content-end gap-2">
                    <a href="${pageContext.request.contextPath}/post/feed" class="btn btn-outline-secondary px-3 rounded-pill">Hủy</a>
                    <button type="submit" class="btn btn-primary px-4 rounded-pill">Lưu thay đổi</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>