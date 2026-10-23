package com.aloute.controller;

import com.aloute.dto.PostCreateDTO;
import com.aloute.entity.Post;
import com.aloute.entity.User;
import com.aloute.repository.PostRepository;
import com.aloute.service.FriendshipService;
import com.aloute.service.PostService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Collections;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/post")
public class PostController {

    @Autowired
    private PostService postService;

    @Autowired
    private PostRepository postRepository;

    @Autowired
    private FriendshipService friendshipService;

    private boolean isUserAdmin(User user) {
        if (user == null || user.getRoles() == null) return false;
        return user.getRoles().stream()
                .anyMatch(r -> "ROLE_ADMIN".equalsIgnoreCase(r.getName()));
    }

    // 1. Xem bảng tin: Admin được xem tất cả để kiểm duyệt, User thường lọc theo quyền riêng tư
    @GetMapping({ "", "/feed" })
    public String showFeed(HttpSession session, Model model) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return "redirect:/login";
        }

        boolean isAdmin = isUserAdmin(currentUser);
        List<Post> posts;
        List<User> myFriends;

        if (isAdmin) {
            posts = postRepository.findAllByOrderByCreatedAtDesc();
            myFriends = Collections.emptyList();
        } else {
            myFriends = friendshipService.getFriends(currentUser.getId());
            List<Long> friendIds = myFriends.stream().map(User::getId).toList();

            if (friendIds.isEmpty()) {
                posts = postRepository.findFeedPostsSecure(currentUser.getId(), Collections.singletonList(-1L));
            } else {
                posts = postRepository.findFeedPostsSecure(currentUser.getId(), friendIds);
            }
        }

        model.addAttribute("posts", posts);
        model.addAttribute("myFriends", myFriends);
        return "post/feed";
    }

    // 2. Xem chi tiết bài viết
    @GetMapping("/{id:[0-9]+}")
    public String viewSinglePost(@PathVariable("id") Long id,
                                 HttpSession session,
                                 Model model,
                                 RedirectAttributes redirectAttributes) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return "redirect:/login?requiredAuth=true";
        }

        Post post = postService.getPostById(id);
        if (post == null) {
            redirectAttributes.addFlashAttribute("errorMessage", "Bài viết không tồn tại hoặc đã bị xóa!");
            return "redirect:/post/feed";
        }

        boolean isAdmin = isUserAdmin(currentUser);
        boolean isAuthor = post.getUser().getId().equals(currentUser.getId());

        if (!isAuthor && !isAdmin) {
            String privacy = post.getPrivacy() != null ? post.getPrivacy().toUpperCase() : "PUBLIC";

            if ("PRIVATE".equals(privacy)) {
                redirectAttributes.addFlashAttribute("errorMessage", "Bạn không có quyền xem bài viết này!");
                return "redirect:/post/feed";
            }

            if ("FRIENDS".equals(privacy)) {
                String friendshipStatus = friendshipService.getFriendshipStatus(currentUser.getId(), post.getUser().getId());
                if (!"FRIENDS".equalsIgnoreCase(friendshipStatus)) {
                    redirectAttributes.addFlashAttribute("errorMessage", "Bài viết này chỉ dành cho bạn bè của tác giả!");
                    return "redirect:/post/feed";
                }
            }
        }

        List<User> myFriends = isAdmin ? Collections.emptyList() : friendshipService.getFriends(currentUser.getId());
        model.addAttribute("post", post);
        model.addAttribute("posts", List.of(post));
        model.addAttribute("myFriends", myFriends);
        return "post/single-post";
    }

    // 3. Hiển thị form tạo bài viết - Chặn Admin
    @GetMapping("/create")
    public String showCreateForm(HttpSession session, RedirectAttributes redirectAttributes, Model model) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser != null && isUserAdmin(currentUser)) {
            redirectAttributes.addFlashAttribute("errorMessage", "Tài khoản Quản trị viên không thể đăng bài viết!");
            return "redirect:/post/feed";
        }
        model.addAttribute("postCreateDTO", new PostCreateDTO());
        return "post/create-post";
    }

    // 4. Xử lý tạo bài viết mới - Chặn Admin
    @PostMapping("/create")
    public String createPost(@ModelAttribute PostCreateDTO postCreateDTO,
                             @RequestParam(value = "redirectUrl", required = false) String redirectUrl,
                             HttpSession session,
                             RedirectAttributes redirectAttributes) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return "redirect:/login";
        }

        if (isUserAdmin(currentUser)) {
            redirectAttributes.addFlashAttribute("errorMessage", "Tài khoản Quản trị viên chỉ có quyền giám sát!");
            return "redirect:/post/feed";
        }

        try {
            postService.createPost(postCreateDTO, currentUser);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return (redirectUrl != null && !redirectUrl.isBlank()) ? "redirect:" + redirectUrl : "redirect:/post/feed";
    }

    // 5. Hiển thị form chỉnh sửa bài viết
    @GetMapping("/edit/{id}")
    public String showEditForm(@PathVariable("id") Long id, HttpSession session, RedirectAttributes redirectAttributes, Model model) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) return "redirect:/login";

        Post post = postService.getPostById(id);
        if (post == null) return "redirect:/post/feed";

        if (!post.getUser().getId().equals(currentUser.getId())) {
            redirectAttributes.addFlashAttribute("errorMessage", "Bạn không có quyền chỉnh sửa bài viết này!");
            return "redirect:/post/feed";
        }

        model.addAttribute("post", post);
        return "post/edit-post";
    }

    // 6. Xử lý cập nhật bài viết
    @PostMapping("/edit/{id}")
    public String updatePost(@PathVariable("id") Long id, 
                             @RequestParam("content") String content,
                             @RequestParam(value = "privacy", defaultValue = "PUBLIC") String privacy,
                             @RequestParam(value = "redirectUrl", required = false) String redirectUrl,
                             HttpSession session) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) return "redirect:/login";

        Post post = postService.getPostById(id);
        if (post != null && post.getUser().getId().equals(currentUser.getId())) {
            try {
                postService.updatePost(id, content, privacy);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return (redirectUrl != null && !redirectUrl.isBlank()) ? "redirect:" + redirectUrl : "redirect:/post/feed";
    }

    // 7.1. API XÓA BÀI VIẾT QUA AJAX CHO SWEETALERT2
    @PostMapping("/api/delete/{id}")
    @ResponseBody
    public ResponseEntity<?> deletePostAjax(@PathVariable("id") Long id, HttpSession session) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Vui lòng đăng nhập để thực hiện!"));
        }

        Post post = postService.getPostById(id);
        if (post == null) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Bài viết không tồn tại hoặc đã bị xóa!"));
        }

        boolean isAuthor = post.getUser().getId().equals(currentUser.getId());
        boolean isAdmin = isUserAdmin(currentUser);

        if (!isAuthor && !isAdmin) {
            return ResponseEntity.status(403).body(Map.of("success", false, "message", "Bạn không có quyền xóa bài viết này!"));
        }

        try {
            postService.deletePost(id);
            return ResponseEntity.ok(Map.of("success", true, "message", "Đã xóa bài viết thành công."));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Không thể xóa bài viết: " + e.getMessage()));
        }
    }

    // 7.2. Xử lý xóa bài viết qua Form truyền thống (dự phòng)
    @PostMapping("/delete/{id}")
    public String deletePost(@PathVariable("id") Long id,
                             HttpSession session,
                             RedirectAttributes redirectAttributes,
                             @RequestHeader(value = "Referer", required = false) String referer) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) return "redirect:/login";

        Post post = postService.getPostById(id);
        if (post != null) {
            boolean isAuthor = post.getUser().getId().equals(currentUser.getId());
            boolean isAdmin = isUserAdmin(currentUser);

            if (isAuthor || isAdmin) {
                try {
                    postService.deletePost(id);
                    redirectAttributes.addFlashAttribute("successMessage", "Đã xóa bài viết thành công.");
                } catch (Exception e) {
                    redirectAttributes.addFlashAttribute("errorMessage", "Không thể xóa bài viết: " + e.getMessage());
                }
            } else {
                redirectAttributes.addFlashAttribute("errorMessage", "Bạn không có quyền xóa bài viết này!");
            }
        }

        return (referer != null && !referer.isEmpty()) ? "redirect:" + referer : "redirect:/post/feed";
    }

    // 8. Danh sách bài viết đã lưu
    @GetMapping("/saved")
    public String showSavedPosts(HttpSession session, Model model) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return "redirect:/login";
        }

        List<Post> savedPosts = postService.getSavedPosts(currentUser);
        List<User> myFriends = isUserAdmin(currentUser) ? Collections.emptyList() : friendshipService.getFriends(currentUser.getId());

        model.addAttribute("posts", savedPosts);
        model.addAttribute("myFriends", myFriends);
        model.addAttribute("isSavedPage", true);
        return "post/saved";
    }

    // 9. Lưu / Bỏ lưu bài viết (Hỗ trợ AJAX)
    @PostMapping("/save/{id}")
    @ResponseBody
    public Map<String, Object> toggleSave(@PathVariable("id") Long id, HttpSession session) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null || isUserAdmin(currentUser)) {
            return Map.of("success", false, "message", "Tài khoản quản trị viên không sử dụng tính năng lưu bài!");
        }
        boolean isSaved = postService.toggleSavePost(id, currentUser);
        return Map.of("success", true, "isSaved", isSaved);
    }

    // 10. Xử lý chia sẻ bài viết
    @PostMapping({"/share", "/share/{id}"})
    public String sharePost(
            @PathVariable(value = "id", required = false) Long pathId,
            @RequestParam(value = "postId", required = false) Long paramId,
            @RequestParam(value = "content", required = false) String content,
            @RequestParam(value = "caption", required = false) String caption,
            @RequestParam(value = "privacy", defaultValue = "PUBLIC") String privacy,
            @RequestParam(value = "redirectUrl", required = false) String redirectUrl,
            HttpSession session,
            RedirectAttributes redirectAttributes) {

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return "redirect:/login";
        }

        if (isUserAdmin(currentUser)) {
            redirectAttributes.addFlashAttribute("errorMessage", "Tài khoản Quản trị viên không thể chia sẻ bài viết!");
            return "redirect:/post/feed";
        }

        Long targetPostId = (pathId != null) ? pathId : paramId;
        String finalCaption = (content != null && !content.isBlank()) ? content : caption;

        if (targetPostId != null) {
            try {
                postService.sharePostToFeed(targetPostId, finalCaption, privacy, currentUser);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        return (redirectUrl != null && !redirectUrl.isBlank()) ? "redirect:" + redirectUrl : "redirect:/post/feed";
    }

    // 11. Chia sẻ nhanh cho bạn bè
    @PostMapping("/share/friend/{id}")
    @ResponseBody
    public Map<String, Object> shareToFriend(@PathVariable("id") Long id, HttpSession session) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null || isUserAdmin(currentUser)) {
            return Map.of("success", false, "message", "Tài khoản quản trị viên không thể chia sẻ!");
        }
        postService.shareToFriend(id);
        return Map.of("success", true);
    }

    // 12. API tăng số lượt chia sẻ bài viết
    @PostMapping("/share/count/{id}")
    @ResponseBody
    public Map<String, Object> incrementShareCount(@PathVariable("id") Long id) {
        Post post = postService.getPostById(id);
        if (post != null) {
            int currentShares = post.getShareCount() != null ? post.getShareCount() : 0;
            post.setShareCount(currentShares + 1);
            postRepository.save(post);
            return Map.of("success", true, "newShareCount", post.getShareCount());
        }
        return Map.of("success", false);
    }
}