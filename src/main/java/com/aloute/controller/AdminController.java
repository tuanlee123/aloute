package com.aloute.controller;

import com.aloute.dto.AdminUserDTO;
import com.aloute.entity.Post;
import com.aloute.entity.User;
import com.aloute.listener.ActiveUserListener;
import com.aloute.service.AdminService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
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

    // 1. Quản lý người dùng: Tìm kiếm & Phân trang (mặc định 10 dòng/trang)
    @GetMapping("/users")
    public String users(
            @RequestParam(value = "keyword", required = false, defaultValue = "") String keyword,
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size,
            Model model) {

        Pageable pageable = PageRequest.of(Math.max(0, page), size);
        Page<AdminUserDTO> userPage = adminService.searchUsersWithStats(keyword, pageable);

        model.addAttribute("userPage", userPage);
        model.addAttribute("users", userPage.getContent());
        model.addAttribute("keyword", keyword);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", userPage.getTotalPages());
        model.addAttribute("totalElements", userPage.getTotalElements());
        model.addAttribute("onlineUserIds", ActiveUserListener.getOnlineUserIds());

        return "admin/manage-users";
    }

    // Xử lý Khóa/Mở tài khoản bằng AJAX: Giữ nguyên trang, cập nhật dữ liệu JSON tức thì cho SweetAlert2
    @PostMapping("/api/users/{id}/toggle-lock")
    @ResponseBody
    public ResponseEntity<?> toggleLockAjax(@PathVariable Long id, HttpSession session) {
        User admin = (User) session.getAttribute("currentUser");
        try {
            boolean active = adminService.toggleActive(id, admin.getId());
            return ResponseEntity.ok(Map.of(
                "success", true,
                "active", active,
                "message", active ? "Đã mở khóa tài khoản thành công." : "Đã khóa tài khoản thành công."
            ));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }

    // Dự phòng: Form Submit truyền thống - Tự động quay về đúng trang trước đó (Referer)
    @PostMapping("/users/{id}/toggle-lock")
    public String toggleLock(@PathVariable Long id, 
                             HttpServletRequest request, 
                             HttpSession session, 
                             RedirectAttributes ra) {
        User admin = (User) session.getAttribute("currentUser");
        try {
            boolean active = adminService.toggleActive(id, admin.getId());
            ra.addFlashAttribute("msg", active ? "Đã mở khóa tài khoản thành công." : "Đã khóa tài khoản thành công.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("err", e.getMessage());
        }

        String referer = request.getHeader("Referer");
        if (referer != null && !referer.isBlank()) {
            return "redirect:" + referer;
        }
        return "redirect:/admin";
    }

    // 2. Quản lý bài viết: Tìm kiếm & Phân trang (mặc định 10 dòng/trang)
    @GetMapping("/posts")
    public String posts(
            @RequestParam(value = "keyword", required = false, defaultValue = "") String keyword,
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size,
            Model model) {

        Pageable pageable = PageRequest.of(Math.max(0, page), size);
        Page<Post> postPage = adminService.searchPosts(keyword, pageable);

        model.addAttribute("postPage", postPage);
        model.addAttribute("posts", postPage.getContent());
        model.addAttribute("keyword", keyword);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", postPage.getTotalPages());
        model.addAttribute("totalElements", postPage.getTotalElements());

        return "admin/manage-posts";
    }

    // API Xóa bài viết qua AJAX mượt mà cho SweetAlert2
    @PostMapping("/api/posts/{id}/delete")
    @ResponseBody
    public ResponseEntity<?> deletePostAjax(@PathVariable Long id) {
        try {
            adminService.deletePost(id);
            return ResponseEntity.ok(Map.of(
                "success", true, 
                "message", "Đã xóa bài viết vi phạm thành công!"
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false, 
                "message", "Không thể xóa bài viết: " + e.getMessage()
            ));
        }
    }

    // Dự phòng: Form Submit truyền thống xóa bài viết
    @PostMapping("/posts/{id}/delete")
    public String deletePost(@PathVariable Long id, 
                             HttpServletRequest request, 
                             RedirectAttributes ra) {
        try {
            adminService.deletePost(id);
            ra.addFlashAttribute("msg", "Đã xóa bài viết vi phạm thành công.");
        } catch (Exception e) {
            ra.addFlashAttribute("err", "Không xóa được bài viết: " + e.getMessage());
        }

        String referer = request.getHeader("Referer");
        if (referer != null && !referer.isBlank()) {
            return "redirect:" + referer;
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