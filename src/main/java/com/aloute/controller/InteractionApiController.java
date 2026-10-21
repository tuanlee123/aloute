package com.aloute.controller;

import com.aloute.dto.CommentResponseDTO;
import com.aloute.entity.Comment;
import com.aloute.entity.User;
import com.aloute.repository.CommentRepository;
import com.aloute.service.InteractionService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;

@RestController
@RequestMapping("/api/interaction")
public class InteractionApiController {

    @Autowired
    private InteractionService interactionService;

    @Autowired
    private CommentRepository commentRepository;

    // Helper kiểm tra và lấy userId từ session
    private Long getCurrentUserId(HttpSession session) {
        User loggedInUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        return (loggedInUser != null) ? loggedInUser.getId() : null;
    }

    // 1. Thả tim (Like / Unlike)
    @PostMapping("/like")
    public ResponseEntity<?> toggleLike(@RequestParam("postId") Long postId, HttpSession session) {
        Long userId = getCurrentUserId(session);
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Bạn chưa đăng nhập!"));
        }
        Map<String, Object> result = interactionService.toggleLike(postId, userId);
        return ResponseEntity.ok(result);
    }

    // 2. Gửi bình luận
    @PostMapping("/comment")
    public ResponseEntity<?> addComment(
            @RequestParam("postId") Long postId,
            @RequestParam("content") String content,
            HttpSession session) {
        Long userId = getCurrentUserId(session);
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Bạn chưa đăng nhập!"));
        }
        CommentResponseDTO result = interactionService.addComment(postId, userId, content);
        return ResponseEntity.ok(result);
    }

    // 3. Chỉnh sửa bình luận
    @PostMapping("/comment/edit")
    public ResponseEntity<?> editComment(@RequestParam("commentId") Long commentId,
                                         @RequestParam("content") String content,
                                         HttpSession session) {
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Bạn chưa đăng nhập!"));
        }

        Comment comment = commentRepository.findById(commentId).orElse(null);
        if (comment == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Không tìm thấy bình luận!");
        }

        if (!comment.getUser().getId().equals(currentUser.getId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Không có quyền sửa!");
        }

        comment.setContent(content);
        comment.setCreatedAt(LocalDateTime.now());
        commentRepository.save(comment);

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm dd/MM/yyyy");
        String formattedTime = comment.getCreatedAt().format(formatter);

        return ResponseEntity.ok(Map.of("success", true, "content", content, "updatedAt", formattedTime));
    }

    // 4. Xóa bình luận
    @PostMapping("/comment/delete")
    public ResponseEntity<?> deleteComment(@RequestParam("commentId") Long commentId,
                                           HttpSession session) {
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Bạn chưa đăng nhập!"));
        }

        Comment comment = commentRepository.findById(commentId).orElse(null);
        if (comment == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Không tìm thấy bình luận!");
        }

        // Cho phép người viết comment HOẶC chủ bài viết xóa
        if (!comment.getUser().getId().equals(currentUser.getId()) && 
            !comment.getPost().getUser().getId().equals(currentUser.getId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Không có quyền xóa!");
        }

        commentRepository.delete(comment);
        return ResponseEntity.ok(Map.of("success", true));
    }
}