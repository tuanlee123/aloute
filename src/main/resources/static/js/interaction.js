document.addEventListener("DOMContentLoaded", function () {

    // Helper mã hóa ký tự tránh lỗi vỡ HTML / XSS
    function escapeHtml(text) {
        if (!text) return "";
        return text
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }

    // Helper format thời gian gửi: Giờ:Phút Ngày/Tháng/Năm (VD: 14:30 21/10/2026)
    function getCurrentTimeString(dateInput) {
        const d = dateInput ? new Date(dateInput) : new Date();
        const hours = String(d.getHours()).padStart(2, '0');
        const minutes = String(d.getMinutes()).padStart(2, '0');
        const day = String(d.getDate()).padStart(2, '0');
        const month = String(d.getMonth() + 1).padStart(2, '0');
        const year = d.getFullYear();
        return `${hours}:${minutes} ${day}/${month}/${year}`;
    }

    // 1. TỰ ĐỘNG CHUYỂN TRANG PROFILE KHI CLICK VÀO BẤT KỲ AVATAR NÀO CÓ DATA-USER-ID
    document.addEventListener("click", function (e) {
        const userTarget = e.target.closest("[data-user-id], .user-avatar-link");
        if (userTarget && !e.target.closest("button") && !e.target.closest(".dropdown") && !e.target.closest("input") && !e.target.closest("form")) {
            const parentLink = userTarget.closest("a");
            if (parentLink && parentLink.getAttribute("href") && parentLink.getAttribute("href") !== "#" && parentLink.getAttribute("href") !== "javascript:void(0)") {
                return; // Nếu đã nằm trong thẻ <a> có link hợp lệ thì để thẻ <a> tự chuyển
            }
            const uid = userTarget.getAttribute("data-user-id");
            if (uid) {
                window.location.href = "/profile?userId=" + uid;
            }
        }
    });

    // 2. ĐẢM BẢO TẤT CẢ NÚT 3 CHẤM (CŨ VÀ MỚI) ĐỀU MỞ ĐƯỢC MENU
    document.addEventListener("click", function (e) {
        const toggleBtn = e.target.closest('[data-bs-toggle="dropdown"]');
        if (toggleBtn && typeof bootstrap !== "undefined" && bootstrap.Dropdown) {
            const dropdownInstance = bootstrap.Dropdown.getOrCreateInstance(toggleBtn);
            if (dropdownInstance) {
                dropdownInstance.toggle();
            }
        }
    });

    // 3. Xử lý Thả tim (Like/Unlike)
    document.querySelectorAll(".btn-like").forEach(button => {
        button.addEventListener("click", function () {
            if (this.disabled) return;
            this.disabled = true; // Chống spam click liên tục

            const postId = this.getAttribute("data-post-id");
            const countSpan = this.querySelector(".like-count");
            const heartIcon = this.querySelector("i");

            const formData = new URLSearchParams();
            formData.append("postId", postId);

            fetch("/api/interaction/like", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: formData
            })
            .then(res => {
                if (!res.ok) throw new Error("HTTP Status: " + res.status);
                return res.json();
            })
            .then(data => {
                if (countSpan) countSpan.textContent = data.likeCount;
                if (data.liked) {
                    this.classList.add("text-danger");
                    if (heartIcon) heartIcon.className = "fas fa-heart text-danger me-1";
                } else {
                    this.classList.remove("text-danger");
                    if (heartIcon) heartIcon.className = "far fa-heart me-1";
                }
            })
            .catch(err => console.error("Lỗi thả tim:", err))
            .finally(() => {
                this.disabled = false; // Mở lại nút
            });
        });
    });

    // 4. Xử lý Gửi Bình luận qua AJAX
    document.querySelectorAll(".form-comment").forEach(form => {
        form.addEventListener("submit", function (e) {
            e.preventDefault();
            const postId = this.getAttribute("data-post-id");
            const input = this.querySelector(".input-comment");
            const submitBtn = this.querySelector("button[type='submit']");
            const content = input.value.trim();
            const commentList = document.querySelector("#comment-list-" + postId);

            if (!content) return;

            if (submitBtn) submitBtn.disabled = true; // Khóa nút gửi tạm thời

            const formData = new URLSearchParams();
            formData.append("postId", postId);
            formData.append("content", content);

            fetch("/api/interaction/comment", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: formData
            })
            .then(res => {
                if (!res.ok) throw new Error("HTTP Status: " + res.status);
                return res.json();
            })
            .then(comment => {
                input.value = ""; // Xóa ô nhập sau khi gửi thành công

                if (commentList) {
                    const avatarUrl = comment.userAvatar ? comment.userAvatar : "https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg";
                    const safeName = escapeHtml(comment.userFullName);
                    const safeContent = escapeHtml(comment.content);
                    const commentId = comment.id || Date.now();
                    const formattedTime = getCurrentTimeString(comment.createdAt);
                    
                    // Lấy userId để tạo link profile (hỗ trợ cả comment.userId và comment.user.id)
                    const uid = comment.userId || (comment.user ? comment.user.id : "");
                    const profileLink = uid ? `/profile?userId=${uid}` : `/profile`;

                    const item = document.createElement("div");
                    item.className = "d-flex align-items-start mb-2 comment-item";
                    item.id = `comment-item-${commentId}`;
                    item.innerHTML = `
                        <!-- BỌC THẺ A DẪN SANG PROFILE CHO AVATAR -->
                        <a href="${profileLink}" class="d-inline-block text-decoration-none me-2">
                            <img src="${avatarUrl}" class="rounded-circle border" width="32" height="32" alt="avatar" style="object-fit: cover; cursor: pointer;">
                        </a>
                        <div class="bg-light p-2 rounded-3 flex-grow-1 position-relative">
                            <div class="d-flex justify-content-between align-items-center">
                                <!-- BỌC THẺ A DẪN SANG PROFILE CHO TÊN -->
                                <a href="${profileLink}" class="text-dark fw-bold text-decoration-none" style="font-size: 0.85rem;">
                                    ${safeName}
                                </a>
                                
                                <!-- MENU 3 CHẤM DỌC CHO BÌNH LUẬN MỚI TẠO -->
                                <div class="dropdown">
                                    <button class="btn btn-link text-muted p-0 border-0 text-decoration-none" 
                                            type="button" 
                                            data-bs-toggle="dropdown" 
                                            aria-expanded="false">
                                        <i class="bi bi-three-dots-vertical" style="font-size: 1rem;"></i>
                                    </button>
                                    <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0 py-1" style="font-size: 0.85rem; z-index: 1060;">
                                        <li>
                                            <a class="dropdown-item py-1" href="javascript:void(0)" onclick="openEditComment(${commentId})">
                                                <i class="bi bi-pencil me-2 text-primary"></i>Chỉnh sửa
                                            </a>
                                        </li>
                                        <li>
                                            <a class="dropdown-item py-1 text-danger" href="javascript:void(0)" onclick="deleteComment(${commentId})">
                                                <i class="bi bi-trash me-2"></i>Xóa
                                            </a>
                                        </li>
                                    </ul>
                                </div>
                            </div>

                            <div id="comment-text-${commentId}" class="text-secondary" style="font-size: 0.9rem;">
                                ${safeContent}
                            </div>

                            <!-- KHUNG SỬA BÌNH LUẬN -->
                            <div id="comment-edit-box-${commentId}" class="d-none mt-2">
                                <input type="text" class="form-control form-control-sm mb-1" id="comment-input-${commentId}" value="${safeContent}">
                                <button class="btn btn-sm btn-primary rounded-pill px-2 py-0" onclick="saveEditComment(${commentId})">Lưu</button>
                                <button class="btn btn-sm btn-light rounded-pill px-2 py-0" onclick="cancelEditComment(${commentId})">Hủy</button>
                            </div>

                            <small class="text-muted d-block mt-1" id="comment-time-${commentId}" style="font-size: 0.72rem;">${formattedTime}</small>
                        </div>
                    `;
                    commentList.appendChild(item);
                }
            })
            .catch(err => {
                console.error("Lỗi gửi bình luận:", err);
                alert("Không thể gửi bình luận, vui lòng thử lại!");
            })
            .finally(() => {
                if (submitBtn) submitBtn.disabled = false;
            });
        });
    });
});

