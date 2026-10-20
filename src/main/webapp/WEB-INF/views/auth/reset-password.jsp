<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt lại mật khẩu - ALOUTE</title>
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
        .caps-warn {
            display: none;
            font-size: 0.8rem;
            color: #dc3545;
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
        <div class="col-md-5 col-lg-4">
            <div class="card shadow-sm border-0 rounded-4 p-4">
                <div class="text-center mb-4">
                    <h2 class="fw-bold text-primary"><i class="bi bi-shield-lock-fill me-2"></i>ALOUTE</h2>
                    <h5 class="fw-bold mb-1">Đặt lại mật khẩu</h5>
                    <p class="text-muted small">Nhập mã OTP đã nhận qua email <br><strong class="text-dark">${resetPasswordDTO.email}</strong></p>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger py-2 small">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i>${error}
                    </div>
                </c:if>

                <form id="resetForm" action="<c:url value='/reset-password'/>" method="post">
                    <input type="hidden" name="email" value="${resetPasswordDTO.email}">

                    <!-- Mã OTP -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold small">Mã OTP (6 chữ số)</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-key text-muted"></i></span>
                            <input type="text" name="otp" maxlength="6" class="form-control text-center fs-5 fw-bold letter-spacing-2" required placeholder="000000" autocomplete="one-time-code">
                        </div>
                    </div>

                    <!-- Mật khẩu mới -->
                    <div class="mb-2">
                        <label class="form-label fw-semibold small">Mật khẩu mới</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-lock text-muted"></i></span>
                            <input type="password" id="newPassword" name="newPassword" maxlength="16" class="form-control" required placeholder="8 - 16 ký tự không dấu" autocomplete="new-password">
                            <span class="input-group-text" onclick="togglePassword('newPassword', 'eyeIconNew')">
                                <i class="bi bi-eye" id="eyeIconNew"></i>
                            </span>
                        </div>
                        
                        <!-- Cảnh báo Caps Lock -->
                        <div id="capsLockWarning" class="caps-warn mt-1">
                            <i class="bi bi-arrow-up-square-fill me-1"></i>Đang bật Caps Lock!
                        </div>

                        <!-- Thanh đo độ mạnh mật khẩu -->
                        <div class="progress mt-2" style="height: 4px;">
                            <div id="strengthBar" class="progress-bar strength-bar" role="progressbar" style="width: 0%"></div>
                        </div>
                        <div class="d-flex justify-content-between align-items-center mt-1">
                            <small id="strengthText" style="font-size: 0.75rem;"></small>
                            <small class="text-muted" style="font-size: 0.75rem;">Tối đa 16 ký tự</small>
                        </div>

                        <!-- Bảng tiêu chí mật khẩu trực quan -->
                        <div class="bg-light rounded-3 p-2 mt-2 border">
                            <div class="row g-1">
                                <div class="col-6 rule-item" id="ruleLength"><i class="bi bi-x-circle me-1"></i>Từ 8 - 16 ký tự</div>
                                <div class="col-6 rule-item" id="ruleUpper"><i class="bi bi-x-circle me-1"></i>Ít nhất 1 chữ hoa (A-Z)</div>
                                <div class="col-6 rule-item" id="ruleNumber"><i class="bi bi-x-circle me-1"></i>Ít nhất 1 chữ số (0-9)</div>
                                <div class="col-6 rule-item" id="ruleSpecial"><i class="bi bi-x-circle me-1"></i>Ký tự đặc biệt (@#$%^&*!_~)</div>
                            </div>
                        </div>
                    </div>

                    <!-- Xác nhận mật khẩu mới -->
                    <div class="mb-4">
                        <label class="form-label fw-semibold small">Xác nhận mật khẩu mới</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-shield-check text-muted"></i></span>
                            <input type="password" id="confirmNewPassword" name="confirmNewPassword" maxlength="16" class="form-control" required placeholder="Nhập lại mật khẩu mới" autocomplete="new-password">
                            <span class="input-group-text" onclick="togglePassword('confirmNewPassword', 'eyeIconConfirmNew')">
                                <i class="bi bi-eye" id="eyeIconConfirmNew"></i>
                            </span>
                        </div>
                        <small id="matchFeedback" class="d-none" style="font-size: 0.8rem;"></small>
                    </div>

                    <!-- Nút xác nhận đổi mật khẩu -->
                    <button type="submit" id="btnReset" class="btn btn-primary btn-lg w-100 fw-bold fs-6">
                        <span id="resetBtnText">Xác nhận đổi mật khẩu</span>
                        <span id="resetBtnSpinner" class="spinner-border spinner-border-sm d-none" role="status" aria-hidden="true"></span>
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
    // 1. Hàm bóc tách loại bỏ dấu tiếng Việt và khoảng trắng
    function sanitizeVietnamese(str) {
        return str.normalize('NFD')
                  .replace(/[\u0300-\u036f]/g, '') // Bỏ dấu sắc, huyền, hỏi, ngã, nặng
                  .replace(/đ/g, 'd').replace(/Đ/g, 'D')
                  .replace(/\s+/g, ''); // Bỏ khoảng trắng
    }

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

    // 3. Bắt cảnh báo Caps Lock
    const pwdInput = document.getElementById('newPassword');
    const capsWarning = document.getElementById('capsLockWarning');
    pwdInput.addEventListener('keyup', function(e) {
        if (e.getModifierState && e.getModifierState('CapsLock')) {
            capsWarning.style.display = 'block';
        } else {
            capsWarning.style.display = 'none';
        }
    });

    // 4. Đo độ mạnh mật khẩu và cập nhật 4 tiêu chuẩn
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

    pwdInput.addEventListener('input', function() {
        // Tự động bỏ dấu tiếng Việt nếu bật Unikey
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

    // 5. Kiểm tra so khớp 2 mật khẩu trực tiếp
    const confirmInput = document.getElementById('confirmNewPassword');
    const matchFeedback = document.getElementById('matchFeedback');

    function checkPasswordMatch() {
        confirmInput.value = sanitizeVietnamese(confirmInput.value);
        if (!confirmInput.value) {
            matchFeedback.classList.add('d-none');
            return;
        }
        matchFeedback.classList.remove('d-none');
        if (pwdInput.value === confirmInput.value) {
            matchFeedback.textContent = 'Mật khẩu trùng khớp';
            matchFeedback.className = 'text-success mt-1 d-block';
        } else {
            matchFeedback.textContent = 'Mật khẩu xác nhận chưa khớp!';
            matchFeedback.className = 'text-danger mt-1 d-block';
        }
    }
    confirmInput.addEventListener('input', checkPasswordMatch);

    // 6. Loading Spinner khi Submit & Chặn nếu mật khẩu chưa đủ 8 ký tự
    const resetForm = document.getElementById('resetForm');
    resetForm.addEventListener('submit', function(e) {
        if (pwdInput.value.length < 8 || pwdInput.value.length > 16) {
            e.preventDefault();
            alert('Mật khẩu mới phải có từ 8 đến 16 ký tự!');
            pwdInput.focus();
            return;
        }
        if (pwdInput.value !== confirmInput.value) {
            e.preventDefault();
            alert('Vui lòng kiểm tra lại: Mật khẩu xác nhận không khớp!');
            confirmInput.focus();
            return;
        }
        const btn = document.getElementById('btnReset');
        const text = document.getElementById('resetBtnText');
        const spinner = document.getElementById('resetBtnSpinner');

        btn.disabled = true;
        text.textContent = 'Đang cập nhật...';
        spinner.classList.remove('d-none');
    });
</script>
</body>
</html>