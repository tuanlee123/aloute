<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><sitemesh:write property='title' /> - ALOUTE</title>

<!-- Bootstrap 5 CSS & Bootstrap Icons -->
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet">
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
	rel="stylesheet">

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
}

.sidebar-link:hover, .sidebar-link.active {
	background-color: #e4e6eb;
	color: #0d6efd;
}

.sidebar-link i {
	font-size: 1.25rem;
	margin-right: 12px;
}
</style>

<sitemesh:write property='head' />
</head>
<body>

	<!-- 1. Header Navbar -->
	<nav class="navbar navbar-expand-lg aloute-navbar sticky-top py-2">
		<div class="container-fluid px-4">
			<a class="navbar-brand fw-bold text-primary fs-3"
				href="<c:url value='/'/>"> <i
				class="bi bi-chat-square-heart-fill me-1"></i>ALOUTE
			</a>

			<!-- Thanh tìm kiếm nhanh -->
			<form class="d-flex ms-3 d-none d-md-block" role="search"
				style="width: 320px;">
				<div class="input-group">
					<span class="input-group-text bg-light border-end-0"><i
						class="bi bi-search"></i></span> <input
						class="form-control bg-light border-start-0" type="search"
						placeholder="Tìm kiếm trên ALOUTE..." aria-label="Search">
				</div>
			</form>

			<!-- Menu bên phải: Thông báo, User Profile hoặc Nút Đăng nhập -->
			<div class="d-flex align-items-center ms-auto gap-3">
				<c:choose>
					<c:when test="${not empty sessionScope.currentUser}">
						<!-- Nút thông báo -->
						<button type="button"
							class="btn btn-light rounded-circle p-2 position-relative"
							title="Thông báo">
							<i class="bi bi-bell-fill fs-5"></i> <span
								class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
								0 </span>
						</button>

						<!-- Menu dropdown cá nhân -->
						<div class="dropdown">
							<button
								class="btn btn-light d-flex align-items-center gap-2 rounded-pill px-3 py-1"
								data-bs-toggle="dropdown" aria-expanded="false">
								<img src="${not empty sessionScope.currentUser.avatar ? sessionScope.currentUser.avatar : 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg'}" 
									alt="Avatar"
									class="rounded-circle" width="32" height="32"
									style="object-fit: cover;"> 
								<span class="fw-semibold d-none d-sm-inline">
									${not empty sessionScope.currentUser.fullName ? sessionScope.currentUser.fullName : sessionScope.currentUser.username}
								</span>
							</button>
							<ul class="dropdown-menu dropdown-menu-end shadow-sm border-0">
								<li><a class="dropdown-item"
									href="<c:url value='/profile'/>"><i
										class="bi bi-person me-2"></i>Trang cá nhân</a></li>
								<li><a class="dropdown-item"
									href="<c:url value='/settings'/>"><i
										class="bi bi-gear me-2"></i>Cài đặt</a></li>
								<li><hr class="dropdown-divider"></li>
								<li><a class="dropdown-item text-danger"
									href="<c:url value='/logout'/>"><i
										class="bi bi-box-arrow-right me-2"></i>Đăng xuất</a></li>
							</ul>
						</div>
					</c:when>
					<c:otherwise>
						<!-- Nếu chưa đăng nhập thì hiện 2 nút -->
						<a href="<c:url value='/login'/>"
							class="btn btn-outline-primary btn-sm px-3">Đăng nhập</a>
						<a href="<c:url value='/register'/>"
							class="btn btn-primary btn-sm px-3">Đăng ký</a>
					</c:otherwise>
				</c:choose>
			</div>
		</div>
	</nav>

	<!-- 2. Thân trang (Sidebar + Main Content) -->
	<div class="container-fluid px-4 mt-3">
		<div class="row">
			<!-- Sidebar bên trái -->
			<aside class="col-md-3 col-lg-2 d-none d-md-block">
				<div class="sticky-top" style="top: 80px;">
					<a href="<c:url value='/'/>" class="sidebar-link active"> <i
						class="bi bi-house-door-fill text-primary"></i> Bảng tin
					</a> <a href="<c:url value='/friends'/>" class="sidebar-link"> <i
						class="bi bi-people-fill text-success"></i> Bạn bè
					</a> <a href="<c:url value='/profile'/>" class="sidebar-link"> <i
						class="bi bi-person-circle text-info"></i> Trang cá nhân
					</a> <a href="<c:url value='/notifications'/>" class="sidebar-link">
						<i class="bi bi-bell text-warning"></i> Thông báo
					</a> <a href="<c:url value='/admin'/>" class="sidebar-link"> <i
						class="bi bi-shield-lock-fill text-danger"></i> Quản trị (Admin)
					</a>
				</div>
			</aside>

			<!-- Khu vực nội dung động do trang JSP con quyết định -->
			<main class="col-md-9 col-lg-10">
				<sitemesh:write property='body' />
			</main>
		</div>
	</div>

	<!-- Bootstrap 5 Bundle JS -->
	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

	<!-- Script chống Back-Forward Cache (bfcache) ngăn treo phiên sau khi đăng xuất -->
	<script>
		window.addEventListener("pageshow", function(event) {
			if (event.persisted || (window.performance && window.performance.getEntriesByType("navigation")[0]?.type === "back_forward")) {
				window.location.reload();
			}
		});
	</script>
</body>
</html>