// ==========================================
// 5. CÁC HÀM SỬA & XÓA BÌNH LUẬN (GLOBAL SCOPE)
// ==========================================

function openEditComment(commentId) {
    const textEl = document.getElementById("comment-text-" + commentId);
    const boxEl = document.getElementById("comment-edit-box-" + commentId);
    if (textEl && boxEl) {
        textEl.classList.add("d-none");
        boxEl.classList.remove("d-none");
        const input = document.getElementById("comment-input-" + commentId);
        if (input) input.focus();
    }
}

function cancelEditComment(commentId) {
    const textEl = document.getElementById("comment-text-" + commentId);
    const boxEl = document.getElementById("comment-edit-box-" + commentId);
    if (textEl && boxEl) {
        textEl.classList.remove("d-none");
        boxEl.classList.add("d-none");
    }
}

function saveEditComment(commentId) {
    const inputEl = document.getElementById("comment-input-" + commentId);
    const newContent = inputEl ? inputEl.value.trim() : "";
    if (!newContent) return;

    const formData = new URLSearchParams();
    formData.append("commentId", commentId);
    formData.append("content", newContent);

    fetch("/api/interaction/comment/edit", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: formData
    })
    .then(res => {
        if (!res.ok) throw new Error("HTTP Status: " + res.status);
        return res.json();
    })
    .then(data => {
        if (data.success) {
            const textEl = document.getElementById("comment-text-" + commentId);
            const timeEl = document.getElementById("comment-time-" + commentId);
            if (textEl) textEl.innerText = data.content;
            if (timeEl) timeEl.innerText = data.updatedAt + " (Đã chỉnh sửa)";
            cancelEditComment(commentId);
        }
    })
    .catch(err => {
        console.error("Lỗi sửa bình luận:", err);
        alert("Không thể chỉnh sửa bình luận!");
    });
}

