package com.aloute.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ConversationItemDTO {
    private Long conversationId;
    private Long partnerId;
    private String partnerName;
    private String partnerAvatar;
    private String lastMessage;
    private String updatedAt;
}