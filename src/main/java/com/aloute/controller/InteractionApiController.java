package com.aloute.controller;

import com.aloute.entity.User;
import com.aloute.service.InteractionService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * REST API cho Like / Comment (gọi bằng AJAX). Trả về JSON.
 * Đường dẫn /api/** đã được SiteMesh loại trừ nên không bị bọc layout.
 */
@RestController
@RequestMapping("/api/posts")
@RequiredArgsConstructor
public class InteractionApiController {

    private final InteractionService interactionService;

    public record CommentRequest(String content) {
    }

    /** Lấy user đang đăng nhập từ session (AuthController lưu với key "currentUser"). */
    private User currentUser(HttpSession session) {
        return session == null ? null : (User) session.getAttribute("currentUser");
    }

    private ResponseEntity<Map<String, Object>> unauthorized() {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Bạn chưa đăng nhập!"));
    }

    private ResponseEntity<Map<String, Object>> badRequest(String message) {
        return ResponseEntity.badRequest().body(Map.of("message", message));
    }

    // POST /api/posts/{postId}/like  -> {"liked":true,"likeCount":5}
    @PostMapping("/{postId}/like")
    public ResponseEntity<?> toggleLike(@PathVariable("postId") Long postId, HttpSession session) {
        User user = currentUser(session);
        if (user == null) return unauthorized();
        try {
            return ResponseEntity.ok(interactionService.toggleLike(postId, user.getId()));
        } catch (IllegalArgumentException e) {
            return badRequest(e.getMessage());
        }
    }

    // GET /api/posts/stats?ids=1,2,3 -> {"1":{"likeCount":..,"liked":..,"commentCount":..}, ...}
    @GetMapping("/stats")
    public ResponseEntity<?> stats(@RequestParam("ids") String ids, HttpSession session) {
        User user = currentUser(session);
        if (user == null) return unauthorized();

        List<Long> postIds = new ArrayList<>();
        for (String s : ids.split(",")) {
            try {
                postIds.add(Long.parseLong(s.trim()));
            } catch (NumberFormatException ignored) {
                // bỏ qua id sai định dạng
            }
        }
        return ResponseEntity.ok(interactionService.getStats(postIds, user.getId()));
    }

    // GET /api/posts/{postId}/comments -> danh sách bình luận (cũ -> mới)
    @GetMapping("/{postId}/comments")
    public ResponseEntity<?> comments(@PathVariable("postId") Long postId, HttpSession session) {
        if (currentUser(session) == null) return unauthorized();
        return ResponseEntity.ok(interactionService.getComments(postId));
    }

    // POST /api/posts/{postId}/comments  body: {"content":"..."} -> bình luận vừa tạo
    @PostMapping("/{postId}/comments")
    public ResponseEntity<?> addComment(@PathVariable("postId") Long postId,
                                        @RequestBody CommentRequest request,
                                        HttpSession session) {
        User user = currentUser(session);
        if (user == null) return unauthorized();
        try {
            return ResponseEntity.ok(interactionService.addComment(postId, user.getId(), request.content()));
        } catch (IllegalArgumentException e) {
            return badRequest(e.getMessage());
        }
    }
}
