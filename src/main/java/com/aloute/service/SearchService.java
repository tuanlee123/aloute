package com.aloute.service;

import com.aloute.entity.Post;
import com.aloute.entity.User;
import com.aloute.repository.PostRepository;
import com.aloute.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SearchService {

    private final UserRepository userRepository;
    private final PostRepository postRepository;

    @Transactional(readOnly = true)
    public List<User> searchUsers(String keyword) {
        if (keyword == null || keyword.isBlank()) return Collections.emptyList();
        String k = keyword.trim();
        return userRepository.findByFullNameContainingIgnoreCaseOrUsernameContainingIgnoreCase(k, k)
                .stream()
                .filter(u -> !Boolean.FALSE.equals(u.getActive()))
                .toList();
    }

    /** Chỉ trả bài PUBLIC hoặc bài của chính người đang tìm (tôn trọng quyền riêng tư). */
    @Transactional(readOnly = true)
    public List<Post> searchPosts(String keyword, Long currentUserId) {
        if (keyword == null || keyword.isBlank()) return Collections.emptyList();
        return postRepository.findByContentContainingIgnoreCaseOrderByCreatedAtDesc(keyword.trim())
                .stream()
                .filter(p -> p.getPrivacy() == null
                        || "PUBLIC".equals(p.getPrivacy())
                        || p.getUser().getId().equals(currentUserId))
                .toList();
    }
}
