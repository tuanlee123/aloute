package com.aloute.controller;

import com.aloute.dto.AdminUserDTO;
import com.aloute.entity.User;
import com.aloute.listener.ActiveUserListener;
import com.aloute.service.AdminService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;

    /**
     * BẢO MẬT & PHÂN QUYỀN TOÀN BỘ CONTROLLER:
     * Tự động chạy trước mọi Request (/admin, /admin/users, /admin/posts, /admin/api/...)
     * Ngăn chặn tuyệt đối việc User thường tự ý gõ URL để vào trang quản trị.
     */
    @ModelAttribute
    public void checkAdminAccess(HttpSession session) {
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        // 1. Chưa đăng nhập -> Chặn với mã lỗi 401 Unauthorized
        if (currentUser == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Vui lòng đăng nhập tài khoản quản trị.");
        }

        // 2. Kiểm tra role ROLE_ADMIN từ entity User
        boolean isAdmin = currentUser.getRoles() != null
                && currentUser.getRoles().stream().anyMatch(r -> "ROLE_ADMIN".equalsIgnoreCase(r.getName()));

        // 3. Đã đăng nhập nhưng chỉ là User thường -> Chặn với mã lỗi 403 Forbidden
        if (!isAdmin) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Bạn không có quyền truy cập trang quản trị!");
        }
    }

    @GetMapping({ "", "/" })
    public String dashboard(Model model) {
        List<AdminUserDTO> regularUsers = getOnlyRegularUsers();
        Set<Long> onlineIds = ActiveUserListener.getOnlineUserIds();

        model.addAttribute("totalUsers", regularUsers.size());
        model.addAttribute("activeUsers", ActiveUserListener.getActiveUsersCount());

        // Gửi danh sách ID user đang online sang JSP để hiển thị huy hiệu xanh/xám ban đầu
        model.addAttribute("onlineUserIds", onlineIds);

        model.addAttribute("totalPosts", adminService.totalPosts());
        model.addAttribute("postsToday", adminService.postsToday());
        model.addAttribute("usersWithStats", regularUsers);

        var posts = adminService.allPosts();
        model.addAttribute("recentPosts", posts.subList(0, Math.min(5, posts.size())));

        return "admin/dashboard";
    }

    // Endpoint API phục vụ vẽ biểu đồ thời gian thực (Real-time Live Chart) & đồng bộ bảng trạng thái
    @GetMapping("/api/stats/realtime")
    @ResponseBody
    public Map<String, Object> realtimeStats() {
        Map<String, Object> data = new HashMap<>();
        data.put("timestamp", new SimpleDateFormat("HH:mm:ss").format(new Date()));

        // 1. Số lượng phục vụ vẽ biểu đồ và thẻ tổng quan
        data.put("activeCount", ActiveUserListener.getActiveUsersCount());
        data.put("totalUsers", getOnlyRegularUsers().size());
        data.put("totalPosts", adminService.totalPosts());

        // 2. Danh sách ID đang online để JS đổi nhãn Trực tuyến/Ngoại tuyến ngay lập tức
        data.put("onlineUserIds", ActiveUserListener.getOnlineUserIds());

        return data;
    }

    @GetMapping("/users")
    public String users(Model model) {
        model.addAttribute("users", getOnlyRegularUsers());
        model.addAttribute("onlineUserIds", ActiveUserListener.getOnlineUserIds());
        return "admin/manage-users";
    }

    @PostMapping("/users/{id}/toggle-lock")
    public String toggleLock(@PathVariable Long id, HttpSession session, RedirectAttributes ra) {
        User admin = (User) session.getAttribute("currentUser");
        try {
            boolean active = adminService.toggleActive(id, admin.getId());
            ra.addFlashAttribute("msg", active ? "Đã mở khóa tài khoản thành công." : "Đã khóa tài khoản thành công.");
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
            ra.addFlashAttribute("msg", "Đã xóa bài viết vi phạm thành công.");
        } catch (Exception e) {
            ra.addFlashAttribute("err", "Không xóa được bài viết: " + e.getMessage());
        }
        return "redirect:/admin/posts";
    }

    /**
     * Hàm phụ trợ: Lọc bỏ tài khoản Admin khỏi danh sách thống kê người dùng
     */
    private List<AdminUserDTO> getOnlyRegularUsers() {
        List<AdminUserDTO> allUsers = adminService.allUsersWithStats();
        if (allUsers == null) return List.of();

        return allUsers.stream()
                .filter(u -> u.getUsername() != null 
                        && !u.getUsername().equalsIgnoreCase("adminutealo")
                        && !u.getUsername().toLowerCase().contains("admin"))
                .toList();
    }
}