package com.aloute.repository;

import com.aloute.entity.Like;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface LikeRepository extends JpaRepository<Like, Long> {
    // Kiểm tra user đã like bài viết chưa
    boolean existsByUserIdAndPostId(Long userId, Long postId);

    // Tìm record like để hủy like (Unlike)
    Optional<Like> findByUserIdAndPostId(Long userId, Long postId);

    // Đếm tổng số lượt like của bài viết
    long countByPostId(Long postId);
}