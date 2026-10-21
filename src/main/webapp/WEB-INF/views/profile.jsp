<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<head>
    <title>${user.fullName} | ALOUTE</title>
    <!-- Cropper.js CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.1/cropper.min.css" />
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

        .cropper-view-box,
        .cropper-face {
            border-radius: 50%;
        }

        .cover-crop .cropper-view-box,
        .cover-crop .cropper-face {
            border-radius: 4px;
        }

        /* LƯỚI ẢNH CHO BÀI VIẾT */
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
        }

        .btn-post-share:hover {
            background-color: #f0f2f5;
            color: #1877f2;
        }

        /* KHỐI BẠN BÈ PROFILE */
        .friend-grid-card {
            text-decoration: none;
            display: block;
            transition: transform 0.15s ease;
        }
        .friend-grid-card:hover {
            transform: scale(1.03);
        }
        .friend-grid-img {
            aspect-ratio: 1 / 1;
            object-fit: cover;
            border-radius: 8px;
            background: #f0f2f5;
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
            <c:if test="${isOwner || (sessionScope.currentUser != null && sessionScope.currentUser.id == user.id)}">
                <button class="btn btn-sm btn-light shadow-sm fw-semibold btn-change-cover"
                    data-bs-toggle="modal" data-bs-target="#coverModal">
                    <i class="bi bi-camera-fill me-1"></i> Chỉnh sửa ảnh bìa
                </button>
            </c:if>

            <!-- Avatar tròn -->
            <div class="profile-avatar-wrapper">
                <img src="${not empty user.avatar ? user.avatar : 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg'}"
                    alt="Avatar" class="rounded-circle profile-avatar shadow-sm" id="avatarDisplay">
                <c:if test="${isOwner || (sessionScope.currentUser != null && sessionScope.currentUser.id == user.id)}">
                    <button class="btn btn-sm btn-change-avatar" data-bs-toggle="modal"
                        data-bs-target="#avatarModal" title="Đổi ảnh đại diện">
                        <i class="bi bi-camera-fill text-dark fs-6"></i>
                    </button>
                </c:if>
            </div>
        </div>

        <div class="profile-header-info">
            <div class="border-bottom pb-3 d-flex justify-content-between align-items-end flex-wrap gap-2">
                <div>
                    <h2 class="fw-bold mb-1 text-dark">${user.fullName != null ? user.fullName : user.username}</h2>
                    <c:if test="${!isOwner && mutualWithProfileUser > 0}">
                        <div class="text-secondary small">
                            <i class="bi bi-people me-1"></i>${mutualWithProfileUser} bạn chung
                        </div>
                    </c:if>
                </div>

                <!-- NÚT TƯƠNG TÁC KHI XEM TRANG CÁ NHÂN NGƯỜI KHÁC -->
                <c:if test="${!isOwner && (sessionScope.currentUser == null || sessionScope.currentUser.id != user.id)}">
                    <div>
                        <c:choose>
                            <%-- DROPDOWN BẠN BÈ & HỦY KẾT BẠN --%>
                            <c:when test="${friendshipStatus == 'FRIENDS'}">
                                <div class="dropdown d-inline-block">
                                    <button class="btn btn-light border fw-semibold rounded-pill px-3 shadow-sm d-flex align-items-center gap-2"
                                            type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                        <i class="bi bi-person-check-fill text-dark"></i>
                                        <span>Bạn bè</span>
                                    </button>
                                    <ul class="dropdown-menu dropdown-menu-end shadow border-0 rounded-4 py-2 mt-1" style="min-width: 230px;">
                                        <li>
                                            <a class="dropdown-item py-2 d-flex align-items-center gap-2 text-dark" href="javascript:void(0)">
                                                <i class="bi bi-star fs-5 text-secondary"></i>
                                                <span>Yêu thích</span>
                                            </a>
                                        </li>
                                        <li>
                                            <a class="dropdown-item py-2 d-flex align-items-center gap-2 text-dark" href="javascript:void(0)">
                                                <i class="bi bi-person-gear fs-5 text-secondary"></i>
                                                <span>Chỉnh sửa danh sách bạn bè</span>
                                            </a>
                                        </li>
                                        <li>
                                            <a class="dropdown-item py-2 d-flex align-items-center gap-2 text-dark" href="javascript:void(0)">
                                                <i class="bi bi-x-square fs-5 text-secondary"></i>
                                                <span>Bỏ theo dõi</span>
                                            </a>
                                        </li>
                                        <li><hr class="dropdown-divider my-1"></li>
                                        <li>
                                            <form action="<c:url value='/friends/unfriend/${user.id}'/>" method="post" class="m-0"
                                                  onsubmit="return confirm('Bạn có chắc chắn muốn hủy kết bạn với ${user.fullName}?');">
                                                <button type="submit" class="dropdown-item py-2 d-flex align-items-center gap-2 text-danger border-0 bg-transparent w-100 text-start">
                                                    <i class="bi bi-person-x fs-5"></i>
                                                    <span class="fw-semibold">Hủy kết bạn</span>
                                                </button>
                                            </form>
                                        </li>
                                    </ul>
                                </div>
                            </c:when>
                            <c:when test="${friendshipStatus == 'SENT'}">
                                <button class="btn btn-light border fw-semibold rounded-pill px-3 shadow-sm" disabled>
                                    <i class="bi bi-clock-history text-secondary me-1"></i>Đã gửi lời mời
                                </button>
                            </c:when>
                            <c:when test="${friendshipStatus == 'RECEIVED'}">
                                <a href="<c:url value='/friends?tab=requests'/>" class="btn btn-primary fw-semibold rounded-pill px-3 shadow-sm">
                                    <i class="bi bi-person-check-fill me-1"></i>Phản hồi lời mời
                                </a>
                            </c:when>
                            <c:otherwise>
                                <form action="<c:url value='/friends/add/${user.id}'/>" method="post" class="m-0">
                                    <button type="submit" class="btn btn-primary fw-semibold rounded-pill px-3 shadow-sm">
                                        <i class="bi bi-person-plus-fill me-1"></i>Thêm bạn bè
                                    </button>
                                </form>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:if>
            </div>

            <div class="d-flex gap-4 pt-2 fw-semibold">
                <a href="#" class="text-primary text-decoration-none border-bottom border-primary border-3 pb-2">Bài viết</a>
                <a href="<c:url value='/friends?userId=${user.id}'/>" class="text-muted text-decoration-none pb-2">Bạn bè (${not empty totalFriendsCount ? totalFriendsCount : 0})</a>
                <a href="#" class="text-muted text-decoration-none pb-2">Ảnh</a>
            </div>
        </div>
    </div>

    <!-- KHU VỰC 2 CỘT -->
    <div class="row g-3">
        <!-- Cột trái: Thông tin hiển thị & Lưới bạn bè -->
        <div class="col-lg-5">
            <!-- 1. Card Giới thiệu -->
            <div class="card border-0 shadow-sm rounded-3 p-3">
                <h5 class="fw-bold mb-3">Giới thiệu</h5>
                <div class="mb-2 text-secondary small">
                    <i class="bi bi-person-badge fs-6 me-2 text-dark"></i>Tên:
                    <strong>${user.fullName != null ? user.fullName : user.username}</strong>
                </div>
                <div class="mb-2 text-secondary small">
                    <i class="bi bi-envelope-at fs-6 me-2 text-dark"></i>Email:
                    <strong>${user.email}</strong>
                </div>
                <div class="mb-3 text-secondary small">
                    <i class="bi bi-calendar-check fs-6 me-2 text-dark"></i>Tham gia: Tháng 10, 2026
                </div>
                <c:if test="${isOwner || (sessionScope.currentUser != null && sessionScope.currentUser.id == user.id)}">
                    <a href="<c:url value='/settings?tab=account'/>" class="btn btn-light w-100 fw-semibold small border">
                        Chỉnh sửa chi tiết
                    </a>
                </c:if>
            </div>

            <!-- 2. Card Bạn bè chuẩn Facebook -->
            <div class="card border-0 shadow-sm rounded-3 p-3 mt-3">
                <div class="d-flex justify-content-between align-items-center mb-1">
                    <h5 class="fw-bold mb-0">Bạn bè</h5>
                    <a href="<c:url value='/friends?userId=${user.id}'/>" class="text-primary text-decoration-none small fw-semibold">
                        Xem tất cả bạn bè
                    </a>
                </div>
                <div class="text-secondary small mb-3">${not empty totalFriendsCount ? totalFriendsCount : 0} người bạn</div>

                <c:choose>
                    <c:when test="${not empty userFriends}">
                        <div class="row row-cols-3 g-2">
                            <c:forEach var="fr" items="${userFriends}" end="8">
                                <div class="col">
                                    <a href="<c:url value='/profile?userId=${fr.id}'/>" class="friend-grid-card">
                                        <img src="${empty fr.avatar ? 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg' : fr.avatar}" 
                                             class="friend-grid-img w-100 border shadow-sm" alt="Avatar">
                                        <div class="text-dark fw-semibold text-truncate mt-1" style="font-size: 13px;" title="${fr.fullName}">
                                            ${fr.fullName}
                                        </div>
                                        <div class="text-muted text-truncate" style="font-size: 11px;">
                                            ${mutualCounts[fr.id] != null ? mutualCounts[fr.id] : 0} bạn chung
                                        </div>
                                    </a>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center py-4 text-muted small">
                            <i class="bi bi-people fs-3 opacity-50 d-block mb-1"></i>
                            Chưa có người bạn nào
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- Cột phải: Khung đăng bài & Danh sách bài viết -->
        <div class="col-lg-7">
            <!-- KHUNG ĐĂNG BÀI VIẾT (CHỈ HIỂN THỊ KHI LÀ CHÍNH CHỦ) -->
            <c:if test="${isOwner || (sessionScope.currentUser != null && sessionScope.currentUser.id == user.id)}">
                <div class="card shadow-sm border-0 mb-3 rounded-3">
                    <div class="card-header bg-white fw-bold py-3 border-0">
                        <i class="bi bi-pencil-square me-2 text-primary"></i>Tạo bài viết mới
                    </div>
                    <div class="card-body pt-0">
                        <form action="${pageContext.request.contextPath}/post/create" method="post" enctype="multipart/form-data">
                            <input type="hidden" name="redirectUrl" value="/profile">
                            <div class="mb-3">
                                <textarea class="form-control border-light-subtle" name="content" rows="3"
                                    placeholder="${user.fullName} ơi, bạn đang nghĩ gì thế?..." required></textarea>
                            </div>

                            <div id="imagePreviewContainer" class="d-flex flex-wrap gap-2 mb-3 d-none"></div>

                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <label class="btn btn-outline-secondary btn-sm rounded-pill" for="filePicker">
                                        <i class="bi bi-images text-success me-1"></i>Thêm ảnh
                                    </label>
                                    <input class="d-none" type="file" id="filePicker" accept="image/*" multiple onchange="addSelectedFiles(this)">
                                    <input class="d-none" type="file" id="postImages" name="images" multiple>
                                </div>

                                <div class="d-flex align-items-center gap-2">
                                    <select name="privacy"
                                        class="form-select form-select-sm rounded-pill border-light-subtle bg-light text-secondary py-1 px-3 fw-semibold"
                                        style="width: auto; cursor: pointer;">
                                        <option value="PUBLIC" selected>🌐 Công khai</option>
                                        <option value="FRIENDS">👥 Bạn bè</option>
                                        <option value="PRIVATE">🔒 Chỉ mình tôi</option>
                                    </select>
                                    <button type="submit" class="btn btn-primary px-4 rounded-pill fw-semibold">Đăng bài</button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </c:if>

            <!-- VÒNG LẶP RENDER TOÀN BỘ BÀI ĐĂNG VÀ BÀI CHIA SẺ -->
            <div class="d-flex flex-column gap-3">
                <c:forEach var="p" items="${posts}">
                    <div class="card shadow-sm border-0 rounded-3" id="post-card-${p.id}">
                        <div class="card-body">
                            <!-- Tác giả, Ngày đăng & Menu 3 chấm -->
                            <div class="d-flex justify-content-between align-items-center mb-2">
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
                                            <button type="button" class="dropdown-item py-2" onclick="savePostAjax(${p.id})">
                                                <i class="bi bi-bookmark-fill text-danger me-2"></i>Lưu bài viết
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
                                                    <input type="hidden" name="redirectUrl" value="/profile${!isOwner ? '?userId='.concat(user.id) : ''}">
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
                            <p class="card-text text-dark mb-2" style="white-space: pre-line;"><c:out value="${p.content}" /></p>

                            <!-- Lưới ảnh đính kèm -->
                            <c:if test="${not empty p.images}">
                                <c:set var="imgCount" value="${fn:length(p.images)}" />
                                <div class="post-images-grid ${imgCount >= 4 ? 'grid-4' : (imgCount == 3 ? 'grid-3' : (imgCount == 2 ? 'grid-2' : 'grid-1'))} mb-3">
                                    <c:forEach var="img" items="${p.images}">
                                        <div class="post-img-box">
                                            <img src="${img.imageUrl}" alt="Ảnh bài viết">
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:if>

                            <!-- Thanh tương tác Thích & Chia sẻ -->
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
                                                class="rounded-circle me-2 border" width="32" height="32" style="object-fit: cover;" alt="Avatar">
                                        </a>

                                        <div class="bg-light p-2 rounded-3 flex-grow-1 position-relative">
                                            <div class="d-flex justify-content-between align-items-center">
                                                <a href="${pageContext.request.contextPath}/profile?userId=${c.user.id}" class="text-dark fw-bold text-decoration-none" style="font-size: 0.85rem;">
                                                    <c:out value="${c.user.fullName != null ? c.user.fullName : c.user.username}" />
                                                </a>

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

                                            <div id="comment-text-${c.id}" class="text-secondary" style="font-size: 0.9rem;">
                                                <c:out value="${c.content}" />
                                            </div>

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

                            <!-- Ô nhập bình luận AJAX -->
                            <form class="form-comment mt-2 d-flex gap-2" data-post-id="${p.id}">
                                <input type="text" class="form-control form-control-sm rounded-pill input-comment px-3"
                                    placeholder="Viết bình luận..." required autocomplete="off" />
                                <button type="submit" class="btn btn-sm btn-primary rounded-pill px-3">Gửi</button>
                            </form>
                        </div>
                    </div>
                </c:forEach>

                <c:if test="${empty posts}">
                    <div class="card border-0 shadow-sm rounded-3 p-4 text-center text-muted">
                        <i class="bi bi-file-earmark-post fs-1 text-secondary opacity-50"></i>
                        <p class="mt-2 mb-0 fw-semibold">Chưa có bài viết nào</p>
                        <small>Những bài viết và bài chia sẻ sẽ xuất hiện tại đây.</small>
                    </div>
                </c:if>
            </div>
        </div>
    </div>
</div>

<!-- ================= MODAL 1: ĐỔI AVATAR ================= -->
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
                    <div class="mb-3">
                        <label class="form-label fw-semibold small text-dark">Tải ảnh lên từ thiết bị:</label>
                        <input type="file" id="avatarFileInput" class="form-control" accept="image/*">
                    </div>

                    <div id="avatarCropArea" class="d-none">
                        <div class="crop-container mb-3">
                            <img id="avatarImageToCrop" src="">
                        </div>

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

<!-- ================= MODAL 2: ĐỔI ẢNH BÌA ================= -->
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
                    <div class="mb-3">
                        <label class="form-label fw-semibold small text-dark">Tải ảnh bìa lên từ thiết bị:</label>
                        <input type="file" id="coverFileInput" class="form-control" accept="image/*">
                    </div>

                    <div id="coverCropArea" class="d-none">
                        <div class="crop-container mb-3">
                            <img id="coverImageToCrop" src="">
                        </div>

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

    avatarFileInput.addEventListener('change', function (e) {
        const file = e.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = function (evt) {
            avatarImageToCrop.src = evt.target.result;
            avatarCropArea.classList.remove('d-none');

            if (avatarCropper) avatarCropper.destroy();

            avatarCropper = new Cropper(avatarImageToCrop, {
                aspectRatio: 1,
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
                ready: function () {
                    btnSaveAvatar.disabled = false;
                    avatarZoomRange.value = 1;
                }
            });
        };
        reader.readAsDataURL(file);
    });

    avatarZoomRange.addEventListener('input', function () {
        if (avatarCropper) {
            avatarCropper.zoomTo(parseFloat(this.value));
        }
    });

    function saveCroppedAvatar() {
        if (!avatarCropper) return;
        const canvas = avatarCropper.getCroppedCanvas({
            width: 360,
            height: 360,
            imageSmoothingEnabled: true,
            imageSmoothingQuality: 'high'
        });
        document.getElementById('avatarFinalData').value = canvas.toDataURL('image/jpeg', 0.85);
        document.getElementById('avatarForm').submit();
    }

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

    coverFileInput.addEventListener('change', function (e) {
        const file = e.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = function (evt) {
            coverImageToCrop.src = evt.target.result;
            coverCropArea.classList.remove('d-none');

            if (coverCropper) coverCropper.destroy();

            coverCropper = new Cropper(coverImageToCrop, {
                aspectRatio: 960 / 300,
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
                ready: function () {
                    btnSaveCover.disabled = false;
                    coverZoomRange.value = 1;
                }
            });
        };
        reader.readAsDataURL(file);
    });

    coverZoomRange.addEventListener('input', function () {
        if (coverCropper) {
            coverCropper.zoomTo(parseFloat(this.value));
        }
    });

    function saveCroppedCover() {
        if (!coverCropper) return;
        const canvas = coverCropper.getCroppedCanvas({
            width: 1200,
            height: 444,
            imageSmoothingEnabled: true,
            imageSmoothingQuality: 'high'
        });
        document.getElementById('coverFinalData').value = canvas.toDataURL('image/jpeg', 0.85);
        document.getElementById('coverForm').submit();
    }

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
        })
        .catch(() => alert('Có lỗi xảy ra khi lưu bài viết!'));
    }

    const profileDt = new DataTransfer();
    function addSelectedFiles(input) {
        if (input.files && input.files.length > 0) {
            for (let i = 0; i < input.files.length; i++) {
                profileDt.items.add(input.files[i]);
            }
            syncPostFiles();
            input.value = '';
        }
    }
    function removeSelectedFile(index) {
        profileDt.items.remove(index);
        syncPostFiles();
    }
    function syncPostFiles() {
        const postImages = document.getElementById('postImages');
        if (postImages) postImages.files = profileDt.files;
        renderImagePreviews();
    }
    function renderImagePreviews() {
        const container = document.getElementById('imagePreviewContainer');
        if (!container) return;
        container.innerHTML = '';
        if (profileDt.files.length > 0) {
            container.classList.remove('d-none');
            Array.from(profileDt.files).forEach((file, index) => {
                const wrap = document.createElement('div');
                wrap.style.cssText = 'position:relative; display:inline-block; width:70px; height:70px;';
                const img = document.createElement('img');
                img.src = URL.createObjectURL(file);
                img.className = 'rounded border shadow-sm w-100 h-100';
                img.style.objectFit = 'cover';
                const btn = document.createElement('button');
                btn.type = 'button';
                btn.className = 'btn btn-danger btn-sm rounded-circle';
                btn.style.cssText = 'position:absolute; top:-5px; right:-5px; width:18px; height:18px; padding:0; line-height:16px; font-size:12px;';
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
</script>

<script src="${pageContext.request.contextPath}/js/interaction.js"></script>