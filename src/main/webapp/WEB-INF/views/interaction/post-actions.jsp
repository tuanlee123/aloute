<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Xác định ID bài viết linh hoạt theo param hoặc object --%>
<c:set var="targetPostId" value="${not empty param.postId ? param.postId : (not empty post ? post.id : p.id)}" />
<c:set var="targetPost" value="${not empty post ? post : p}" />

<!-- Nút Thích & Số lượt thích -->
<div class="d-flex align-items-center my-2">
    <button type="button" class="btn btn-sm btn-outline-danger btn-like rounded-pill px-3" data-post-id="${targetPostId}">
        <i class="far fa-heart me-1"></i>
        Thích (<span class="like-count">${not empty targetPost && targetPost.likes != null ? targetPost.likes.size() : 0}</span>)
    </button>
</div>

<!-- Danh sách Comment hiện có -->
<div id="comment-list-${targetPostId}" class="mt-3">
    <c:if test="${not empty targetPost && not empty targetPost.comments}">
        <c:forEach items="${targetPost.comments}" var="c">
            <div class="d-flex align-items-start mb-2 comment-item" id="comment-item-${c.id}">
                <a href="${pageContext.request.contextPath}/profile?userId=${c.user.id}" class="text-decoration-none">
                    <img src="${c.user.avatar != null && !c.user.avatar.isEmpty() ? c.user.avatar : 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg'}" 
                         class="rounded-circle me-2 border" 
                         width="32" 
                         height="32" 
                         style="object-fit: cover;" 
                         alt="Avatar">
                </a>
                <div class="bg-light p-2 rounded-3 flex-grow-1 position-relative">
                    <div class="d-flex justify-content-between align-items-center">
                        <a href="${pageContext.request.contextPath}/profile?userId=${c.user.id}" class="text-dark fw-bold text-decoration-none" style="font-size: 0.85rem;">
                            <c:out value="${c.user.fullName != null ? c.user.fullName : c.user.username}" />
                        </a>
                        <c:if test="${sessionScope.currentUser != null && sessionScope.currentUser.id == c.user.id}">
                            <div class="dropdown">
                                <button class="btn btn-link text-muted p-0 border-0 text-decoration-none" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                    <i class="bi bi-three-dots-vertical" style="font-size: 1rem;"></i>
                                </button>
                                <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0 py-1" style="font-size: 0.85rem; z-index: 1060;">
                                    <li><a class="dropdown-item py-1" href="javascript:void(0)" onclick="openEditComment(${c.id})"><i class="bi bi-pencil me-2 text-primary"></i>Chỉnh sửa</a></li>
                                    <li><a class="dropdown-item py-1 text-danger" href="javascript:void(0)" onclick="deleteComment(${c.id})"><i class="bi bi-trash me-2"></i>Xóa</a></li>
                                </ul>
                            </div>
                        </c:if>
                    </div>
                    <div id="comment-text-${c.id}" class="text-secondary" style="font-size: 0.9rem;">
                        <c:out value="${c.content}" />
                    </div>
                    <div id="comment-edit-box-${c.id}" class="d-none mt-2">
                        <input type="text" class="form-control form-control-sm mb-1" id="comment-input-${c.id}" value="${c.content}">
                        <button class="btn btn-sm btn-primary rounded-pill px-2 py-0" onclick="saveEditComment(${c.id})">Lưu</button>
                        <button class="btn btn-sm btn-light rounded-pill px-2 py-0" onclick="cancelEditComment(${c.id})">Hủy</button>
                    </div>
                    <small class="text-muted d-block mt-1" id="comment-time-${c.id}" style="font-size: 0.72rem;">${c.createdAt}</small>
                </div>
            </div>
        </c:forEach>
    </c:if>
</div>

<!-- Ô nhập Comment -->
<form class="form-comment mt-2 d-flex gap-2" data-post-id="${targetPostId}">
    <input type="text" class="form-control form-control-sm rounded-pill input-comment px-3" placeholder="Viết bình luận..." required autocomplete="off" />
    <button type="submit" class="btn btn-sm btn-primary rounded-pill px-3">Gửi</button>
</form>