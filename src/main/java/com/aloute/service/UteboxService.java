package com.aloute.service;

import com.aloute.dto.ConversationItemDTO;
import com.aloute.dto.UteboxMessageDTO;
import com.aloute.entity.Conversation;
import com.aloute.entity.Message;
import com.aloute.entity.User;
import com.aloute.repository.ConversationRepository;
import com.aloute.repository.MessageRepository;
import com.aloute.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
@EnableScheduling
public class UteboxService {

    @Autowired
    private ConversationRepository conversationRepository;

    @Autowired
    private MessageRepository messageRepository;

    @Autowired
    private UserRepository userRepository;

    private static final int MAX_MESSAGE_LENGTH = 1000;
    private static final long MIN_SEND_INTERVAL_MS = 300;
    private static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("HH:mm dd/MM/yyyy");

    private final Map<Long, SseEmitter> userEmitters = new ConcurrentHashMap<>();
    private final Map<Long, Long> lastSentTimeMap = new ConcurrentHashMap<>();

    public SseEmitter registerUser(Long userId) {
        SseEmitter emitter = new SseEmitter(12 * 60 * 60 * 1000L);
        userEmitters.put(userId, emitter);

        emitter.onCompletion(() -> userEmitters.remove(userId));
        emitter.onTimeout(() -> userEmitters.remove(userId));
        emitter.onError(e -> userEmitters.remove(userId));

        try {
            emitter.send(SseEmitter.event().name("init").data("CONNECTED"));
        } catch (IOException e) {
            userEmitters.remove(userId);
        }

        return emitter;
    }

    @Scheduled(fixedRate = 25000)
    public void sendHeartbeat() {
        userEmitters.forEach((userId, emitter) -> {
            try {
                emitter.send(SseEmitter.event().name("ping").data("heartbeat"));
            } catch (Exception e) {
                userEmitters.remove(userId);
            }
        });
    }

    @Transactional
    public Conversation getOrCreateConversation(Long myId, Long partnerId) {
        if (myId.equals(partnerId)) {
            throw new IllegalArgumentException("Không thể tự trò chuyện với chính mình!");
        }

        return conversationRepository.findBetweenUsers(myId, partnerId)
                .orElseGet(() -> {
                    User u1 = userRepository.findById(myId)
                            .orElseThrow(() -> new IllegalArgumentException("Người dùng hiện tại không tồn tại!"));
                    User u2 = userRepository.findById(partnerId)
                            .orElseThrow(() -> new IllegalArgumentException("Đối phương không tồn tại!"));

                    return conversationRepository.save(Conversation.builder()
                            .userOne(u1)
                            .userTwo(u2)
                            .lastMessage("")
                            .build());
                });
    }

    // SỬA LỖI TIẾNG VIỆT TẠI ĐÂY: Lưu text chuẩn UTF-8, không dùng htmlEscape
    @Transactional
    public UteboxMessageDTO sendMessage(Long senderId, Long partnerId, String rawContent) {
        long now = System.currentTimeMillis();
        Long lastSent = lastSentTimeMap.get(senderId);
        if (lastSent != null && (now - lastSent) < MIN_SEND_INTERVAL_MS) {
            throw new IllegalStateException("Bạn đang gửi tin nhắn quá nhanh!");
        }
        lastSentTimeMap.put(senderId, now);

        if (rawContent == null || rawContent.trim().isEmpty()) {
            throw new IllegalArgumentException("Nội dung tin nhắn không được rỗng!");
        }

        String content = rawContent.trim();
        if (content.length() > MAX_MESSAGE_LENGTH) {
            throw new IllegalArgumentException("Tin nhắn vượt quá giới hạn " + MAX_MESSAGE_LENGTH + " ký tự!");
        }

        Conversation conv = getOrCreateConversation(senderId, partnerId);
        User sender = userRepository.findById(senderId)
                .orElseThrow(() -> new IllegalArgumentException("Người gửi không tồn tại!"));

        Message msg = Message.builder()
                .conversation(conv)
                .sender(sender)
                .content(content)
                .build();
        Message saved = messageRepository.save(msg);

        String lastMsgSnippet = content.length() > 60 ? content.substring(0, 57) + "..." : content;
        conv.setLastMessage(lastMsgSnippet);
        conversationRepository.save(conv);

        String avatar = (sender.getAvatar() != null && !sender.getAvatar().isBlank()) 
                ? sender.getAvatar() 
                : "https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg";

        String senderName = sender.getFullName() != null ? sender.getFullName() : sender.getUsername();

        UteboxMessageDTO dto = UteboxMessageDTO.builder()
                .id(saved.getId())
                .conversationId(conv.getId())
                .senderId(sender.getId())
                .senderName(senderName)
                .senderAvatar(avatar)
                .receiverId(partnerId)
                .content(saved.getContent())
                .createdAt(saved.getCreatedAt().format(TIME_FMT))
                .build();

        pushToUser(partnerId, dto);
        return dto;
    }

    @Transactional(readOnly = true)
    public List<UteboxMessageDTO> getMessagesSecure(Long currentUserId, Long partnerId) {
        Conversation conv = getOrCreateConversation(currentUserId, partnerId);

        if (!conv.hasUser(currentUserId)) {
            throw new SecurityException("Bạn không có quyền xem cuộc trò chuyện này!");
        }

        return messageRepository.findByConversationIdOrderByCreatedAtAsc(conv.getId())
                .stream()
                .map(m -> {
                    User s = m.getSender();
                    return UteboxMessageDTO.builder()
                            .id(m.getId())
                            .conversationId(conv.getId())
                            .senderId(s.getId())
                            .senderName(s.getFullName() != null ? s.getFullName() : s.getUsername())
                            .senderAvatar(s.getAvatar())
                            .content(m.getContent())
                            .createdAt(m.getCreatedAt().format(TIME_FMT))
                            .build();
                })
                .toList();
    }

    // LẤY DANH SÁCH CÁC ĐOẠN CHAT GẦN ĐÂY CHUẨN FACEBOOK
    @Transactional(readOnly = true)
    public List<ConversationItemDTO> getUserConversations(Long currentUserId) {
        List<Conversation> list = conversationRepository.findAllByUserIdOrderByUpdatedAtDesc(currentUserId);
        return list.stream().map(c -> {
            User partner = c.getUserOne().getId().equals(currentUserId) ? c.getUserTwo() : c.getUserOne();
            String name = (partner.getFullName() != null && !partner.getFullName().isBlank()) ? partner.getFullName() : partner.getUsername();
            String avatar = (partner.getAvatar() != null && !partner.getAvatar().isBlank()) ? partner.getAvatar() : "https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg";
            String updated = (c.getUpdatedAt() != null) ? c.getUpdatedAt().format(TIME_FMT) : "";

            return ConversationItemDTO.builder()
                    .conversationId(c.getId())
                    .partnerId(partner.getId())
                    .partnerName(name)
                    .partnerAvatar(avatar)
                    .lastMessage(c.getLastMessage() != null ? c.getLastMessage() : "")
                    .updatedAt(updated)
                    .build();
        }).toList();
    }

    private void pushToUser(Long userId, UteboxMessageDTO dto) {
        SseEmitter emitter = userEmitters.get(userId);
        if (emitter != null) {
            try {
                emitter.send(SseEmitter.event().name("chat-message").data(dto));
            } catch (IOException e) {
                userEmitters.remove(userId);
            }
        }
    }
}