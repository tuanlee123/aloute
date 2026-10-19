package com.aloute.controller;

import com.aloute.entity.Post;
import com.aloute.service.PostService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Controller
public class PostController {

    @Autowired
    private PostService postService;

    // Trang bảng tin hiển thị danh sách bài viết
    @GetMapping("/feed")
    public String showFeed(Model model) {
        List<Post> posts = postService.getAllPosts();
        model.addAttribute("posts", posts);
        return "feed";
    }

    // Xử lý tạo bài viết
    @PostMapping("/post/create")
    public String createPost(@RequestParam("content") String content,
                             @RequestParam("image") MultipartFile image) {
        try {
            postService.createPost(content, image);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "redirect:/feed";
    }
}