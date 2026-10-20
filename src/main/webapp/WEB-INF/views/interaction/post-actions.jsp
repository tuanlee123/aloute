<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- Nút Thích & Số lượt thích -->
<div class="d-flex align-items-center my-2">
    <button type="button" class="btn btn-sm btn-outline-secondary btn-like me-2 mr-2" data-post-id="${post.id}">
        <i class="far fa-heart"></i>
        Thích (<span class="like-count">${post.likes != null ? post.likes.size() : 0}</span>)
    </button>
</div>

<!-- Danh sách Comment hiện có -->
<div id="comment-list-${post.id}" class="mt-3">
    <c:forEach items="${post.comments}" var="c">
        <div class="d-flex align-items-start mb-2 comment-item">
            <img src="${c.user.avatar != null && !c.user.avatar.isEmpty() ? c.user.avatar : '/images/default-avatar.png'}" 
                 class="rounded-circle mr-2 me-2" 
                 width="32" 
                 height="32" 
                 style="object-fit: cover;" 
                 alt="Avatar">
            <div class="bg-light p-2 rounded flex-grow-1" style="border-radius: 12px;">
                <strong class="d-block" style="font-size: 0.9rem;">
                    <c:out value="${c.user.fullName != null ? c.user.fullName : c.user.username}" />
                </strong>
                <span style="font-size: 0.95rem;">
                    <c:out value="${c.content}" />
                </span>
            </div>
        </div>
    </c:forEach>
</div>

<!-- Ô nhập Comment -->
<form class="form-comment mt-2 d-flex" data-post-id="${post.id}">
    <input type="text" class="form-control form-control-sm mr-2 me-2 input-comment" placeholder="Viết bình luận..." required autocomplete="off" />
    <button type="submit" class="btn btn-sm btn-primary">Gửi</button>
</form>