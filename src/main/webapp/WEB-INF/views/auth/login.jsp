<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - ALOUTE</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        .input-group-text {
            cursor: pointer;
            background-color: transparent;
        }
        .caps-warn {
            display: none;
            font-size: 0.8rem;
            color: #dc3545;
        }
    </style>
</head>
<body class="bg-light d-flex align-items-center min-vh-100">
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-5 col-lg-4">
            <div class="card shadow-sm border-0 rounded-4 p-4">
                <div class="text-center mb-4">
                    <h2 class="fw-bold text-primary"><i class="bi bi-chat-square-heart-fill me-2"></i>ALOUTE</h2>
                    <p class="text-muted small">Đăng nhập để kết nối cùng bạn bè</p>
                </div>

                <!-- Thông báo yêu cầu đăng nhập từ AuthInterceptor -->
                <c:if test="${param.requiredAuth == 'true'}">
                    <div class="alert alert-warning py-2 small">
                        <i class="bi bi-info-circle-fill me-2"></i>Vui lòng đăng nhập để truy cập trang này!
                    </div>
                </c:if>

                <!-- Thông báo lỗi khi đăng nhập thất bại -->
                <c:if test="${not empty error}">
                    <div class="alert alert-danger py-2 small">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i>${error}
                    </div>
                </c:if>

                <!-- Thông báo kích hoạt tài khoản thành công qua OTP -->
                <c:if test="${param.activated == 'true'}">
                    <div class="alert alert-success py-2 small">
                        <i class="bi bi-check-circle-fill me-2"></i>Kích hoạt thành công! Hãy đăng nhập.
                    </div>
                </c:if>

                <!-- Thông báo đổi mật khẩu qua OTP thành công -->
                <c:if test="${param.resetSuccess == 'true'}">
                    <div class="alert alert-success py-2 small">
                        <i class="bi bi-check-circle-fill me-2"></i>Đặt lại mật khẩu thành công! Vui lòng đăng nhập với mật khẩu mới.
                    </div>
                </c:if>

                <form id="loginForm" action="<c:url value='/login'/>" method="post">
                    <!-- Tên đăng nhập / Email -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold small">Tên đăng nhập hoặc Email</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-person text-muted"></i></span>
                            <input type="text" name="usernameOrEmail" class="form-control" required placeholder="Nhập username hoặc email" autocomplete="username">
                        </div>
                    </div>
                    
                    <!-- Mật khẩu kèm con mắt -->
                    <div class="mb-2">
                        <label class="form-label fw-semibold small">Mật khẩu</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-lock text-muted"></i></span>
                            <input type="password" id="loginPassword" name="password" class="form-control" required placeholder="Nhập mật khẩu" autocomplete="current-password">
                            <span class="input-group-text" onclick="togglePassword('loginPassword', 'eyeIconLogin')">
                                <i class="bi bi-eye" id="eyeIconLogin"></i>
                            </span>
                        </div>
                        <div id="capsLockWarning" class="caps-warn mt-1">
                            <i class="bi bi-arrow-up-square-fill me-1"></i>Đang bật Caps Lock!
                        </div>
                    </div>

                    <!-- Quên mật khẩu & Ghi nhớ -->
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="rememberMe">
                            <label class="form-check-label small text-muted" for="rememberMe">Ghi nhớ tôi</label>
                        </div>
                        <a href="<c:url value='/forgot-password'/>" class="text-decoration-none small text-primary fw-semibold">Quên mật khẩu?</a>
                    </div>

                    <!-- Nút Đăng nhập có Loading Spinner -->
                    <button type="submit" id="btnLogin" class="btn btn-primary btn-lg w-100 fw-bold fs-6">
                        <span id="btnText">Đăng nhập</span>
                        <span id="btnSpinner" class="spinner-border spinner-border-sm d-none" role="status" aria-hidden="true"></span>
                    </button>
                </form>

                <hr class="my-4 text-muted">
                <div class="text-center small">
                    <span class="text-muted">Chưa có tài khoản? </span>
                    <a href="<c:url value='/register'/>" class="fw-bold text-decoration-none">Đăng ký ngay</a>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    // 1. Chức năng ẩn/hiện mật khẩu
    function togglePassword(inputId, iconId) {
        const input = document.getElementById(inputId);
        const icon = document.getElementById(iconId);
        if (input.type === 'password') {
            input.type = 'text';
            icon.classList.remove('bi-eye');
            icon.classList.add('bi-eye-slash');
        } else {
            input.type = 'password';
            icon.classList.remove('bi-eye-slash');
            icon.classList.add('bi-eye');
        }
    }

    // 2. Bắt cảnh báo Caps Lock
    const pwdInput = document.getElementById('loginPassword');
    const capsWarning = document.getElementById('capsLockWarning');
    pwdInput.addEventListener('keyup', function(e) {
        if (e.getModifierState && e.getModifierState('CapsLock')) {
            capsWarning.style.display = 'block';
        } else {
            capsWarning.style.display = 'none';
        }
    });

    // 3. Loading Spinner & Chống click nhiều lần
    const form = document.getElementById('loginForm');
    form.addEventListener('submit', function() {
        const btn = document.getElementById('btnLogin');
        const text = document.getElementById('btnText');
        const spinner = document.getElementById('btnSpinner');

        btn.disabled = true;
        text.textContent = 'Đang xử lý...';
        spinner.classList.remove('d-none');
    });
</script>
</body>
</html>