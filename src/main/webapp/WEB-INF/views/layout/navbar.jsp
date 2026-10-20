<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<nav class="navbar navbar-expand-lg navbar-white bg-white border-bottom sticky-top py-2 shadow-sm">
    <div class="container">
        <!-- Logo -->
        <a class="navbar-brand fw-bold text-primary fs-4" href="<c:url value='/'/>">
            <i class="bi bi-chat-square-heart-fill me-2"></i>ALOUTE
        </a>

        <!-- Nút toggle trên thiết bị di động -->
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#alouteNavbar">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="alouteNavbar">
            <!-- Thanh tìm kiếm nhanh ở giữa -->
            <ul class="navbar-nav me-auto mb-2 mb-lg-0 ms-lg-3">
                <li class="nav-item">
                    <a class="nav-link fw-semibold active" href="<c:url value='/'/>">
                        <i class="bi bi-house-door-fill me-1"></i>Trang chủ
                    </a>
                </li>
            </ul>

            <!-- Khu vực trạng thái người dùng (Bên phải) -->
            <div class="d-flex align-items-center gap-3">
                <c:choose>
                    <%-- KHI ĐÃ ĐĂNG NHẬP --%>
                    <c:when test="${not empty sessionScope.currentUser}">
                        <div class="dropdown">
                            <a href="#" class="d-flex align-items-center text-dark text-decoration-none dropdown-toggle" id="userDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                                <!-- Avatar tròn -->
                                <img src="${not empty sessionScope.currentUser.avatar ? sessionScope.currentUser.avatar : 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg'}" 
                                     alt="Avatar" 
                                     width="36" 
                                     height="36" 
                                     class="rounded-circle object-fit-cover me-2 border">
                                <!-- Tên hiển thị -->
                                <span class="fw-semibold small">
                                    ${not empty sessionScope.currentUser.fullName ? sessionScope.currentUser.fullName : sessionScope.currentUser.username}
                                </span>
                            </a>
                            
                            <!-- Menu thả xuống -->
                            <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0 rounded-3 mt-2" aria-labelledby="userDropdown">
                                <li class="px-3 py-2 border-bottom">
                                    <span class="d-block text-muted small">Đang đăng nhập với</span>
                                    <strong class="small text-truncate d-block" style="max-width: 180px;">${sessionScope.currentUser.email}</strong>
                                </li>
                                <li>
                                    <a class="dropdown-item py-2 small" href="<c:url value='/profile'/>">
                                        <i class="bi bi-person-circle me-2 text-primary"></i>Trang cá nhân
                                    </a>
                                </li>
                                <li><hr class="dropdown-divider my-1"></li>
                                <li>
                                    <a class="dropdown-item py-2 small text-danger" href="<c:url value='/logout'/>">
                                        <i class="bi bi-box-arrow-right me-2"></i>Đăng xuất
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </c:when>

                    <%-- KHI CHƯA ĐĂNG NHẬP --%>
                    <c:otherwise>
                        <a href="<c:url value='/login'/>" class="btn btn-outline-primary btn-sm px-3 fw-semibold">
                            Đăng nhập
                        </a>
                        <a href="<c:url value='/register'/>" class="btn btn-primary btn-sm px-3 fw-semibold">
                            Đăng ký
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</nav>

<script>
    // Dự phòng chống cache trực tiếp trên Navbar
    window.addEventListener("pageshow", function(event) {
        if (event.persisted || (window.performance && window.performance.navigation && window.performance.navigation.type === 2)) {
            window.location.reload();
        }
    });
</script>