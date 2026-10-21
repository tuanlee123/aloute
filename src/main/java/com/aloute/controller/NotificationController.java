package com.aloute.controller;

import com.aloute.entity.User;
import com.aloute.service.NotificationService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;

@Controller
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping("/notifications")
    public String page(HttpSession session, Model model) {
        User user = (User) session.getAttribute("currentUser");
        model.addAttribute("notifications", notificationService.listAll(user.getId()));
        return "notification/notifications";
    }

    /** Bấm vào 1 thông báo: đổi isRead = true rồi nhảy tới bài viết. */
    @GetMapping("/notifications/{id}/open")
    public String open(@PathVariable Long id, HttpSession session) {
        User user = (User) session.getAttribute("currentUser");
        String url = notificationService.openAndMarkRead(id, user.getId());
        // chỉ cho phép chuyển hướng nội bộ
        if (url == null || !url.startsWith("/")) url = "/post/feed";
        return "redirect:" + url;
    }

    @PostMapping("/notifications/read-all")
    public String readAll(HttpSession session) {
        User user = (User) session.getAttribute("currentUser");
        notificationService.markAllRead(user.getId());
        return "redirect:/notifications";
    }
}