function deleteComment(commentId) {
    if (!confirm("Bạn có chắc chắn muốn xóa bình luận này không?")) return;

    const formData = new URLSearchParams();
    formData.append("commentId", commentId);

    fetch("/api/interaction/comment/delete", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: formData
    })
    .then(res => {
        if (!res.ok) throw new Error("HTTP Status: " + res.status);
        return res.json();
    })
    .then(data => {
        if (data.success) {
            const item = document.getElementById("comment-item-" + commentId);
            if (item) item.remove();
        }
    })
    .catch(err => {
        console.error("Lỗi xóa bình luận:", err);
        alert("Không thể xóa bình luận!");
    });
}

// Hàm mở dropdown thủ công dùng chung (nếu trang nào dùng custom-dropdown-menu)
window.toggleDropdownMenu = function(button, event) {
    if (event) event.stopPropagation();
    const parent = button.parentElement;
    const menu = parent.querySelector('.custom-dropdown-menu, .dropdown-menu');
    if (!menu) return;
    const isShown = menu.classList.contains('show');
    document.querySelectorAll('.custom-dropdown-menu.show, .dropdown-menu.show').forEach(m => m.classList.remove('show'));
    if (!isShown) {
        menu.classList.add('show');
    }
};

document.addEventListener('click', function () {
    document.querySelectorAll('.custom-dropdown-menu.show').forEach(m => m.classList.remove('show'));
});