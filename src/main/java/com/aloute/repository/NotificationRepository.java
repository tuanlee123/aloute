package com.aloute.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.aloute.entity.Notification;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {
    // Lấy danh sách thông báo của một người theo thời gian giảm dần
    List<Notification> findByRecipientIdOrderByCreatedAtDesc(Long recipientId);

    // Đếm số lượng thông báo chưa đọc
    long countByRecipientIdAndIsReadFalse(Long recipientId);
}