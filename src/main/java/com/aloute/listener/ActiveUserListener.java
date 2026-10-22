package com.aloute.listener;

import com.aloute.entity.User;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class ActiveUserListener implements Filter {

    // Map lưu: userId -> timestamp hoạt động cuối cùng
    private static final Map<Long, Long> activeUserHeartbeat = new ConcurrentHashMap<>();

    // Sau 5 phút không tương tác -> tự động tính là Offline
    private static final long TIMEOUT_MILLIS = 5 * 60 * 1000;

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpSession session = req.getSession(false);

        if (session != null) {
            User user = (User) session.getAttribute("currentUser");
            if (user != null && user.getId() != null) {
                boolean isAdmin = user.getRoles() != null && user.getRoles().stream()
                        .anyMatch(r -> "ROLE_ADMIN".equalsIgnoreCase(r.getName()));

                // Chỉ ghi nhận User thường, tuyệt đối không tính Admin
                if (!isAdmin) {
                    activeUserHeartbeat.put(user.getId(), System.currentTimeMillis());
                }
            }
        }

        chain.doFilter(request, response);
    }

    // Đếm số lượng User thường đang thực sự trực tuyến
    public static int getActiveUsersCount() {
        cleanUpExpiredUsers();
        return activeUserHeartbeat.size();
    }

    // Lấy danh sách ID user đang trực tuyến để đối chiếu trong bảng
    public static Set<Long> getOnlineUserIds() {
        cleanUpExpiredUsers();
        return activeUserHeartbeat.keySet();
    }

    // Kiểm tra 1 User cụ thể có đang online không
    public static boolean isUserOnline(Long userId) {
        cleanUpExpiredUsers();
        return userId != null && activeUserHeartbeat.containsKey(userId);
    }

    // Gọi khi User bấm Đăng xuất
    public static void userLoggedOut(User user) {
        if (user != null && user.getId() != null) {
            activeUserHeartbeat.remove(user.getId());
        }
    }

    // Xóa những User đã tắt trình duyệt hoặc không hoạt động quá thời gian timeout
    private static void cleanUpExpiredUsers() {
        long now = System.currentTimeMillis();
        activeUserHeartbeat.entrySet().removeIf(entry -> (now - entry.getValue()) > TIMEOUT_MILLIS);
    }
}