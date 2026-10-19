<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đăng nhập - ALOUTE</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex align-items-center min-vh-100">
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-5">
            <div class="card shadow-sm border-0 rounded-4 p-4">
                <div class="text-center mb-4">
                    <h2 class="fw-bold text-primary"><i class="bi bi-chat-square-heart-fill me-2"></i>ALOUTE</h2>
                    <p class="text-muted">Đăng nhập để kết nối cùng bạn bè</p>
                </div>

                <!-- Thông báo lỗi nếu đăng nhập thất bại -->
                <c:if test="${not empty error}">
                    <div class="alert alert-danger py-2">${error}</div>
                </c:if>

                <!-- Thông báo khi tài khoản vừa được kích hoạt OTP thành công -->
                <c:if test="${param.activated == 'true'}">
                    <div class="alert alert-success py-2">Kích hoạt tài khoản thành công! Bạn có thể đăng nhập ngay.</div>
                </c:if>

                <!-- Thông báo khi vừa đổi mật khẩu qua OTP thành công -->
                <c:if test="${param.resetSuccess == 'true'}">
                    <div class="alert alert-success py-2">Đặt lại mật khẩu thành công! Vui lòng đăng nhập với mật khẩu mới.</div>
                </c:if>

                <form action="<c:url value='/login'/>" method="post">
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Tên đăng nhập hoặc Email</label>
                        <input type="text" name="usernameOrEmail" class="form-control form-control-lg fs-6" required placeholder="Nhập username hoặc email">
                    </div>
                    
                    <div class="mb-2">
                        <label class="form-label fw-semibold">Mật khẩu</label>
                        <input type="password" name="password" class="form-control form-control-lg fs-6" required placeholder="Nhập mật khẩu">
                    </div>

                    <!-- Liên kết Quên mật khẩu -->
                    <div class="d-flex justify-content-end mb-4">
                        <a href="<c:url value='/forgot-password'/>" class="text-decoration-none small text-primary fw-semibold">Quên mật khẩu?</a>
                    </div>

                    <button type="submit" class="btn btn-primary btn-lg w-100 fw-bold">Đăng nhập</button>
                </form>

                <hr class="my-4">
                <div class="text-center">
                    <span>Chưa có tài khoản? </span>
                    <a href="<c:url value='/register'/>" class="fw-bold text-decoration-none">Đăng ký ngay</a>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>