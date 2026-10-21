<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<head>
    <title>Kết quả tìm kiếm: "${keyword}" - ALOUTE</title>
    <style>
        .search-container {
            max-width: 720px;
            margin: 0 auto;
        }

        /* CARD NGƯỜI DÙNG */
        .user-result-card {
            background: #ffffff;
            border-radius: 10px;
            border: 1px solid #e4e6eb;
            padding: 12px 16px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            transition: background-color 0.15s ease;
        }
        .user-result-card:hover {
            background-color: #f7f8fa;
        }

        .mutual-text {
            font-size: 13px;
            color: #65676b;
            cursor: pointer;
        }
        .mutual-text:hover {
            text-decoration: underline;
            color: #1877f2;
        }

        /* LƯỚI ẢNH BÀI VIẾT */
        .post-images-grid {
            display: grid;
            gap: 4px;
            width: 100%;
            border-radius: 10px;
            overflow: hidden;
            background-color: #f0f2f5;
        }
        .grid-1 { grid-template-columns: 1fr; }
        .grid-1 .post-img-box { aspect-ratio: 16 / 9; max-height: 420px; }
        .grid-2 { grid-template-columns: repeat(2, 1fr); }
        .grid-2 .post-img-box { aspect-ratio: 1 / 1; }
        .grid-3 { grid-template-columns: repeat(2, 1fr); }
        .grid-3 .post-img-box:first-child { grid-column: span 2; aspect-ratio: 16 / 9; }
        .grid-3 .post-img-box:not(:first-child) { aspect-ratio: 1 / 1; }
        .grid-4 { grid-template-columns: repeat(2, 1fr); }
        .grid-4 .post-img-box { aspect-ratio: 1 / 1; }

        .post-img-box {
            position: relative;
            width: 100%;
            overflow: hidden;
        }
        .post-img-box img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
        }

        .post-action-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding-top: 10px;
            border-top: 1px solid #f0f2f5;
        }
    </style>
</head>

