package com.aloute.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "conversations", indexes = {
    @Index(name = "idx_users_conv", columnList = "user_one_id, user_two_id")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Conversation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_one_id", nullable = false)
    private User userOne;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_two_id", nullable = false)
    private User userTwo;

    @Column(name = "last_message", length = 500)
    private String lastMessage;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    // Kiểm tra xem user có nằm trong cuộc trò chuyện hay không
    public boolean hasUser(Long userId) {
        if (userId == null) return false;
        Long id1 = (this.userOne != null) ? this.userOne.getId() : null;
        Long id2 = (this.userTwo != null) ? this.userTwo.getId() : null;
        return userId.equals(id1) || userId.equals(id2);
    }
}