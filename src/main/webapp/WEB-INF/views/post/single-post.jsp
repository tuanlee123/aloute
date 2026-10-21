<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<head>
    <title>Bài viết của ${post.user.fullName != null ? post.user.fullName : post.user.username} | ALOUTE</title>
</head>

<div class="container my-4" style="max-width: 680px;">
    <!-- Nút quay lại bảng tin -->
    <div class="mb-3">
        <a href="<c:url value='/post/feed'/>" class="btn btn-light rounded-pill px-3 fw-semibold border shadow-sm">
            <i class="bi bi-arrow-left me-1"></i> Quay lại Bảng tin
        </a>
    </div>

    <!-- Khung hiển thị chi tiết bài viết -->
    <div class="card shadow-sm border-0 rounded-3" id="post-card-${post.id}">
        <div class="card-body">
            <!-- Header bài viết -->
            <div class="d-flex align-items-center mb-3">
                <a href="${pageContext.request.contextPath}/profile?userId=${post.user.id}">
                    <img src="${empty post.user.avatar ? 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg' : post.user.avatar}"
                         class="rounded-circle me-3 border" width="46" height="46" style="object-fit: cover;">
                </a>
                <div>
                    <a href="${pageContext.request.contextPath}/profile?userId=${post.user.id}" class="text-decoration-none fw-bold text-dark d-block">
                        ${post.user.fullName != null ? post.user.fullName : post.user.username}
                    </a>
                    <div class="d-flex align-items-center gap-1 text-muted small" style="font-size: 0.82rem;">
                        <span>${post.createdAt}</span> <span>·</span>
                        <c:choose>
                            <c:when test="${post.privacy == 'PRIVATE'}">
                                <i class="bi bi-lock-fill" title="Chỉ mình tôi"></i>
                            </c:when>
                            <c:when test="${post.privacy == 'FRIENDS'}">
                                <i class="bi bi-people-fill" title="Bạn bè"></i>
                            </c:when>
                            <c:otherwise>
                                <i class="bi bi-globe-americas" title="Công khai"></i>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- Nội dung bài viết -->
            <p class="card-text text-dark mb-3 fs-6" style="white-space: pre-line;"><c:out value="${post.content}" /></p>

            <!-- Ảnh đính kèm (nếu có) -->
            <c:if test="${not empty post.images}">
                <div class="d-flex flex-column gap-2 mb-3">
                    <c:forEach var="img" items="${post.images}">
                        <img src="${img.imageUrl}" class="w-100 rounded-3 border" style="max-height: 550px; object-fit: cover;">
                    </c:forEach>
                </div>
            </c:if>

            <!-- Tương tác: Thích & Chia sẻ -->
            <div class="d-flex justify-content-between align-items-center pt-2 border-top">
                <button type="button" class="btn btn-sm btn-outline-danger btn-like rounded-pill px-3" data-post-id="${post.id}">
                    <i class="far fa-heart me-1"></i> Thích (<span class="like-count">${post.likes != null ? post.likes.size() : 0}</span>)
                </button>
                <span class="text-muted small" id="share-count-${post.id}">
                    ${not empty post.shareCount ? post.shareCount : 0} lượt chia sẻ 
                </span>
            </div>

            <!-- DANH SÁCH BÌNH LUẬN (ĐÃ BỔ SUNG HIỂN THỊ THỜI GIAN) -->
            <div id="comment-list-${post.id}" class="mt-3 pt-2 border-top">
                <c:forEach items="${post.comments}" var="c">
                    <div class="d-flex align-items-start mb-2 comment-item" id="comment-item-${c.id}">
                        <a href="${pageContext.request.contextPath}/profile?userId=${c.user.id}">
                            <img src="${c.user.avatar != null && !c.user.avatar.isEmpty() ? c.user.avatar : 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg'}"
                                 class="rounded-circle me-2 border" width="32" height="32" style="object-fit: cover;">
                        </a>
                        <div class="bg-light p-2 rounded-3 flex-grow-1">
                            <a href="${pageContext.request.contextPath}/profile?userId=${c.user.id}" class="text-dark fw-bold text-decoration-none" style="font-size: 0.85rem;">
                                ${c.user.fullName != null ? c.user.fullName : c.user.username}
                            </a>
                            <div class="text-secondary small mt-1">
                                <c:out value="${c.content}" />
                            </div>
                            <!-- THỜI GIAN BÌNH LUẬN -->
                            <small class="text-muted d-block mt-1" style="font-size: 0.72rem;">
                                ${c.createdAt}
                            </small>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <!-- Ô nhập bình luận -->
            <form class="form-comment mt-3 d-flex gap-2" data-post-id="${post.id}" onsubmit="handleSinglePostComment(event, ${post.id})">
                <input type="text" id="commentInput-${post.id}" class="form-control form-control-sm rounded-pill input-comment px-3"
                       placeholder="Viết bình luận..." required autocomplete="off" />
                <button type="submit" class="btn btn-sm btn-primary rounded-pill px-3">Gửi</button>
            </form>
        </div>
    </div>
