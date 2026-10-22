package com.aloute.repository;

import com.aloute.entity.Post;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface PostRepository extends JpaRepository<Post, Long> {

    // 1. Dành cho chính chủ xem trang cá nhân (Lấy tất cả bài viết bao gồm cả PRIVATE)
    List<Post> findByUserIdOrderByCreatedAtDesc(Long userId);

    // 2. Dành cho bạn bè xem trang cá nhân (Chỉ lấy PUBLIC và FRIENDS, loại bỏ PRIVATE)
    @Query("SELECT p FROM Post p WHERE p.user.id = :userId AND (p.privacy = 'PUBLIC' OR p.privacy = 'FRIENDS') ORDER BY p.createdAt DESC")
    List<Post> findPostsForFriends(@Param("userId") Long userId);

    // 3. Dành cho người lạ xem trang cá nhân (Chỉ lấy PUBLIC)
    @Query("SELECT p FROM Post p WHERE p.user.id = :userId AND p.privacy = 'PUBLIC' ORDER BY p.createdAt DESC")
    List<Post> findPublicPosts(@Param("userId") Long userId);

    // 4. Dành cho Bảng tin (Feed): Lọc bảo mật bài viết
    // - Lấy toàn bộ bài PUBLIC
    // - Lấy bài của chính người đang đăng nhập (bao gồm cả PRIVATE)
    // - Lấy bài FRIENDS nếu tác giả nằm trong danh sách bạn bè
    @Query("SELECT p FROM Post p WHERE p.privacy = 'PUBLIC' " +
           "OR p.user.id = :currentUserId " +
           "OR (p.privacy = 'FRIENDS' AND p.user.id IN :friendIds) " +
           "ORDER BY p.createdAt DESC")
    List<Post> findFeedPostsSecure(@Param("currentUserId") Long currentUserId, @Param("friendIds") List<Long> friendIds);

    // 5. Lấy toàn bộ bài viết mới nhất trên bảng tin (dành cho Admin / Quản trị)
    List<Post> findAllByOrderByCreatedAtDesc();

    // 6. Tìm kiếm bài viết theo từ khóa nội dung
    List<Post> findByContentContainingIgnoreCaseOrderByCreatedAtDesc(String keyword);

    // 7. Đếm bài viết từ một mốc thời gian (dùng cho thống kê)
    long countByCreatedAtGreaterThanEqual(LocalDateTime start);
    
    long countByUserId(Long userId);
    long countByCreatedAtBetween(LocalDateTime start, LocalDateTime end);
    
}