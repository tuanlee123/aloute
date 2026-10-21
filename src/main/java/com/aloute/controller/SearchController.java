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

    @GetMapping("/search")
    public String searchAll(@RequestParam(value = "q", required = false) String keyword,
                            HttpSession session,
                            Model model) {
        User currentUser = getLoggedInUser(session);
        if (currentUser == null) return "redirect:/login";

        model.addAttribute("keyword", keyword);

        if (keyword != null && !keyword.trim().isEmpty()) {
            String query = keyword.trim();

            // 1. Tìm người dùng từ Database và bọc vào new ArrayList để tránh lỗi danh sách bất biến
            List<User> foundUsers = new ArrayList<>(
                userRepository.findByFullNameContainingIgnoreCaseOrUsernameContainingIgnoreCase(query, query)
            );
            foundUsers.removeIf(u -> u.getId().equals(currentUser.getId()));

            // Tính toán bạn chung và trạng thái quan hệ
            Map<Long, Integer> mutualCounts = new HashMap<>();
            Map<Long, String> statusMap = new HashMap<>();
            for (User u : foundUsers) {
                mutualCounts.put(u.getId(), friendshipService.countMutualFriends(currentUser.getId(), u.getId()));
                statusMap.put(u.getId(), friendshipService.getFriendshipStatus(currentUser.getId(), u.getId()));
            }

            model.addAttribute("foundUsers", foundUsers);
            model.addAttribute("users", foundUsers);
            model.addAttribute("mutualCounts", mutualCounts);
            model.addAttribute("statusMap", statusMap);

            // 2. Tìm bài viết theo nội dung
            try {
                List<Post> foundPosts = postRepository.findByContentContainingIgnoreCaseOrderByCreatedAtDesc(query);
                model.addAttribute("foundPosts", foundPosts);
                model.addAttribute("posts", foundPosts);
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

        return "search"; // Mở file /WEB-INF/views/search.jsp
    }
}