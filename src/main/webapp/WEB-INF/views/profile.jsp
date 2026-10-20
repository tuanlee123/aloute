<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<head>
    <title>${user.fullName} - ALOUTE</title>
    <!-- Cropper.js CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.1/cropper.min.css"/>
    <style>
        .profile-cover {
            height: 300px;
            background-color: #2b3035;
            background-image: url('${not empty user.coverImage ? user.coverImage : "https://images.unsplash.com/photo-1707343843437-caacff5cfa74?q=80&w=1200"}');
            background-size: cover;
            background-position: center;
            border-bottom-left-radius: 12px;
            border-bottom-right-radius: 12px;
            position: relative;
        }
        .btn-change-cover {
            position: absolute;
            bottom: 16px;
            right: 16px;
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(4px);
        }
        .profile-avatar-wrapper {
            position: absolute;
            bottom: -45px;
            left: 32px;
        }
        .profile-avatar {
            width: 145px;
            height: 145px;
            border: 4px solid #ffffff;
            object-fit: cover;
        }
        .btn-change-avatar {
            position: absolute;
            bottom: 6px;
            right: 6px;
            width: 38px;
            height: 38px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #e4e6eb;
            border: 2px solid #ffffff;
            cursor: pointer;
        }
        .btn-change-avatar:hover {
            background: #d8dadf;
        }
        .profile-header-info {
            padding-top: 55px;
            padding-left: 32px;
            padding-right: 32px;
            padding-bottom: 12px;
        }
        /* Khung hiển thị bộ cắt ảnh */
        .crop-container {
            max-height: 420px;
            background-color: #1a1a1a;
            overflow: hidden;
            display: flex;
            justify-content: center;
            align-items: center;
            border-radius: 8px;
        }
        .crop-container img {
            max-width: 100%;
            display: block;
        }
        /* Vòng tròn xem trước phong cách FB */
        .cropper-view-box,
        .cropper-face {
            border-radius: 50%;
        }
        .cover-crop .cropper-view-box,
        .cover-crop .cropper-face {
            border-radius: 4px;
        }
    </style>
</head>

