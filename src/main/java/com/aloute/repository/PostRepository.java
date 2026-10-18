package com.aloute.repository;

import com.aloute.entity.Post;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PostRepository extends JpaRepository<Post, Long> {
    // Lấy bài viết của một user theo thời gian giảm dần
    List<Post> findByUserIdOrderByCreatedAtDesc(Long userId);

    // Lấy toàn bộ bài viết mới nhất trên bảng tin
    List<Post> findAllByOrderByCreatedAtDesc();

    // Tìm kiếm bài viết theo từ khóa nội dung
    List<Post> findByContentContainingIgnoreCaseOrderByCreatedAtDesc(String keyword);
}
