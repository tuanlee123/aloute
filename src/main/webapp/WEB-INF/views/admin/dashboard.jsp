<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>ALOUTE - Hệ Thống Quản Trị Hệ Thống</title>
<!-- Bootstrap 5 & Icons -->
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
	rel="stylesheet">
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<style>
body {
	background-color: #f4f6f9;
	font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
		sans-serif;
}

.admin-navbar {
	background: #ffffff;
	border-bottom: 1px solid #e2e8f0;
}

.card-stat {
	border-radius: 14px;
	border: none;
	box-shadow: 0 2px 10px rgba(0, 0, 0, 0.04);
}
</style>
</head>
<body>

	<!-- 1. Thanh điều hướng tối giản riêng của Admin -->
	<nav
		class="admin-navbar py-2 px-4 d-flex justify-content-between align-items-center sticky-top">
		<div class="d-flex align-items-center gap-2">
			<a href="<c:url value='/post/feed'/>" class="text-decoration-none fs-4 fw-bold text-primary">
				<i class="bi bi-shield-shaded me-1"></i>ALOUTE
			</a> 
			<span class="badge bg-danger-subtle text-danger border border-danger-subtle rounded-pill px-2">Admin Portal</span>
		</div>
		<div class="d-flex align-items-center gap-3">
			<div class="text-end d-none d-sm-block">
				<div class="fw-bold small text-dark">${sessionScope.currentUser.fullName}</div>
				<small class="text-muted">Quản trị viên</small>
			</div>
			<a href="<c:url value='/post/feed'/>" class="btn btn-sm btn-outline-primary rounded-pill px-3">
				<i class="bi bi-house-door me-1"></i>Bảng tin
			</a>
			<a href="<c:url value='/logout'/>"
				class="btn btn-sm btn-outline-danger rounded-pill px-3"> 
				<i class="bi bi-box-arrow-right me-1"></i>Đăng xuất
			</a>
		</div>
	</nav>

	<div class="container-fluid py-4 px-4">
		<!-- 2. Thẻ chỉ số tổng quan cần thiết -->
		<div class="row g-3 mb-4">
			<div class="col-12 col-sm-6 col-xl-3">
				<div class="card card-stat bg-primary text-white p-3 h-100">
					<div class="d-flex justify-content-between align-items-center">
						<div>
							<div class="text-white-50 small fw-bold text-uppercase">Tổng Người dùng</div>
							<h2 class="fw-bold mb-0 mt-1">${totalUsers}</h2>
						</div>
						<i class="bi bi-people-fill fs-1 text-white-50"></i>
					</div>
				</div>
			</div>
			<div class="col-12 col-sm-6 col-xl-3">
				<div class="card card-stat bg-success text-white p-3 h-100">
					<div class="d-flex justify-content-between align-items-center">
						<div>
							<div class="text-white-50 small fw-bold text-uppercase">Đang trực tuyến</div>
							<h2 class="fw-bold mb-0 mt-1" id="stat-active-users">${activeUsers}</h2>
						</div>
						<i class="bi bi-broadcast fs-1 text-white-50"></i>
					</div>
				</div>
			</div>
			<div class="col-12 col-sm-6 col-xl-3">
				<div class="card card-stat bg-warning text-dark p-3 h-100">
					<div class="d-flex justify-content-between align-items-center">
						<div>
							<div class="text-black-50 small fw-bold text-uppercase">Tổng bài đăng</div>
							<h2 class="fw-bold mb-0 mt-1">${totalPosts}</h2>
						</div>
						<i class="bi bi-file-earmark-text-fill fs-1 text-black-50"></i>
					</div>
				</div>
			</div>
			<div class="col-12 col-sm-6 col-xl-3">
				<div class="card card-stat bg-info text-white p-3 h-100">
					<div class="d-flex justify-content-between align-items-center">
						<div>
							<div class="text-white-50 small fw-bold text-uppercase">Bài mới hôm nay</div>
							<h2 class="fw-bold mb-0 mt-1">${postsToday}</h2>
						</div>
						<i class="bi bi-calendar2-plus-fill fs-1 text-white-50"></i>
					</div>
				</div>
			</div>
		</div>

		<!-- 3. Biểu đồ thời gian thực -->
		<div class="card card-stat bg-white mb-4">
			<div
				class="card-header bg-white border-0 pt-3 px-4 d-flex justify-content-between align-items-center">
				<h6 class="fw-bold mb-0 text-dark">
					<i class="bi bi-activity text-danger me-2"></i>Lưu lượng Trực tuyến Thời gian thực (Real-time Live)
				</h6>
				<span
					class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-3 py-1">
					<i class="bi bi-circle-fill me-1 small"></i>Live (3s)
				</span>
			</div>
			<div class="card-body px-4 pb-4">
				<div style="height: 260px; width: 100%;">
					<canvas id="realtimeChart"></canvas>
				</div>
			</div>
		</div>

		<!-- 4. Danh sách tài khoản hệ thống -->
		<div class="card card-stat bg-white">
			<div
				class="card-header bg-white border-0 pt-3 px-4 d-flex justify-content-between align-items-center">
				<h6 class="fw-bold mb-0 text-dark">
					<i class="bi bi-person-lines-fill text-primary me-2"></i>Thông tin Người dùng Hệ thống
				</h6>
				<span class="badge bg-light text-muted border px-2 py-1">${fn:length(usersWithStats)} tài khoản</span>
			</div>
			<div class="card-body p-0">
				<div class="table-responsive">
					<table class="table table-hover align-middle mb-0">
						<thead class="table-light">
							<tr>
								<th class="ps-4">Thành viên</th>
								<th>Email</th>
								<th>Trạng thái</th>
								<th class="text-center">Số bài đăng</th>
								<th class="text-center">Số bạn bè</th>
								<th>Ngày tạo</th>
								<th class="text-end pe-4">Khóa/Mở khóa</th>
							</tr>
						</thead>
						<tbody>
							<c:forEach var="u" items="${usersWithStats}">
								<!-- Kiểm tra User có trong danh sách Online lúc nạp trang -->
								<c:set var="isUserOnlineNow" value="false" />
								<c:forEach var="onId" items="${onlineUserIds}">
									<c:if test="${onId == u.id}">
										<c:set var="isUserOnlineNow" value="true" />
									</c:if>
								</c:forEach>

								<tr>
									<td class="ps-4">
										<div class="d-flex align-items-center gap-2">
											<img
												src="${empty u.avatar ? 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg' : u.avatar}"
												class="rounded-circle border" width="38" height="38"
												style="object-fit: cover;">
											<div>
												<div class="fw-bold text-dark">
													<c:out value="${u.fullName}" />
												</div>
												<small class="text-muted">@<c:out
														value="${u.username}" /></small>
											</div>
										</div>
									</td>
									<td><c:out value="${u.email}" /></td>

									<!-- TRẠNG THÁI: ONLINE / OFFLINE / BỊ KHÓA -->
									<td>
										<c:choose>
											<c:when test="${!u.active}">
												<span class="badge bg-danger-subtle text-danger border border-danger-subtle rounded-pill px-2">
													<i class="bi bi-slash-circle me-1"></i>Bị khóa
												</span>
											</c:when>
											<c:otherwise>
												<span id="status-badge-${u.id}"
													class="badge user-status-badge ${isUserOnlineNow ? 'bg-success-subtle text-success border-success-subtle' : 'bg-secondary-subtle text-secondary border-secondary-subtle'} border rounded-pill px-2">
													<i class="bi ${isUserOnlineNow ? 'bi-circle-fill' : 'bi-moon-fill'} me-1 small"></i>
													${isUserOnlineNow ? 'Trực tuyến' : 'Ngoại tuyến'}
												</span>
											</c:otherwise>
										</c:choose>
									</td>

									<td class="text-center fw-bold text-primary">${u.totalPosts}</td>
									<td class="text-center fw-bold text-success">${u.totalFriends}</td>
									<td class="text-muted small">${fn:replace(fn:substring(u.createdAt, 0, 16), 'T', ' ')}</td>

									<!-- CỘT THAO TÁC -->
									<td class="text-end pe-4">
										<div class="d-inline-flex gap-1 align-items-center">
											<a href="<c:url value='/profile?userId=${u.id}'/>"
												class="btn btn-sm btn-outline-primary rounded-pill px-2"
												title="Xem trang cá nhân của User" target="_blank"> 
												<i class="bi bi-eye"></i> Xem
											</a>

											<form action="<c:url value='/admin/users/${u.id}/toggle-lock'/>"
												method="post" class="d-inline m-0">
												<button type="submit"
													class="btn btn-sm ${u.active ? 'btn-outline-danger' : 'btn-outline-success'} rounded-pill px-2"
													onclick="return confirm('Xác nhận thay đổi trạng thái tài khoản này?');"
													title="${u.active ? 'Khóa tài khoản' : 'Mở khóa'}">
													<i class="bi ${u.active ? 'bi-lock-fill' : 'bi-unlock-fill'}"></i>
													${u.active ? 'Khóa' : 'Mở'}
												</button>
											</form>
										</div>
									</td>
								</tr>
							</c:forEach>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>

	<!-- Script Chart.js & Đồng bộ trạng thái Realtime -->
	<script>
    document.addEventListener("DOMContentLoaded", function () {
        const ctx = document.getElementById('realtimeChart').getContext('2d');
        const maxPoints = 15;

        const realtimeChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: [],
                datasets: [{
                    label: 'Người dùng trực tuyến',
                    data: [],
                    borderColor: '#198754',
                    backgroundColor: 'rgba(25, 135, 84, 0.12)',
                    borderWidth: 2,
                    tension: 0.35,
                    fill: true,
                    pointRadius: 4,
                    pointBackgroundColor: '#198754'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: { stepSize: 1, precision: 0 }
                    },
                    x: { grid: { display: false } }
                },
                plugins: { legend: { display: true } }
            }
        });

        function fetchRealtime() {
            fetch('${pageContext.request.contextPath}/admin/api/stats/realtime')
                .then(res => res.json())
                .then(data => {
                    // 1. Cập nhật biểu đồ đường
                    if (realtimeChart.data.labels.length >= maxPoints) {
                        realtimeChart.data.labels.shift();
                        realtimeChart.data.datasets[0].data.shift();
                    }
                    realtimeChart.data.labels.push(data.timestamp);
                    realtimeChart.data.datasets[0].data.push(data.activeCount);
                    realtimeChart.update();

                    // 2. Cập nhật thẻ số lượng
                    const activeCard = document.getElementById('stat-active-users');
                    if (activeCard && data.activeCount !== undefined) {
                        activeCard.innerText = data.activeCount;
                    }

                    // 3. Đồng bộ đổi màu huy hiệu Trực tuyến / Ngoại tuyến ngay lập tức trong bảng
                    if (data.onlineUserIds) {
                        const onlineSet = new Set(data.onlineUserIds.map(Number));

                        document.querySelectorAll('.user-status-badge').forEach(badge => {
                            const rawId = badge.id.replace('status-badge-', '');
                            const userId = Number(rawId);

                            if (onlineSet.has(userId)) {
                                badge.className = 'badge user-status-badge bg-success-subtle text-success border border-success-subtle rounded-pill px-2';
                                badge.innerHTML = '<i class="bi bi-circle-fill me-1 small"></i>Trực tuyến';
                            } else {
                                badge.className = 'badge user-status-badge bg-secondary-subtle text-secondary border border-secondary-subtle rounded-pill px-2';
                                badge.innerHTML = '<i class="bi bi-moon-fill me-1 small"></i>Ngoại tuyến';
                            }
                        });
                    }
                })
                .catch(e => console.error("Realtime error:", e));
        }

        fetchRealtime();
        setInterval(fetchRealtime, 3000);
    });
    </script>
</body>
</html>