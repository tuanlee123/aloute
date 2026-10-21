package com.aloute.service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.aloute.dto.CommentResponseDTO;
import com.aloute.entity.Comment;
import com.aloute.entity.Like;
import com.aloute.entity.Post;
import com.aloute.entity.User;
import com.aloute.repository.CommentRepository;
import com.aloute.repository.LikeRepository;
import com.aloute.repository.PostRepository;
import com.aloute.repository.UserRepository;

@Service
public class InteractionService {

    @Autowired
    private LikeRepository likeRepository;

    @Autowired
    private CommentRepository commentRepository;

    @Autowired
    private PostRepository postRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private NotificationService notificationService;

    @Transactional
    public Map<String, Object> toggleLike(Long postId, Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User không tồn tại với ID: " + userId));
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("Bài viết không tồn tại với ID: " + postId));

        Optional<Like> existingLike = likeRepository.findByUserAndPost(user, post);
        boolean isLiked;

        if (existingLike.isPresent()) {
            likeRepository.delete(existingLike.get());
            isLiked = false;
        } else {
            Like like = new Like();
            like.setUser(user);
            like.setPost(post);
            likeRepository.save(like);
            isLiked = true;
            notificationService.create(post.getUser(), user, "đã thích bài viết của bạn",
                    "/post/feed#post-card-" + postId);
        }

        long totalLikes = likeRepository.countByPost(post);

        Map<String, Object> response = new HashMap<>();
        response.put("liked", isLiked);
        response.put("likeCount", totalLikes);
        return response;
    }

    @Transactional
    public CommentResponseDTO addComment(Long postId, Long userId, String content) {
        if (content == null || content.trim().isEmpty()) {
            throw new IllegalArgumentException("Nội dung bình luận không được rỗng");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User không tồn tại với ID: " + userId));
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("Bài viết không tồn tại với ID: " + postId));

        Comment comment = Comment.builder()
                .user(user)
                .post(post)
                .content(content.trim())
                .build();

        Comment saved = commentRepository.save(comment);

        notificationService.create(post.getUser(), user, "đã bình luận về bài viết của bạn",
                "/post/feed#post-card-" + postId);

        // Lấy thông tin hiển thị an toàn trực tiếp từ User
        String fullName = (user.getFullName() != null && !user.getFullName().isBlank()) 
                ? user.getFullName() 
                : user.getUsername();
        String avatar = (user.getAvatar() != null && !user.getAvatar().isBlank()) 
                ? user.getAvatar() 
                : "/images/default-avatar.png";

        LocalDateTime createdAt = (saved.getCreatedAt() != null) ? saved.getCreatedAt() : LocalDateTime.now();

        return new CommentResponseDTO(saved.getId(), saved.getContent(), fullName, avatar, createdAt);
    }
}