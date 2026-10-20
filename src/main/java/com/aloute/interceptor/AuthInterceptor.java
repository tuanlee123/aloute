package com.aloute.interceptor;

import com.aloute.entity.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class AuthInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // 1. CẤM TRÌNH DUYỆT LƯU CACHE CÁC TRANG NỘI BỘ
        // Giúp nút Back của trình duyệt bắt buộc phải hỏi lại Server thay vì lấy lại ảnh cũ trong RAM
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
        response.setHeader("Pragma", "no-cache"); // HTTP 1.0
        response.setDateHeader("Expires", 0); // Proxies

        // 2. Kiểm tra Session hiện tại (không tự động tạo mới nếu không có)
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        // 3. Nếu chưa đăng nhập -> Chuyển hướng về trang đăng nhập
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login?requiredAuth=true");
            return false;
        }

        // 4. Kiểm tra phân quyền truy cập các route quản trị /admin/**
        String uri = request.getRequestURI();
        if (uri.startsWith(request.getContextPath() + "/admin")) {
            boolean isAdmin = currentUser.getRoles() != null && currentUser.getRoles().stream()
                    .anyMatch(role -> "ROLE_ADMIN".equals(role.getName()));

            if (!isAdmin) {
                // Không có quyền Admin -> điều hướng về trang chủ
                response.sendRedirect(request.getContextPath() + "/?forbidden=true");
                return false;
            }
        }

        return true;
    }
}