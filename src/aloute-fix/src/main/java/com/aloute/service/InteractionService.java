package com.aloute.service;

import com.aloute.entity.Comment;
import com.aloute.entity.Like;
import com.aloute.entity.Post;
import com.aloute.entity.User;
import com.aloute.repository.CommentRepository;
import com.aloute.repository.LikeRepository;
import com.aloute.repository.PostRepository;
import com.aloute.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Xử lý Like và Comment (Bạn 3 - feature/social-interaction).
 */
@Service
@RequiredArgsConstructor
public class InteractionService {

    private static final String DEFAULT_AVATAR =
            "https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg";
    private static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private static final int MAX_COMMENT_LENGTH = 1000;

    private final LikeRepository likeRepository;
    private final CommentRepository commentRepository;
    private final PostRepository postRepository;
    private final UserRepository userRepository;

    /** Dữ liệu 1 bình luận trả về cho giao diện (JSON). */
    public record CommentView(Long id, String content, Long userId, String fullName,
                              String avatar, String createdAt) {
    }

    // ------------------------------------------------------------------
    // LIKE
    // ------------------------------------------------------------------

    /** Bấm lần 1 = Like, bấm lần 2 = Unlike. Trả về trạng thái mới và tổng số like. */
    @Transactional
    public Map<String, Object> toggleLike(Long postId, Long userId) {
        Post post = findPost(postId);

        Optional<Like> existing = likeRepository.findByUserIdAndPostId(userId, postId);
        boolean liked;
        if (existing.isPresent()) {
            likeRepository.delete(existing.get());
            liked = false;
        } else {
            User user = findUser(userId);
            likeRepository.save(Like.builder().user(user).post(post).build());
            liked = true;
            // TODO(Bạn 4): khi ghép Notification -> gọi NotificationService tạo thông báo
            // "<user> đã thích bài viết của bạn" cho post.getUser() (nếu khác người like).
        }
        likeRepository.flush();

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("liked", liked);
        result.put("likeCount", likeRepository.countByPostId(postId));
        return result;
    }

    // ------------------------------------------------------------------
    // COMMENT
    // ------------------------------------------------------------------

    @Transactional(readOnly = true)
    public List<CommentView> getComments(Long postId) {
        return commentRepository.findByPostIdAndParentIsNullOrderByCreatedAtAsc(postId)
                .stream()
                .map(this::toView)
                .toList();
    }

    /** Lưu bình luận mới, trả về bình luận vừa tạo kèm tổng số bình luận. */
    @Transactional
    public Map<String, Object> addComment(Long postId, Long userId, String rawContent) {
        String content = rawContent == null ? "" : rawContent.trim();
        if (content.isEmpty()) {
            throw new IllegalArgumentException("Nội dung bình luận không được để trống!");
        }
        if (content.length() > MAX_COMMENT_LENGTH) {
            throw new IllegalArgumentException("Bình luận tối đa " + MAX_COMMENT_LENGTH + " ký tự!");
        }

        Post post = findPost(postId);
        User user = findUser(userId);

        Comment saved = commentRepository.saveAndFlush(
                Comment.builder().content(content).user(user).post(post).build());
        // TODO(Bạn 4): tạo thông báo "<user> đã bình luận bài viết của bạn".

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("comment", toView(saved));
        result.put("commentCount", commentRepository.countByPostId(postId));
        return result;
    }

    // ------------------------------------------------------------------
    // THỐNG KÊ CHO BẢNG TIN (số like, đã like chưa, số comment)
    // ------------------------------------------------------------------

    @Transactional(readOnly = true)
    public Map<Long, Map<String, Object>> getStats(List<Long> postIds, Long userId) {
        Map<Long, Map<String, Object>> stats = new LinkedHashMap<>();
        for (Long postId : postIds) {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("likeCount", likeRepository.countByPostId(postId));
            item.put("liked", likeRepository.existsByUserIdAndPostId(userId, postId));
            item.put("commentCount", commentRepository.countByPostId(postId));
            stats.put(postId, item);
        }
        return stats;
    }

    // ------------------------------------------------------------------

    private CommentView toView(Comment c) {
        User u = c.getUser();
        String name = (u.getFullName() != null && !u.getFullName().isBlank()) ? u.getFullName() : u.getUsername();
        String avatar = (u.getAvatar() == null || u.getAvatar().isBlank()) ? DEFAULT_AVATAR : u.getAvatar();
        String time = c.getCreatedAt() != null ? c.getCreatedAt().format(TIME_FMT) : "";
        return new CommentView(c.getId(), c.getContent(), u.getId(), name, avatar, time);
    }

    private Post findPost(Long postId) {
        return postRepository.findById(postId)
                .orElseThrow(() -> new IllegalArgumentException("Bài viết không tồn tại!"));
    }

    private User findUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy người dùng!"));
    }
}
