<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng ký tài khoản - ALOUTE</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        .input-group-text {
            cursor: pointer;
            background-color: transparent;
        }
        .strength-bar {
            height: 4px;
            border-radius: 2px;
            transition: all 0.3s ease;
        }
        .rule-item {
            font-size: 0.78rem;
            color: #6c757d;
            transition: color 0.2s;
        }
        .rule-item.valid {
            color: #198754;
            font-weight: 600;
        }
    </style>
</head>
<body class="bg-light d-flex align-items-center min-vh-100">
<div class="container my-4">
    <div class="row justify-content-center">
        <div class="col-md-6 col-lg-5">
            <div class="card shadow-sm border-0 rounded-4 p-4">
                <div class="text-center mb-4">
                    <h2 class="fw-bold text-primary"><i class="bi bi-chat-square-heart-fill me-2"></i>ALOUTE</h2>
                    <p class="text-muted small">Tạo tài khoản mới để tham gia cộng đồng</p>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger py-2 small"><i class="bi bi-exclamation-triangle-fill me-2"></i>${error}</div>
                </c:if>

                <form id="regForm" action="<c:url value='/register'/>" method="post">
                    <!-- Họ và tên (được phép gõ tiếng Việt có dấu) -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold small">Họ và tên</label>
                        <input type="text" name="fullName" class="form-control" required placeholder="Ví dụ: Nguyễn Văn A">
                    </div>

                    <!-- Username & Email (tự động loại bỏ dấu tiếng Việt) -->
                    <div class="row g-2 mb-3">
                        <div class="col-6">
                            <label class="form-label fw-semibold small">Tên đăng nhập</label>
                            <input type="text" id="regUsername" name="username" maxlength="20" class="form-control" required placeholder="tuanlee123" autocomplete="username">
                        </div>
                        <div class="col-6">
                            <label class="form-label fw-semibold small">Email</label>
                            <input type="email" id="regEmail" name="email" class="form-control" required placeholder="name@example.com">
                        </div>
                    </div>

                    <!-- Mật khẩu chính -->
                    <div class="mb-2">
                        <label class="form-label fw-semibold small">Mật khẩu</label>
                        <div class="input-group">
                            <input type="password" id="regPassword" name="password" maxlength="16" class="form-control" required placeholder="8 -16 ký tự không dấu" autocomplete="new-password">
                            <span class="input-group-text" onclick="togglePassword('regPassword', 'eyeIconPass')">
                                <i class="bi bi-eye" id="eyeIconPass"></i>
                            </span>
                        </div>
                        
                        <!-- Thanh đo độ mạnh mật khẩu -->
                        <div class="progress mt-2" style="height: 4px;">
                            <div id="strengthBar" class="progress-bar strength-bar" role="progressbar" style="width: 0%"></div>
                        </div>
                        <div class="d-flex justify-content-between align-items-center mt-1">
                            <small id="strengthText" style="font-size: 0.75rem;"></small>
                            <small class="text-muted" style="font-size: 0.75rem;">Tối đa 16 ký tự</small>
                        </div>

                        <!-- Danh sách điều kiện mật khẩu trực quan -->
                        <div class="bg-light rounded-3 p-2 mt-2 border">
                            <div class="row g-1">
                                <div class="col-6 rule-item" id="ruleLength"><i class="bi bi-x-circle me-1"></i>Từ 8 - 16 ký tự</div>
                                <div class="col-6 rule-item" id="ruleUpper"><i class="bi bi-x-circle me-1"></i>Ít nhất 1 chữ hoa (A-Z)</div>
                                <div class="col-6 rule-item" id="ruleNumber"><i class="bi bi-x-circle me-1"></i>Ít nhất 1 chữ số (0-9)</div>
                                <div class="col-6 rule-item" id="ruleSpecial"><i class="bi bi-x-circle me-1"></i>Ký tự đặc biệt (@#$%^&*!_~)</div>
                            </div>
                        </div>
                    </div>

                    <!-- Xác nhận mật khẩu -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold small">Xác nhận mật khẩu</label>
                        <div class="input-group">
                            <input type="password" id="confirmPassword" name="confirmPassword" maxlength="16" class="form-control" required placeholder="Nhập lại mật khẩu" autocomplete="new-password">
                            <span class="input-group-text" onclick="togglePassword('confirmPassword', 'eyeIconConfirm')">
                                <i class="bi bi-eye" id="eyeIconConfirm"></i>
                            </span>
                        </div>
                        <small id="matchFeedback" class="d-none" style="font-size: 0.8rem;"></small>
                    </div>

                    <!-- Đồng ý điều khoản -->
                    <div class="form-check mb-4">
                        <input class="form-check-input" type="checkbox" id="termsCheck" required>
                        <label class="form-check-label small text-muted" for="termsCheck">
                            Tôi đồng ý với <a href="#" class="text-decoration-none">Điều khoản sử dụng</a> & <a href="#" class="text-decoration-none">Chính sách bảo mật</a>
                        </label>
                    </div>

                    <!-- Nút Đăng ký -->
                    <button type="submit" id="btnRegister" class="btn btn-primary btn-lg w-100 fw-bold fs-6">
                        <span id="regBtnText">Tạo tài khoản</span>
                        <span id="regBtnSpinner" class="spinner-border spinner-border-sm d-none" role="status" aria-hidden="true"></span>
                    </button>
                </form>

                <hr class="my-4 text-muted">
                <div class="text-center small">
                    <span class="text-muted">Đã có tài khoản? </span>
                    <a href="<c:url value='/login'/>" class="fw-bold text-decoration-none">Đăng nhập</a>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    // 1. Hàm bóc tách loại bỏ dấu tiếng Việt và ký tự lạ
    function sanitizeVietnamese(str) {
        return str.normalize('NFD')
                  .replace(/[\u0300-\u036f]/g, '') // Xóa dấu sắc, huyền, hỏi, ngã, nặng
                  .replace(/đ/g, 'd').replace(/Đ/g, 'D')
                  .replace(/\s+/g, ''); // Bỏ khoảng trắng
    }

    // Tự động chuẩn hóa Username và Email khi gõ
    const usernameInput = document.getElementById('regUsername');
    const emailInput = document.getElementById('regEmail');

    usernameInput.addEventListener('input', function() {
        this.value = sanitizeVietnamese(this.value).toLowerCase().replace(/[^a-z0-9_.]/g, '');
    });

    emailInput.addEventListener('input', function() {
        this.value = sanitizeVietnamese(this.value).toLowerCase();
    });

    // 2. Chức năng ẩn/hiện mật khẩu
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

    // 3. Kiểm tra độ mạnh và chuẩn hóa mật khẩu (loại bỏ dấu tiếng Việt)
    const passInput = document.getElementById('regPassword');
    const strengthBar = document.getElementById('strengthBar');
    const strengthText = document.getElementById('strengthText');

    const ruleLength = document.getElementById('ruleLength');
    const ruleUpper = document.getElementById('ruleUpper');
    const ruleNumber = document.getElementById('ruleNumber');
    const ruleSpecial = document.getElementById('ruleSpecial');

    function updateRule(elem, isValid) {
        if (isValid) {
            elem.className = 'col-6 rule-item valid';
            elem.innerHTML = '<i class="bi bi-check-circle-fill me-1"></i>' + elem.innerText.trim();
        } else {
            elem.className = 'col-6 rule-item';
            elem.innerHTML = '<i class="bi bi-x-circle me-1"></i>' + elem.innerText.trim();
        }
    }

    passInput.addEventListener('input', function() {
        // Tự động bỏ dấu tiếng Việt nếu người dùng quên tắt Unikey
        const originalVal = this.value;
        const sanitizedVal = sanitizeVietnamese(originalVal);
        if (originalVal !== sanitizedVal) {
            this.value = sanitizedVal;
        }

        const val = this.value;
        const isLen = val.length >= 8 && val.length <= 16;
        const isUp = /[A-Z]/.test(val);
        const isNum = /[0-9]/.test(val);
        const isSpec = /[@#$%^&*!_~]/.test(val);

        updateRule(ruleLength, isLen);
        updateRule(ruleUpper, isUp);
        updateRule(ruleNumber, isNum);
        updateRule(ruleSpecial, isSpec);

        let score = (isLen ? 25 : 0) + (isUp ? 25 : 0) + (isNum ? 25 : 0) + (isSpec ? 25 : 0);

        strengthBar.style.width = score + '%';
        if (score === 0) {
            strengthBar.className = 'progress-bar strength-bar';
            strengthText.textContent = '';
        } else if (score <= 50) {
            strengthBar.className = 'progress-bar strength-bar bg-danger';
            strengthText.textContent = 'Mật khẩu yếu';
            strengthText.className = 'text-danger fw-semibold';
        } else if (score === 75) {
            strengthBar.className = 'progress-bar strength-bar bg-warning';
            strengthText.textContent = 'Mật khẩu trung bình';
            strengthText.className = 'text-warning fw-semibold';
        } else {
            strengthBar.className = 'progress-bar strength-bar bg-success';
            strengthText.textContent = 'Mật khẩu đạt chuẩn';
            strengthText.className = 'text-success fw-semibold';
        }
        checkPasswordMatch();
    });

    // 4. Kiểm tra so khớp 2 mật khẩu trực tiếp
    const confirmInput = document.getElementById('confirmPassword');
    const matchFeedback = document.getElementById('matchFeedback');

    function checkPasswordMatch() {
        confirmInput.value = sanitizeVietnamese(confirmInput.value);
        if (!confirmInput.value) {
            matchFeedback.classList.add('d-none');
            return;
        }
        matchFeedback.classList.remove('d-none');
        if (passInput.value === confirmInput.value) {
            matchFeedback.textContent = 'Mật khẩu trùng khớp';
            matchFeedback.className = 'text-success mt-1 d-block';
        } else {
            matchFeedback.textContent = 'Mật khẩu xác nhận chưa khớp!';
            matchFeedback.className = 'text-danger mt-1 d-block';
        }
    }
    confirmInput.addEventListener('input', checkPasswordMatch);

    // 5. Loading Spinner khi nhấn gửi & chặn gửi nếu mật khẩu chưa đủ 8 ký tự
    const regForm = document.getElementById('regForm');
    regForm.addEventListener('submit', function(e) {
        if (passInput.value.length < 8 || passInput.value.length > 16) {
            e.preventDefault();
            alert('Mật khẩu phải từ 8 đến 16 ký tự!');
            passInput.focus();
            return;
        }
        if (passInput.value !== confirmInput.value) {
            e.preventDefault();
            alert('Mật khẩu xác nhận không khớp!');
            confirmInput.focus();
            return;
        }

        const btn = document.getElementById('btnRegister');
        const text = document.getElementById('regBtnText');
        const spinner = document.getElementById('regBtnSpinner');

        btn.disabled = true;
        text.textContent = 'Đang đăng ký...';
        spinner.classList.remove('d-none');
    });
</script>
</body>
</html>