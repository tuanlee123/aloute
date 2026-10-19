<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đăng ký tài khoản - ALOUTE</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex align-items-center min-vh-100">
<div class="container my-5">
    <div class="row justify-content-center">
        <div class="col-md-6">
            <div class="card shadow-sm border-0 rounded-4 p-4">
                <div class="text-center mb-4">
                    <h2 class="fw-bold text-primary"><i class="bi bi-chat-square-heart-fill me-2"></i>ALOUTE</h2>
                    <p class="text-muted">Tạo tài khoản mới</p>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger py-2">${error}</div>
                </c:if>

                <form action="<c:url value='/register'/>" method="post">
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Họ và tên</label>
                        <input type="text" name="fullName" class="form-control" required placeholder="Ví dụ: Nguyễn Văn A">
                    </div>
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Tên đăng nhập</label>
                            <input type="text" name="username" class="form-control" required placeholder="username">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Email</label>
                            <input type="email" name="email" class="form-control" required placeholder="name@example.com">
                        </div>
                    </div>
                    <div class="row mb-4">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Mật khẩu</label>
                            <input type="password" name="password" class="form-control" required placeholder="Tối thiểu 6 ký tự">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Xác nhận mật khẩu</label>
                            <input type="password" name="confirmPassword" class="form-control" required placeholder="Nhập lại mật khẩu">
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary btn-lg w-100 fw-bold">Đăng ký</button>
                </form>

                <hr class="my-4">
                <div class="text-center">
                    <span>Đã có tài khoản? </span>
                    <a href="<c:url value='/login'/>" class="fw-bold text-decoration-none">Đăng nhập</a>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>