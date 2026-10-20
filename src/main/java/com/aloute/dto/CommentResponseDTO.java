package com.aloute.dto;

import java.time.LocalDateTime;

public class CommentResponseDTO {
    private Long id;
    private String content;
    private String userFullName;
    private String userAvatar;
    private LocalDateTime createdAt;

    public CommentResponseDTO(Long id, String content, String userFullName, String userAvatar, LocalDateTime createdAt) {
        this.id = id;
        this.content = content;
        this.userFullName = userFullName;
        this.userAvatar = userAvatar;
        this.createdAt = createdAt;
    }

    public Long getId() { return id; }
    public String getContent() { return content; }
    public String getUserFullName() { return userFullName; }
    public String getUserAvatar() { return userAvatar; }
    public LocalDateTime getCreatedAt() { return createdAt; }
}