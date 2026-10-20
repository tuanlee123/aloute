<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<head>
    <title>Cài đặt tài khoản - ALOUTE</title>
    <style>
        .settings-nav .nav-link {
            color: #333;
            font-weight: 500;
            border-radius: 8px;
            padding: 10px 16px;
            margin-bottom: 6px;
            display: flex;
            align-items: center;
        }
        .settings-nav .nav-link:hover {
            background-color: #e4e6eb;
        }
        .settings-nav .nav-link.active {
            background-color: #e7f3ff;
            color: #1877f2;
            font-weight: 600;
        }
        .settings-nav .nav-link i {
            font-size: 1.2rem;
            margin-right: 12px;
        }
        .strength-bar {
            height: 6px;
            border-radius: 4px;
            background-color: #e9ecef;
            transition: all 0.3s ease;
        }
    </style>
</head>

<div class="container py-4" style="max-width: 960px;">
    <div class="row g-4">
        <!-- MENU CÀI ĐẶT BÊN TRÁI -->
        <div class="col-md-4">
            <div class="card border-0 shadow-sm rounded-4 p-3">
                <h5 class="fw-bold px-2 mb-3">Cài đặt</h5>
                <nav class="nav flex-column settings-nav">
                    <a class="nav-link ${activeTab == 'account' ? 'active' : ''}" 
                       href="<c:url value='/settings?tab=account'/>">
                        <i class="bi bi-person-gear"></i> Thông tin tài khoản
                    </a>
                    <a class="nav-link ${activeTab == 'security' ? 'active' : ''}" 
                       href="<c:url value='/settings?tab=security'/>">
                        <i class="bi bi-shield-lock"></i> Mật khẩu & Bảo mật
                    </a>
                    <a class="nav-link text-muted opacity-75" href="#" onclick="alert('Tính năng đang phát triển!'); return false;">
                        <i class="bi bi-bell"></i> Thông báo
                    </a>
                    <a class="nav-link text-muted opacity-75" href="#" onclick="alert('Tính năng đang phát triển!'); return false;">
                        <i class="bi bi-eye-slash"></i> Quyền riêng tư
                    </a>
                </nav>
            </div>
        </div>

        <!-- NỘI DUNG CÀI ĐẶT BÊN PHẢI -->
        <div class="col-md-8">
            <div class="card border-0 shadow-sm rounded-4 p-4">
                <c:choose>
                    <%-- TAB 1: THÔNG TIN TÀI KHOẢN --%>
                    <c:when test="${activeTab == 'account'}">
                        <h4 class="fw-bold mb-1">Cài đặt tài khoản chung</h4>
                        <p class="text-muted small mb-4 pb-2 border-bottom">Quản lý các thông tin cá nhân cơ bản của bạn trên ALOUTE</p>

                        <c:if test="${not empty accountSuccess}">
                            <div class="alert alert-success alert-dismissible fade show small" role="alert">
                                <i class="bi bi-check-circle-fill me-2"></i>${accountSuccess}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>
                        <c:if test="${not empty accountError}">
                            <div class="alert alert-danger alert-dismissible fade show small" role="alert">
                                <i class="bi bi-exclamation-triangle-fill me-2"></i>${accountError}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>

                        <form action="<c:url value='/settings/update-account'/>" method="post">
                            <div class="mb-3">
                                <label class="form-label text-dark fw-semibold small">Tên người dùng (Username)</label>
                                <input type="text" class="form-control bg-light py-2" value="${user.username}" readonly>
                            </div>

                            <div class="mb-3">
                                <label class="form-label text-dark fw-semibold small">Địa chỉ Email</label>
                                <input type="email" class="form-control bg-light py-2" value="${user.email}" readonly>
                            </div>

                            <div class="mb-4">
                                <label class="form-label text-dark fw-semibold small">Họ và tên hiển thị</label>
                                <input type="text" name="fullName" class="form-control py-2" value="${user.fullName}" required maxlength="50">
                            </div>

                            <div class="d-flex justify-content-end">
                                <button type="submit" class="btn btn-primary px-4 fw-semibold rounded-3">
                                    <i class="bi bi-save me-1"></i> Lưu thay đổi
                                </button>
                            </div>
                        </form>
                    </c:when>

                    <%-- TAB 2: MẬT KHẨU & BẢO MẬT --%>
                    <c:otherwise>
                        <h4 class="fw-bold mb-1">Đổi mật khẩu</h4>
                        <p class="text-muted small mb-4 pb-2 border-bottom">Mật khẩu mạnh bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt</p>

                        <c:if test="${not empty passwordSuccess}">
                            <div class="alert alert-success alert-dismissible fade show small" role="alert">
                                <i class="bi bi-check-circle-fill me-2"></i>${passwordSuccess}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>
                        <c:if test="${not empty passwordError}">
                            <div class="alert alert-danger alert-dismissible fade show small" role="alert">
                                <i class="bi bi-exclamation-triangle-fill me-2"></i>${passwordError}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>

                        <form action="<c:url value='/settings/change-password'/>" method="post">
                            <!-- 1. Mật khẩu hiện tại -->
                            <div class="mb-3">
                                <label class="form-label text-dark fw-semibold small">Mật khẩu hiện tại</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light border-end-0"><i class="bi bi-key text-muted"></i></span>
                                    <input type="password" id="currentPass" name="currentPassword" class="form-control border-start-0 border-end-0 py-2" required placeholder="Nhập mật khẩu hiện tại">
                                    <button class="btn btn-outline-secondary border-start-0" type="button" onclick="togglePass('currentPass', 'eyeCurrent')">
                                        <i class="bi bi-eye" id="eyeCurrent"></i>
                                    </button>
                                </div>
                            </div>

                            <!-- 2. Mật khẩu mới (Khóa cứng tối đa 16 ký tự) -->
                            <div class="mb-2">
                                <label class="form-label text-dark fw-semibold small">Mật khẩu mới (8-16 ký tự)</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light border-end-0"><i class="bi bi-lock text-muted"></i></span>
                                    <input type="password" id="newPass" name="newPassword" class="form-control border-start-0 border-end-0 py-2" required maxlength="16" placeholder="Nhập mật khẩu mới">
                                    <button class="btn btn-outline-secondary border-start-0" type="button" onclick="togglePass('newPass', 'eyeNew')">
                                        <i class="bi bi-eye" id="eyeNew"></i>
                                    </button>
                                </div>
                            </div>

                            <!-- Thanh hiển thị độ mạnh/yếu -->
                            <div class="progress mb-2" style="height: 6px;">
                                <div id="strengthMeter" class="progress-bar" role="progressbar" style="width: 0%;"></div>
                            </div>
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <span class="small text-muted">Độ mạnh mật khẩu:</span>
                                <span id="strengthText" class="small fw-bold text-muted">Chưa nhập</span>
                            </div>

                            <!-- Bộ tiêu chí Checklist -->
                            <div class="p-3 bg-light rounded-3 mb-3">
                                <div class="small fw-semibold text-secondary mb-2">Tiêu chuẩn mật khẩu an toàn:</div>
                                <ul class="list-unstyled mb-0 small text-muted">
                                    <li id="ruleLength" class="mb-1"><i class="bi bi-circle me-2"></i>Độ dài từ 8 đến 16 ký tự</li>
                                    <li id="ruleCase" class="mb-1"><i class="bi bi-circle me-2"></i>Bao gồm cả chữ hoa (A-Z) và chữ thường (a-z)</li>
                                    <li id="ruleNumber" class="mb-1"><i class="bi bi-circle me-2"></i>Có ít nhất 1 chữ số (0-9)</li>
                                    <li id="ruleSpecial" class="mb-1"><i class="bi bi-circle me-2"></i>Có ít nhất 1 ký tự đặc biệt (@, #, $, !, %, ...)</li>
                                    <li id="ruleNoSpace"><i class="bi bi-circle me-2"></i>Không chứa khoảng trắng hoặc dấu tiếng Việt</li>
                                </ul>
                            </div>

                            <!-- 3. Xác nhận mật khẩu mới (Khóa cứng tối đa 16 ký tự) -->
                            <div class="mb-4">
                                <label class="form-label text-dark fw-semibold small">Nhập lại mật khẩu mới</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light border-end-0"><i class="bi bi-shield-check text-muted"></i></span>
                                    <input type="password" id="confirmPass" name="confirmPassword" class="form-control border-start-0 border-end-0 py-2" required maxlength="16" placeholder="Nhập lại mật khẩu mới">
                                    <button class="btn btn-outline-secondary border-start-0" type="button" onclick="togglePass('confirmPass', 'eyeConfirm')">
                                        <i class="bi bi-eye" id="eyeConfirm"></i>
                                    </button>
                                </div>
                                <div id="matchFeedback" class="small mt-1"></div>
                            </div>

                            <div class="d-flex justify-content-end">
                                <button type="submit" id="btnSubmitPassword" class="btn btn-primary px-4 fw-semibold rounded-3" disabled>
                                    <i class="bi bi-shield-check me-1"></i> Cập nhật mật khẩu
                                </button>
                            </div>
                        </form>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

<script>
    // Hàm ẩn/hiện mật khẩu
    function togglePass(inputId, eyeIconId) {
        const input = document.getElementById(inputId);
        const icon = document.getElementById(eyeIconId);
        if (input.type === "password") {
            input.type = "text";
            icon.classList.replace("bi-eye", "bi-eye-slash");
        } else {
            input.type = "password";
            icon.classList.replace("bi-eye-slash", "bi-eye");
        }
    }

    const newPass = document.getElementById('newPass');
    const confirmPass = document.getElementById('confirmPass');
    const strengthMeter = document.getElementById('strengthMeter');
    const strengthText = document.getElementById('strengthText');
    const btnSubmitPassword = document.getElementById('btnSubmitPassword');

    const ruleLength = document.getElementById('ruleLength');
    const ruleCase = document.getElementById('ruleCase');
    const ruleNumber = document.getElementById('ruleNumber');
    const ruleSpecial = document.getElementById('ruleSpecial');
    const ruleNoSpace = document.getElementById('ruleNoSpace');
    const matchFeedback = document.getElementById('matchFeedback');

    function updateRule(element, isValid, text) {
        if (isValid) {
            element.className = "mb-1 text-success fw-semibold";
            element.innerHTML = '<i class="bi bi-check-circle-fill me-2"></i>' + text;
        } else {
            element.className = "mb-1 text-muted";
            element.innerHTML = '<i class="bi bi-circle me-2"></i>' + text;
        }
    }

    function validateAll() {
        const val = newPass ? newPass.value : "";
        let score = 0;

        // 1. Độ dài chuẩn từ 8 đến 16 ký tự
        const isLengthOk = val.length >= 8 && val.length <= 16;
        updateRule(ruleLength, isLengthOk, "Độ dài từ 8 đến 16 ký tự");
        if (isLengthOk) score++;

        // 2. Chữ hoa và chữ thường
        const isCaseOk = /[a-z]/.test(val) && /[A-Z]/.test(val);
        updateRule(ruleCase, isCaseOk, "Bao gồm cả chữ hoa (A-Z) và chữ thường (a-z)");
        if (isCaseOk) score++;

        // 3. Số
        const isNumberOk = /\d/.test(val);
        updateRule(ruleNumber, isNumberOk, "Có ít nhất 1 chữ số (0-9)");
        if (isNumberOk) score++;

        // 4. Ký tự đặc biệt
        const isSpecialOk = /[!@#$%^&*(),.?":{}|<>]/.test(val);
        updateRule(ruleSpecial, isSpecialOk, "Có ít nhất 1 ký tự đặc biệt (@, #, $, !, %, ...)");
        if (isSpecialOk) score++;

        // 5. Không chứa khoảng trắng hoặc dấu tiếng Việt
        const hasSpaceOrVietnamese = /[\sàáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]/i.test(val);
        const isNoSpaceOk = val.length > 0 && !hasSpaceOrVietnamese;
        updateRule(ruleNoSpace, isNoSpaceOk, "Không chứa khoảng trắng hoặc dấu tiếng Việt");
        if (isNoSpaceOk) score++;

        // Đánh giá thanh lực: nếu chưa đủ 8 ký tự hoặc vượt quá 16 ký tự thì luôn là Yếu
        if (val.length === 0) {
            strengthMeter.style.width = "0%";
            strengthMeter.className = "progress-bar";
            strengthText.innerText = "Chưa nhập";
            strengthText.className = "small fw-bold text-muted";
        } else if (!isLengthOk || score <= 2) {
            strengthMeter.style.width = "25%";
            strengthMeter.className = "progress-bar bg-danger";
            strengthText.innerText = "Yếu (Chưa đủ điều kiện)";
            strengthText.className = "small fw-bold text-danger";
        } else if (score === 3 || score === 4) {
            strengthMeter.style.width = "70%";
            strengthMeter.className = "progress-bar bg-warning";
            strengthText.innerText = "Trung bình";
            strengthText.className = "small fw-bold text-warning";
        } else if (score === 5) {
            strengthMeter.style.width = "100%";
            strengthMeter.className = "progress-bar bg-success";
            strengthText.innerText = "Rất mạnh";
            strengthText.className = "small fw-bold text-success";
        }

        // Kiểm tra khớp xác nhận mật khẩu
        const confirmVal = confirmPass ? confirmPass.value : "";
        let isMatch = false;
        if (confirmVal === "") {
            matchFeedback.innerHTML = "";
        } else if (confirmVal === val) {
            matchFeedback.className = "small mt-1 text-success";
            matchFeedback.innerHTML = '<i class="bi bi-check-circle-fill me-1"></i>Mật khẩu trùng khớp';
            isMatch = true;
        } else {
            matchFeedback.className = "small mt-1 text-danger";
            matchFeedback.innerHTML = '<i class="bi bi-x-circle-fill me-1"></i>Mật khẩu xác nhận chưa khớp';
            isMatch = false;
        }

        // Khóa hoặc mở nút Submit: Phải đủ 8-16 ký tự, không dấu, mật khẩu khớp và độ mạnh tối thiểu đạt mức Trung bình
        if (btnSubmitPassword) {
            const canSubmit = isLengthOk && isNoSpaceOk && isMatch && (score >= 3);
            btnSubmitPassword.disabled = !canSubmit;
        }
    }

    if (newPass) newPass.addEventListener('input', validateAll);
    if (confirmPass) confirmPass.addEventListener('input', validateAll);
</script>