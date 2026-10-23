package com.aloute.repository;

import com.aloute.entity.Post;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface PostRepository extends JpaRepository<Post, Long> {

    // 1. Xem trang cá nhân
    List<Post> findByUserIdOrderByCreatedAtDesc(Long userId);
    Page<Post> findByUserIdOrderByCreatedAtDesc(Long userId, Pageable pageable);

    // 2. Dành cho bạn bè xem trang cá nhân (PUBLIC và FRIENDS)
    @Query("SELECT p FROM Post p WHERE p.user.id = :userId AND (p.privacy = 'PUBLIC' OR p.privacy = 'FRIENDS') ORDER BY p.createdAt DESC")
    List<Post> findPostsForFriends(@Param("userId") Long userId);

    // 3. Dành cho người lạ xem trang cá nhân (Chỉ PUBLIC)
    @Query("SELECT p FROM Post p WHERE p.user.id = :userId AND p.privacy = 'PUBLIC' ORDER BY p.createdAt DESC")
    List<Post> findPublicPosts(@Param("userId") Long userId);

    // 4.1. Dành cho Bảng tin (Feed): Lọc bảo mật bài viết CÓ PHÂN TRANG
    @Query("SELECT p FROM Post p WHERE p.privacy = 'PUBLIC' " +
           "OR p.user.id = :currentUserId " +
           "OR (p.privacy = 'FRIENDS' AND p.user.id IN :friendIds) " +
           "ORDER BY p.createdAt DESC")
    Page<Post> findFeedPostsSecure(@Param("currentUserId") Long currentUserId, 
                                   @Param("friendIds") List<Long> friendIds, 
                                   Pageable pageable);

    // 4.2. Dành cho Bảng tin (Feed): Lọc bảo mật bài viết KHÔNG PHÂN TRANG (trả về List)
    @Query("SELECT p FROM Post p WHERE p.privacy = 'PUBLIC' " +
           "OR p.user.id = :currentUserId " +
           "OR (p.privacy = 'FRIENDS' AND p.user.id IN :friendIds) " +
           "ORDER BY p.createdAt DESC")
    List<Post> findFeedPostsSecure(@Param("currentUserId") Long currentUserId, 
                                   @Param("friendIds") List<Long> friendIds);

    // 5. Quản trị Admin: Phân trang toàn bộ bài viết mới nhất
    Page<Post> findAllByOrderByCreatedAtDesc(Pageable pageable);
    List<Post> findAllByOrderByCreatedAtDesc();

    // 6. Quản trị Admin: Tìm kiếm bài viết theo từ khóa nội dung hoặc tên/username người đăng (có phân trang)
    @Query("SELECT p FROM Post p WHERE (:keyword IS NULL OR :keyword = '' " +
           "OR LOWER(p.content) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
           "OR LOWER(p.user.fullName) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
           "OR LOWER(p.user.username) LIKE LOWER(CONCAT('%', :keyword, '%')))")
    Page<Post> searchPostsForAdmin(@Param("keyword") String keyword, Pageable pageable);

    List<Post> findByContentContainingIgnoreCaseOrderByCreatedAtDesc(String keyword);

    // 7. Thống kê
    long countByCreatedAtGreaterThanEqual(LocalDateTime start);
    long countByUserId(Long userId);
    long countByCreatedAtBetween(LocalDateTime start, LocalDateTime end);
}