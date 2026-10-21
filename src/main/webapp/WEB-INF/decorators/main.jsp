<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><sitemesh:write property='title' /> | ALOUTE</title>

    <!-- Bootstrap 5 CSS & Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">

    <!-- Font Awesome (dành cho icon Trái tim Like / Unlike) -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        body {
            background-color: #f0f2f5;
        }
        .aloute-navbar {
            background-color: #ffffff;
            box-shadow: 0 2px 4px rgba(0,0,0,.08);
        }
        .sidebar-link {
            display: flex;
            align-items: center;
            padding: 10px 14px;
            color: #333;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 500;
            margin-bottom: 4px;
            transition: background-color 0.15s ease;
        }
        .sidebar-link:hover, .sidebar-link.active {
            background-color: #e4e6eb;
            color: #0d6efd;
        }
        .sidebar-link i {
            font-size: 1.25rem;
            margin-right: 12px;
            width: 24px;
            text-align: center;
            display: inline-block;
        }
        /* Icon cờ lưu gradient hồng tím chuẩn Facebook */
        .icon-saved-gradient {
            background: linear-gradient(135deg, #e0245e, #8a3ab9);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
    </style>

    <sitemesh:write property='head' />
</head>
<body>

    <!-- 1. Header Navbar duy nhất -->
    <nav class="navbar navbar-expand-lg aloute-navbar sticky-top py-2">
        <div class="container-fluid px-4">
            <a class="navbar-brand fw-bold text-primary fs-3" href="<c:url value='/post/feed'/>">
                <i class="bi bi-chat-square-heart-fill me-1"></i>ALOUTE
            </a>

            <!-- Thanh tìm kiếm nhanh -->
            <form class="d-flex ms-3 d-none d-md-block" role="search" action="<c:url value='/search'/>" method="get" style="width: 320px;">
                <div class="input-group">
                    <span class="input-group-text bg-light border-end-0"><i class="bi bi-search"></i></span>
                    <input class="form-control bg-light border-start-0" type="search" name="q" required
                           value="${param.q}" placeholder="Tìm kiếm trên ALOUTE..." aria-label="Search">
                </div>
            </form>

            <!-- Menu bên phải: Thông báo, Avatar / Tên User hoặc Nút Đăng nhập -->
            <div class="d-flex align-items-center ms-auto gap-3">
                <c:choose>
                    <c:when test="${not empty sessionScope.currentUser}">
                        <!-- Chuông thông báo -->
                        <div class="dropdown">
                            <button type="button" id="bellBtn" class="btn btn-light rounded-circle p-2 position-relative"
                                    title="Thông báo" data-bs-toggle="dropdown" data-bs-auto-close="outside" aria-expanded="false">
                                <i class="bi bi-bell-fill fs-5"></i>
                                <span id="bellBadge" class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger d-none">0</span>
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end shadow border-0 p-0" style="width:340px; max-height:420px; overflow-y:auto;">
                                <li class="px-3 py-2 border-bottom d-flex justify-content-between align-items-center">
                                    <strong>Thông báo</strong>
                                    <a href="<c:url value='/notifications'/>" class="small">Xem tất cả</a>
                                </li>
                                <li id="notiList"><div class="px-3 py-3 text-muted small">Đang tải...</div></li>
                            </ul>
                        </div>

                        <!-- Dropdown cá nhân -->
                        <div class="dropdown">
                            <button class="btn btn-light d-flex align-items-center gap-2 rounded-pill px-3 py-1" data-bs-toggle="dropdown" aria-expanded="false">
                                <img src="${not empty sessionScope.currentUser.avatar ? sessionScope.currentUser.avatar : 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg'}" 
                                     alt="Avatar" class="rounded-circle" width="32" height="32" style="object-fit: cover;"> 
                                <span class="fw-semibold d-none d-sm-inline">
                                    ${not empty sessionScope.currentUser.fullName ? sessionScope.currentUser.fullName : sessionScope.currentUser.username}
                                </span>
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0">
                                <li>
                                    <a class="dropdown-item" href="<c:url value='/profile'/>">
                                        <i class="bi bi-person me-2"></i>Trang cá nhân
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item" href="<c:url value='/post/saved'/>">
                                        <i class="bi bi-bookmark-fill me-2 icon-saved-gradient"></i>Mục đã lưu
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item" href="<c:url value='/settings'/>">
                                        <i class="bi bi-gear me-2"></i>Cài đặt
                                    </a>
                                </li>
                                <li><hr class="dropdown-divider"></li>
                                <li>
                                    <a class="dropdown-item text-danger" href="<c:url value='/logout'/>">
                                        <i class="bi bi-box-arrow-right me-2"></i>Đăng xuất
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <a href="<c:url value='/login'/>" class="btn btn-outline-primary btn-sm px-3">Đăng nhập</a>
                        <a href="<c:url value='/register'/>" class="btn btn-primary btn-sm px-3">Đăng ký</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </nav>

    <!-- 2. Thân trang (Sidebar + Vùng nội dung động) -->
    <div class="container-fluid px-4 mt-3">
        <div class="row">
            <!-- Sidebar bên trái -->
            <aside class="col-md-3 col-lg-2 d-none d-md-block">
                <div class="sticky-top" style="top: 80px;">
                    <a href="<c:url value='/post/feed'/>" class="sidebar-link active">
                        <i class="bi bi-house-door-fill text-primary"></i> Bảng tin
                    </a>
                    <a href="<c:url value='/friends'/>" class="sidebar-link">
                        <i class="bi bi-people-fill text-success"></i> Bạn bè
                    </a>
                    <a href="<c:url value='/profile'/>" class="sidebar-link">
                        <i class="bi bi-person-circle text-info"></i> Trang cá nhân
                    </a>
                    <a href="<c:url value='/post/saved'/>" class="sidebar-link">
                        <i class="bi bi-bookmark-fill icon-saved-gradient"></i> Đã lưu
                    </a>
                    <a href="<c:url value='/settings'/>" class="sidebar-link">
                        <i class="bi bi-gear text-secondary"></i> Cài đặt
                    </a>
                    <a href="<c:url value='/notifications'/>" class="sidebar-link">
                        <i class="bi bi-bell text-warning"></i> Thông báo
                    </a>
                    <c:set var="isAdminUser" value="false"/>
                    <c:forEach var="r" items="${sessionScope.currentUser.roles}">
                        <c:if test="${r.name == 'ROLE_ADMIN'}"><c:set var="isAdminUser" value="true"/></c:if>
                    </c:forEach>
                    <c:if test="${isAdminUser}">
                        <a href="<c:url value='/admin'/>" class="sidebar-link">
                            <i class="bi bi-shield-lock-fill text-danger"></i> Quản trị (Admin)
                        </a>
                    </c:if>
                </div>
            </aside>

            <!-- Khu vực nội dung do các trang con (feed, profile,...) quyết định -->
            <main class="col-md-9 col-lg-10">
                <sitemesh:write property='body' />
            </main>
        </div>
    </div>

    <!-- Bootstrap 5 Bundle JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Script tương tác AJAX (Like & Comment) của bạn -->
    <script src="<c:url value='/js/interaction.js' />"></script>

    <c:if test="${not empty sessionScope.currentUser}">
    <script>
    (function () {
        var BASE = '<c:url value="/"/>';
        var badge = document.getElementById('bellBadge');
        var list = document.getElementById('notiList');
        if (!badge || !list) return;

        function esc(s) { var d = document.createElement('div'); d.textContent = s == null ? '' : s; return d.innerHTML; }

        function loadNoti() {
            fetch(BASE + 'api/notifications', { headers: { 'Accept': 'application/json' } })
                .then(function (r) { return r.ok ? r.json() : null; })
                .then(function (data) {
                    if (!data) return;
                    if (data.unread > 0) {
                        badge.textContent = data.unread > 99 ? '99+' : data.unread;
                        badge.classList.remove('d-none');
                    } else {
                        badge.classList.add('d-none');
                    }
                    if (!data.items.length) {
                        list.innerHTML = '<div class="px-3 py-3 text-muted small">Chưa có thông báo nào</div>';
                        return;
                    }
                    list.innerHTML = data.items.map(function (n) {
                        return '<a class="dropdown-item py-2 border-bottom ' + (n.read ? '' : 'bg-primary-subtle fw-semibold') + '" ' +
                               'style="white-space:normal" href="' + BASE + 'notifications/' + n.id + '/open">' +
                               esc(n.content) + '<br><small class="text-muted">' +
                               esc(String(n.createdAt).replace('T', ' ').substring(0, 16)) + '</small></a>';
                    }).join('');
                })
                .catch(function () { /* bỏ qua lỗi mạng/phiên hết hạn */ });
        }

        loadNoti();
        setInterval(loadNoti, 30000);
    })();
    </script>
    </c:if>

    <!-- Script chống Back-Forward Cache (bfcache) -->
    <script>
        window.addEventListener("pageshow", function(event) {
            if (event.persisted || (window.performance && window.performance.getEntriesByType("navigation")[0]?.type === "back_forward")) {
                window.location.reload();
            }
        });
    </script>
</body>
</html>