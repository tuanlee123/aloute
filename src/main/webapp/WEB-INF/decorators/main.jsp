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

<!-- Font Awesome -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<style>
body {
	background-color: #f0f2f5;
}

.aloute-navbar {
	background-color: #ffffff;
	box-shadow: 0 2px 4px rgba(0, 0, 0, .08);
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

.icon-saved-gradient {
	background: linear-gradient(135deg, #e0245e, #8a3ab9);
	-webkit-background-clip: text;
	-webkit-text-fill-color: transparent;
}
</style>

<sitemesh:write property='head' />
</head>
<body>

	<!-- Header Navbar -->
	<nav class="navbar navbar-expand-lg aloute-navbar sticky-top py-2">
		<div class="container-fluid px-4">
			<a class="navbar-brand fw-bold text-primary fs-3" href="<c:url value='/post/feed'/>">
				<i class="bi bi-chat-square-heart-fill me-1"></i>ALOUTE
			</a>

			<!-- Form tìm kiếm tổng hợp: Người dùng & Bài viết -->
			<form class="d-flex ms-3 d-none d-md-block" role="search" style="width: 340px;" action="<c:url value='/search'/>" method="get">
				<div class="input-group">
					<span class="input-group-text bg-light border-end-0"><i class="bi bi-search"></i></span> 
					<input class="form-control bg-light border-start-0" type="search" name="q"
						placeholder="Tìm kiếm người dùng, bài viết..." aria-label="Search"
						value="${not empty param.q ? param.q : keyword}" required autocomplete="off">
				</div>
			</form>

			<!-- Menu bên phải: Thông báo, Tài khoản cá nhân -->
			<div class="d-flex align-items-center ms-auto gap-3">
				<c:choose>
					<c:when test="${not empty sessionScope.currentUser}">
						<!-- DROPDOWN THÔNG BÁO -->
						<div class="dropdown">
							<button type="button" class="btn btn-light rounded-circle p-2 position-relative"
								id="notificationBellBtn" data-bs-toggle="dropdown" aria-expanded="false" title="Thông báo">
								<i class="bi bi-bell-fill fs-5"></i>
								<span id="notifBadge" class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger d-none">
									0
								</span>
							</button>
							<div class="dropdown-menu dropdown-menu-end shadow border-0 rounded-4 py-2"
								style="width: 360px; max-height: 480px; overflow-y: auto;" id="notifDropdownMenu">
								<div class="d-flex justify-content-between align-items-center px-3 py-2 border-bottom">
									<h6 class="fw-bold mb-0 text-dark">Thông báo</h6>
									<a href="<c:url value='/notifications'/>" class="text-primary text-decoration-none small fw-semibold">Xem tất cả</a>
								</div>
								<div id="notifListContainer" class="p-2">
									<div class="text-center py-3 text-muted small">Đang tải thông báo...</div>
								</div>
							</div>
						</div>

						<!-- Dropdown tài khoản cá nhân -->
						<div class="dropdown">
							<button class="btn btn-light d-flex align-items-center gap-2 rounded-pill px-3 py-1"
								data-bs-toggle="dropdown" aria-expanded="false">
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
					<a href="<c:url value='/post/feed'/>" class="sidebar-link">
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
					<c:set var="isAdminUser" value="false" />
					<c:forEach var="r" items="${sessionScope.currentUser.roles}">
						<c:if test="${r.name == 'ROLE_ADMIN'}"><c:set var="isAdminUser" value="true" /></c:if>
					</c:forEach>
					<c:if test="${isAdminUser}">
						<a href="<c:url value='/admin'/>" class="sidebar-link">
							<i class="bi bi-shield-lock-fill text-danger"></i> Quản trị (Admin)
						</a>
					</c:if>
				</div>
			</aside>

			<!-- Khu vực nội dung động SiteMesh -->
			<main class="col-md-9 col-lg-10">
				<sitemesh:write property='body' />
			</main>
		</div>
	</div>

	<!-- Bootstrap 5 Bundle JS -->
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

	<!-- Script tương tác AJAX (Like & Comment) -->
	<script src="<c:url value='/js/interaction.js' />"></script>

	<!-- Quản lý thông báo và số lượng chưa đọc -->
	<script>
		function fetchNotifications() {
			fetch('<c:url value="/api/notifications" />')
				.then(res => res.json())
				.then(data => {
					const badge = document.getElementById('notifBadge');
					const container = document.getElementById('notifListContainer');
					if (!badge || !container) return;

					// 1. Cập nhật số đỏ trên quả chuông
					const count = data.unreadCount != null ? data.unreadCount : (data.unread != null ? data.unread : 0);
					if (count > 0) {
						badge.innerText = count > 99 ? '99+' : count;
						badge.classList.remove('d-none');
					} else {
						badge.classList.add('d-none');
					}

					// 2. Render danh sách thông báo vào Dropdown
					const notifs = data.notifications || data.items || [];
					if (notifs.length === 0) {
						container.innerHTML = '<div class="text-center py-4 text-muted small"><i class="bi bi-bell-slash fs-3 d-block mb-1 opacity-50"></i>Bạn chưa có thông báo nào.</div>';
						return;
					}

					let html = '';
					notifs.slice(0, 8).forEach(n => {
						const isRead = n.isRead != null ? n.isRead : n.read;
						const unreadBg = !isRead ? 'background-color: #e7f3ff;' : '';
						const avatar = n.senderAvatar ? n.senderAvatar : 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg';
						const target = n.targetUrl ? '<c:url value="" />' + n.targetUrl : '<c:url value="/notifications/" />' + n.id + '/open';

						html += `
							<a href="\${target}" class="d-flex align-items-center gap-3 p-2 text-decoration-none rounded-3 mb-1" style="\${unreadBg} transition: background 0.15s;">
								<img src="\${avatar}" class="rounded-circle border" width="46" height="46" style="object-fit: cover;">
								<div class="flex-grow-1 text-truncate">
									<div class="text-dark small \${!isRead ? 'fw-bold' : ''}" style="white-space: normal; line-height: 1.3;">
										\${n.content}
									</div>
								</div>
								\${!isRead ? '<span class="p-1 bg-primary border border-light rounded-circle"></span>' : ''}
							</a>
						`;
					});
					container.innerHTML = html;
				})
				.catch(() => {});
		}

		// Khi click vào quả chuông: ẩn số badge và đánh dấu đã đọc trên server
		document.getElementById('notificationBellBtn')?.addEventListener('click', function() {
			const badge = document.getElementById('notifBadge');
			if (badge && !badge.classList.contains('d-none')) {
				badge.classList.add('d-none');
				fetch('<c:url value="/api/notifications/mark-read" />', { method: 'POST' });
			}
		});

		// Chạy ngay khi tải trang và kiểm tra định kỳ mỗi 15 giây
		document.addEventListener('DOMContentLoaded', function() {
			fetchNotifications();
			setInterval(fetchNotifications, 15000);
		});

		// Chống lưu cache trang (bfcache)
		window.addEventListener("pageshow", function(event) {
			if (event.persisted || (window.performance && window.performance.getEntriesByType("navigation")[0]?.type === "back_forward")) {
				window.location.reload();
			}
		});
	</script>
</body>
</html>