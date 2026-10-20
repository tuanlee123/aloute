<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bảng tin ALOUTE</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <style>
        .post-dropdown-menu {
            display: none;
            position: absolute;
            right: 0;
            top: 100%;
            z-index: 1050;
            min-width: 190px;
            background-color: #fff;
        }
        .preview-img-wrap {
            position: relative;
            display: inline-block;
            width: 90px;
            height: 90px;
        }
        .btn-remove-preview {
            position: absolute;
            top: -6px;
            right: -6px;
            width: 20px;
            height: 20px;
            line-height: 18px;
            padding: 0;
            font-size: 13px;
            border-radius: 50%;
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

        /* THANH TƯƠNG TÁC (CHIA SẺ) */
        .post-action-bar {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            padding-top: 10px;
            border-top: 1px solid #f0f2f5;
        }
        .btn-post-share {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            color: #65676b;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            padding: 6px 14px;
            border-radius: 8px;
            border: none;
            background: transparent;
            transition: background 0.15s;
        }
        .btn-post-share:hover {
            background-color: #f0f2f5;
            color: #1877f2;
        }

        /* KHUNG XEM ẢNH TOÀN MÀN HÌNH (LIGHTBOX) */
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
            overflow: hidden;
        }
        #imageViewerImg {
            max-width: 82vw;
            max-height: 84vh;
            object-fit: contain;
            border-radius: 6px;
            box-shadow: 0 8px 30px rgba(0, 0, 0, 0.7);
            transition: transform 0.2s cubic-bezier(0.2, 0, 0.2, 1), opacity 0.2s ease;
            transform-origin: center center;
        }
        .viewer-top-tools {
            position: absolute;
            top: 18px;
            right: 25px;
            display: flex;
            align-items: center;
            gap: 12px;
            z-index: 100002;
        }
        .viewer-tool-btn {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            background: rgba(40, 40, 40, 0.85);
            border: 1px solid rgba(255, 255, 255, 0.2);
            color: #ffffff;
            font-size: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.2s ease;
            text-decoration: none;
        }
        .viewer-tool-btn:hover:not(:disabled) {
            background: rgba(70, 70, 70, 0.95);
            color: #ffffff;
            transform: scale(1.08);
        }
        .viewer-tool-btn:disabled,
        .viewer-tool-btn.btn-disabled {
            opacity: 0.35 !important;
            cursor: not-allowed !important;
            transform: none !important;
        }
        .viewer-counter-badge {
            color: #f1f1f1;
            font-size: 14px;
            font-weight: 600;
            background: rgba(30, 30, 30, 0.75);
            padding: 6px 14px;
            border-radius: 16px;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        /* THANH CHIA SẺ BÊN DƯỚI KHUNG XEM ẢNH */
        .viewer-bottom-bar {
            position: absolute;
            bottom: 20px;
            left: 50%;
            transform: translateX(-50%);
            display: flex;
            align-items: center;
            gap: 12px;
            z-index: 100002;
        }
        .viewer-share-btn {
            background: rgba(255, 255, 255, 0.2);
            backdrop-filter: blur(8px);
            border: 1px solid rgba(255, 255, 255, 0.3);
            color: #ffffff;
            padding: 8px 20px;
            border-radius: 24px;
            font-weight: 600;
            font-size: 15px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            transition: all 0.2s;
        }
        .viewer-share-btn:hover {
            background: rgba(255, 255, 255, 0.35);
            color: #ffffff;
            transform: scale(1.05);
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
            color: #ffffff;
            font-size: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.2s ease;
            z-index: 100001;
        }
        .viewer-side-btn:hover {
            background: rgba(70, 70, 70, 0.95);
            color: #ffffff;
            transform: translateY(-50%) scale(1.1);
        }
        .viewer-btn-left { left: 24px; }
        .viewer-btn-right { right: 24px; }

        /* DANH SÁCH BẠN BÈ TRONG MODAL CHIA SẺ */
        .friend-avatar-list {
            display: flex;
            gap: 16px;
            overflow-x: auto;
            padding-bottom: 8px;
        }
        .friend-item {
            display: flex;
            flex-direction: column;
            align-items: center;
            width: 72px;
            cursor: pointer;
            text-align: center;
        }
        .friend-item img {
            width: 56px;
            height: 56px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid transparent;
            transition: all 0.2s;
        }
        .friend-item:hover img {
            border-color: #1877f2;
            transform: scale(1.08);
        }
        .friend-item span {
            font-size: 12px;
            color: #333;
            margin-top: 4px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            width: 100%;
        }

        /* ICON ĐÃ LƯU GRADIENT HỒNG TÍM */
        .icon-saved-gradient {
            background: linear-gradient(135deg, #e0245e, #8a3ab9);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        
/* Đảm bảo Modal Chia sẻ luôn nổi lên trên cùng */
        #shareModal {
            z-index: 100005 !important;
        }
        .modal-backdrop {
            z-index: 100003 !important;
        }
    </style>
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
                
                <div id="imagePreviewContainer" class="d-flex flex-wrap gap-2 mb-3 d-none"></div>

                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <label class="btn btn-outline-secondary btn-sm rounded-pill" for="filePicker">
                            <i class="bi bi-images text-success me-1"></i>Thêm ảnh (chọn nhiều lần)
                        </label>
                        <input class="d-none" type="file" id="filePicker" accept="image/*" multiple onchange="addSelectedFiles(this)">
                        <input class="d-none" type="file" id="postImages" name="images" multiple>
                    </div>
                    <button type="submit" class="btn btn-primary px-4 rounded-pill fw-semibold">Đăng bài</button>
                </div>
            </form>
        </div>
    </div>

    <!-- DANH SÁCH BÀI VIẾT TRÊN BẢNG TIN -->
    <div class="d-flex flex-column gap-3">
        <c:forEach var="p" items="${posts}">
            <div class="card shadow-sm border-0 rounded-3" id="post-card-${p.id}">
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

                        <!-- MENU 3 CHẤM (LƯU / SỬA / XÓA) -->
                        <div class="position-relative post-menu-container">
                            <button class="btn btn-light btn-sm rounded-circle border-0" type="button" onclick="togglePostMenu(this, event)">
                                <i class="bi bi-three-dots-vertical"></i>
                            </button>
                            <ul class="dropdown-menu shadow border rounded-3 post-dropdown-menu py-1">
                                <!-- NÚT LƯU BÀI VIẾT -->
                                <li>
                                    <button type="button" class="dropdown-item py-2" onclick="savePostAjax(${p.id})">
                                        <i class="bi bi-bookmark-fill icon-saved-gradient me-2"></i>Lưu bài viết
                                    </button>
                                </li>
                                <li>
                                    <a class="dropdown-item py-2" href="${pageContext.request.contextPath}/post/edit/${p.id}">
                                        <i class="bi bi-pencil me-2 text-warning"></i>Chỉnh sửa
                                    </a>
                                </li>
                                <li><hr class="dropdown-divider my-1"></li>
                                <li>
                                    <form action="${pageContext.request.contextPath}/post/delete/${p.id}" method="post" 
                                          onsubmit="return confirm('Bạn có chắc chắn muốn xóa bài viết này không?');">
                                        <button type="submit" class="dropdown-item py-2 text-danger border-0 bg-transparent w-100 text-start">
                                            <i class="bi bi-trash me-2"></i>Xóa bài viết
                                        </button>
                                    </form>
                                </li>
                            </ul>
                        </div>
                    </div>

                    <!-- NỘI DUNG BÀI VIẾT: RÚT GỌN NẾU DÀI KÈM "... XEM THÊM" -->
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

                    <!-- LƯỚI ẢNH: BẤM VÀO ĐỂ MỞ LIGHTBOX -->
                    <c:if test="${not empty p.images}">
                        <c:set var="imgCount" value="${fn:length(p.images)}" />
                        <div class="post-images-grid ${imgCount >= 4 ? 'grid-4' : (imgCount == 3 ? 'grid-3' : (imgCount == 2 ? 'grid-2' : 'grid-1'))}">
                            
                            <c:forEach var="img" items="${p.images}" varStatus="status" end="3">
                                <div class="post-img-box" onclick="openImageViewer(${p.id}, ${status.index})">
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

                    <!-- NÚT CHIA SẺ & SỐ LƯỢT CHIA SẺ (DƯỚI BÀI VIẾT NHƯ HÌNH 1 & 4) -->
                    <div class="post-action-bar mt-3">
                        <button type="button" class="btn-post-share" onclick="openShareModal(${p.id}, '${p.user.fullName != null ? p.user.fullName : p.user.username}')">
                            <i class="bi bi-reply-fill" style="transform: scaleX(-1); font-size: 19px;"></i>
                            <span id="share-count-${p.id}">${p.shareCount != null ? p.shareCount : 0}</span>
                        </button>
                    </div>

                </div>
            </div>
        </c:forEach>

        <c:if test="${empty posts}">
            <div class="alert alert-white shadow-sm text-center py-5 rounded-3">
                <i class="bi bi-chat-square-dots display-6 text-muted mb-3 d-block"></i>
                <span class="text-muted">Chưa có bài viết nào trên bảng tin.</span>
            </div>
        </c:if>
    </div>

</div>

<!-- MODAL CHIA SẺ CHUẨN FACEBOOK (NHƯ HÌNH 5) -->
<div class="modal fade" id="shareModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" style="max-width: 520px;">
        <div class="modal-content rounded-4 border-0 shadow">
            
            <!-- HEADER MODAL -->
            <div class="modal-header border-0 pb-0 justify-content-center position-relative">
                <h5 class="modal-title fw-bold fs-5">Chia sẻ</h5>
                <button type="button" class="btn-close position-absolute end-0 me-3" data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body pt-3">
                
                <!-- PHẦN 1: CHIA SẺ LÊN BẢNG FEED CỦA MÌNH -->
                <form id="shareFeedForm" action="" method="post">
                    <div class="d-flex align-items-center gap-2 mb-3">
                        <img src="https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg" class="rounded-circle border" width="46" height="46">
                        <div>
                            <div class="fw-bold">Bạn</div>
                            <div class="d-flex gap-1 mt-1">
                                <span class="badge bg-light text-dark border fw-normal px-2 py-1">Bảng feed</span>
                                <select name="privacy" class="form-select form-select-sm py-0 px-2 text-muted border-light-subtle rounded-3" style="width: auto; font-size: 12px;">
                                    <option value="PUBLIC">Công khai</option>
                                    <option value="FRIENDS">Bạn bè</option>
                                    <option value="PRIVATE" selected>Chỉ mình tôi</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="mb-3">
                        <textarea class="form-control border-0 px-0 fs-6" name="caption" rows="2" 
                                  placeholder="Hãy nói gì đó về nội dung này..." style="resize: none;"></textarea>
                    </div>

                    <div class="d-flex justify-content-end mb-3">
                        <button type="submit" class="btn btn-primary px-4 rounded-pill fw-semibold">Chia sẻ ngay</button>
                    </div>
                </form>

                <hr class="text-secondary my-3 opacity-25">

                <!-- PHẦN 2: GỬI BẰNG MESSENGER / CHIA SẺ CHO BẠN BÈ ĐÃ KẾT BẠN -->
                <div>
                    <div class="fw-bold text-dark mb-3">Gửi bằng Messenger</div>
                    <div class="friend-avatar-list">
                        
                        <div class="friend-item" onclick="sendToFriend(this, 'nhóc')">
                            <img src="https://images.unsplash.com/photo-1543610892-0b1f7e6d8ac1?w=100&h=100&fit=crop">
                            <span>nhóc</span>
                        </div>
                        <div class="friend-item" onclick="sendToFriend(this, 'Đoàn Anh Bảo')">
                            <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&h=100&fit=crop">
                            <span>Đoàn Anh Bảo</span>
                        </div>
                        <div class="friend-item" onclick="sendToFriend(this, 'Lớp ae ATTT')">
                            <img src="https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=100&h=100&fit=crop">
                            <span>Lớp ae ATTT</span>
                        </div>
                        <div class="friend-item" onclick="sendToFriend(this, 'Duy Thông')">
                            <img src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop">
                            <span>Duy Thông</span>
                        </div>
                        <div class="friend-item" onclick="sendToFriend(this, 'Võ Ngọc Kiều Vy')">
                            <img src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop">
                            <span>Kiều Vy</span>
                        </div>

                    </div>
                </div>

            </div>
        </div>
    </div>
</div>

<!-- KHUNG MODAL XEM ẢNH LIGHTBOX (CÓ NÚT CHIA SẺ DƯỚI ẢNH) -->
<div id="imageViewerModal" onclick="closeViewerOnBackdrop(event)">
    
    <!-- THANH CÔNG CỤ TRÊN GÓC PHẢI -->
    <div class="viewer-top-tools" onclick="event.stopPropagation()">
        <span class="viewer-counter-badge" id="viewerCounter">1 / 1</span>
        
        <button type="button" class="viewer-tool-btn" id="btnZoomIn" title="Phóng to" onclick="triggerZoomIn(event)">
            <i class="bi bi-zoom-in"></i>
        </button>
        
        <button type="button" class="viewer-tool-btn" id="btnZoomOut" title="Thu nhỏ" onclick="triggerZoomOut(event)">
            <i class="bi bi-zoom-out"></i>
        </button>

        <a id="viewerDirectLink" href="#" target="_blank" class="viewer-tool-btn" title="Mở link ảnh gốc Cloudinary">
            <i class="bi bi-box-arrow-up-right"></i>
        </a>

        <button type="button" class="viewer-tool-btn" title="Đóng" onclick="closeImageViewer(event)">
            <i class="bi bi-x-lg"></i>
        </button>
    </div>

    <!-- NÚT ĐIỀU HƯỚNG TRÁI / PHẢI -->
    <button type="button" class="viewer-side-btn viewer-btn-left" title="Ảnh trước đó" onclick="showPrevImage(event)">
        <i class="bi bi-chevron-left"></i>
    </button>

    <div class="viewer-image-container" onwheel="handleWheelZoom(event)">
        <img id="imageViewerImg" src="" alt="Xem ảnh" ondblclick="toggleDoubleZoom(event)">
    </div>

    <!-- NÚT CHIA SẺ BÊN DƯỚI KHUNG XEM ẢNH -->
    <div class="viewer-bottom-bar" onclick="event.stopPropagation()">
        <button type="button" class="viewer-share-btn" onclick="openShareModalFromViewer()">
            <i class="bi bi-reply-fill" style="transform: scaleX(-1); font-size: 20px;"></i>
            <span>Chia sẻ</span>
        </button>
    </div>

    <button type="button" class="viewer-side-btn viewer-btn-right" title="Ảnh tiếp theo" onclick="showNextImage(event)">
        <i class="bi bi-chevron-right"></i>
    </button>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
// 1. Quản lý upload cộng dồn nhiều ảnh
const dt = new DataTransfer();

function addSelectedFiles(input) {
    if (input.files && input.files.length > 0) {
        for (let i = 0; i < input.files.length; i++) {
            dt.items.add(input.files[i]);
        }
        syncPostFiles();
        input.value = '';
    }
}

function removeSelectedFile(index) {
    dt.items.remove(index);
    syncPostFiles();
}

function syncPostFiles() {
    document.getElementById('postImages').files = dt.files;
    renderImagePreviews();
}

function renderImagePreviews() {
    const container = document.getElementById('imagePreviewContainer');
    container.innerHTML = '';
    
    if (dt.files.length > 0) {
        container.classList.remove('d-none');
        Array.from(dt.files).forEach((file, index) => {
            const wrap = document.createElement('div');
            wrap.className = 'preview-img-wrap';

            const img = document.createElement('img');
            img.src = URL.createObjectURL(file);
            img.className = 'rounded border shadow-sm w-100 h-100';
            img.style.objectFit = 'cover';

            const btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'btn btn-danger btn-remove-preview';
            btn.innerHTML = '&times;';
            btn.onclick = () => removeSelectedFile(index);

            wrap.appendChild(img);
            wrap.appendChild(btn);
            container.appendChild(wrap);
        });
    } else {
        container.classList.add('d-none');
    }
}

// 2. Menu 3 chấm
function togglePostMenu(button, event) {
    event.stopPropagation();
    const menu = button.nextElementSibling;
    const isCurrentlyOpen = menu.style.display === 'block';

    document.querySelectorAll('.post-dropdown-menu').forEach(m => m.style.display = 'none');
    menu.style.display = isCurrentlyOpen ? 'none' : 'block';
}

document.addEventListener('click', function() {
    document.querySelectorAll('.post-dropdown-menu').forEach(m => m.style.display = 'none');
});

// 3. RÚT GỌN NỘI DUNG DÀI KÈM "... XEM THÊM"
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

// 4. LƯU BÀI VIẾT (AJAX)
function savePostAjax(postId) {
    fetch('${pageContext.request.contextPath}/post/save/' + postId, {
        method: 'POST'
    })
    .then(res => res.json())
    .then(data => {
        if (data.isSaved) {
            alert('Đã lưu bài viết vào mục "Đã lưu"!');
        } else {
            alert('Đã bỏ lưu bài viết!');
        }
        document.querySelectorAll('.post-dropdown-menu').forEach(m => m.style.display = 'none');
    })
    .catch(() => alert('Có lỗi xảy ra khi lưu bài viết!'));
}

// 5. CHIA SẺ BÀI VIẾT & MODAL CHIA SẺ
let activeSharePostId = null;

function openShareModal(postId, authorName) {
    activeSharePostId = postId;
    const form = document.getElementById('shareFeedForm');
    form.action = '${pageContext.request.contextPath}/post/share/' + postId;
    
    const shareModal = new bootstrap.Modal(document.getElementById('shareModal'));
    shareModal.show();
}

function openShareModalFromViewer() {
    if (activeViewerPostId) {
        // Tạm đóng lightbox để mở modal chia sẻ nổi bật nhất
        closeImageViewer();
        openShareModal(activeViewerPostId, '');
    }
}

function sendToFriend(element, friendName) {
    if (!activeSharePostId) return;

    fetch('${pageContext.request.contextPath}/post/share/friend/' + activeSharePostId, {
        method: 'POST'
    })
    .then(res => res.json())
    .then(data => {
        alert('Đã gửi bài viết cho ' + friendName + ' thành công!');
        const counter = document.getElementById('share-count-' + activeSharePostId);
        if (counter) {
            counter.innerText = parseInt(counter.innerText) + 1;
        }
        bootstrap.Modal.getInstance(document.getElementById('shareModal')).hide();
    });
}

// 6. XỬ LÝ LIGHTBOX XEM ẢNH, ZOOM VÀ ĐIỀU HƯỚNG TRÁI / PHẢI
let currentPostImages = [];
let currentImageIndex = 0;
let currentZoom = 1.0;
let activeViewerPostId = null;

function openImageViewer(postId, index) {
    if (!window.postImagesMap || !window.postImagesMap[postId]) return;
    
    activeViewerPostId = postId;
    currentPostImages = window.postImagesMap[postId];
    currentImageIndex = index;
    currentZoom = 1.0;
    
    updateViewerImage();
    const modal = document.getElementById('imageViewerModal');
    modal.style.display = 'block';
    document.body.style.overflow = 'hidden';
}

function updateViewerImage() {
    const imgEl = document.getElementById('imageViewerImg');
    const counterEl = document.getElementById('viewerCounter');
    const directLinkEl = document.getElementById('viewerDirectLink');
    
    currentZoom = 1.0;
    applyZoom();

    imgEl.style.opacity = '0.3';
    setTimeout(() => {
        const currentUrl = currentPostImages[currentImageIndex];
        imgEl.src = currentUrl;
        if (directLinkEl) {
            directLinkEl.href = currentUrl;
        }
        imgEl.style.opacity = '1';
    }, 100);

    counterEl.innerText = (currentImageIndex + 1) + ' / ' + currentPostImages.length;
}

function applyZoom() {
    const imgEl = document.getElementById('imageViewerImg');
    const btnIn = document.getElementById('btnZoomIn');
    const btnOut = document.getElementById('btnZoomOut');
    
    if (imgEl) {
        imgEl.style.transform = "scale(" + currentZoom + ")";
        imgEl.style.cursor = currentZoom > 1.0 ? 'zoom-out' : 'zoom-in';
    }
    if (btnOut) {
        if (currentZoom <= 1.0) btnOut.classList.add('btn-disabled');
        else btnOut.classList.remove('btn-disabled');
    }
    if (btnIn) {
        if (currentZoom >= 3.0) btnIn.classList.add('btn-disabled');
        else btnIn.classList.remove('btn-disabled');
    }
}

function triggerZoomIn(e) {
    if (e) { e.preventDefault(); e.stopPropagation(); }
    if (currentZoom < 3.0) {
        currentZoom = Math.min(Math.round((currentZoom + 0.4) * 10) / 10, 3.0);
        applyZoom();
    }
}

function triggerZoomOut(e) {
    if (e) { e.preventDefault(); e.stopPropagation(); }
    if (currentZoom > 1.0) {
        currentZoom = Math.max(Math.round((currentZoom - 0.4) * 10) / 10, 1.0);
        applyZoom();
    }
}

function toggleDoubleZoom(e) {
    if (e) e.stopPropagation();
    currentZoom = (currentZoom === 1.0) ? 1.8 : 1.0;
    applyZoom();
}

function handleWheelZoom(e) {
    if (e) e.preventDefault();
    if (e.deltaY < 0) triggerZoomIn();
    else triggerZoomOut();
}

function showPrevImage(e) {
    if (e) e.stopPropagation();
    if (currentPostImages.length <= 1) return;
    currentImageIndex = (currentImageIndex - 1 + currentPostImages.length) % currentPostImages.length;
    updateViewerImage();
}

function showNextImage(e) {
    if (e) e.stopPropagation();
    if (currentPostImages.length <= 1) return;
    currentImageIndex = (currentImageIndex + 1) % currentPostImages.length;
    updateViewerImage();
}

function closeImageViewer(e) {
    if (e) e.stopPropagation();
    document.getElementById('imageViewerModal').style.display = 'none';
    document.body.style.overflow = '';
    currentZoom = 1.0;
    applyZoom();
}

function closeViewerOnBackdrop(e) {
    if (e.target.id === 'imageViewerModal' || e.target.classList.contains('viewer-image-container')) {
        closeImageViewer();
    }
}

document.addEventListener('keydown', function(e) {
    const modal = document.getElementById('imageViewerModal');
    if (modal && modal.style.display === 'block') {
        if (e.key === 'ArrowLeft') showPrevImage();
        else if (e.key === 'ArrowRight') showNextImage();
        else if (e.key === '+' || e.key === '=') triggerZoomIn();
        else if (e.key === '-' || e.key === '_') triggerZoomOut();
        else if (e.key === 'Escape') closeImageViewer();
    }
});
</script>

</body>
</html>