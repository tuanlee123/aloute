package com.aloute.controller;

import com.aloute.dto.ConversationItemDTO;
import com.aloute.dto.UteboxMessageDTO;
import com.aloute.entity.User;
import com.aloute.service.UteboxService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.Collections;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/utebox")
public class UteboxApiController {

    @Autowired
    private UteboxService uteboxService;

    private User getAuthenticatedUser(HttpSession session) {
        return (session != null) ? (User) session.getAttribute("currentUser") : null;
    }

    private boolean isUserAdmin(User user) {
        if (user == null || user.getRoles() == null) return false;
        return user.getRoles().stream()
                .anyMatch(r -> "ROLE_ADMIN".equalsIgnoreCase(r.getName()));
    }

    @GetMapping(value = "/subscribe", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public ResponseEntity<SseEmitter> subscribe(HttpSession session) {
        User currentUser = getAuthenticatedUser(session);
        if (currentUser == null) return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        
        // Không đăng ký SSE cho tài khoản Admin
        if (isUserAdmin(currentUser)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        return ResponseEntity.ok(uteboxService.registerUser(currentUser.getId()));
    }

    // Endpoint lấy danh sách đoạn chat cho Dropdown Messenger
    @GetMapping("/conversations")
    public ResponseEntity<?> getConversations(HttpSession session) {
        User currentUser = getAuthenticatedUser(session);
        if (currentUser == null) return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();

        // Admin không có hộp thư tin nhắn cá nhân
        if (isUserAdmin(currentUser)) {
            return ResponseEntity.ok(Collections.emptyList());
        }

        List<ConversationItemDTO> list = uteboxService.getUserConversations(currentUser.getId());
        return ResponseEntity.ok(list);
    }

    @GetMapping("/messages")
    public ResponseEntity<?> getMessages(@RequestParam("partnerId") Long partnerId, HttpSession session) {
        User currentUser = getAuthenticatedUser(session);
        if (currentUser == null) return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Vui lòng đăng nhập!"));

        // Chặn Admin đọc tin nhắn riêng tư của người dùng
        if (isUserAdmin(currentUser)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Tài khoản Quản trị viên không thể tham gia trò chuyện cá nhân!"));
        }

        try {
            List<UteboxMessageDTO> messages = uteboxService.getMessagesSecure(currentUser.getId(), partnerId);
            return ResponseEntity.ok(Map.of("messages", messages));
        } catch (SecurityException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    // Gửi tin nhắn - Chặn hoàn toàn Admin
    @PostMapping("/send")
    public ResponseEntity<?> sendMessage(
            @RequestParam("partnerId") Long partnerId,
            @RequestParam("content") String content,
            HttpSession session) {
        User currentUser = getAuthenticatedUser(session);
        if (currentUser == null) return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Vui lòng đăng nhập!"));

        // CHẶN ADMIN GỬI TIN NHẮN
        if (isUserAdmin(currentUser)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Tài khoản Quản trị viên chỉ có quyền xem, không được gửi tin nhắn!"));
        }

        try {
            UteboxMessageDTO savedMsg = uteboxService.sendMessage(currentUser.getId(), partnerId, content);
            return ResponseEntity.ok(savedMsg);
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.TOO_MANY_REQUESTS).body(Map.of("message", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }
}