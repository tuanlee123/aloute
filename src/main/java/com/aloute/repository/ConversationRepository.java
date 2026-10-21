package com.aloute.repository;

import com.aloute.entity.Conversation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ConversationRepository extends JpaRepository<Conversation, Long> {

    @Query("SELECT c FROM Conversation c WHERE " +
           "(c.userOne.id = :u1 AND c.userTwo.id = :u2) OR " +
           "(c.userOne.id = :u2 AND c.userTwo.id = :u1)")
    Optional<Conversation> findBetweenUsers(@Param("u1") Long u1, @Param("u2") Long u2);

    // Lấy toàn bộ danh sách hội thoại của user sắp xếp theo tin nhắn mới nhất
    @Query("SELECT c FROM Conversation c WHERE c.userOne.id = :userId OR c.userTwo.id = :userId ORDER BY c.updatedAt DESC")
    List<Conversation> findAllByUserIdOrderByUpdatedAtDesc(@Param("userId") Long userId);
}