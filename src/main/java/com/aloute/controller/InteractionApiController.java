package com.aloute.controller;

import com.aloute.dto.CommentResponseDTO;
import com.aloute.entity.Comment;
import com.aloute.entity.User;
import com.aloute.repository.CommentRepository;
import com.aloute.service.InteractionService;
import jakarta.servlet.http.HttpServletRequest;
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

    // Helper trích xuất User: Ưu tiên lấy từ JWT do AuthInterceptor giải mã, dự phòng HttpSession
    private User getCurrentUser(HttpServletRequest request) {
        if (request == null) return null;

        // 1. Lấy User từ kết quả giải mã Token JWT trong Interceptor
        User user = (User) request.getAttribute("currentUser");
        if (user != null) {
            return user;
        }

        // 2. Dự phòng lấy từ Session nếu request nội bộ chưa qua Interceptor
        HttpSession session = request.getSession(false);
        return (session != null) ? (User) session.getAttribute("currentUser") : null;
    }

    // Helper kiểm tra xem tài khoản có phải Admin không
    private boolean isUserAdmin(User user) {
        if (user == null || user.getRoles() == null) return false;
        return user.getRoles().stream()
                .anyMatch(r -> "ROLE_ADMIN".equalsIgnoreCase(r.getName()));
    }

    // 1. Thả tim (Like / Unlike) - Chặn Admin
    @PostMapping("/like")
    public ResponseEntity<?> toggleLike(@RequestParam("postId") Long postId, HttpServletRequest request) {
        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Bạn chưa đăng nhập!"));
        }

        // CHẶN ADMIN THẢ TIM
        if (isUserAdmin(currentUser)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("message", "Tài khoản Quản trị viên chỉ có quyền xem, không được tương tác!"));
        }

        Map<String, Object> result = interactionService.toggleLike(postId, currentUser.getId());
        return ResponseEntity.ok(result);
    }

    // 2. Gửi bình luận - Chặn Admin
    @PostMapping("/comment")
    public ResponseEntity<?> addComment(
            @RequestParam("postId") Long postId,
            @RequestParam("content") String content,
            HttpServletRequest request) {
        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Bạn chưa đăng nhập!"));
        }

        // CHẶN ADMIN BÌNH LUẬN
        if (isUserAdmin(currentUser)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("message", "Tài khoản Quản trị viên chỉ có quyền xem, không được bình luận!"));
        }

        CommentResponseDTO result = interactionService.addComment(postId, currentUser.getId(), content);
        return ResponseEntity.ok(result);
    }

    // 3. Chỉnh sửa bình luận
    @PostMapping("/comment/edit")
    public ResponseEntity<?> editComment(@RequestParam("commentId") Long commentId,
                                         @RequestParam("content") String content,
                                         HttpServletRequest request) {
        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Bạn chưa đăng nhập!"));
        }

        Comment comment = commentRepository.findById(commentId).orElse(null);
        if (comment == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Không tìm thấy bình luận!");
        }

        // Chỉ chính chủ viết comment mới được sửa (Admin cũng không sửa lời của user)
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

    // 4. Xóa bình luận (Người viết, Chủ bài viết HOẶC ADMIN ĐỀU CÓ QUYỀN XÓA)
    @PostMapping("/comment/delete")
    public ResponseEntity<?> deleteComment(@RequestParam("commentId") Long commentId,
                                           HttpServletRequest request) {
        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Bạn chưa đăng nhập!"));
        }

        Comment comment = commentRepository.findById(commentId).orElse(null);
        if (comment == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Không tìm thấy bình luận!");
        }

        boolean isAuthor = comment.getUser().getId().equals(currentUser.getId());
        boolean isPostOwner = comment.getPost().getUser().getId().equals(currentUser.getId());
        boolean isAdmin = isUserAdmin(currentUser);

        // Cho phép người viết comment, chủ bài viết HOẶC ADMIN xóa vi phạm
        if (!isAuthor && !isPostOwner && !isAdmin) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Không có quyền xóa!");
        }

        commentRepository.delete(comment);
        return ResponseEntity.ok(Map.of("success", true));
    }
}