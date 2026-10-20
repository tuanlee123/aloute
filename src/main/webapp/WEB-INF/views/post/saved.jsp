<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Mục đã lưu - ALOUTE</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
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
<body class="bg-light">

<div class="container my-4" style="max-width: 680px;">
    
    <!-- Tiêu đề trang Mục đã lưu -->
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

    <!-- Danh sách bài viết đã lưu -->
    <div class="d-flex flex-column gap-3" id="savedPostsList">
        <c:forEach var="p" items="${posts}">
            <div class="card shadow-sm border-0 rounded-3" id="saved-card-${p.id}">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <div class="d-flex align-items-center">
                            <img src="${empty p.user.avatar ? 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg' : p.user.avatar}" 
                                 class="rounded-circle me-3 border" width="45" height="45" style="object-fit: cover;">
                            <div>
                                <div class="fw-bold text-dark">${p.user.fullName != null ? p.user.fullName : p.user.username}</div>
                                <small class="text-muted"><i class="bi bi-clock me-1"></i>${p.createdAt}</small>
                            </div>
                        </div>

                        <!-- NÚT BỎ LƯU BÀI VIẾT -->
                        <button type="button" class="btn btn-outline-danger btn-sm rounded-pill px-3" onclick="unsavePost(${p.id})">
                            <i class="bi bi-bookmark-x me-1"></i>Bỏ lưu
                        </button>
                    </div>

                    <!-- Nội dung rút gọn nếu dài -->
                    <div class="card-text text-dark mb-3" style="white-space: pre-line;">
                        <c:choose>
                            <c:when test="${fn:length(p.content) > 160}">
                                <span>${fn:substring(p.content, 0, 160)}</span><span id="dots-${p.id}">... </span><a href="javascript:void(0)" id="btn-more-${p.id}" onclick="toggleReadMore(${p.id})" class="fw-bold text-dark text-decoration-none">Xem thêm</a><span id="more-${p.id}" class="d-none">${fn:substring(p.content, 160, fn:length(p.content))}</span>
                            </c:when>
                            <c:otherwise>
                                ${p.content}
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- LƯỚI ẢNH ĐẦY ĐỦ 2 TRÊN 2 DƯỚI (HIỆN HẾT TẤT CẢ ẢNH) -->
                    <c:if test="${not empty p.images}">
                        <c:set var="imgCount" value="${fn:length(p.images)}" />
                        <div class="post-images-grid ${imgCount >= 4 ? 'grid-4' : (imgCount == 3 ? 'grid-3' : (imgCount == 2 ? 'grid-2' : 'grid-1'))}">
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

// BỎ LƯU BÀI VIẾT (XÓA KHỎI DANH SÁCH TỨC THÌ)
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

// Xử lý lightbox
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
</body>
</html>