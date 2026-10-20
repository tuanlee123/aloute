package com.aloute.controller;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.aloute.dto.CommentResponseDTO;
import com.aloute.entity.Comment;
import com.aloute.entity.User;
import com.aloute.repository.CommentRepository;
import com.aloute.service.InteractionService;

import jakarta.servlet.http.HttpSession;

@RestController
@RequestMapping("/api/interaction")
public class InteractionApiController {

    @Autowired
    private InteractionService interactionService;

    @Autowired
    private CommentRepository commentRepository; // Đã thêm CommentRepository

    // Helper lấy userId từ session hoặc fallback ID=1 test tạm
    private Long getCurrentUserId(HttpSession session) {
        User loggedInUser = (User) session.getAttribute("currentUser");
        return (loggedInUser != null) ? loggedInUser.getId() : 1L;
    }

    @PostMapping("/like")
    public ResponseEntity<?> toggleLike(@RequestParam("postId") Long postId, HttpSession session) {
        Long userId = getCurrentUserId(session);
        Map<String, Object> result = interactionService.toggleLike(postId, userId);
        return ResponseEntity.ok(result);
    }

    @PostMapping("/comment")
    public ResponseEntity<?> addComment(
            @RequestParam("postId") Long postId,
            @RequestParam("content") String content,
            HttpSession session) {
        Long userId = getCurrentUserId(session);
        CommentResponseDTO result = interactionService.addComment(postId, userId, content);
        return ResponseEntity.ok(result);
    }

    // 1. Sửa bình luận (đã sửa đường dẫn thành /comment/edit)
    @PostMapping("/comment/edit")
    public ResponseEntity<?> editComment(@RequestParam("commentId") Long commentId,
                                         @RequestParam("content") String content,
                                         HttpSession session) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();

        // Tìm comment và kiểm tra quyền sở hữu
        Comment comment = commentRepository.findById(commentId).orElse(null);
        if (comment == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Không tìm thấy bình luận!");
        }

        if (!comment.getUser().getId().equals(currentUser.getId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Không có quyền sửa!");
        }

        comment.setContent(content);
        // Cập nhật lại thời gian sửa mới nhất
        comment.setCreatedAt(LocalDateTime.now());
        commentRepository.save(comment);

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm dd/MM/yyyy");
        String formattedTime = comment.getCreatedAt().format(formatter);

        return ResponseEntity.ok(Map.of("success", true, "content", content, "updatedAt", formattedTime));
    }

    // 2. Xóa bình luận (đã sửa đường dẫn thành /comment/delete)
    @PostMapping("/comment/delete")
    public ResponseEntity<?> deleteComment(@RequestParam("commentId") Long commentId,
                                           HttpSession session) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();

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