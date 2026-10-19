<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quên mật khẩu - ALOUTE</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex align-items-center min-vh-100">
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-5 col-lg-4">
            <div class="card shadow-sm border-0 rounded-4 p-4">
                <div class="text-center mb-4">
                    <h2 class="fw-bold text-primary"><i class="bi bi-key-fill me-2"></i>ALOUTE</h2>
                    <h5 class="fw-bold mb-1">Quên mật khẩu?</h5>
                    <p class="text-muted small">Nhập email đăng ký tài khoản của bạn để nhận mã xác thực OTP.</p>
                </div>

                <form id="forgotForm" action="<c:url value='/forgot-password'/>" method="post">
                    <div class="mb-4">
                        <label class="form-label fw-semibold small">Địa chỉ Email</label>
                        <div class="input-group">
                            <span class="input-group-text bg-transparent"><i class="bi bi-envelope text-muted"></i></span>
                            <input type="email" name="email" class="form-control" required placeholder="name@example.com" autocomplete="email">
                        </div>
                    </div>
                    
                    <button type="submit" id="btnForgot" class="btn btn-primary btn-lg w-100 fw-bold fs-6">
                        <span id="forgotText">Gửi mã xác thực</span>
                        <span id="forgotSpinner" class="spinner-border spinner-border-sm d-none" role="status" aria-hidden="true"></span>
                    </button>
                </form>

                <hr class="my-4 text-muted">
                <div class="text-center small">
                    <a href="<c:url value='/login'/>" class="fw-semibold text-decoration-none">
                        <i class="bi bi-arrow-left me-1"></i>Quay lại Đăng nhập
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    const forgotForm = document.getElementById('forgotForm');
    forgotForm.addEventListener('submit', function() {
        const btn = document.getElementById('btnForgot');
        const text = document.getElementById('forgotText');
        const spinner = document.getElementById('forgotSpinner');

        btn.disabled = true;
        text.textContent = 'Đang gửi mã...';
        spinner.classList.remove('d-none');
    });
</script>
</body>
</html>