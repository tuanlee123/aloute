package com.aloute.controller;

import com.aloute.entity.Friendship;
import com.aloute.entity.User;
import com.aloute.repository.UserRepository;
import com.aloute.service.FriendshipService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.*;

@Controller
@RequestMapping("/friends")
@RequiredArgsConstructor
public class FriendController {

    private final FriendshipService friendshipService;
    private final UserRepository userRepository;

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

    // Trang Bạn bè: Cho phép Admin xem danh sách bạn bè của bất kỳ user nào qua userId
    @GetMapping({"", "/"})
    public String showFriendsPage(
            @RequestParam(value = "userId", required = false) Long userId,
            @RequestParam(value = "tab", required = false) String tab,
            @RequestParam(value = "search", required = false) String search,
            HttpSession session, 
            Model model) {

        User currentUser = getLoggedInUser(session);
        if (currentUser == null) return "redirect:/login";

        boolean isAdmin = isUserAdmin(currentUser);

        // Xác định đối tượng đang xem
        Long targetId = (userId != null) ? userId : currentUser.getId();
        User viewUser = userRepository.findById(targetId).orElse(currentUser);
        boolean isOwner = currentUser.getId().equals(viewUser.getId()) && !isAdmin;

        model.addAttribute("viewUser", viewUser);
        model.addAttribute("isOwner", isOwner);
        model.addAttribute("currentUserId", currentUser.getId());

        // Nếu là Admin hoặc xem bạn bè người khác thì mặc định chỉ hiển thị tab "all"
        if (!isOwner || isAdmin) {
            tab = "all";
        } else if (tab == null || tab.isEmpty()) {
            tab = "all";
        }
        model.addAttribute("activeTab", tab);

        // 1. Danh sách bạn bè của người đang được xem
        List<User> friends = friendshipService.getFriends(viewUser.getId());
        long totalFriendsCount = friendshipService.countFriends(viewUser.getId());
        model.addAttribute("friends", friends);
        model.addAttribute("totalFriendsCount", totalFriendsCount);

        // Tính bạn chung (Admin không tính bạn chung)
        Map<Long, Integer> friendMutualCounts = new HashMap<>();
        if (!isAdmin) {
            for (User friend : friends) {
                friendMutualCounts.put(friend.getId(), friendshipService.countMutualFriends(currentUser.getId(), friend.getId()));
            }
        }
        model.addAttribute("friendMutualCounts", friendMutualCounts);

        // 2. Danh sách lời mời kết bạn (Chỉ user thường xem trang của chính mình)
        if (isOwner && !isAdmin) {
            List<Friendship> requests = friendshipService.getPendingRequests(currentUser.getId());
            model.addAttribute("requests", requests);

            Map<Long, Integer> requestMutualCounts = new HashMap<>();
            for (Friendship f : requests) {
                requestMutualCounts.put(f.getId(), friendshipService.countMutualFriends(currentUser.getId(), f.getRequester().getId()));
            }
            model.addAttribute("requestMutualCounts", requestMutualCounts);
        }

        // 3. Kết quả tìm kiếm kết bạn
        if (isOwner && !isAdmin && "search".equals(tab) && search != null && !search.trim().isEmpty()) {
            List<User> searchResults = friendshipService.searchUsers(search.trim());
            searchResults.removeIf(u -> u.getId().equals(currentUser.getId()) || isUserAdmin(u));
            
            Map<Long, String> statusMap = new HashMap<>();
            Map<Long, Integer> searchMutualCounts = new HashMap<>();
            for (User u : searchResults) {
                statusMap.put(u.getId(), friendshipService.getFriendshipStatus(currentUser.getId(), u.getId()));
                searchMutualCounts.put(u.getId(), friendshipService.countMutualFriends(currentUser.getId(), u.getId()));
            }
            model.addAttribute("searchResults", searchResults);
            model.addAttribute("statusMap", statusMap);
            model.addAttribute("searchMutualCounts", searchMutualCounts);
            model.addAttribute("searchKeyword", search.trim());
        }

        return "friends";
    }

