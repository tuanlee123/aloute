<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<head>
    <title>Mục đã lưu - ALOUTE</title>
    <style>
        .icon-saved-gradient {
            background: linear-gradient(135deg, #e0245e, #8a3ab9);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        /* LƯỚI ẢNH CHUẨN FACEBOOK */
        .post-images-grid {
            display: grid;
            gap: 4px;
            width: 100%;
            border-radius: 10px;
            overflow: hidden;
            background-color: #f0f2f5;
        }

        .grid-1 { grid-template-columns: 1fr; }
        .grid-1 .post-img-box { aspect-ratio: 16 / 9; max-height: 480px; }
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
            cursor: pointer;
        }

        .post-img-box img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
            transition: transform 0.25s ease;
        }

        .post-img-box:hover img {
            transform: scale(1.02);
        }

        .post-img-overlay {
            position: absolute;
            inset: 0;
            background: rgba(0, 0, 0, 0.5);
            backdrop-filter: blur(2px);
            color: #ffffff;
            font-size: 2.2rem;
            font-weight: 700;
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 2;
        }

        /* THANH TƯƠNG TÁC (LIKE, CHIA SẺ) */
        .post-action-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding-top: 10px;
            border-top: 1px solid #f0f2f5;
        }

        /* KHUNG LIGHTBOX XEM ẢNH */
        #imageViewerModal {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0, 0, 0, 0.95);
            z-index: 99999;
            user-select: none;
            overflow: hidden;
        }

        .viewer-image-container {
            width: 100vw;
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        #imageViewerImg {
            max-width: 82vw;
            max-height: 84vh;
            object-fit: contain;
            border-radius: 6px;
        }

        .viewer-top-tools {
            position: absolute;
            top: 18px;
            right: 25px;
            display: flex;
            gap: 12px;
            z-index: 100002;
        }

        .viewer-tool-btn {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            background: rgba(40, 40, 40, 0.85);
            border: 1px solid rgba(255, 255, 255, 0.2);
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
        }

        .viewer-side-btn {
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            width: 52px;
            height: 52px;
            border-radius: 50%;
            background: rgba(40, 40, 40, 0.75);
            border: 1px solid rgba(255, 255, 255, 0.25);
            color: #fff;
            font-size: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            z-index: 100001;
        }

        .viewer-btn-left { left: 24px; }
        .viewer-btn-right { right: 24px; }
    </style>
</head>

