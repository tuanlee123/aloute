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
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        // 1. Kiểm tra đăng nhập
        if (currentUser == null) {
            // Chuyển hướng về trang đăng nhập kèm thông báo
            response.sendRedirect(request.getContextPath() + "/login?requiredAuth=true");
            return false;
        }

        // 2. Kiểm tra phân quyền truy cập các route quản trị /admin/**
        String uri = request.getRequestURI();
        if (uri.startsWith(request.getContextPath() + "/admin")) {
            boolean isAdmin = currentUser.getRoles().stream()
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