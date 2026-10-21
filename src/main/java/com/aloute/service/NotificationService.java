package com.aloute.service;

import com.aloute.entity.Notification;
import com.aloute.entity.User;
import com.aloute.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;

    /**
     * Tạo thông báo theo chuẩn của bạn: "<Tên người gửi> <action>".
     * Ví dụ: create(chuBai, nguoiLike, "đã thích bài viết của bạn", "/post/feed#post-card-5")
     */
    @Transactional
    public void create(User recipient, User sender, String action, String targetUrl) {
        if (recipient == null || sender == null) return;
        if (recipient.getId().equals(sender.getId())) return; // không tự thông báo cho chính mình

        String name = (sender.getFullName() != null && !sender.getFullName().isBlank())
                ? sender.getFullName() : sender.getUsername();
        String content = name + " " + action;
        if (content.length() > 255) content = content.substring(0, 255);

        if (notificationRepository.existsByRecipientIdAndSenderIdAndContentAndTargetUrlAndIsReadFalse(
                recipient.getId(), sender.getId(), content, targetUrl)) {
            return; // đã có thông báo y hệt chưa đọc
        }

        notificationRepository.save(Notification.builder()
                .recipient(recipient)
                .sender(sender)
                .content(content)
                .targetUrl(targetUrl)
                .isRead(false)
                .build());
    }

    /**
     * Hỗ trợ tạo thông báo truyền trực tiếp nội dung đầy đủ (dùng cho FriendshipService)
     */
    @Transactional
    public void createNotification(User recipient, User sender, String fullContent, String targetUrl) {
        if (recipient == null || sender == null) return;
        if (recipient.getId().equals(sender.getId())) return;

        if (fullContent != null && fullContent.length() > 255) {
            fullContent = fullContent.substring(0, 255);
        }

        notificationRepository.save(Notification.builder()
                .recipient(recipient)
                .sender(sender)
                .content(fullContent)
                .targetUrl(targetUrl)
                .isRead(false)
                .build());
    }

    @Transactional(readOnly = true)
    public long countUnread(Long userId) {
        return notificationRepository.countByRecipientIdAndIsReadFalse(userId);
    }

    /** 20 thông báo mới nhất dưới dạng Map (cho dropdown chuông) */
    @Transactional(readOnly = true)
    public List<Map<String, Object>> latest(Long userId) {
        List<Map<String, Object>> result = new ArrayList<>();
        notificationRepository.findByRecipientIdOrderByCreatedAtDesc(userId).stream().limit(20).forEach(n -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("id", n.getId());
            m.put("content", n.getContent());
            m.put("read", Boolean.TRUE.equals(n.getIsRead()));
            m.put("createdAt", String.valueOf(n.getCreatedAt()));
            result.add(m);
        });
        return result;
    }

    @Transactional(readOnly = true)
    public List<Notification> listAll(Long userId) {
        return notificationRepository.findByRecipientIdOrderByCreatedAtDesc(userId);
    }

    /** Alias trỏ về listAll để tương thích */
    @Transactional(readOnly = true)
    public List<Notification> getNotifications(Long userId) {
        return listAll(userId);
    }

    /** Đánh dấu đã đọc và trả về link đích */
    @Transactional
    public String openAndMarkRead(Long notificationId, Long userId) {
        Notification n = notificationRepository.findById(notificationId).orElse(null);
        if (n == null || !n.getRecipient().getId().equals(userId)) return null;
        n.setIsRead(true);
        notificationRepository.save(n);
        return n.getTargetUrl();
    }

    @Transactional
    public void markAllRead(Long userId) {
        List<Notification> list = notificationRepository.findByRecipientIdOrderByCreatedAtDesc(userId);
        list.forEach(n -> n.setIsRead(true));
        notificationRepository.saveAll(list);
    }

    /** Alias trỏ về markAllRead để tương thích */
    @Transactional
    public void markAllAsRead(Long userId) {
        markAllRead(userId);
    }
}