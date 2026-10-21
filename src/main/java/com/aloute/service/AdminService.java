package com.aloute.service;

import com.aloute.entity.Post;
import com.aloute.entity.User;
import com.aloute.repository.PostRepository;
import com.aloute.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AdminService {

    private final UserRepository userRepository;
    private final PostRepository postRepository;
    private final PostService postService; // dùng lại deletePost của Bạn 2 (đã xử lý bảng "đã lưu")

    public long totalUsers() {
        return userRepository.count();
    }

    public long totalPosts() {
        return postRepository.count();
    }

    public long postsToday() {
        return postRepository.countByCreatedAtGreaterThanEqual(LocalDate.now().atStartOfDay());
    }

    public List<User> allUsers() {
        return userRepository.findAll(Sort.by(Sort.Direction.DESC, "createdAt"));
    }

    public List<Post> allPosts() {
        return postRepository.findAllByOrderByCreatedAtDesc();
    }

    /** Khóa / mở khóa tài khoản. Trả về trạng thái active mới. */
    @Transactional
    public boolean toggleActive(Long targetUserId, Long adminId) {
        if (targetUserId.equals(adminId)) {
            throw new IllegalArgumentException("Bạn không thể tự khóa tài khoản của mình!");
        }
        User u = userRepository.findById(targetUserId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy người dùng!"));
        boolean targetIsAdmin = u.getRoles() != null
                && u.getRoles().stream().anyMatch(r -> "ROLE_ADMIN".equals(r.getName()));
        if (targetIsAdmin) {
            throw new IllegalArgumentException("Không thể khóa tài khoản Admin khác!");
        }
        boolean newState = !Boolean.TRUE.equals(u.getActive());
        u.setActive(newState);
        userRepository.save(u);
        return newState;
    }

    @Transactional
    public void deletePost(Long postId) {
        postService.deletePost(postId);
    }
}
