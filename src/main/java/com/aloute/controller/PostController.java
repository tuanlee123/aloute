package com.aloute.controller;

import com.aloute.dto.PostCreateDTO;
import com.aloute.entity.Post;
import com.aloute.entity.User;
import com.aloute.repository.PostRepository;
import com.aloute.service.FriendshipService;
import com.aloute.service.PostService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Collections;
import java.util.List;

@Controller
@RequestMapping("/post")
public class PostController {

    @Autowired
    private PostService postService;

    @Autowired
    private PostRepository postRepository;

    @Autowired
    private FriendshipService friendshipService;

    // 1. Xem bảng tin: Đã phân quyền riêng tư và nạp danh sách bạn bè cho Modal chia sẻ
    @GetMapping({ "", "/feed" })
    public String showFeed(HttpSession session, Model model) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return "redirect:/login";
        }

        // Lấy danh sách bạn bè của người dùng hiện tại
        List<User> myFriends = friendshipService.getFriends(currentUser.getId());
        List<Long> friendIds = myFriends.stream().map(User::getId).toList();

        // Lọc bài viết Bảng tin an toàn (bảo vệ bài viết PRIVATE)
        List<Post> posts;
        if (friendIds.isEmpty()) {
            posts = postRepository.findFeedPostsSecure(currentUser.getId(), Collections.singletonList(-1L));
        } else {
            posts = postRepository.findFeedPostsSecure(currentUser.getId(), friendIds);
        }

        model.addAttribute("posts", posts);
        model.addAttribute("myFriends", myFriends); // Cung cấp dữ liệu cho modal Utebox
        return "post/feed";
    }

    // 2. Mở xem chi tiết một bài viết qua URL: /post/{id}
    // CÓ CƠ CHẾ BẢO MẬT CHỐNG IDOR: Ngăn chặn truy cập bài viết PRIVATE trái phép
    @GetMapping("/{id:[0-9]+}")
    public String viewSinglePost(@PathVariable("id") Long id,
                                 HttpSession session,
                                 Model model,
                                 RedirectAttributes redirectAttributes) {
        // Bắt buộc phải đăng nhập
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return "redirect:/login?requiredAuth=true";
        }

        // Tìm bài viết theo ID
        Post post = postService.getPostById(id);
        if (post == null) {
            redirectAttributes.addFlashAttribute("errorMessage", "Bài viết không tồn tại hoặc đã bị xóa!");
            return "redirect:/post/feed";
        }

        // KIỂM TRA QUYỀN TRUY CẬP (BACKEND SECURITY)
        boolean isAuthor = post.getUser().getId().equals(currentUser.getId());

        if (!isAuthor) {
            String privacy = post.getPrivacy() != null ? post.getPrivacy().toUpperCase() : "PUBLIC";

            // TRƯỜNG HỢP 1: Bài viết "Chỉ mình tôi" (PRIVATE) -> Chặn 100% dù có trực tiếp URL
            if ("PRIVATE".equals(privacy)) {
                redirectAttributes.addFlashAttribute("errorMessage", "Bạn không có quyền xem bài viết này!");
                return "redirect:/post/feed";
            }

            // TRƯỜNG HỢP 2: Bài viết "Bạn bè" (FRIENDS) -> Kiểm tra quan hệ bạn bè từ database
            if ("FRIENDS".equals(privacy)) {
                String friendshipStatus = friendshipService.getFriendshipStatus(currentUser.getId(), post.getUser().getId());
                if (!"FRIENDS".equalsIgnoreCase(friendshipStatus)) {
                    redirectAttributes.addFlashAttribute("errorMessage", "Bài viết này chỉ dành cho bạn bè của tác giả!");
                    return "redirect:/post/feed";
                }
            }
        }

        // Hợp lệ: Nạp dữ liệu và hiển thị view
        List<User> myFriends = friendshipService.getFriends(currentUser.getId());
        model.addAttribute("post", post);
        model.addAttribute("posts", List.of(post)); // Tương thích render lưới ảnh/comment
        model.addAttribute("myFriends", myFriends);
        return "post/single-post";
    }

    // 3. Hiển thị trang tạo bài viết riêng biệt
    @GetMapping("/create")
    public String showCreateForm(Model model) {
        model.addAttribute("postCreateDTO", new PostCreateDTO());
        return "post/create-post";
    }

    // 4. Xử lý tạo bài viết mới
    @PostMapping("/create")
    public String createPost(@ModelAttribute PostCreateDTO postCreateDTO,
                             @RequestParam(value = "redirectUrl", required = false) String redirectUrl,
                             HttpSession session) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return "redirect:/login";
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
    public String showEditForm(@PathVariable("id") Long id, Model model) {
        Post post = postService.getPostById(id);
        model.addAttribute("post", post);
        return "post/edit-post";
    }

    // 6. Xử lý cập nhật bài viết
    @PostMapping("/edit/{id}")
    public String updatePost(@PathVariable("id") Long id, 
                             @RequestParam("content") String content,
                             @RequestParam(value = "privacy", defaultValue = "PUBLIC") String privacy,
                             @RequestParam(value = "redirectUrl", required = false) String redirectUrl) {
        try {
            postService.updatePost(id, content, privacy);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return (redirectUrl != null && !redirectUrl.isBlank()) ? "redirect:" + redirectUrl : "redirect:/post/feed";
    }

    // 7. Xử lý xóa bài viết
    @PostMapping("/delete/{id}")
    public String deletePost(@PathVariable("id") Long id,
                             @RequestHeader(value = "Referer", required = false) String referer) {
        try {
            postService.deletePost(id);
        } catch (Exception e) {
            e.printStackTrace();
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
        List<User> myFriends = friendshipService.getFriends(currentUser.getId());

        model.addAttribute("posts", savedPosts);
        model.addAttribute("myFriends", myFriends);
        model.addAttribute("isSavedPage", true);
        return "post/saved";
    }

    // 9. Lưu / Bỏ lưu bài viết (Hỗ trợ AJAX)
    @PostMapping("/save/{id}")
    @ResponseBody
    public java.util.Map<String, Object> toggleSave(@PathVariable("id") Long id, HttpSession session) {
        User currentUser = (User) session.getAttribute("currentUser");
        boolean isSaved = postService.toggleSavePost(id, currentUser);
        return java.util.Map.of("success", true, "isSaved", isSaved);
    }

    // 10. Xử lý chia sẻ bài viết lên Bảng tin: Hỗ trợ linh hoạt cả 2 URL để tránh lỗi 404
    @PostMapping({"/share", "/share/{id}"})
    public String sharePost(
            @PathVariable(value = "id", required = false) Long pathId,
            @RequestParam(value = "postId", required = false) Long paramId,
            @RequestParam(value = "content", required = false) String content,
            @RequestParam(value = "caption", required = false) String caption,
            @RequestParam(value = "privacy", defaultValue = "PUBLIC") String privacy,
            @RequestParam(value = "redirectUrl", required = false) String redirectUrl,
            HttpSession session) {

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return "redirect:/login";
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
    public java.util.Map<String, Object> shareToFriend(@PathVariable("id") Long id) {
        postService.shareToFriend(id);
        return java.util.Map.of("success", true);
    }
    
 // API tăng số lượt chia sẻ bài viết (dùng khi gửi qua Utebox hoặc chia sẻ link)
    @PostMapping("/share/count/{id}")
    @ResponseBody
    public java.util.Map<String, Object> incrementShareCount(@PathVariable("id") Long id) {
        Post post = postService.getPostById(id);
        if (post != null) {
            int currentShares = post.getShareCount() != null ? post.getShareCount() : 0;
            post.setShareCount(currentShares + 1);
            postRepository.save(post);
            return java.util.Map.of("success", true, "newShareCount", post.getShareCount());
        }
        return java.util.Map.of("success", false);
    }
}