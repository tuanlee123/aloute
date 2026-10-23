package com.aloute.interceptor;

import com.aloute.entity.User;
import com.aloute.jwt.JwtUtils;
import com.aloute.listener.ActiveUserListener;
import com.aloute.repository.UserRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;

@Component
@RequiredArgsConstructor
public class AuthInterceptor implements HandlerInterceptor {

    private final UserRepository userRepository;
    private final JwtUtils jwtUtils;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        String uri = request.getRequestURI();
        boolean isApiRequest = uri.startsWith(request.getContextPath() + "/api/");

        String accessToken = jwtUtils.resolveAccessToken(request);
        User verifiedUser = null;

        // 1. Kiểm tra Access Token trước
        if (accessToken != null && jwtUtils.validateToken(accessToken)) {
            Long userId = jwtUtils.getUserIdFromToken(accessToken);
            if (userId != null) {
                verifiedUser = userRepository.findById(userId).orElse(null);
            }
        }

        // 2. Nếu Access Token hết hạn -> Tự động dùng Refresh Token để phục hồi phiên
        if (verifiedUser == null) {
            String refreshToken = jwtUtils.resolveRefreshToken(request);
            if (refreshToken != null && jwtUtils.validateToken(refreshToken)) {
                Long userId = jwtUtils.getUserIdFromToken(refreshToken);
                if (userId != null) {
                    User dbUser = userRepository.findById(userId).orElse(null);
                    // Đối chiếu token trong DB và kiểm tra hạn sử dụng
                    if (dbUser != null && refreshToken.equals(dbUser.getRefreshToken())
                            && dbUser.getRefreshTokenExpiryTime() != null
                            && dbUser.getRefreshTokenExpiryTime().isAfter(LocalDateTime.now())) {
                        
                        verifiedUser = dbUser;
                        // Tự động cấp Access Token mới
                        String newAccessToken = jwtUtils.generateAccessToken(verifiedUser);
                        jwtUtils.addAuthCookies(response, newAccessToken, refreshToken);
                        response.setHeader("X-New-Access-Token", newAccessToken);
                    }
                }
            }
        }

        // 3. Nếu không xác thực được bất kỳ token nào
        if (verifiedUser == null) {
            handleUnauthorized(request, response, isApiRequest);
            return false;
        }

        // 4. Kiểm tra tài khoản có bị khóa không
        if (Boolean.FALSE.equals(verifiedUser.getActive())) {
            ActiveUserListener.userLoggedOut(verifiedUser);
            jwtUtils.deleteAllAuthCookies(response);
            if (isApiRequest) {
                response.setStatus(HttpStatus.FORBIDDEN.value());
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"message\":\"Tài khoản của bạn đã bị khóa!\"}");
            } else {
                String errorMsg = URLEncoder.encode("Tài khoản của bạn đã bị khóa bởi Quản trị viên!", StandardCharsets.UTF_8);
                response.sendRedirect(request.getContextPath() + "/login?error=" + errorMsg);
            }
            return false;
        }

        // 5. ĐỒNG BỘ ĐỂ API VÀ JSP DÙNG ĐƯỢC CẢ HAI
        // Gán vào request attribute để API Controller đọc trực tiếp từ JWT (không phụ thuộc session)
        request.setAttribute("currentUser", verifiedUser);

        // Vẫn giữ vào Session để các taglib JSTL trên JSP hiển thị bình thường
        HttpSession session = request.getSession(true);
        session.setAttribute("currentUser", verifiedUser);
        boolean isAdmin = verifiedUser.getRoles() != null && verifiedUser.getRoles().stream()
                .anyMatch(r -> "ROLE_ADMIN".equalsIgnoreCase(r.getName()));
        session.setAttribute("isAdminUser", isAdmin);

        // 6. Phân quyền route Admin
        if (uri.startsWith(request.getContextPath() + "/admin") && !isAdmin) {
            if (isApiRequest) {
                response.setStatus(HttpStatus.FORBIDDEN.value());
                return false;
            }
            response.sendRedirect(request.getContextPath() + "/?forbidden=true");
            return false;
        }

        return true;
    }

    private void handleUnauthorized(HttpServletRequest request, HttpServletResponse response, boolean isApiRequest) throws Exception {
        jwtUtils.deleteAllAuthCookies(response);
        if (isApiRequest) {
            response.setStatus(HttpStatus.UNAUTHORIZED.value());
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"message\":\"Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại!\"}");
        } else {
            response.sendRedirect(request.getContextPath() + "/login?requiredAuth=true");
        }
    }
}