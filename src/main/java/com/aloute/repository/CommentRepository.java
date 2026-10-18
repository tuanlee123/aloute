package com.aloute.repository;

import com.aloute.entity.Comment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CommentRepository extends JpaRepository<Comment, Long> {
    // Lấy các bình luận gốc (không có parent) của một bài viết
    List<Comment> findByPostIdAndParentIsNullOrderByCreatedAtAsc(Long postId);

    // Đếm tổng số bình luận của một bài viết
    long countByPostId(Long postId);
}