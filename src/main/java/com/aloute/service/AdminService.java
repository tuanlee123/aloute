package com.aloute.service;

import com.aloute.dto.AdminUserDTO;
import com.aloute.entity.Post;
import com.aloute.entity.User;
import com.aloute.repository.FriendshipRepository;
import com.aloute.repository.PostRepository;
import com.aloute.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
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

    // Danh sách đầy đủ người dùng kèm thống kê (dành cho Dashboard)
    public List<AdminUserDTO> allUsersWithStats() {
        List<User> users = userRepository.findAll();
        List<AdminUserDTO> result = new ArrayList<>();

        for (User u : users) {
            long userPosts = postRepository.countByUserId(u.getId());
            long userFriends = friendshipRepository.countAcceptedFriendsByUserId(u.getId());

            result.add(convertToDTO(u, userPosts, userFriends));
        }
        return result;
    }

    // 1. Phân trang & Tìm kiếm người dùng cho Admin
    public Page<AdminUserDTO> searchUsersWithStats(String keyword, Pageable pageable) {
        String cleanKeyword = (keyword != null) ? keyword.trim() : "";
        Page<User> userPage = userRepository.searchUsersForAdmin(cleanKeyword, pageable);

        List<AdminUserDTO> dtos = userPage.getContent().stream().map(u -> {
            long userPosts = postRepository.countByUserId(u.getId());
            long userFriends = friendshipRepository.countAcceptedFriendsByUserId(u.getId());
            return convertToDTO(u, userPosts, userFriends);
        }).toList();

        return new PageImpl<>(dtos, pageable, userPage.getTotalElements());
    }

    // 2. Phân trang & Tìm kiếm bài viết cho Admin
    public Page<Post> searchPosts(String keyword, Pageable pageable) {
        String cleanKeyword = (keyword != null) ? keyword.trim() : "";
        return postRepository.searchPostsForAdmin(cleanKeyword, pageable);
    }

    private AdminUserDTO convertToDTO(User u, long userPosts, long userFriends) {
        return AdminUserDTO.builder()
                .id(u.getId())
                .username(u.getUsername())
                .fullName(u.getFullName() != null && !u.getFullName().isBlank() ? u.getFullName() : u.getUsername())
                .email(u.getEmail())
                .avatar(u.getAvatar())
                .active(Boolean.TRUE.equals(u.getActive()))
                .totalPosts(userPosts)
                .totalFriends(userFriends)
                .createdAt(u.getCreatedAt())
                .build();
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
        return Boolean.TRUE.equals(user.getActive());
    }

    @Transactional
    public void deletePost(Long postId) {
        postRepository.deleteById(postId);
    }
}