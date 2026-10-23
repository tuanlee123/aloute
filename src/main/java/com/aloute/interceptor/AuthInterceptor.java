package com.aloute.interceptor;

import com.aloute.entity.User;
import com.aloute.jwt.JwtUtils;
import com.aloute.listener.ActiveUserListener;
import com.aloute.repository.UserRepository;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@Component
@RequiredArgsConstructor
public class AuthInterceptor implements HandlerInterceptor {

    private final UserRepository userRepository;
    private final JwtUtils jwtUtils;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // 1. CẤM TRÌNH DUYỆT LƯU CACHE CÁC TRANG NỘI BỘ
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        // 2. TRÍCH XUẤT VÀ KIỂM TRA MÃ JWT TOKEN
        String token = jwtUtils.resolveToken(request);

        // Nếu không có Token hoặc Token hết hạn/bị giả mạo -> Hủy phiên và yêu cầu đăng nhập
        if (token == null || !jwtUtils.validateToken(token)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            jwtUtils.deleteJwtCookie(response);
            response.sendRedirect(request.getContextPath() + "/login?requiredAuth=true");
            return false;
        }

        // 3. GIẢI MÃ LẤY ID TỪ JWT VÀ TRUY VẤN DATABASE
        Long userId = jwtUtils.getUserIdFromToken(token);
        String username = jwtUtils.getUsernameFromToken(token);

        User dbUser = null;
        if (userId != null) {
            dbUser = userRepository.findById(userId).orElse(null);
        } else if (username != null) {
            dbUser = userRepository.findByUsername(username).orElse(null);
        }

        // 4. KIỂM TRA TRẠNG THÁI KHÓA TỨC THÌ (ADMIN VỪA BẤM KHÓA)
        if (dbUser == null || Boolean.FALSE.equals(dbUser.getActive())) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                User currentUser = (User) session.getAttribute("currentUser");
                if (currentUser != null) {
                    ActiveUserListener.userLoggedOut(currentUser);
                }
                session.removeAttribute("currentUser");
                session.removeAttribute("isAdminUser");
                session.invalidate();
            }

            // Xóa Cookie JSESSIONID
            Cookie cookie = new Cookie("JSESSIONID", null);
            cookie.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath());
            cookie.setHttpOnly(true);
            cookie.setMaxAge(0);
            response.addCookie(cookie);

            // Xóa Cookie JWT
            jwtUtils.deleteJwtCookie(response);

            // Đẩy văng về trang đăng nhập kèm thông báo
            String errorMsg = URLEncoder.encode("Tài khoản của bạn đã bị khóa bởi Quản trị viên!", StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/login?error=" + errorMsg);
            return false;
        }

        // 5. ĐỒNG BỘ SESSION ĐỂ GIAO DIỆN JSP / JSTL HOẠT ĐỘNG LIỀN MẠCH
        HttpSession session = request.getSession(true);
        session.setAttribute("currentUser", dbUser);
        boolean isAdmin = dbUser.getRoles() != null && dbUser.getRoles().stream()
                .anyMatch(role -> "ROLE_ADMIN".equalsIgnoreCase(role.getName()));
        session.setAttribute("isAdminUser", isAdmin);

        // 6. KIỂM TRA PHÂN QUYỀN TRUY CẬP ROUTE QUẢN TRỊ /admin/**
        String uri = request.getRequestURI();
        if (uri.startsWith(request.getContextPath() + "/admin")) {
            if (!isAdmin) {
                response.sendRedirect(request.getContextPath() + "/?forbidden=true");
                return false;
            }
        }

        return true;
    }
}