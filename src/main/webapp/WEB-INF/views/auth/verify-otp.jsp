<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Xác thực tài khoản - ALOUTE</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex align-items-center min-vh-100">
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-5">
            <div class="card shadow-sm border-0 rounded-4 p-4 text-center">
                <h3 class="fw-bold text-primary mb-2">Nhập mã OTP</h3>
                <p class="text-muted small">Mã kích hoạt 6 chữ số đã được gửi tới email <strong>${verifyOtpDTO.email}</strong></p>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger py-2 text-start">${error}</div>
                </c:if>
                <c:if test="${param.resent == 'true'}">
                    <div class="alert alert-success py-2 text-start">Đã gửi lại mã OTP mới vào hộp thư của bạn!</div>
                </c:if>

                <form action="<c:url value='/verify-otp'/>" method="post">
                    <input type="hidden" name="email" value="${verifyOtpDTO.email}">
                    <div class="mb-3">
                        <input type="text" name="otp" maxlength="6" class="form-control text-center fs-4 letter-spacing-2" required placeholder="000000">
                    </div>
                    <button type="submit" class="btn btn-primary btn-lg w-100 fw-bold">Kích hoạt tài khoản</button>
                </form>
                <div class="mt-3">
                    <a href="<c:url value='/resend-otp?email=${verifyOtpDTO.email}'/>" class="text-decoration-none small">Chưa nhận được mã? Gửi lại OTP</a>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>