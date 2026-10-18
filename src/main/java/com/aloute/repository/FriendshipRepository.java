package com.aloute.repository;

import com.aloute.entity.Friendship;
import com.aloute.entity.Friendship.FriendshipStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FriendshipRepository extends JpaRepository<Friendship, Long> {
    // Tìm mối quan hệ giữa 2 người bất kể ai là người gửi/nhận
    @Query("SELECT f FROM Friendship f WHERE " +
           "(f.requester.id = :u1 AND f.addressee.id = :u2) OR " +
           "(f.requester.id = :u2 AND f.addressee.id = :u1)")
    Optional<Friendship> findRelationBetween(@Param("u1") Long userId1, @Param("u2") Long userId2);

    // Lấy danh sách lời mời kết bạn gửi đến một người dùng
    List<Friendship> findByAddresseeIdAndStatus(Long addresseeId, FriendshipStatus status);
}