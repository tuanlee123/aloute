package com.aloute.repository;

import com.aloute.entity.SavedPost;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SavedPostRepository extends JpaRepository<SavedPost, Long> {
    Optional<SavedPost> findByUserIdAndPostId(Long userId, Long postId);
    
    boolean existsByUserIdAndPostId(Long userId, Long postId);
    
    List<SavedPost> findAllByUserIdOrderByCreatedAtDesc(Long userId);
    
    void deleteByUserIdAndPostId(Long userId, Long postId);

    // BỔ SUNG: Xóa toàn bộ liên kết bài đã lưu khi bài viết bị xóa
    @Modifying
    @Query("DELETE FROM SavedPost sp WHERE sp.post.id = :postId")
    void deleteByPostId(@Param("postId") Long postId);
}