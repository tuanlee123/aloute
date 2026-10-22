package com.aloute.service;

import com.aloute.dto.AdminUserDTO;
import com.aloute.entity.Post;
import com.aloute.entity.User;
import com.aloute.repository.FriendshipRepository;
import com.aloute.repository.PostRepository;
import com.aloute.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;

@Service
@RequiredArgsConstructor
public class AdminService {

    private final UserRepository userRepository;
    private final PostRepository postRepository;
    private final FriendshipRepository friendshipRepository;

    public long totalUsers() {
        return userRepository.count();
    }

    public long activeUsers() {
        return userRepository.countByActive(true);
    }

    public long totalPosts() {
        return postRepository.count();
    }

    public long postsToday() {
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        LocalDateTime endOfDay = LocalDate.now().atTime(LocalTime.MAX);
        return postRepository.countByCreatedAtBetween(startOfDay, endOfDay);
    }

    public List<User> allUsers() {
        return userRepository.findAll();
    }

    public List<Post> allPosts() {
        return postRepository.findAllByOrderByCreatedAtDesc();
    }

    // Lấy danh sách User kèm số bạn bè và số bài viết
    public List<AdminUserDTO> allUsersWithStats() {
        List<User> users = userRepository.findAll();
        List<AdminUserDTO> result = new ArrayList<>();

        for (User u : users) {
            long userPosts = postRepository.countByUserId(u.getId());
            long userFriends = friendshipRepository.countAcceptedFriendsByUserId(u.getId());

            result.add(AdminUserDTO.builder()
                    .id(u.getId())
                    .username(u.getUsername())
                    .fullName(u.getFullName() != null && !u.getFullName().isBlank() ? u.getFullName() : u.getUsername())
                    .email(u.getEmail())
                    .avatar(u.getAvatar())
                    .active(Boolean.TRUE.equals(u.getActive()))
                    .totalPosts(userPosts)
                    .totalFriends(userFriends)
                    .createdAt(u.getCreatedAt())
                    .build());
        }
        return result;
    }

    @Transactional
    public boolean toggleActive(Long userId, Long currentAdminId) {
        if (userId.equals(currentAdminId)) {
            throw new IllegalArgumentException("Không thể tự khóa tài khoản của chính mình.");
        }
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("Người dùng không tồn tại"));
        boolean currentStatus = Boolean.TRUE.equals(user.getActive());
        user.setActive(!currentStatus);
        userRepository.save(user);
        return user.getActive() != null && user.getActive();
    }

    @Transactional
    public void deletePost(Long postId) {
        postRepository.deleteById(postId);
    }
}