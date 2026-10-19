<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đặt lại mật khẩu - ALOUTE</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex align-items-center min-vh-100">
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-5">
            <div class="card shadow-sm border-0 rounded-4 p-4">
                <h3 class="fw-bold text-primary text-center mb-2">Đặt lại mật khẩu</h3>
                <p class="text-muted text-center small mb-3">Nhập mã OTP đã nhận qua email <strong>${resetPasswordDTO.email}</strong></p>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger py-2">${error}</div>
                </c:if>

                <form action="<c:url value='/reset-password'/>" method="post">
                    <input type="hidden" name="email" value="${resetPasswordDTO.email}">
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Mã OTP (6 số)</label>
                        <input type="text" name="otp" maxlength="6" class="form-control text-center fs-5" required placeholder="000000">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Mật khẩu mới</label>
                        <input type="password" name="newPassword" class="form-control" required placeholder="Nhập mật khẩu mới">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Xác nhận mật khẩu mới</label>
                        <input type="password" name="confirmNewPassword" class="form-control" required placeholder="Nhập lại mật khẩu mới">
                    </div>
                    <button type="submit" class="btn btn-primary btn-lg w-100 fw-bold">Xác nhận đổi mật khẩu</button>
                </form>
            </div>
        </div>
    </div>
</div>
</body>
</html>