<div class="container my-4 search-container">
    <div class="mb-4">
        <h4 class="fw-bold text-dark">
            Kết quả tìm kiếm cho <span class="text-primary">"${keyword}"</span>
        </h4>
    </div>

    <!-- ================= 1. KẾT QUẢ: MỌI NGƯỜI (BẠN BÈ) ================= -->
    <div class="card border-0 shadow-sm rounded-3 mb-4">
        <div class="card-header bg-white border-0 pt-3 pb-2 d-flex justify-content-between align-items-center">
            <h5 class="fw-bold mb-0 text-dark">
                <i class="bi bi-people-fill text-primary me-2"></i>Mọi người
            </h5>
            <span class="badge bg-light text-secondary rounded-pill px-3 py-1 fw-semibold">
                ${fn:length(foundUsers)} kết quả
            </span>
        </div>

        <div class="card-body pt-1">
            <c:choose>
                <c:when test="${not empty foundUsers}">
                    <div class="d-flex flex-column gap-2">
                        <c:forEach var="u" items="${foundUsers}">
                            <div class="user-result-card">
                                <div class="d-flex align-items-center gap-3">
                                    <a href="<c:url value='/profile?userId=${u.id}'/>">
                                        <img src="${empty u.avatar ? 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg' : u.avatar}"[cite: 19]
                                             alt="Avatar" class="rounded-circle border" width="56" height="56" style="object-fit: cover;">
                                    </a>
                                    <div>
                                        <a href="<c:url value='/profile?userId=${u.id}'/>" class="fw-bold text-dark text-decoration-none fs-6">
                                            ${u.fullName}
                                        </a>
                                        <div class="mutual-text mt-1" onclick="openMutualModal(${u.id}, '${u.fullName}')">
                                            <i class="bi bi-people me-1"></i>${mutualCounts[u.id]} bạn chung
                                        </div>
                                    </div>
                                </div>

                                <!-- Nút tương tác kết bạn -->
                                <div>
                                    <c:choose>
                                        <c:when test="${statusMap[u.id] == 'FRIENDS'}">
                                            <a href="<c:url value='/profile?userId=${u.id}'/>" class="btn btn-light btn-sm rounded-pill px-3 border fw-semibold">
                                                <i class="bi bi-check-lg text-success me-1"></i>Bạn bè
                                            </a>
                                        </c:when>
                                        <c:when test="${statusMap[u.id] == 'SENT'}">
                                            <button class="btn btn-light btn-sm rounded-pill px-3 border text-secondary" disabled>
                                                <i class="bi bi-clock-history me-1"></i>Đã gửi lời mời
                                            </button>
                                        </c:when>
                                        <c:when test="${statusMap[u.id] == 'RECEIVED'}">
                                            <a href="<c:url value='/friends?tab=requests'/>" class="btn btn-primary btn-sm rounded-pill px-3 fw-semibold">
                                                Phản hồi lời mời
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            <form action="<c:url value='/friends/add/${u.id}'/>" method="post" class="m-0">
                                                <input type="hidden" name="search" value="${keyword}">
                                                <button type="submit" class="btn btn-primary btn-sm rounded-pill px-3 fw-semibold">
                                                    <i class="bi bi-person-plus-fill me-1"></i>Thêm bạn bè
                                                </button>
                                            </form>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="text-center py-4 text-muted small">
                        <i class="bi bi-person-x fs-2 opacity-50 d-block mb-1"></i>
                        Không tìm thấy người dùng nào phù hợp với từ khóa này.
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- ================= 2. KẾT QUẢ: BÀI VIẾT ================= -->
    <div class="card border-0 shadow-sm rounded-3 mb-4">
        <div class="card-header bg-white border-0 pt-3 pb-2 d-flex justify-content-between align-items-center">
            <h5 class="fw-bold mb-0 text-dark">
                <i class="bi bi-newspaper text-danger me-2"></i>Bài viết
            </h5>
            <span class="badge bg-light text-secondary rounded-pill px-3 py-1 fw-semibold">
                ${fn:length(foundPosts)} kết quả
            </span>
        </div>

        <div class="card-body pt-1">
            <c:choose>
                <c:when test="${not empty foundPosts}">
                    <div class="d-flex flex-column gap-3">
                        <c:forEach var="p" items="${foundPosts}">
                            <div class="card border rounded-3 p-3" id="post-card-${p.id}">
                                <!-- Thông tin tác giả -->
                                <div class="d-flex align-items-center mb-2">
                                    <a href="<c:url value='/profile?userId=${p.user.id}'/>">
                                        <img src="${empty p.user.avatar ? 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg' : p.user.avatar}"[cite: 19]
                                             class="rounded-circle me-3 border" width="42" height="42" style="object-fit: cover;">
                                    </a>
                                    <div>
                                        <a href="<c:url value='/profile?userId=${p.user.id}'/>" class="fw-bold text-dark text-decoration-none">
                                            ${p.user.fullName != null ? p.user.fullName : p.user.username}[cite: 19]
                                        </a>
                                        <div class="text-muted small" style="font-size: 0.78rem;">
                                            <span>${p.createdAt}</span>[cite: 19]
                                        </div>
                                    </div>
                                </div>

                                <!-- Nội dung bài viết -->
                                <p class="card-text text-dark mb-2" style="white-space: pre-line;"><c:out value="${p.content}" /></p>

                                <!-- Lưới ảnh đính kèm (nếu có) -->
                                <c:if test="${not empty p.images}">
                                    <c:set var="imgCount" value="${fn:length(p.images)}" />
                                    <div class="post-images-grid ${imgCount >= 4 ? 'grid-4' : (imgCount == 3 ? 'grid-3' : (imgCount == 2 ? 'grid-2' : 'grid-1'))} mb-2">
                                        <c:forEach var="img" items="${p.images}">
                                            <div class="post-img-box">
                                                <img src="${img.imageUrl}" alt="Ảnh bài viết">
                                            </div>
                                        </c:forEach>
                                    </div>
                                </c:if>

                                <!-- Khối tương tác -->
                                <div class="post-action-bar">
                                    <button type="button" class="btn btn-sm btn-outline-danger btn-like rounded-pill px-3" data-post-id="${p.id}">
                                        <i class="far fa-heart me-1"></i>
                                        Thích (<span class="like-count">${p.likes != null ? p.likes.size() : 0}</span>)[cite: 19]
                                    </button>
                                    <a href="<c:url value='/profile?userId=${p.user.id}#post-card-${p.id}'/>" class="btn btn-light btn-sm rounded-pill px-3 border text-secondary fw-semibold">
                                        <i class="bi bi-box-arrow-up-right me-1"></i>Xem bài viết
                                    </a>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="text-center py-4 text-muted small">
                        <i class="bi bi-chat-square-dots fs-2 opacity-50 d-block mb-1"></i>
                        Không tìm thấy bài viết nào chứa từ khóa này.
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<!-- MODAL HIỂN THỊ DANH SÁCH BẠN CHUNG KHI BẤM VÀO -->
<div class="modal fade" id="mutualFriendsModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content rounded-4 border-0 shadow">
            <div class="modal-header border-bottom py-2">
                <h6 class="modal-title fw-bold" id="mutualModalTitle">Bạn chung</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-2" id="mutualModalBody" style="max-height: 350px; overflow-y: auto;">
                <!-- Dữ liệu JS nạp vào -->
            </div>
        </div>
    </div>
</div>

<script>
function openMutualModal(targetUserId, targetName) {
    document.getElementById('mutualModalTitle').innerText = 'Bạn chung với ' + targetName;
    const body = document.getElementById('mutualModalBody');
    body.innerHTML = '<div class="text-center py-3 text-muted">Đang tải...</div>';
    
    const modal = new bootstrap.Modal(document.getElementById('mutualFriendsModal'));
    modal.show();

    fetch('${pageContext.request.contextPath}/friends/mutual/' + targetUserId)
        .then(res => res.json())
        .then(data => {
            if (data.length === 0) {
                body.innerHTML = '<div class="text-center py-3 text-muted small">Không có bạn chung nào</div>';
                return;
            }
            let html = '';
            data.forEach(u => {
                const avatar = u.avatar ? u.avatar : 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg';
                html += `
                    <div class="d-flex align-items-center gap-2 p-2 border-bottom">
                        <img src="${avatar}" class="rounded-circle border" width="36" height="36" style="object-fit: cover;">
                        <a href="${pageContext.request.contextPath}/profile?userId=${u.id}" class="text-dark fw-semibold text-decoration-none small text-truncate">
                            ${u.fullName}
                        </a>
                    </div>
                `;
            });
            body.innerHTML = html;
        })
        .catch(() => {
            body.innerHTML = '<div class="text-center py-3 text-danger small">Lỗi khi tải danh sách!</div>';
        });
}
</script>