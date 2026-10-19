<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quên mật khẩu - ALOUTE</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex align-items-center min-vh-100">
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-5">
            <div class="card shadow-sm border-0 rounded-4 p-4">
                <h3 class="fw-bold text-primary text-center mb-2">Quên mật khẩu</h3>
                <p class="text-muted text-center small mb-3">Nhập email đăng ký của bạn để nhận mã OTP đặt lại mật khẩu</p>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger py-2">${error}</div>
                </c:if>

                <form action="<c:url value='/forgot-password'/>" method="post">
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Email tài khoản</label>
                        <input type="email" name="email" class="form-control" required placeholder="name@example.com">
                    </div>
                    <button type="submit" class="btn btn-primary btn-lg w-100 fw-bold">Gửi mã OTP</button>
                </form>
                <div class="text-center mt-3">
                    <a href="<c:url value='/login'/>" class="text-decoration-none small">Quay lại Đăng nhập</a>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>