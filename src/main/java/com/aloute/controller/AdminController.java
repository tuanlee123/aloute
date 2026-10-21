package com.aloute.controller;

import com.aloute.entity.User;
import com.aloute.service.AdminService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

// Quyền ROLE_ADMIN đã được AuthInterceptor kiểm tra cho toàn bộ /admin/**
@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;

    @GetMapping({"", "/"})
    public String dashboard(Model model) {
        model.addAttribute("totalUsers", adminService.totalUsers());
        model.addAttribute("totalPosts", adminService.totalPosts());
        model.addAttribute("postsToday", adminService.postsToday());
        List<User> users = adminService.allUsers();
        var posts = adminService.allPosts();
        model.addAttribute("recentUsers", users.subList(0, Math.min(5, users.size())));
        model.addAttribute("recentPosts", posts.subList(0, Math.min(5, posts.size())));
        return "admin/dashboard";
    }

    @GetMapping("/users")
    public String users(Model model) {
        model.addAttribute("users", adminService.allUsers());
        return "admin/manage-users";
    }

    @PostMapping("/users/{id}/toggle-lock")
    public String toggleLock(@PathVariable Long id, HttpSession session, RedirectAttributes ra) {
        User admin = (User) session.getAttribute("currentUser");
        try {
            boolean active = adminService.toggleActive(id, admin.getId());
            ra.addFlashAttribute("msg", active ? "Đã mở khóa tài khoản." : "Đã khóa tài khoản.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("err", e.getMessage());
        }
        return "redirect:/admin/users";
    }

    @GetMapping("/posts")
    public String posts(Model model) {
        model.addAttribute("posts", adminService.allPosts());
        return "admin/manage-posts";
    }

    @PostMapping("/posts/{id}/delete")
    public String deletePost(@PathVariable Long id, RedirectAttributes ra) {
        try {
            adminService.deletePost(id);
            ra.addFlashAttribute("msg", "Đã xóa bài viết vi phạm.");
        } catch (Exception e) {
            ra.addFlashAttribute("err", "Không xóa được bài viết: " + e.getMessage());
        }
        return "redirect:/admin/posts";
    }
}
