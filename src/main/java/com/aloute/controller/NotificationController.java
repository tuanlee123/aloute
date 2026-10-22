package com.aloute.controller;

import com.aloute.entity.Notification;
import com.aloute.entity.User;
import com.aloute.service.NotificationService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;

import java.util.Collections;
import java.util.List;

@Controller
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    private User getLoggedInUser(HttpSession session) {
        if (session == null) return null;
        User u = (User) session.getAttribute("currentUser");
        return u != null ? u : (User) session.getAttribute("user");
    }

    private boolean isUserAdmin(User user) {
        if (user == null || user.getRoles() == null) return false;
        return user.getRoles().stream()
                .anyMatch(r -> "ROLE_ADMIN".equalsIgnoreCase(r.getName()));
    }

    // 1. Mở trang toàn bộ danh sách thông báo (/notifications)
    @GetMapping("/notifications")
    public String page(HttpSession session, Model model) {
        User user = getLoggedInUser(session);
        if (user == null) return "redirect:/login";

        // Admin không có luồng tương tác bạn bè / thông báo cá nhân
        if (isUserAdmin(user)) {
            model.addAttribute("notifications", Collections.emptyList());
            model.addAttribute("isAdminNotice", true);
            return "notifications";
        }

        List<Notification> list;
        try {
            list = notificationService.getNotifications(user.getId());
        } catch (Exception e) {
            list = notificationService.listAll(user.getId());
        }

        model.addAttribute("notifications", list);
        return "notifications"; // Trỏ đến file /WEB-INF/views/notifications.jsp
    }

    // 2. Click vào 1 thông báo cụ thể: đánh dấu đã đọc và chuyển hướng
    @GetMapping("/notifications/{id}/open")
    public String open(@PathVariable Long id, HttpSession session) {
        User user = getLoggedInUser(session);
        if (user == null) return "redirect:/login";

        if (isUserAdmin(user)) {
            return "redirect:/admin";
        }

        String url = notificationService.openAndMarkRead(id, user.getId());
        if (url == null || !url.startsWith("/")) {
            url = "/post/feed";
        }
        return "redirect:" + url;
    }

    // 3. Đánh dấu tất cả thông báo là đã đọc
    @PostMapping("/notifications/read-all")
    public String readAll(HttpSession session) {
        User user = getLoggedInUser(session);
        if (user != null && !isUserAdmin(user)) {
            try {
                notificationService.markAllAsRead(user.getId());
            } catch (Exception e) {
                notificationService.markAllRead(user.getId());
            }
        }
        return "redirect:/notifications";
    }
}