<div class="container px-0" style="max-width: 960px;">
    <!-- THÔNG BÁO -->
    <c:if test="${not empty successMessage}">
        <div class="alert alert-success alert-dismissible fade show small my-2 shadow-sm" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i>${successMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show small my-2 shadow-sm" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>${errorMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <!-- HEADER PROFILE -->
    <div class="bg-white rounded-bottom shadow-sm mb-3">
        <!-- Ảnh bìa -->
        <div class="profile-cover" id="coverContainer">
            <button class="btn btn-sm btn-light shadow-sm fw-semibold btn-change-cover" data-bs-toggle="modal" data-bs-target="#coverModal">
                <i class="bi bi-camera-fill me-1"></i> Chỉnh sửa ảnh bìa
            </button>
            <!-- Avatar tròn -->
            <div class="profile-avatar-wrapper">
                <img src="${not empty user.avatar ? user.avatar : 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg'}" 
                     alt="Avatar" class="rounded-circle profile-avatar shadow-sm" id="avatarDisplay">
                <button class="btn btn-sm btn-change-avatar" data-bs-toggle="modal" data-bs-target="#avatarModal" title="Đổi ảnh đại diện">
                    <i class="bi bi-camera-fill text-dark fs-6"></i>
                </button>
            </div>
        </div>

        <div class="profile-header-info">
            <div class="border-bottom pb-3">
                <h2 class="fw-bold mb-0 text-dark">${user.fullName}</h2>
            </div>

            <div class="d-flex gap-4 pt-2 fw-semibold">
                <a href="#" class="text-primary text-decoration-none border-bottom border-primary border-3 pb-2">Bài viết</a>
                <a href="#" class="text-muted text-decoration-none pb-2">Bạn bè</a>
                <a href="#" class="text-muted text-decoration-none pb-2">Ảnh</a>
            </div>
        </div>
    </div>

    <!-- KHU VỰC 2 CỘT -->
    <div class="row g-3">
        <!-- Cột trái: Thông tin hiển thị -->
        <div class="col-lg-5">
            <div class="card border-0 shadow-sm rounded-3 p-3">
                <h5 class="fw-bold mb-3">Giới thiệu</h5>
                <div class="mb-2 text-secondary small">
                    <i class="bi bi-person-badge fs-6 me-2 text-dark"></i>Tên: <strong>${user.fullName}</strong>
                </div>
                <div class="mb-2 text-secondary small">
                    <i class="bi bi-envelope-at fs-6 me-2 text-dark"></i>Email: <strong>${user.email}</strong>
                </div>
                <div class="mb-3 text-secondary small">
                    <i class="bi bi-calendar-check fs-6 me-2 text-dark"></i>Tham gia: Tháng 10, 2026
                </div>
                <a href="<c:url value='/settings?tab=account'/>" class="btn btn-light w-100 fw-semibold small border">
                    Chỉnh sửa chi tiết
                </a>
            </div>
        </div>

        <!-- Cột phải: Đăng bài -->
        <div class="col-lg-7">
            <div class="card border-0 shadow-sm rounded-3 p-3 mb-3">
                <div class="d-flex gap-2 align-items-center">
                    <img src="${not empty user.avatar ? user.avatar : 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg'}" 
                         class="rounded-circle" width="38" height="38" style="object-fit: cover;">
                    <input type="text" class="form-control rounded-pill bg-light border-0 py-2 px-3" placeholder="${user.fullName} ơi, bạn đang nghĩ gì?">
                </div>
            </div>

            <div class="card border-0 shadow-sm rounded-3 p-4 text-center text-muted">
                <i class="bi bi-file-earmark-post fs-1 text-secondary opacity-50"></i>
                <p class="mt-2 mb-0 fw-semibold">Chưa có bài viết nào</p>
                <small>Những bài viết của bạn sẽ được hiển thị ở đây.</small>
            </div>
        </div>
    </div>
</div>

<!-- ================= MODAL 1: ĐỔI AVATAR (CÓ KÉO THU PHÓNG CẮT ẢNH) ================= -->
<div class="modal fade" id="avatarModal" tabindex="-1" data-bs-backdrop="static">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content border-0 shadow rounded-4">
            <div class="modal-header border-bottom">
                <h5 class="modal-title fw-bold">Chỉnh sửa ảnh đại diện</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" onclick="destroyAvatarCropper()"></button>
            </div>
            <form action="<c:url value='/profile/update-avatar'/>" method="post" id="avatarForm">
                <input type="hidden" id="avatarFinalData" name="avatarUrl">
                <div class="modal-body">
                    <!-- Chọn file -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold small text-dark">Tải ảnh lên từ thiết bị:</label>
                        <input type="file" id="avatarFileInput" class="form-control" accept="image/*">
                    </div>

                    <!-- Vùng kéo cắt ảnh -->
                    <div id="avatarCropArea" class="d-none">
                        <div class="crop-container mb-3">
                            <img id="avatarImageToCrop" src="">
                        </div>

                        <!-- Thanh công cụ Zoom in/out và xoay ảnh -->
                        <div class="d-flex align-items-center justify-content-center gap-3 bg-light p-2 rounded-3">
                            <i class="bi bi-zoom-out text-muted fs-5"></i>
                            <input type="range" class="form-range w-50" id="avatarZoomRange" min="0.1" max="3" step="0.05" value="1">
                            <i class="bi bi-zoom-in text-muted fs-5"></i>
                            <button type="button" class="btn btn-sm btn-outline-secondary ms-2" onclick="avatarCropper.rotate(90)" title="Xoay 90 độ">
                                <i class="bi bi-arrow-clockwise"></i>
                            </button>
                        </div>
                        <small class="text-muted d-block text-center mt-2">Dùng chuột hoặc thanh trượt để kéo di chuyển và thu phóng vùng chọn tròn.</small>
                    </div>
                </div>
                <div class="modal-footer border-top">
                    <button type="button" class="btn btn-light fw-semibold" data-bs-dismiss="modal" onclick="destroyAvatarCropper()">Hủy</button>
                    <button type="button" id="btnSaveAvatar" class="btn btn-primary fw-semibold px-4" disabled onclick="saveCroppedAvatar()">
                        Lưu Avatar
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ================= MODAL 2: ĐỔI ẢNH BÌA (CÓ KÉO THU PHÓNG CẮT ẢNH 16:9) ================= -->
<div class="modal fade" id="coverModal" tabindex="-1" data-bs-backdrop="static">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content border-0 shadow rounded-4 cover-crop">
            <div class="modal-header border-bottom">
                <h5 class="modal-title fw-bold">Chỉnh sửa ảnh bìa</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" onclick="destroyCoverCropper()"></button>
            </div>
            <form action="<c:url value='/profile/update-cover'/>" method="post" id="coverForm">
                <input type="hidden" id="coverFinalData" name="coverUrl">
                <div class="modal-body">
                    <!-- Chọn file -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold small text-dark">Tải ảnh bìa lên từ thiết bị:</label>
                        <input type="file" id="coverFileInput" class="form-control" accept="image/*">
                    </div>

                    <!-- Vùng kéo cắt ảnh -->
                    <div id="coverCropArea" class="d-none">
                        <div class="crop-container mb-3">
                            <img id="coverImageToCrop" src="">
                        </div>

                        <!-- Thanh công cụ Zoom in/out -->
                        <div class="d-flex align-items-center justify-content-center gap-3 bg-light p-2 rounded-3">
                            <i class="bi bi-zoom-out text-muted fs-5"></i>
                            <input type="range" class="form-range w-50" id="coverZoomRange" min="0.1" max="3" step="0.05" value="1">
                            <i class="bi bi-zoom-in text-muted fs-5"></i>
                            <button type="button" class="btn btn-sm btn-outline-secondary ms-2" onclick="coverCropper.rotate(90)" title="Xoay 90 độ">
                                <i class="bi bi-arrow-clockwise"></i>
                            </button>
                        </div>
                        <small class="text-muted d-block text-center mt-2">Kéo ảnh và phóng to/thu nhỏ để chọn khung hiển thị đẹp nhất.</small>
                    </div>
                </div>
                <div class="modal-footer border-top">
                    <button type="button" class="btn btn-light fw-semibold" data-bs-dismiss="modal" onclick="destroyCoverCropper()">Hủy</button>
                    <button type="button" id="btnSaveCover" class="btn btn-primary fw-semibold px-4" disabled onclick="saveCroppedCover()">
                        Lưu Ảnh bìa
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Cropper.js JavaScript -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.1/cropper.min.js"></script>

<script>
    let avatarCropper = null;
    let coverCropper = null;

    // --- 1. XỬ LÝ CROP AVATAR (TỈ LỆ 1:1) ---
    const avatarFileInput = document.getElementById('avatarFileInput');
    const avatarImageToCrop = document.getElementById('avatarImageToCrop');
    const avatarCropArea = document.getElementById('avatarCropArea');
    const avatarZoomRange = document.getElementById('avatarZoomRange');
    const btnSaveAvatar = document.getElementById('btnSaveAvatar');

    function destroyAvatarCropper() {
        if (avatarCropper) {
            avatarCropper.destroy();
            avatarCropper = null;
        }
        avatarCropArea.classList.add('d-none');
        avatarFileInput.value = '';
        btnSaveAvatar.disabled = true;
    }

    avatarFileInput.addEventListener('change', function(e) {
        const file = e.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = function(evt) {
            avatarImageToCrop.src = evt.target.result;
            avatarCropArea.classList.remove('d-none');

            if (avatarCropper) avatarCropper.destroy();

            avatarCropper = new Cropper(avatarImageToCrop, {
                aspectRatio: 1, // Tỉ lệ vuông 1:1 cho avatar
                viewMode: 1,
                dragMode: 'move',
                autoCropArea: 0.8,
                restore: false,
                guides: false,
                center: true,
                highlight: false,
                cropBoxMovable: false,
                cropBoxResizable: false,
                toggleDragModeOnDblclick: false,
                ready: function() {
                    btnSaveAvatar.disabled = false;
                    avatarZoomRange.value = 1;
                }
            });
        };
        reader.readAsDataURL(file);
    });

    avatarZoomRange.addEventListener('input', function() {
        if (avatarCropper) {
            avatarCropper.zoomTo(parseFloat(this.value));
        }
    });

    function saveCroppedAvatar() {
        if (!avatarCropper) return;
        // Xuất ảnh ra kích thước chuẩn 360x360 nén JPEG chất lượng cao
        const canvas = avatarCropper.getCroppedCanvas({
            width: 360,
            height: 360,
            imageSmoothingEnabled: true,
            imageSmoothingQuality: 'high'
        });
        document.getElementById('avatarFinalData').value = canvas.toDataURL('image/jpeg', 0.85);
        document.getElementById('avatarForm').submit();
    }

    // --- 2. XỬ LÝ CROP ẢNH BÌA (TỈ LỆ 2.7:1 CHUẨN BANNER FB) ---
    const coverFileInput = document.getElementById('coverFileInput');
    const coverImageToCrop = document.getElementById('coverImageToCrop');
    const coverCropArea = document.getElementById('coverCropArea');
    const coverZoomRange = document.getElementById('coverZoomRange');
    const btnSaveCover = document.getElementById('btnSaveCover');

    function destroyCoverCropper() {
        if (coverCropper) {
            coverCropper.destroy();
            coverCropper = null;
        }
        coverCropArea.classList.add('d-none');
        coverFileInput.value = '';
        btnSaveCover.disabled = true;
    }

    coverFileInput.addEventListener('change', function(e) {
        const file = e.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = function(evt) {
            coverImageToCrop.src = evt.target.result;
            coverCropArea.classList.remove('d-none');

            if (coverCropper) coverCropper.destroy();

            coverCropper = new Cropper(coverImageToCrop, {
                aspectRatio: 960 / 300, // Tỉ lệ khung ảnh bìa ALOUTE
                viewMode: 1,
                dragMode: 'move',
                autoCropArea: 0.9,
                restore: false,
                guides: true,
                center: true,
                highlight: false,
                cropBoxMovable: false,
                cropBoxResizable: false,
                toggleDragModeOnDblclick: false,
                ready: function() {
                    btnSaveCover.disabled = false;
                    coverZoomRange.value = 1;
                }
            });
        };
        reader.readAsDataURL(file);
    });

    coverZoomRange.addEventListener('input', function() {
        if (coverCropper) {
            coverCropper.zoomTo(parseFloat(this.value));
        }
    });

    function saveCroppedCover() {
        if (!coverCropper) return;
        // Xuất ảnh ra kích thước 1200x444 nén JPEG
        const canvas = coverCropper.getCroppedCanvas({
            width: 1200,
            height: 444,
            imageSmoothingEnabled: true,
            imageSmoothingQuality: 'high'
        });
        document.getElementById('coverFinalData').value = canvas.toDataURL('image/jpeg', 0.85);
        document.getElementById('coverForm').submit();
    }
</script>