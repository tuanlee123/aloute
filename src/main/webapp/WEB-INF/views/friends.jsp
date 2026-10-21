<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<head>
    <title>${isOwner ? 'Bạn bè' : 'Bạn bè của '.concat(viewUser.fullName)} - ALOUTE</title>
    <style>
        .friends-sidebar {
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.08);
            padding: 16px;
        }
        .friend-menu-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 16px;
            border-radius: 10px;
            color: #050505;
            font-weight: 600;
            text-decoration: none;
            transition: background 0.15s;
            margin-bottom: 4px;
        }
        .friend-menu-item:hover {
            background: #f0f2f5;
            color: #050505;
        }
        .friend-menu-item.active {
            background: #e7f3ff;
            color: #1877f2;
        }
        .friend-menu-item i {
            font-size: 20px;
        }
        .friend-card {
            background: #ffffff;
            border: 1px solid #e4e6eb;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
            transition: transform 0.2s, box-shadow 0.2s;
            height: 100%;
            display: flex;
            flex-direction: column;
        }
        .friend-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        .friend-card-img {
            width: 100%;
            aspect-ratio: 1 / 1;
            object-fit: cover;
            cursor: pointer;
            background: #f0f2f5;
        }
        .friend-card-body {
            padding: 12px;
            display: flex;
            flex-direction: column;
            flex-grow: 1;
        }
        .mutual-badge {
            color: #65676b;
            font-size: 13px;
            cursor: pointer;
        }
        .mutual-badge:hover {
            text-decoration: underline;
            color: #1877f2;
        }
    </style>
</head>

