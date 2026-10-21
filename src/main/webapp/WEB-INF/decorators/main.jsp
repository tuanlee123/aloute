<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><sitemesh:write property='title' /> | ALOUTE</title>

<!-- Bootstrap 5 CSS & Bootstrap Icons -->
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet">
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
	rel="stylesheet">

<!-- Font Awesome -->
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

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

.messenger-item {
	transition: background-color 0.15s;
	cursor: pointer;
	border-radius: 8px;
}

.messenger-item:hover {
	background-color: #f2f2f2;
}
</style>

<sitemesh:write property='head' />
</head>
<body>

	<!-- 1. Header Navbar -->
	<nav class="navbar navbar-expand-lg aloute-navbar sticky-top py-2">
		<div class="container-fluid px-4">
			<a class="navbar-brand fw-bold text-primary fs-3"
				href="<c:url value='/post/feed'/>"> <i
				class="bi bi-chat-square-heart-fill me-1"></i>ALOUTE
			</a>

			<!-- Form tìm kiếm nhanh -->
			<form class="d-flex ms-3 d-none d-md-block" role="search"
				style="width: 340px;" action="<c:url value='/search'/>" method="get">
				<div class="input-group">
					<span class="input-group-text bg-light border-end-0"><i
						class="bi bi-search"></i></span> <input
						class="form-control bg-light border-start-0" type="search"
						name="q" placeholder="Tìm kiếm người dùng, bài viết..."
						aria-label="Search"
						value="${not empty param.q ? param.q : keyword}" required
						autocomplete="off">
				</div>
			</form>

			<!-- Menu bên phải: Messenger, Thông báo, Tài khoản cá nhân -->
			<div class="d-flex align-items-center ms-auto gap-2">
				<c:choose>
					<c:when test="${not empty sessionScope.currentUser}">

						<!-- 1. ICON UTEBOX LOGO MỚI CHUẨN FACEBOOK -->
						<div class="dropdown">
							<button type="button" id="messengerBtn"
								class="btn btn-light rounded-circle p-1 position-relative d-flex align-items-center justify-content-center border-0 shadow-sm"
								style="width: 40px; height: 40px; background-color: #f0f2f5;"
								title="Utebox Chat" data-bs-toggle="dropdown"
								aria-expanded="false" onclick="loadConversationsList()">

								<!-- Logo UB của bạn -->
								<img src="<c:url value='/images/utebox-logo.png'/>" alt="UB"
									class="rounded-circle" width="30" height="30"
									style="object-fit: cover;">

								<!-- Badge thông báo tin nhắn chưa đọc -->
								<span id="messengerBadge"
									class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger d-none"
									style="font-size: 0.7rem; border: 2px solid #fff;"> 0 </span>
							</button>
							<div
								class="dropdown-menu dropdown-menu-end shadow border-0 p-0 rounded-4"
								style="width: 360px; max-height: 480px; overflow-y: auto;">
								<div
									class="p-3 border-bottom d-flex justify-content-between align-items-center">
									<div class="d-flex align-items-center gap-2">
										<img src="<c:url value='/images/utebox-logo.png'/>" alt="UB"
											class="rounded-circle" width="26" height="26">
										<h6 class="fw-bold mb-0 text-dark">Utebox</h6>
									</div>
									<span
										class="badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill px-2">Đoạn
										chat</span>
								</div>
								<div id="conversationList" class="p-2">
									<div class="text-center py-4 text-muted small">Đang tải
										đoạn chat...</div>
								</div>
							</div>
						</div>

						<!-- 2. DROPDOWN THÔNG BÁO -->
						<div class="dropdown">
							<button type="button"
								class="btn btn-light rounded-circle p-2 position-relative d-flex align-items-center justify-content-center"
								style="width: 40px; height: 40px;" id="notificationBellBtn"
								data-bs-toggle="dropdown" aria-expanded="false"
								title="Thông báo">
								<i class="bi bi-bell-fill fs-5"></i> <span id="notifBadge"
									class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger d-none">
									0 </span>
							</button>
							<div
								class="dropdown-menu dropdown-menu-end shadow border-0 rounded-4 py-2"
								style="width: 360px; max-height: 480px; overflow-y: auto;"
								id="notifDropdownMenu">
								<div
									class="d-flex justify-content-between align-items-center px-3 py-2 border-bottom">
									<h6 class="fw-bold mb-0 text-dark">Thông báo</h6>
									<a href="<c:url value='/notifications'/>"
										class="text-primary text-decoration-none small fw-semibold">Xem
										tất cả</a>
								</div>
								<div id="notifListContainer" class="p-2">
									<div class="text-center py-3 text-muted small">Đang tải
										thông báo...</div>
								</div>
							</div>
						</div>

						<!-- 3. Dropdown tài khoản cá nhân -->
						<div class="dropdown">
							<button
								class="btn btn-light d-flex align-items-center gap-2 rounded-pill px-3 py-1"
								data-bs-toggle="dropdown" aria-expanded="false">
								<img
									src="${not empty sessionScope.currentUser.avatar ? sessionScope.currentUser.avatar : 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg'}"
									alt="Avatar" class="rounded-circle" width="32" height="32"
									style="object-fit: cover;"> <span
									class="fw-semibold d-none d-sm-inline"> ${not empty sessionScope.currentUser.fullName ? sessionScope.currentUser.fullName : sessionScope.currentUser.username}
								</span>
							</button>
							<ul class="dropdown-menu dropdown-menu-end shadow-sm border-0">
								<li><a class="dropdown-item"
									href="<c:url value='/profile'/>"> <i
										class="bi bi-person me-2"></i>Trang cá nhân
								</a></li>
								<li><a class="dropdown-item"
									href="<c:url value='/post/saved'/>"> <i
										class="bi bi-bookmark-fill me-2 icon-saved-gradient"></i>Mục
										đã lưu
								</a></li>
								<li><a class="dropdown-item"
									href="<c:url value='/settings'/>"> <i
										class="bi bi-gear me-2"></i>Cài đặt
								</a></li>
								<li><hr class="dropdown-divider"></li>
								<li><a class="dropdown-item text-danger"
									href="<c:url value='/logout'/>"> <i
										class="bi bi-box-arrow-right me-2"></i>Đăng xuất
								</a></li>
							</ul>
						</div>
					</c:when>
					<c:otherwise>
						<a href="<c:url value='/login'/>"
							class="btn btn-outline-primary btn-sm px-3">Đăng nhập</a>
						<a href="<c:url value='/register'/>"
							class="btn btn-primary btn-sm px-3">Đăng ký</a>
					</c:otherwise>
				</c:choose>
			</div>
		</div>
	</nav>

	<!-- 2. Thân trang -->
	<div class="container-fluid px-4 mt-3">
		<div class="row">
			<!-- Sidebar bên trái -->
			<aside class="col-md-3 col-lg-2 d-none d-md-block">
				<div class="sticky-top" style="top: 80px;">
					<a href="<c:url value='/post/feed'/>" class="sidebar-link"> <i
						class="bi bi-house-door-fill text-primary"></i> Bảng tin
					</a> <a href="<c:url value='/friends'/>" class="sidebar-link"> <i
						class="bi bi-people-fill text-success"></i> Bạn bè
					</a> <a href="<c:url value='/profile'/>" class="sidebar-link"> <i
						class="bi bi-person-circle text-info"></i> Trang cá nhân
					</a> <a href="<c:url value='/post/saved'/>" class="sidebar-link"> <i
						class="bi bi-bookmark-fill icon-saved-gradient"></i> Đã lưu
					</a> <a href="<c:url value='/settings'/>" class="sidebar-link"> <i
						class="bi bi-gear text-secondary"></i> Cài đặt
					</a> <a href="<c:url value='/notifications'/>" class="sidebar-link">
						<i class="bi bi-bell text-warning"></i> Thông báo
					</a>
					<c:set var="isAdminUser" value="false" />
					<c:forEach var="r" items="${sessionScope.currentUser.roles}">
						<c:if test="${r.name == 'ROLE_ADMIN'}">
							<c:set var="isAdminUser" value="true" />
						</c:if>
					</c:forEach>
					<c:if test="${isAdminUser}">
						<a href="<c:url value='/admin'/>" class="sidebar-link"> <i
							class="bi bi-shield-lock-fill text-danger"></i> Quản trị (Admin)
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

	<!-- KHUNG CHAT UTEBOX (REAL-TIME SSE) -->
	<c:if test="${not empty sessionScope.currentUser}">
		<div id="uteboxContainer"
			style="position: fixed; bottom: 20px; right: 25px; z-index: 10500;">
			<div id="uteboxCard" class="card shadow-lg border-0 rounded-4 d-none"
				style="width: 340px; height: 460px; position: absolute; bottom: 0; right: 0; overflow: hidden; display: flex; flex-direction: column;">

				<!-- Header khung chat -->
				<div
					class="card-header bg-primary text-white py-2 px-3 d-flex justify-content-between align-items-center">
					<div class="d-flex align-items-center gap-2">
						<img id="uteboxAvatar"
							src="https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg"
							class="rounded-circle border border-white" width="34" height="34"
							style="object-fit: cover;">
						<div>
							<h6 class="mb-0 fw-bold" id="uteboxPartnerName"
								style="font-size: 0.92rem;">Utebox Chat</h6>
							<small id="uteboxStatus"
								style="font-size: 0.72rem; color: #a3e635;"><i
								class="bi bi-circle-fill me-1" style="font-size: 0.5rem;"></i>Đang
								trực tuyến</small>
						</div>
					</div>
					<button type="button"
						class="btn btn-link text-white p-0 text-decoration-none"
						onclick="closeUtebox()">
						<i class="bi bi-x-lg fs-6"></i>
					</button>
				</div>

				<!-- Khung nội dung tin nhắn -->
				<div class="card-body p-3 overflow-y-auto flex-grow-1"
					id="uteboxBody"
					style="background-color: #f0f2f5; font-size: 0.88rem;">
					<div class="text-center text-muted small py-4">Đang kết nối
						bảo mật...</div>
				</div>

				<!-- Khung nhập văn bản gửi tin nhắn -->
				<div class="card-footer bg-white border-top p-2">
					<form id="uteboxForm" onsubmit="submitUtebox(event)"
						class="d-flex gap-2 m-0">
						<input type="text" id="uteboxInput"
							class="form-control form-control-sm rounded-pill px-3"
							placeholder="Nhập tin nhắn..." maxlength="1000" required
							autocomplete="off">
						<button type="submit" id="btnUteboxSend"
							class="btn btn-primary btn-sm rounded-circle d-flex align-items-center justify-content-center"
							style="width: 32px; height: 32px; flex-shrink: 0;">
							<i class="bi bi-send-fill" style="font-size: 0.8rem;"></i>
						</button>
					</form>
				</div>
			</div>
		</div>
	</c:if>

	<!-- Bootstrap 5 Bundle JS -->
	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

	<!-- Script tương tác AJAX (Like & Comment) -->
	<script src="<c:url value='/js/interaction.js' />"></script>

	<!-- Script quản lý Thông báo -->
	<script>
		function fetchNotifications() {
			fetch('<c:url value="/api/notifications" />')
				.then(res => res.json())
				.then(data => {
					const badge = document.getElementById('notifBadge');
					const container = document.getElementById('notifListContainer');
					if (!badge || !container) return;

					const count = data.unreadCount != null ? data.unreadCount : (data.unread != null ? data.unread : 0);
					if (count > 0) {
						badge.innerText = count > 99 ? '99+' : count;
						badge.classList.remove('d-none');
					} else {
						badge.classList.add('d-none');
					}

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

		document.getElementById('notificationBellBtn')?.addEventListener('click', function() {
			const badge = document.getElementById('notifBadge');
			if (badge && !badge.classList.contains('d-none')) {
				badge.classList.add('d-none');
				fetch('<c:url value="/api/notifications/mark-read" />', { method: 'POST' });
			}
		});

		document.addEventListener('DOMContentLoaded', function() {
			fetchNotifications();
			setInterval(fetchNotifications, 15000);
		});

		window.addEventListener("pageshow", function(event) {
			if (event.persisted || (window.performance && window.performance.getEntriesByType("navigation")[0]?.type === "back_forward")) {
				window.location.reload();
			}
		});
	</script>

	<!-- Script xử lý Utebox Chat Real-time & Dropdown Messenger -->
	<c:if test="${not empty sessionScope.currentUser}">
		<script>
		const MY_USER_ID = ${sessionScope.currentUser.id};
		let activeUteboxPartnerId = null;
		let sseSource = null;
		let unreadChatCount = 0;

		// 1. Kết nối Real-time SSE
		function initUteboxSSE() {
			if (sseSource) sseSource.close();
			sseSource = new EventSource('${pageContext.request.contextPath}/api/utebox/subscribe');

			sseSource.addEventListener('chat-message', function(event) {
				const msg = JSON.parse(event.data);
				
				if (activeUteboxPartnerId && String(msg.senderId) === String(activeUteboxPartnerId)) {
					appendUteboxMessage(msg, false);
				} else {
					unreadChatCount++;
					const badge = document.getElementById('messengerBadge');
					if (badge) {
						badge.textContent = unreadChatCount > 9 ? '9+' : unreadChatCount;
						badge.classList.remove('d-none');
					}
					openChatWith(msg.senderId, msg.senderName, msg.senderAvatar);
				}
			});

			sseSource.onerror = function() {
				const statusEl = document.getElementById('uteboxStatus');
				if (statusEl) statusEl.innerHTML = '<span class="text-warning">Đang kết nối lại...</span>';
				sseSource.close();
				setTimeout(initUteboxSSE, 4000);
			};
		}

		// 2. Mở khung chat
		function openChatWith(partnerId, partnerName, partnerAvatar) {
			if (!partnerId || String(partnerId) === String(MY_USER_ID)) return;

			activeUteboxPartnerId = partnerId;
			document.getElementById('uteboxPartnerName').textContent = partnerName || 'Trò chuyện';
			if (partnerAvatar) document.getElementById('uteboxAvatar').src = partnerAvatar;

			const card = document.getElementById('uteboxCard');
			card.classList.remove('d-none');

			const badge = document.getElementById('messengerBadge');
			if (badge && unreadChatCount > 0) {
				unreadChatCount = 0;
				badge.classList.add('d-none');
			}

			const body = document.getElementById('uteboxBody');
			body.innerHTML = '<div class="text-center text-muted small py-4">Đang tải tin nhắn...</div>';

			fetch('${pageContext.request.contextPath}/api/utebox/messages?partnerId=' + partnerId)
				.then(res => {
					if (!res.ok) throw new Error("Không thể tải tin nhắn");
					return res.json();
				})
				.then(data => {
					body.innerHTML = '';
					if (!data.messages || !data.messages.length) {
						body.innerHTML = '<div class="text-center text-muted small py-4">Hãy gửi lời chào đầu tiên! 👋</div>';
					} else {
						data.messages.forEach(msg => {
							appendUteboxMessage(msg, String(msg.senderId) === String(MY_USER_ID));
						});
					}
				})
				.catch(err => {
					body.innerHTML = '<div class="text-center text-danger small py-4">' + err.message + '</div>';
				});
		}

		function closeUtebox() {
			document.getElementById('uteboxCard').classList.add('d-none');
			activeUteboxPartnerId = null;
		}

		// 3. Render tin nhắn an toàn tiếng Việt bằng textContent
		// 3. Render tin nhắn an toàn tiếng Việt & tự động nhận diện link bài viết
        function appendUteboxMessage(msg, isMe) {
            const body = document.getElementById('uteboxBody');
            const emptyAlert = body.querySelector('.text-center');
            if (emptyAlert) emptyAlert.remove();

            const row = document.createElement('div');
            row.className = 'd-flex mb-2 ' + (isMe ? 'justify-content-end' : 'justify-content-start');

            const bubble = document.createElement('div');
            bubble.className = 'px-3 py-2 rounded-4 shadow-sm';
            bubble.style.maxWidth = '82%';
            bubble.style.wordBreak = 'break-word';
            bubble.style.fontSize = '0.85rem';
            bubble.style.backgroundColor = isMe ? '#0d6efd' : '#ffffff';
            bubble.style.color = isMe ? '#ffffff' : '#212529';

            const contentDiv = document.createElement('div');

            // Tự động nhận diện đường link bài viết ALOUTE hoặc link web
            const urlRegex = /(https?:\/\/[^\s]+)/g;
            if (urlRegex.test(msg.content)) {
                const parts = msg.content.split(urlRegex);
                parts.forEach(part => {
                    if (part.match(urlRegex)) {
                        const a = document.createElement('a');
                        a.href = part;
                        a.target = '_blank';
                        a.textContent = ' 🔗 Xem bài viết được chia sẻ';
                        a.style.color = isMe ? '#ffe484' : '#0d6efd';
                        a.style.fontWeight = 'bold';
                        a.style.textDecoration = 'underline';
                        contentDiv.appendChild(a);
                    } else if (part) {
                        contentDiv.appendChild(document.createTextNode(part));
                    }
                });
            } else {
                contentDiv.textContent = msg.content;
            }

            const timeSmall = document.createElement('small');
            timeSmall.className = 'd-block text-end mt-1';
            timeSmall.style.fontSize = '0.65rem';
            timeSmall.style.opacity = '0.75';
            timeSmall.textContent = msg.createdAt;

            bubble.appendChild(contentDiv);
            bubble.appendChild(timeSmall);
            row.appendChild(bubble);

            body.appendChild(row);
            body.scrollTop = body.scrollHeight;
        }

		// 4. Gửi tin nhắn qua POST
		function submitUtebox(e) {
			e.preventDefault();
			const input = document.getElementById('uteboxInput');
			const btnSend = document.getElementById('btnUteboxSend');
			const content = input.value.trim();

			if (!content || !activeUteboxPartnerId) return;

			btnSend.disabled = true;

			const params = new URLSearchParams();
			params.append('partnerId', activeUteboxPartnerId);
			params.append('content', content);

			input.value = '';

			fetch('${pageContext.request.contextPath}/api/utebox/send', {
				method: 'POST',
				headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
				body: params
			})
			.then(async res => {
				const data = await res.json();
				if (!res.ok) throw new Error(data.message || "Gửi tin nhắn thất bại");
				return data;
			})
			.then(savedMsg => {
				appendUteboxMessage(savedMsg, true);
			})
			.catch(err => {
				alert(err.message);
			})
			.finally(() => {
				btnSend.disabled = false;
				input.focus();
			});
		}

		// 5. Tải danh sách hội thoại vào Dropdown Messenger
		function loadConversationsList() {
			const listEl = document.getElementById('conversationList');
			fetch('${pageContext.request.contextPath}/api/utebox/conversations')
				.then(r => r.json())
				.then(items => {
					if (!items.length) {
						listEl.innerHTML = '<div class="text-center py-4 text-muted small">Chưa có cuộc trò chuyện nào</div>';
						return;
					}
					listEl.innerHTML = items.map(c => `
						<div class="messenger-item p-2 d-flex align-items-center gap-2" onclick="openChatWith(\${c.partnerId}, '\${c.partnerName.replace(/'/g, "\\\\'")}', '\${c.partnerAvatar}')">
							<img src="\${c.partnerAvatar}" class="rounded-circle border" width="46" height="46" style="object-fit:cover;">
							<div class="flex-grow-1 overflow-hidden">
								<div class="fw-semibold text-dark text-truncate" style="font-size: 0.9rem;">\${c.partnerName}</div>
								<div class="text-muted small text-truncate" style="font-size: 0.8rem;">\${c.lastMessage || 'Bắt đầu cuộc trò chuyện'}</div>
							</div>
							<small class="text-muted" style="font-size: 0.7rem; white-space: nowrap;">\${c.updatedAt ? c.updatedAt.substring(0, 5) : ''}</small>
						</div>
					`).join('');
				})
				.catch(() => {
					listEl.innerHTML = '<div class="text-center py-4 text-danger small">Không thể tải đoạn chat</div>';
				});
		}

		document.addEventListener("DOMContentLoaded", initUteboxSSE);
	</script>
	</c:if>

</body>
</html>