package com.aloute.controller;

import com.aloute.dto.PostCreateDTO;
import com.aloute.entity.Post;
import com.aloute.service.PostService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequestMapping("/post")
public class PostController {

    @Autowired
    private PostService postService;

    // Xem bảng tin: /post hoặc /post/feed
    @GetMapping({"", "/feed"})
    public String showFeed(Model model) {
        List<Post> posts = postService.getAllPosts();
        model.addAttribute("posts", posts);
        return "post/feed"; // Trỏ đến WEB-INF/views/post/feed.jsp
    }

    // Hiển thị trang tạo bài viết riêng biệt (create-post.jsp)
    @GetMapping("/create")
    public String showCreateForm(Model model) {
        model.addAttribute("postCreateDTO", new PostCreateDTO());
        return "post/create-post"; // Trỏ đến WEB-INF/views/post/create-post.jsp
    }

    // Xử lý tạo bài viết mới (nhận dữ liệu từ form qua DTO)
    @PostMapping("/create")
    public String createPost(@ModelAttribute PostCreateDTO postCreateDTO) {
        try {
            postService.createPost(postCreateDTO);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "redirect:/post/feed";
    }

    // Hiển thị form chỉnh sửa bài viết
    @GetMapping("/edit/{id}")
    public String showEditForm(@PathVariable("id") Long id, Model model) {
        Post post = postService.getPostById(id);
        model.addAttribute("post", post);
        return "post/edit-post"; // Trỏ đến WEB-INF/views/post/edit-post.jsp
    }

    // Xử lý cập nhật bài viết
    @PostMapping("/edit/{id}")
    public String updatePost(@PathVariable("id") Long id,
                             @RequestParam("content") String content,
                             @RequestParam(value = "privacy", defaultValue = "PUBLIC") String privacy) {
        try {
            postService.updatePost(id, content, privacy);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "redirect:/post/feed";
    }

    // Xử lý xóa bài viết
    @PostMapping("/delete/{id}")
    public String deletePost(@PathVariable("id") Long id) {
        try {
            postService.deletePost(id);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "redirect:/post/feed";
        
    }
    
 // Danh sách bài viết đã lưu
    @GetMapping("/saved")
    public String showSavedPosts(Model model) {
        List<Post> savedPosts = postService.getSavedPosts();
        model.addAttribute("posts", savedPosts);
        model.addAttribute("isSavedPage", true);
        return "post/saved";
    }

    // Lưu / Bỏ lưu bài viết (Hỗ trợ Ajax)
    @PostMapping("/save/{id}")
    @ResponseBody
    public java.util.Map<String, Object> toggleSave(@PathVariable("id") Long id) {
        boolean isSaved = postService.toggleSavePost(id);
        return java.util.Map.of("success", true, "isSaved", isSaved);
    }

    // Chia sẻ lên Feed của mình
    @PostMapping("/share/{id}")
    public String sharePost(@PathVariable("id") Long id,
                            @RequestParam(value = "caption", required = false) String caption,
                            @RequestParam(value = "privacy", defaultValue = "PUBLIC") String privacy) {
        try {
            postService.sharePostToFeed(id, caption, privacy);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "redirect:/post/feed";
    }

    // Chia sẻ nhanh cho bạn bè
    @PostMapping("/share/friend/{id}")
    @ResponseBody
    public java.util.Map<String, Object> shareToFriend(@PathVariable("id") Long id) {
        postService.shareToFriend(id);
        return java.util.Map.of("success", true);
    }
}