<div class="container my-4" style="max-width: 680px;">

    <!-- TIÊU ĐỀ TRANG MỤC ĐÃ LƯU -->
    <div class="d-flex align-items-center justify-content-between mb-4 bg-white p-3 rounded-3 shadow-sm border">
        <div class="d-flex align-items-center gap-2">
            <i class="bi bi-bookmark-fill fs-3 icon-saved-gradient"></i>
            <div>
                <h5 class="fw-bold mb-0">Mục đã lưu</h5>
                <small class="text-muted">Các bài viết bạn đã lưu để xem lại sau</small>
            </div>
        </div>
        <a href="${pageContext.request.contextPath}/post/feed" class="btn btn-outline-primary btn-sm rounded-pill px-3">
            <i class="bi bi-arrow-left me-1"></i>Về bảng tin
        </a>
    </div>

    <!-- DANH SÁCH BÀI VIẾT ĐÃ LƯU -->
    <div class="d-flex flex-column gap-3" id="savedPostsList">
        <c:forEach var="p" items="${posts}">
            <div class="card shadow-sm border-0 rounded-3" id="saved-card-${p.id}">
                <div class="card-body">
                    <!-- Tác giả, Ngày đăng & Menu 3 chấm -->
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <div class="d-flex align-items-center">
                            <a href="${pageContext.request.contextPath}/profile?userId=${p.user.id}" class="text-decoration-none">
                                <img src="${empty p.user.avatar ? 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg' : p.user.avatar}"
                                    class="rounded-circle me-3 border" width="45" height="45" style="object-fit: cover;">
                            </a>
                            <div>
                                <a href="${pageContext.request.contextPath}/profile?userId=${p.user.id}" class="text-decoration-none fw-bold text-dark d-block">
                                    ${p.user.fullName != null ? p.user.fullName : p.user.username}
                                </a>
                                <div class="d-flex align-items-center gap-1 text-muted small" style="font-size: 0.8rem;">
                                    <span>${p.createdAt}</span>
                                    <span>·</span>
                                    <c:choose>
                                        <c:when test="${p.privacy == 'PRIVATE'}">
                                            <i class="bi bi-lock-fill" title="Chỉ mình tôi"></i>
                                        </c:when>
                                        <c:when test="${p.privacy == 'FRIENDS'}">
                                            <i class="bi bi-people-fill" title="Bạn bè"></i>
                                        </c:when>
                                        <c:otherwise>
                                            <i class="bi bi-globe-americas" title="Công khai"></i>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                        <!-- MENU 3 CHẤM BÀI VIẾT -->
                        <div class="dropdown">
                            <button class="btn btn-light btn-sm rounded-circle border-0 d-flex align-items-center justify-content-center"
                                type="button" data-bs-toggle="dropdown" aria-expanded="false" style="width: 36px; height: 36px;">
                                <i class="bi bi-three-dots-vertical fs-6"></i>
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end shadow border-0 rounded-3 py-2" style="min-width: 190px; z-index: 1055;">
                                <li>
                                    <button type="button" class="dropdown-item py-2 text-danger" onclick="unsavePost(${p.id})">
                                        <i class="bi bi-bookmark-x me-2"></i>Bỏ lưu bài viết
                                    </button>
                                </li>
                                <c:if test="${sessionScope.currentUser != null && sessionScope.currentUser.id == p.user.id}">
                                    <li><hr class="dropdown-divider my-1"></li>
                                    <li>
                                        <a class="dropdown-item py-2" href="${pageContext.request.contextPath}/post/edit/${p.id}">
                                            <i class="bi bi-pencil me-2 text-warning"></i>Chỉnh sửa bài viết
                                        </a>
                                    </li>
                                    <li>
                                        <form action="${pageContext.request.contextPath}/post/delete/${p.id}" method="post"
                                            onsubmit="return confirm('Bạn có chắc chắn muốn xóa bài viết này không?');" class="m-0">
                                            <button type="submit" class="dropdown-item py-2 text-danger border-0 bg-transparent w-100 text-start">
                                                <i class="bi bi-trash me-2"></i>Xóa bài viết
                                            </button>
                                        </form>
                                    </li>
                                </c:if>
                            </ul>
                        </div>
                    </div>

                    <!-- Nội dung bài viết -->
                    <div class="card-text text-dark mb-3" style="white-space: pre-line;">
                        <c:choose>
                            <c:when test="${fn:length(p.content) > 160}">
                                <span>${fn:substring(p.content, 0, 160)}</span><span id="dots-${p.id}">... </span><a href="javascript:void(0)"
                                    id="btn-more-${p.id}" onclick="toggleReadMore(${p.id})"
                                    class="fw-bold text-dark text-decoration-none">Xem thêm</a><span
                                    id="more-${p.id}" class="d-none">${fn:substring(p.content, 160, fn:length(p.content))}</span>
                            </c:when>
                            <c:otherwise>
                                ${p.content}
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- LƯỚI ẢNH -->
                    <c:if test="${not empty p.images}">
                        <c:set var="imgCount" value="${fn:length(p.images)}" />
                        <div class="post-images-grid ${imgCount >= 4 ? 'grid-4' : (imgCount == 3 ? 'grid-3' : (imgCount == 2 ? 'grid-2' : 'grid-1'))} mb-3">
                            <c:forEach var="img" items="${p.images}" varStatus="status" end="3">
                                <div class="post-img-box" onclick="openImageViewer(${p.id},${status.index})">
                                    <img src="${img.imageUrl}" alt="Hình ảnh bài viết">
                                    <c:if test="${status.index == 3 && imgCount > 4}">
                                        <div class="post-img-overlay">
                                            +${imgCount - 3}
                                        </div>
                                    </c:if>
                                </div>
                            </c:forEach>
                        </div>

                        <script>
                            window.postImagesMap = window.postImagesMap || {};
                            window.postImagesMap[${p.id}] = [
                                <c:forEach var="item" items="${p.images}" varStatus="st">
                                    "${item.imageUrl}"<c:if test="${!st.last}">,</c:if>
                                </c:forEach>
                            ];
                        </script>
                    </c:if>

                    <!-- THANH TƯƠNG TÁC THÍCH & CHIA SẺ -->
                    <div class="post-action-bar mt-2">
                        <button type="button" class="btn btn-sm btn-outline-danger btn-like rounded-pill px-3" data-post-id="${p.id}">
                            <i class="far fa-heart me-1"></i>
                            Thích (<span class="like-count">${p.likes != null ? p.likes.size() : 0}</span>)
                        </button>
                        <span class="text-muted small">
                            <i class="bi bi-reply-fill" style="transform: scaleX(-1);"></i>
                            ${p.shareCount != null ? p.shareCount : 0} chia sẻ
                        </span>
                    </div>

                    <!-- DANH SÁCH BÌNH LUẬN -->
                    <div id="comment-list-${p.id}" class="mt-3 pt-2 border-top">
                        <c:forEach items="${p.comments}" var="c">
                            <div class="d-flex align-items-start mb-2 comment-item" id="comment-item-${c.id}">
                                <a href="${pageContext.request.contextPath}/profile?userId=${c.user.id}" class="text-decoration-none">
                                    <img src="${c.user.avatar != null && !c.user.avatar.isEmpty() ? c.user.avatar : 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg'}"
                                        class="rounded-circle me-2 border" width="32" height="32" style="object-fit: cover;">
                                </a>

                                <div class="bg-light p-2 rounded-3 flex-grow-1 position-relative group-comment">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <a href="${pageContext.request.contextPath}/profile?userId=${c.user.id}" class="text-decoration-none text-dark fw-bold" style="font-size: 0.85rem;">
                                            <c:out value="${c.user.fullName != null ? c.user.fullName : c.user.username}" />
                                        </a>

                                        <!-- MENU 3 CHẤM BÌNH LUẬN -->
                                        <c:if test="${sessionScope.currentUser != null && sessionScope.currentUser.id == c.user.id}">
                                            <div class="dropdown">
                                                <button class="btn btn-link text-muted p-0 border-0 text-decoration-none"
                                                    type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                                    <i class="bi bi-three-dots-vertical" style="font-size: 1rem;"></i>
                                                </button>
                                                <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0 py-1" style="font-size: 0.85rem; z-index: 1060;">
                                                    <li>
                                                        <a class="dropdown-item py-1" href="javascript:void(0)" onclick="openEditComment(${c.id})">
                                                            <i class="bi bi-pencil me-2 text-primary"></i>Chỉnh sửa
                                                        </a>
                                                    </li>
                                                    <li>
                                                        <a class="dropdown-item py-1 text-danger" href="javascript:void(0)" onclick="deleteComment(${c.id})">
                                                            <i class="bi bi-trash me-2"></i>Xóa
                                                        </a>
                                                    </li>
                                                </ul>
                                            </div>
                                        </c:if>
                                    </div>

                                    <!-- Nội dung bình luận -->
                                    <div id="comment-text-${c.id}" class="text-secondary" style="font-size: 0.9rem;">
                                        <c:out value="${c.content}" />
                                    </div>

                                    <!-- Khung sửa bình luận -->
                                    <div id="comment-edit-box-${c.id}" class="d-none mt-2">
                                        <input type="text" class="form-control form-control-sm mb-1" id="comment-input-${c.id}" value="${c.content}">
                                        <button class="btn btn-sm btn-primary rounded-pill px-2 py-0" onclick="saveEditComment(${c.id})">Lưu</button>
                                        <button class="btn btn-sm btn-light rounded-pill px-2 py-0" onclick="cancelEditComment(${c.id})">Hủy</button>
                                    </div>

                                    <small class="text-muted d-block mt-1" id="comment-time-${c.id}" style="font-size: 0.72rem;">
                                        ${c.createdAt}
                                    </small>
                                </div>
                            </div>
                        </c:forEach>
                    </div>

                    <!-- Ô NHẬP BÌNH LUẬN MỚI -->
                    <form class="form-comment mt-2 d-flex gap-2" data-post-id="${p.id}">
                        <input type="text" class="form-control form-control-sm rounded-pill input-comment px-3"
                            placeholder="Viết bình luận..." required autocomplete="off" />
                        <button type="submit" class="btn btn-sm btn-primary rounded-pill px-3">Gửi</button>
                    </form>

                </div>
            </div>
        </c:forEach>

        <c:if test="${empty posts}">
            <div class="alert alert-white shadow-sm text-center py-5 rounded-3 border">
                <i class="bi bi-bookmark-x display-6 text-muted mb-3 d-block"></i>
                <span class="text-muted">Bạn chưa lưu bài viết nào.</span>
            </div>
        </c:if>
    </div>

