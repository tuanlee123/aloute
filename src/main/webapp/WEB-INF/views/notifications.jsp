<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<head>
    <title>Thông báo | ALOUTE</title>
    <style>
        .notification-item {
            transition: background-color 0.15s ease;
        }
        .notification-item:hover {
            background-color: #f2f4f7 !important;
        }
        .notif-unread {
            background-color: #e7f3ff;
        }
        .notif-dot-unread {
            width: 10px;
            height: 10px;
            background-color: #1877f2;
            border-radius: 50%;
            flex-shrink: 0;
        }
    </style>
</head>

<div class="container my-4" style="max-width: 680px;">
    <div class="card border-0 shadow-sm rounded-4">
        <div class="card-header bg-white border-0 py-3 d-flex justify-content-between align-items-center">
            <h4 class="fw-bold mb-0 text-dark">
                <i class="bi bi-bell-fill text-warning me-2"></i>Thông báo
            </h4>
        </div>
        <div class="card-body pt-0">
            <c:choose>
                <c:when test="${not empty notifications}">
                    <div class="d-flex flex-column gap-2">
                        <c:forEach var="n" items="${notifications}">
                            <a href="<c:url value='${not empty n.targetUrl ? n.targetUrl : "#"}'/>" 
                               class="notification-item d-flex align-items-center gap-3 p-3 text-decoration-none rounded-3 border-bottom ${!n.isRead ? 'notif-unread' : 'bg-white'}">
                                <img src="${not empty n.sender.avatar ? n.sender.avatar : 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg'}" 
                                     class="rounded-circle border" width="52" height="52" style="object-fit: cover;" alt="Avatar">
                                <div class="flex-grow-1">
                                    <div class="text-dark ${!n.isRead ? 'fw-bold' : ''}" style="line-height: 1.35;">
                                        <c:out value="${n.content}" />
                                    </div>
                                    <div class="text-muted small mt-1">
                                        <i class="bi bi-clock me-1"></i>${n.createdAt}
                                    </div>
                                </div>
                                <c:if test="${!n.isRead}">
                                    <span class="notif-dot-unread" title="Chưa đọc"></span>
                                </c:if>
                            </a>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="text-center py-5 text-muted">
                        <i class="bi bi-bell-slash fs-1 opacity-50 d-block mb-2"></i>
                        <p class="mb-0 fw-semibold">Bạn không có thông báo nào</p>
                        <small>Khi có tương tác mới hoặc lời mời kết bạn, thông báo sẽ hiển thị ở đây.</small>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>