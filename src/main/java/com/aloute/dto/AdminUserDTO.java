package com.aloute.dto;

import lombok.*;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AdminUserDTO {
    private Long id;
    private String username;
    private String fullName;
    private String email;
    private String avatar;
    private boolean active;
    private long totalPosts;
    private long totalFriends;
    private LocalDateTime createdAt;
}