</div>

<!-- LIGHTBOX XEM ẢNH -->
<div id="imageViewerModal" onclick="closeViewerOnBackdrop(event)">
    <div class="viewer-top-tools" onclick="event.stopPropagation()">
        <button type="button" class="viewer-tool-btn" onclick="closeImageViewer(event)">
            <i class="bi bi-x-lg"></i>
        </button>
    </div>
    <button type="button" class="viewer-side-btn viewer-btn-left" onclick="showPrevImage(event)">
        <i class="bi bi-chevron-left"></i>
    </button>
    <div class="viewer-image-container">
        <img id="imageViewerImg" src="" alt="Xem ảnh">
    </div>
    <button type="button" class="viewer-side-btn viewer-btn-right" onclick="showNextImage(event)">
        <i class="bi bi-chevron-right"></i>
    </button>
</div>

<script>
    function toggleReadMore(postId) {
        const dots = document.getElementById('dots-' + postId);
        const moreText = document.getElementById('more-' + postId);
        const btnText = document.getElementById('btn-more-' + postId);

        if (dots.style.display === 'none') {
            dots.style.display = 'inline';
            btnText.innerHTML = 'Xem thêm';
            moreText.classList.add('d-none');
        } else {
            dots.style.display = 'none';
            btnText.innerHTML = ' Thu gọn';
            moreText.classList.remove('d-none');
        }
    }

    // BỎ LƯU BÀI VIẾT
    function unsavePost(postId) {
        if (!confirm('Bạn có chắc chắn muốn bỏ lưu bài viết này không?')) return;

        fetch('${pageContext.request.contextPath}/post/save/' + postId, {
            method: 'POST'
        })
        .then(res => res.json())
        .then(data => {
            const card = document.getElementById('saved-card-' + postId);
            if (card) {
                card.remove();
            }
            const remaining = document.querySelectorAll('#savedPostsList .card');
            if (remaining.length === 0) {
                document.getElementById('savedPostsList').innerHTML = `
                    <div class="alert alert-white shadow-sm text-center py-5 rounded-3 border">
                        <i class="bi bi-bookmark-x display-6 text-muted mb-3 d-block"></i>
                        <span class="text-muted">Bạn chưa lưu bài viết nào.</span>
                    </div>`;
            }
        })
        .catch(() => alert('Có lỗi xảy ra khi bỏ lưu!'));
    }

    // Lightbox xem ảnh
    let currentPostImages = [];
    let currentImageIndex = 0;

    function openImageViewer(postId, index) {
        if (!window.postImagesMap || !window.postImagesMap[postId]) return;
        currentPostImages = window.postImagesMap[postId];
        currentImageIndex = index;
        document.getElementById('imageViewerImg').src = currentPostImages[currentImageIndex];
        document.getElementById('imageViewerModal').style.display = 'block';
        document.body.style.overflow = 'hidden';
    }

    function showPrevImage(e) {
        if (e) e.stopPropagation();
        currentImageIndex = (currentImageIndex - 1 + currentPostImages.length) % currentPostImages.length;
        document.getElementById('imageViewerImg').src = currentPostImages[currentImageIndex];
    }

    function showNextImage(e) {
        if (e) e.stopPropagation();
        currentImageIndex = (currentImageIndex + 1) % currentPostImages.length;
        document.getElementById('imageViewerImg').src = currentPostImages[currentImageIndex];
    }

    function closeImageViewer(e) {
        if (e) e.stopPropagation();
        document.getElementById('imageViewerModal').style.display = 'none';
        document.body.style.overflow = '';
    }

    function closeViewerOnBackdrop(e) {
        if (e.target.id === 'imageViewerModal' || e.target.classList.contains('viewer-image-container')) {
            closeImageViewer();
        }
    }
</script>

