package com.aloute.controller;

import com.aloute.entity.User;
import com.aloute.service.NotificationService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collections;
import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationApiController {

    private final NotificationService notificationService;

    private boolean isUserAdmin(User user) {
        if (user == null || user.getRoles() == null) return false;
        return user.getRoles().stream()
                .anyMatch(r -> "ROLE_ADMIN".equalsIgnoreCase(r.getName()));
    }

    @GetMapping
    public ResponseEntity<?> list(HttpSession session) {
        User user = (User) session.getAttribute("currentUser");
        if (user == null) return ResponseEntity.status(401).build();

        // Tài khoản Quản trị viên không nhận thông báo tương tác mạng xã hội
        if (isUserAdmin(user)) {
            return ResponseEntity.ok(Map.of(
                    "unread", 0,
                    "items", Collections.emptyList()
            ));
        }

        return ResponseEntity.ok(Map.of(
                "unread", notificationService.countUnread(user.getId()),
                "items", notificationService.latest(user.getId())
        ));
    }
}