<div class="container my-4" style="max-width: 1080px;">
    <div class="row g-4">
        <!-- CỘT TRÁI: MENU ĐIỀU HƯỚNG BẠN BÈ -->
        <div class="col-lg-4 col-md-5">
            <div class="friends-sidebar sticky-top" style="top: 80px;">
                <h4 class="fw-bold mb-3">${isOwner ? 'Bạn bè' : 'Bạn bè của '.concat(viewUser.fullName)}</h4>

                <!-- Khung tìm kiếm (Chỉ hiện khi xem bạn bè của chính mình) -->
                <c:if test="${isOwner}">
                    <form action="<c:url value='/friends'/>" method="get" class="mb-3">
                        <input type="hidden" name="tab" value="search">
                        <div class="input-group">
                            <span class="input-group-text bg-light border-0"><i class="bi bi-search text-muted"></i></span>
                            <input type="text" name="search" class="form-control bg-light border-0" 
                                   placeholder="Tìm kiếm bạn bè..." value="${searchKeyword}">
                        </div>
                    </form>
                </c:if>

                <div class="d-flex flex-column">
                    <!-- 1. Lời mời kết bạn (Chỉ hiển thị khi là chính chủ) -->
                    <c:if test="${isOwner}">
                        <a href="<c:url value='/friends?tab=requests'/>" 
                           class="friend-menu-item ${activeTab == 'requests' ? 'active' : ''}">
                            <i class="bi bi-person-plus-fill"></i>
                            <span class="flex-grow-1">Lời mời kết bạn</span>
                            <c:if test="${not empty requests}">
                                <span class="badge bg-danger rounded-pill">${fn:length(requests)}</span>
                            </c:if>
                        </a>
                    </c:if>

                    <!-- 2. Tất cả bạn bè -->
                    <a href="<c:url value='/friends${!isOwner ? "?userId=".concat(viewUser.id) : "?tab=all"}'/>" 
                       class="friend-menu-item ${activeTab == 'all' ? 'active' : ''}">
                        <i class="bi bi-people-fill"></i>
                        <span class="flex-grow-1">Tất cả bạn bè</span>
                        <span class="badge bg-light text-dark rounded-pill">${totalFriendsCount}</span>
                    </a>

                    <!-- Nếu đang xem bạn bè của người khác: có nút quay về trang cá nhân của họ -->
                    <c:if test="${!isOwner}">
                        <a href="<c:url value='/profile?userId=${viewUser.id}'/>" class="friend-menu-item mt-2 text-primary">
                            <i class="bi bi-arrow-left"></i>
                            <span>Về trang cá nhân</span>
                        </a>
                    </c:if>
                </div>
            </div>
        </div>

        <!-- CỘT PHẢI: DANH SÁCH BẠN BÈ / LỜI MỜI -->
        <div class="col-lg-8 col-md-7">
            <!-- 1. TAB LỜI MỜI KẾT BẠN -->
            <c:if test="${isOwner && activeTab == 'requests'}">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h5 class="fw-bold mb-0">Lời mời kết bạn (${fn:length(requests)})</h5>
                </div>

                <c:choose>
                    <c:when test="${not empty requests}">
                        <div class="row row-cols-2 row-cols-md-3 g-3">
                            <c:forEach var="req" items="${requests}">
                                <div class="col">
                                    <div class="friend-card">
                                        <a href="<c:url value='/profile?userId=${req.requester.id}'/>">
                                            <img src="${empty req.requester.avatar ? 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg' : req.requester.avatar}" 
                                                 class="friend-card-img" alt="Avatar">
                                        </a>
                                        <div class="friend-card-body">
                                            <a href="<c:url value='/profile?userId=${req.requester.id}'/>" class="text-dark text-decoration-none fw-bold text-truncate mb-1">
                                                ${req.requester.fullName}
                                            </a>
                                            <span class="mutual-badge mb-3" onclick="openMutualModal(${req.requester.id}, '${req.requester.fullName}')">
                                                <i class="bi bi-people me-1"></i>${requestMutualCounts[req.id]} bạn chung
                                            </span>

                                            <div class="d-flex flex-column gap-2 mt-auto">
                                                <form action="<c:url value='/friends/accept/${req.id}'/>" method="post" class="m-0">
                                                    <button type="submit" class="btn btn-primary btn-sm w-100 fw-semibold rounded-3 py-2">Xác nhận</button>
                                                </form>
                                                <form action="<c:url value='/friends/reject/${req.id}'/>" method="post" class="m-0">
                                                    <button type="submit" class="btn btn-light btn-sm w-100 fw-semibold rounded-3 py-2 border">Xóa</button>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="card border-0 shadow-sm rounded-3 p-5 text-center text-muted">
                            <i class="bi bi-person-check fs-1 text-secondary opacity-50 mb-2"></i>
                            <h6 class="fw-bold text-dark">Không có lời mời kết bạn nào</h6>
                        </div>
                    </c:otherwise>
                </c:choose>
            </c:if>

            <!-- 2. TAB TẤT CẢ BẠN BÈ (CỦA CHÍNH MÌNH HOẶC CỦA NGƯỜI ĐANG XEM) -->
            <c:if test="${activeTab == 'all'}">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h5 class="fw-bold mb-0">
                        ${isOwner ? 'Tất cả bạn bè' : 'Tất cả bạn bè của '.concat(viewUser.fullName)} (${totalFriendsCount})
                    </h5>
                </div>

                <c:choose>
                    <c:when test="${not empty friends}">
                        <div class="row row-cols-2 row-cols-md-3 g-3">
                            <c:forEach var="fr" items="${friends}">
                                <div class="col">
                                    <div class="friend-card">
                                        <a href="<c:url value='/profile?userId=${fr.id}'/>">
                                            <img src="${empty fr.avatar ? 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg' : fr.avatar}" 
                                                 class="friend-card-img" alt="Avatar">
                                        </a>
                                        <div class="friend-card-body">
                                            <a href="<c:url value='/profile?userId=${fr.id}'/>" class="text-dark text-decoration-none fw-bold text-truncate mb-1">
                                                ${fr.fullName}
                                            </a>
                                            <span class="mutual-badge mb-3" onclick="openMutualModal(${fr.id}, '${fr.fullName}')">
                                                <i class="bi bi-people me-1"></i>${friendMutualCounts[fr.id]} bạn chung
                                            </span>

                                            <div class="mt-auto">
                                                <a href="<c:url value='/profile?userId=${fr.id}'/>" class="btn btn-light btn-sm w-100 fw-semibold rounded-3 py-2 border">
                                                    Xem trang cá nhân
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="card border-0 shadow-sm rounded-3 p-5 text-center text-muted">
                            <i class="bi bi-people fs-1 text-secondary opacity-50 mb-2"></i>
                            <h6 class="fw-bold text-dark">Chưa có người bạn nào</h6>
                        </div>
                    </c:otherwise>
                </c:choose>
            </c:if>

            <!-- 3. KẾT QUẢ TÌM KIẾM BẠN BÈ -->
            <c:if test="${isOwner && activeTab == 'search'}">
                <h5 class="fw-bold mb-3">Kết quả tìm kiếm cho: "${searchKeyword}"</h5>
                <c:choose>
                    <c:when test="${not empty searchResults}">
                        <div class="row row-cols-2 row-cols-md-3 g-3">
                            <c:forEach var="usr" items="${searchResults}">
                                <div class="col">
                                    <div class="friend-card">
                                        <a href="<c:url value='/profile?userId=${usr.id}'/>">
                                            <img src="${empty usr.avatar ? 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg' : usr.avatar}" 
                                                 class="friend-card-img" alt="Avatar">
                                        </a>
                                        <div class="friend-card-body">
                                            <a href="<c:url value='/profile?userId=${usr.id}'/>" class="text-dark text-decoration-none fw-bold text-truncate mb-1">
                                                ${usr.fullName}
                                            </a>
                                            <span class="mutual-badge mb-3" onclick="openMutualModal(${usr.id}, '${usr.fullName}')">
                                                <i class="bi bi-people me-1"></i>${searchMutualCounts[usr.id]} bạn chung
                                            </span>

                                            <div class="mt-auto">
                                                <c:choose>
                                                    <c:when test="${statusMap[usr.id] == 'FRIENDS'}">
                                                        <button class="btn btn-secondary btn-sm w-100 rounded-3" disabled>Bạn bè</button>
                                                    </c:when>
                                                    <c:when test="${statusMap[usr.id] == 'SENT'}">
                                                        <button class="btn btn-light btn-sm w-100 border rounded-3" disabled>Đã gửi lời mời</button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <form action="<c:url value='/friends/add/${usr.id}'/>" method="post" class="m-0">
                                                            <input type="hidden" name="search" value="${searchKeyword}">
                                                            <button type="submit" class="btn btn-primary btn-sm w-100 fw-semibold rounded-3 py-2">
                                                                <i class="bi bi-person-plus-fill me-1"></i>Thêm bạn bè
                                                            </button>
                                                        </form>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="card border-0 shadow-sm rounded-3 p-5 text-center text-muted">
                            <i class="bi bi-search fs-1 text-secondary opacity-50 mb-2"></i>
                            <h6 class="fw-bold text-dark">Không tìm thấy người dùng phù hợp</h6>
                        </div>
                    </c:otherwise>
                </c:choose>
            </c:if>
        </div>
    </div>
</div>

<!-- MODAL BẠN CHUNG -->
<div class="modal fade" id="mutualFriendsModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content rounded-4 border-0 shadow">
            <div class="modal-header border-bottom py-2">
                <h6 class="modal-title fw-bold" id="mutualModalTitle">Bạn chung</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-2" id="mutualModalBody" style="max-height: 350px; overflow-y: auto;">
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