</div>

<script src="<c:url value='/js/interaction.js' />"></script>

<script>
    // 1. Xử lý Thích/Bỏ thích tức thì không cần reload
    document.addEventListener("DOMContentLoaded", function () {
        const likeBtn = document.querySelector('.btn-like');
        if (likeBtn) {
            likeBtn.addEventListener('click', function (e) {
                e.preventDefault();
                const postId = this.getAttribute('data-post-id');
                const countSpan = this.querySelector('.like-count');
                const icon = this.querySelector('i');

                fetch('${pageContext.request.contextPath}/post/like/' + postId, {
                    method: 'POST'
                })
                .then(res => res.json())
                .then(data => {
                    if (countSpan && data.likeCount !== undefined) {
                        countSpan.innerText = data.likeCount;
                    }
                    if (data.isLiked) {
                        icon.classList.remove('far');
                        icon.classList.add('fas');
                        likeBtn.classList.remove('btn-outline-danger');
                        likeBtn.classList.add('btn-danger', 'text-white');
                    } else {
                        icon.classList.remove('fas');
                        icon.classList.add('far');
                        likeBtn.classList.remove('btn-danger', 'text-white');
                        likeBtn.classList.add('btn-outline-danger');
                    }
                })
                .catch(err => console.error("Lỗi khi thích:", err));
            });
        }
    });

    // 2. Gửi bình luận và chèn vào DOM kèm thời gian ngay lập tức
    function handleSinglePostComment(e, postId) {
        e.preventDefault();
        const input = document.getElementById('commentInput-' + postId);
        const content = input.value.trim();
        if (!content) return;

        const params = new URLSearchParams();
        params.append('content', content);

        fetch('${pageContext.request.contextPath}/post/comment/' + postId, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params
        })
        .then(res => res.json())
        .then(comment => {
            input.value = '';
            const list = document.getElementById('comment-list-' + postId);
            
            const item = document.createElement('div');
            item.className = 'd-flex align-items-start mb-2 comment-item';
            
            const avatar = comment.userAvatar || 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg';
            const name = comment.userName || 'Bạn';
            const time = comment.createdAt || 'Vừa xong';

            item.innerHTML = `
                <img src="\${avatar}" class="rounded-circle me-2 border" width="32" height="32" style="object-fit: cover;">
                <div class="bg-light p-2 rounded-3 flex-grow-1">
                    <span class="fw-bold text-dark small">\${name}</span>
                    <div class="text-secondary small mt-1"></div>
                    <small class="text-muted d-block mt-1" style="font-size: 0.72rem;">\${time}</small>
                </div>
            `;
            item.querySelector('.text-secondary').textContent = comment.content;
            list.appendChild(item);
        })
        .catch(err => console.error("Lỗi bình luận:", err));
    }
</script>