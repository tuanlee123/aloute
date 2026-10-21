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

    // Trang Bạn bè: Xem được cả bạn bè của mình và bạn bè của người khác qua userId
    @GetMapping({"", "/"})
    public String showFriendsPage(
            @RequestParam(value = "userId", required = false) Long userId,
            @RequestParam(value = "tab", required = false) String tab,
            @RequestParam(value = "search", required = false) String search,
            HttpSession session, 
            Model model) {

        User currentUser = getLoggedInUser(session);
        if (currentUser == null) return "redirect:/login";

        // Xác định đối tượng đang xem: nếu có truyền userId thì xem bạn của người đó, ngược lại xem của chính mình
        Long targetId = (userId != null) ? userId : currentUser.getId();
        User viewUser = userRepository.findById(targetId).orElse(currentUser);
        boolean isOwner = currentUser.getId().equals(viewUser.getId());

        model.addAttribute("viewUser", viewUser);
        model.addAttribute("isOwner", isOwner);
        model.addAttribute("currentUserId", currentUser.getId());

        // Nếu xem bạn bè người khác thì mặc định chỉ mở tab tất cả bạn bè (all)
        if (!isOwner) {
            tab = "all";
        } else if (tab == null || tab.isEmpty()) {
            tab = "all";
        }
        model.addAttribute("activeTab", tab);

        // 1. Danh sách bạn bè của người đang được xem (viewUser)
        List<User> friends = friendshipService.getFriends(viewUser.getId());
        long totalFriendsCount = friendshipService.countFriends(viewUser.getId());
        model.addAttribute("friends", friends);
        model.addAttribute("totalFriendsCount", totalFriendsCount);

        // Tính bạn chung của từng người trong danh sách với currentUser
        Map<Long, Integer> friendMutualCounts = new HashMap<>();
        for (User friend : friends) {
            friendMutualCounts.put(friend.getId(), friendshipService.countMutualFriends(currentUser.getId(), friend.getId()));
        }
        model.addAttribute("friendMutualCounts", friendMutualCounts);

        // 2. Danh sách lời mời kết bạn (Chỉ chính chủ mới có)
        if (isOwner) {
            List<Friendship> requests = friendshipService.getPendingRequests(currentUser.getId());
            model.addAttribute("requests", requests);

            Map<Long, Integer> requestMutualCounts = new HashMap<>();
            for (Friendship f : requests) {
                requestMutualCounts.put(f.getId(), friendshipService.countMutualFriends(currentUser.getId(), f.getRequester().getId()));
            }
            model.addAttribute("requestMutualCounts", requestMutualCounts);
        }

        // 3. Kết quả tìm kiếm (khi tìm trên thanh tìm kiếm của trang bạn bè)
        if (isOwner && "search".equals(tab) && search != null && !search.trim().isEmpty()) {
            List<User> searchResults = friendshipService.searchUsers(search.trim());
            searchResults.removeIf(u -> u.getId().equals(currentUser.getId()));
            
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

    // Chấp nhận lời mời kết bạn
    @PostMapping("/accept/{id}")
    public String acceptFriend(@PathVariable("id") Long friendshipId, 
                               HttpServletRequest request, 
                               HttpSession session) {
        User currentUser = getLoggedInUser(session);
        if (currentUser != null) {
            friendshipService.acceptRequest(friendshipId, currentUser.getId());
        }
        String referer = request.getHeader("Referer");
        return "redirect:" + (referer != null ? referer : "/friends?tab=requests");
    }

    // Xóa/Từ chối lời mời kết bạn
    @PostMapping("/reject/{id}")
    public String rejectFriend(@PathVariable("id") Long friendshipId, 
                               HttpServletRequest request, 
                               HttpSession session) {
        User currentUser = getLoggedInUser(session);
        if (currentUser != null) {
            friendshipService.deleteOrReject(friendshipId, currentUser.getId());
        }
        String referer = request.getHeader("Referer");
        return "redirect:" + (referer != null ? referer : "/friends?tab=requests");
    }

    // Gửi lời mời kết bạn
    @PostMapping("/add/{targetUserId}")
    public String addFriend(@PathVariable("targetUserId") Long targetUserId,
                            HttpServletRequest request,
                            HttpSession session) {
        User currentUser = getLoggedInUser(session);
        if (currentUser != null) {
            friendshipService.sendFriendRequest(currentUser.getId(), targetUserId);
        }
        String referer = request.getHeader("Referer");
        return "redirect:" + (referer != null ? referer : "/friends");
    }

    // HỦY KẾT BẠN (Xóa bạn bè thật khỏi Database)
    @PostMapping("/unfriend/{targetUserId}")
    public String unfriend(@PathVariable("targetUserId") Long targetUserId, 
                           HttpServletRequest request, 
                           HttpSession session) {
        User currentUser = getLoggedInUser(session);
        if (currentUser != null) {
            friendshipService.unfriend(currentUser.getId(), targetUserId);
        }
        String referer = request.getHeader("Referer");
        return "redirect:" + (referer != null ? referer : "/profile?userId=" + targetUserId);
    }

    // API lấy danh sách bạn chung cho Modal
    @GetMapping("/mutual/{targetUserId}")
    @ResponseBody
    public List<Map<String, Object>> getMutualFriendsApi(@PathVariable("targetUserId") Long targetUserId, HttpSession session) {
        User currentUser = getLoggedInUser(session);
        if (currentUser == null) return Collections.emptyList();

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