    // Chấp nhận lời mời kết bạn - Chặn Admin
    @PostMapping("/accept/{id}")
    public String acceptFriend(@PathVariable("id") Long friendshipId, 
                               HttpServletRequest request, 
                               HttpSession session,
                               RedirectAttributes ra) {
        User currentUser = getLoggedInUser(session);
        if (currentUser != null) {
            if (isUserAdmin(currentUser)) {
                ra.addFlashAttribute("errorMessage", "Tài khoản Quản trị viên không thể chấp nhận kết bạn!");
            } else {
                friendshipService.acceptRequest(friendshipId, currentUser.getId());
            }
        }
        String referer = request.getHeader("Referer");
        return "redirect:" + (referer != null ? referer : "/friends?tab=requests");
    }

    // Xóa/Từ chối lời mời kết bạn - Chặn Admin
    @PostMapping("/reject/{id}")
    public String rejectFriend(@PathVariable("id") Long friendshipId, 
                               HttpServletRequest request, 
                               HttpSession session,
                               RedirectAttributes ra) {
        User currentUser = getLoggedInUser(session);
        if (currentUser != null) {
            if (isUserAdmin(currentUser)) {
                ra.addFlashAttribute("errorMessage", "Tài khoản Quản trị viên không thể từ chối kết bạn!");
            } else {
                friendshipService.deleteOrReject(friendshipId, currentUser.getId());
            }
        }
        String referer = request.getHeader("Referer");
        return "redirect:" + (referer != null ? referer : "/friends?tab=requests");
    }

    // Gửi lời mời kết bạn - Chặn Admin gửi hoặc kết bạn với Admin
    @PostMapping("/add/{targetUserId}")
    public String addFriend(@PathVariable("targetUserId") Long targetUserId,
                            HttpServletRequest request,
                            HttpSession session,
                            RedirectAttributes ra) {
        User currentUser = getLoggedInUser(session);
        if (currentUser != null) {
            User targetUser = userRepository.findById(targetUserId).orElse(null);
            if (isUserAdmin(currentUser)) {
                ra.addFlashAttribute("errorMessage", "Tài khoản Quản trị viên không thể gửi lời mời kết bạn!");
            } else if (targetUser != null && isUserAdmin(targetUser)) {
                ra.addFlashAttribute("errorMessage", "Không thể gửi lời mời kết bạn tới tài khoản Quản trị viên!");
            } else {
                friendshipService.sendFriendRequest(currentUser.getId(), targetUserId);
            }
        }
        String referer = request.getHeader("Referer");
        return "redirect:" + (referer != null ? referer : "/friends");
    }

    // HỦY KẾT BẠN - Chặn Admin
    @PostMapping("/unfriend/{targetUserId}")
    public String unfriend(@PathVariable("targetUserId") Long targetUserId, 
                           HttpServletRequest request, 
                           HttpSession session,
                           RedirectAttributes ra) {
        User currentUser = getLoggedInUser(session);
        if (currentUser != null) {
            if (isUserAdmin(currentUser)) {
                ra.addFlashAttribute("errorMessage", "Tài khoản Quản trị viên không thể thực hiện thao tác này!");
            } else {
                friendshipService.unfriend(currentUser.getId(), targetUserId);
            }
        }
        String referer = request.getHeader("Referer");
        return "redirect:" + (referer != null ? referer : "/profile?userId=" + targetUserId);
    }

    // API lấy danh sách bạn chung
    @GetMapping("/mutual/{targetUserId}")
    @ResponseBody
    public List<Map<String, Object>> getMutualFriendsApi(@PathVariable("targetUserId") Long targetUserId, HttpSession session) {
        User currentUser = getLoggedInUser(session);
        if (currentUser == null || isUserAdmin(currentUser)) return Collections.emptyList();

        List<User> mutualList = friendshipService.getMutualFriends(currentUser.getId(), targetUserId);
        return mutualList.stream().map(u -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", u.getId());
            map.put("fullName", u.getFullName());
            map.put("avatar", u.getAvatar());
            return map;
        }).toList();
    }
}