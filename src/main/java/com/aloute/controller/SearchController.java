package com.aloute.controller;

import com.aloute.entity.Post;
import com.aloute.entity.User;
import com.aloute.repository.PostRepository;
import com.aloute.repository.UserRepository;
import com.aloute.service.FriendshipService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequiredArgsConstructor
public class SearchController {

    private final UserRepository userRepository;
    private final PostRepository postRepository;
    private final FriendshipService friendshipService;

    private User getLoggedInUser(HttpSession session) {
        if (session == null) return null;
        User u = (User) session.getAttribute("currentUser");
        return u != null ? u : (User) session.getAttribute("user");
    }

    private boolean isUserAdmin(User user) {
        if (user == null || user.getRoles() == null) return false;
        return user.getRoles().stream()
                .anyMatch(r -> "ROLE_ADMIN".equalsIgnoreCase(r.getName()));
    }

    @GetMapping("/search")
    public String searchAll(@RequestParam(value = "q", required = false) String keyword,
                            HttpSession session,
                            Model model) {
        User currentUser = getLoggedInUser(session);
        if (currentUser == null) return "redirect:/login";

        boolean isAdmin = isUserAdmin(currentUser);
        model.addAttribute("keyword", keyword);

        if (keyword != null && !keyword.trim().isEmpty()) {
            String query = keyword.trim();

            // 1. TÌM KIẾM NGƯỜI DÙNG
            List<User> foundUsers = new ArrayList<>(
                    userRepository.findByFullNameContainingIgnoreCaseOrUsernameContainingIgnoreCase(query, query)
            );

            // Loại bỏ chính mình và loại bỏ các tài khoản Admin ra khỏi kết quả
            foundUsers.removeIf(u -> u.getId().equals(currentUser.getId()) || isUserAdmin(u));

            Map<Long, Integer> mutualCounts = new HashMap<>();
            Map<Long, String> statusMap = new HashMap<>();

            // Chỉ tính bạn chung và trạng thái quan hệ khi là User thường
            if (!isAdmin) {
                for (User u : foundUsers) {
                    mutualCounts.put(u.getId(), friendshipService.countMutualFriends(currentUser.getId(), u.getId()));
                    statusMap.put(u.getId(), friendshipService.getFriendshipStatus(currentUser.getId(), u.getId()));
                }
            }

            model.addAttribute("foundUsers", foundUsers);
            model.addAttribute("users", foundUsers);
            model.addAttribute("mutualCounts", mutualCounts);
            model.addAttribute("statusMap", statusMap);

            // 2. TÌM KIẾM BÀI VIẾT
            try {
                List<Post> rawPosts = postRepository.findByContentContainingIgnoreCaseOrderByCreatedAtDesc(query);
                List<Post> filteredPosts;

                if (isAdmin) {
                    // Admin xem tất cả bài viết khớp từ khóa để kiểm duyệt nội dung
                    filteredPosts = rawPosts;
                } else {
                    // User thường: Lọc bỏ bài viết PRIVATE của người khác và bài viết FRIENDS nếu chưa kết bạn
                    filteredPosts = rawPosts.stream().filter(p -> {
                        if (p.getUser().getId().equals(currentUser.getId())) return true;
                        String privacy = p.getPrivacy() != null ? p.getPrivacy().toUpperCase() : "PUBLIC";
                        if ("PRIVATE".equals(privacy)) return false;
                        if ("FRIENDS".equals(privacy)) {
                            String status = friendshipService.getFriendshipStatus(currentUser.getId(), p.getUser().getId());
                            return "FRIENDS".equalsIgnoreCase(status);
                        }
                        return true;
                    }).toList();
                }

                model.addAttribute("foundPosts", filteredPosts);
                model.addAttribute("posts", filteredPosts);
            } catch (Exception e) {
                model.addAttribute("foundPosts", new ArrayList<>());
                model.addAttribute("posts", new ArrayList<>());
            }
        } else {
            model.addAttribute("foundUsers", new ArrayList<>());
            model.addAttribute("users", new ArrayList<>());
            model.addAttribute("foundPosts", new ArrayList<>());
            model.addAttribute("posts", new ArrayList<>());
        }

        return "search"; // File /WEB-INF/views/search.jsp
    }
}