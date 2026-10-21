package com.aloute.repository;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import com.aloute.entity.Like;
import com.aloute.entity.Post;
import com.aloute.entity.User;

@Repository
public interface LikeRepository extends JpaRepository<Like, Long> {
    boolean existsByUserAndPost(User user, Post post);
    Optional<Like> findByUserAndPost(User user, Post post);
    long countByPost(Post post);
    long countByPostId(Long postId);
}