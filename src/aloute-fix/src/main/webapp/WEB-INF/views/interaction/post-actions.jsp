<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- Khối Like / Comment dưới mỗi bài viết. Nhúng bằng:
     <jsp:include page="/WEB-INF/views/interaction/post-actions.jsp">
         <jsp:param name="postId" value="${p.id}"/>
     </jsp:include>
     Dữ liệu (số like, số comment) được JS /js/interaction.js nạp bằng AJAX. --%>
<div class="interaction-bar d-flex align-items-center gap-2 mt-3 pt-2 border-top"
     data-post-id="${param.postId}" data-ctx="${pageContext.request.contextPath}">
    <button type="button" class="btn-like btn btn-light btn-sm rounded-pill px-3">
        <i class="bi bi-heart"></i> <span class="like-count">0</span>
    </button>
    <button type="button" class="btn-comment-toggle btn btn-light btn-sm rounded-pill px-3">
        <i class="bi bi-chat-dots"></i> <span class="comment-count">0</span>
    </button>
</div>

<div class="comment-section d-none mt-2" data-post-id="${param.postId}">
    <div class="comment-list d-flex flex-column gap-2"></div>
    <div class="input-group input-group-sm mt-2">
        <input type="text" class="form-control comment-input rounded-start-pill" maxlength="1000"
               placeholder="Viết bình luận...">
        <button type="button" class="btn btn-primary btn-comment-send rounded-end-pill px-3">Gửi</button>
    </div>
    <div class="comment-error text-danger small mt-1 d-none"></div>
</div>
