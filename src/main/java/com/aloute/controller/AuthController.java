package com.aloute.controller;

import com.aloute.dto.ChangePasswordDTO;
import com.aloute.dto.LoginDTO;
import com.aloute.dto.RegisterDTO;
import com.aloute.dto.ResetPasswordDTO;
import com.aloute.dto.UpdateProfileDTO;
import com.aloute.dto.VerifyOtpDTO;
import com.aloute.entity.Post;
import com.aloute.entity.User;
import com.aloute.jwt.JwtUtils;
import com.aloute.listener.ActiveUserListener;
import com.aloute.repository.PostRepository;
import com.aloute.repository.UserRepository;
import com.aloute.service.AuthService;
import com.aloute.service.FriendshipService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequiredArgsConstructor
public class AuthController {

	private final AuthService authService;
	private final PostRepository postRepository;
	private final UserRepository userRepository;
	private final FriendshipService friendshipService;
	private final JwtUtils jwtUtils;

	// --- 1. ĐĂNG KÝ ---
	@GetMapping("/register")
	public String showRegisterForm(Model model, HttpSession session) {
		if (session != null && session.getAttribute("currentUser") != null) {
			Boolean isAdmin = (Boolean) session.getAttribute("isAdminUser");
			return (isAdmin != null && isAdmin) ? "redirect:/admin" : "redirect:/";
		}
		model.addAttribute("registerDTO", new RegisterDTO());
		return "auth/register";
	}

	@PostMapping("/register")
	public String processRegister(@ModelAttribute("registerDTO") RegisterDTO registerDTO, Model model) {
		try {
			authService.register(registerDTO);
			return "redirect:/verify-otp?email=" + registerDTO.getEmail();
		} catch (IllegalArgumentException e) {
			model.addAttribute("error", e.getMessage());
			return "auth/register";
		}
	}

	// --- 2. XÁC THỰC KÍCH HOẠT OTP ---
	@GetMapping("/verify-otp")
	public String showVerifyOtpForm(@RequestParam("email") String email, Model model) {
		VerifyOtpDTO dto = new VerifyOtpDTO();
		dto.setEmail(email);
		model.addAttribute("verifyOtpDTO", dto);
		return "auth/verify-otp";
	}

	@PostMapping("/verify-otp")
	public String processVerifyOtp(@ModelAttribute("verifyOtpDTO") VerifyOtpDTO dto, Model model) {
		try {
			authService.verifyAccount(dto.getEmail(), dto.getOtp());
			return "redirect:/login?activated=true";
		} catch (IllegalArgumentException e) {
			model.addAttribute("error", e.getMessage());
			return "auth/verify-otp";
		}
	}

	@GetMapping("/resend-otp")
	public String resendOtp(@RequestParam("email") String email, Model model) {
		try {
			authService.resendActivationOtp(email);
			return "redirect:/verify-otp?email=" + email + "&resent=true";
		} catch (IllegalArgumentException e) {
			model.addAttribute("error", e.getMessage());
			return "auth/verify-otp";
		}
	}

	// --- 3. ĐĂNG NHẬP (TÍCH HỢP ACCESS TOKEN & REFRESH TOKEN) ---
	@GetMapping("/login")
	public String showLoginForm(Model model, HttpSession session) {
		if (session != null && session.getAttribute("currentUser") != null) {
			Boolean isAdmin = (Boolean) session.getAttribute("isAdminUser");
			return (isAdmin != null && isAdmin) ? "redirect:/admin" : "redirect:/";
		}
		model.addAttribute("loginDTO", new LoginDTO());
		return "auth/login";
	}

	@PostMapping("/login")
	public String processLogin(@ModelAttribute("loginDTO") LoginDTO dto, 
	                           HttpSession session, 
	                           HttpServletResponse response, 
	                           Model model) {
		try {
			User user = authService.login(dto);

			// 1. Sinh cặp Access Token (15 phút) và Refresh Token (7 ngày)
			String accessToken = jwtUtils.generateAccessToken(user);
			String refreshToken = jwtUtils.generateRefreshToken(user);

			// 2. Lưu Refresh Token và thời hạn hết hạn vào Database để kiểm soát phiên
			user.setRefreshToken(refreshToken);
			user.setRefreshTokenExpiryTime(LocalDateTime.now().plusSeconds(jwtUtils.getRefreshExpirationMs() / 1000));
			userRepository.save(user);

			// 3. Gửi cả 2 Cookie HttpOnly (ALOUTE_ACCESS_TOKEN & ALOUTE_REFRESH_TOKEN) về trình duyệt
			jwtUtils.addAuthCookies(response, accessToken, refreshToken);

			// 4. Kiểm tra quyền ROLE_ADMIN
			boolean isAdmin = user.getRoles() != null && user.getRoles().stream()
					.anyMatch(r -> "ROLE_ADMIN".equalsIgnoreCase(r.getName()));

			// 5. Đồng bộ vào Session hỗ trợ render các taglib JSP / JSTL
			session.setAttribute("currentUser", user);
			session.setAttribute("isAdminUser", isAdmin);

			// Admin vào thẳng /admin, User thường vào trang chủ
			if (isAdmin) {
				return "redirect:/admin";
			}
			return "redirect:/";
		} catch (IllegalArgumentException e) {
			model.addAttribute("error", e.getMessage());
			return "auth/login";
		}
	}

	// --- 4. ĐĂNG XUẤT (GỠ BỎ ONLINE, THU HỒI TOKEN & HỦY COOKIE) ---
	@GetMapping("/logout")
	public String logout(HttpServletRequest request, HttpServletResponse response) {
		HttpSession session = request.getSession(false);
		if (session != null) {
			User currentUser = (User) session.getAttribute("currentUser");
			
			// 1. Gỡ khỏi Active Tracker và xóa Refresh Token trong Database
			if (currentUser != null) {
				ActiveUserListener.userLoggedOut(currentUser);
				userRepository.findById(currentUser.getId()).ifPresent(u -> {
					u.setRefreshToken(null);
					u.setRefreshTokenExpiryTime(null);
					userRepository.save(u);
				});
			}

			session.removeAttribute("currentUser");
			session.removeAttribute("isAdminUser");
			session.invalidate();
		}

		// 2. Xóa sạch mọi Cookie xác thực (Access Token, Refresh Token, JSESSIONID)
		jwtUtils.deleteAllAuthCookies(response);

		response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
		response.setHeader("Pragma", "no-cache");
		response.setDateHeader("Expires", 0);

		return "redirect:/login?logout=true";
	}

	// --- 5. QUÊN MẬT KHẨU ---
	@GetMapping("/forgot-password")
	public String showForgotPasswordForm() {
		return "auth/forgot-password";
	}

	@PostMapping("/forgot-password")
	public String processForgotPassword(@RequestParam("email") String email) {
		authService.sendForgotPasswordOtp(email);
		return "redirect:/reset-password?email=" + email;
	}

	@GetMapping("/reset-password")
	public String showResetPasswordForm(@RequestParam("email") String email, Model model) {
		ResetPasswordDTO dto = new ResetPasswordDTO();
		dto.setEmail(email);
		model.addAttribute("resetPasswordDTO", dto);
		return "auth/reset-password";
	}

	@PostMapping("/reset-password")
	public String processResetPassword(@ModelAttribute("resetPasswordDTO") ResetPasswordDTO dto, Model model) {
		try {
			authService.resetPassword(dto);
			return "redirect:/login?resetSuccess=true";
		} catch (IllegalArgumentException e) {
			model.addAttribute("error", e.getMessage());
			return "auth/reset-password";
		}
	}

	// ==========================================
	// TRANG CÁ NHÂN (/profile)
	// ==========================================
	@GetMapping("/profile")
	public String showProfilePage(@RequestParam(value = "userId", required = false) Long userId, HttpSession session,
			Model model) {
		User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
		if (currentUser == null) {
			return "redirect:/login?requiredAuth=true";
		}

		User profileUser = currentUser;
		if (userId != null && !userId.equals(currentUser.getId())) {
			profileUser = userRepository.findById(userId).orElse(currentUser);
		}

		boolean isOwner = profileUser.getId().equals(currentUser.getId());
		List<Post> userPosts;

		if (isOwner) {
			userPosts = postRepository.findByUserIdOrderByCreatedAtDesc(profileUser.getId());
		} else {
			String friendshipStatus = friendshipService.getFriendshipStatus(currentUser.getId(), profileUser.getId());
			int mutualWithProfileUser = friendshipService.countMutualFriends(currentUser.getId(), profileUser.getId());
			model.addAttribute("friendshipStatus", friendshipStatus);
			model.addAttribute("mutualWithProfileUser", mutualWithProfileUser);

			if ("FRIENDS".equalsIgnoreCase(friendshipStatus)) {
				userPosts = postRepository.findPostsForFriends(profileUser.getId());
			} else {
				userPosts = postRepository.findPublicPosts(profileUser.getId());
			}
		}

		List<User> userFriends = friendshipService.getFriends(profileUser.getId());
		List<User> myFriends = friendshipService.getFriends(currentUser.getId());

		Map<Long, Integer> mutualCounts = new HashMap<>();
		for (User f : userFriends) {
			mutualCounts.put(f.getId(), friendshipService.countMutualFriends(currentUser.getId(), f.getId()));
		}

		model.addAttribute("user", profileUser);
		model.addAttribute("posts", userPosts);
		model.addAttribute("isOwner", isOwner);
		model.addAttribute("userFriends", userFriends);
		model.addAttribute("myFriends", myFriends);
		model.addAttribute("totalFriendsCount", userFriends.size());
		model.addAttribute("mutualCounts", mutualCounts);

		return "profile";
	}

	@PostMapping("/profile/update-avatar")
	public String updateAvatar(@RequestParam("avatarUrl") String avatarUrl, HttpSession session,
			RedirectAttributes redirectAttributes) {
		User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
		if (currentUser == null)
			return "redirect:/login";

		try {
			User updatedUser = authService.updateAvatar(currentUser.getId(), avatarUrl);
			session.setAttribute("currentUser", updatedUser);
			redirectAttributes.addFlashAttribute("successMessage", "Cập nhật ảnh đại diện thành công!");
		} catch (Exception e) {
			redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
		}
		return "redirect:/profile";
	}

	@PostMapping("/profile/update-cover")
	public String updateCover(@RequestParam("coverUrl") String coverUrl, HttpSession session,
			RedirectAttributes redirectAttributes) {
		User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
		if (currentUser == null)
			return "redirect:/login";

		try {
			User updatedUser = authService.updateCoverImage(currentUser.getId(), coverUrl);
			session.setAttribute("currentUser", updatedUser);
			redirectAttributes.addFlashAttribute("successMessage", "Cập nhật ảnh bìa thành công!");
		} catch (Exception e) {
			redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
		}
		return "redirect:/profile";
	}

	// ==========================================
	// TRANG CÀI ĐẶT TỔNG HỢP (/settings)
	// ==========================================
	@GetMapping("/settings")
	public String showSettingsPage(@RequestParam(value = "tab", defaultValue = "account") String tab,
			HttpSession session, Model model) {
		User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
		if (currentUser == null) {
			return "redirect:/login?requiredAuth=true";
		}

		UpdateProfileDTO profileDTO = new UpdateProfileDTO();
		profileDTO.setFullName(currentUser.getFullName());

		model.addAttribute("user", currentUser);
		model.addAttribute("profileDTO", profileDTO);
		model.addAttribute("passwordDTO", new ChangePasswordDTO());
		model.addAttribute("activeTab", tab);

		return "settings";
	}

	@PostMapping("/settings/update-account")
	public String updateAccountInfo(@ModelAttribute("profileDTO") UpdateProfileDTO profileDTO, HttpSession session,
			RedirectAttributes redirectAttributes) {
		User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
		if (currentUser == null)
			return "redirect:/login";

		try {
			User updatedUser = authService.updateProfile(currentUser.getId(), profileDTO.getFullName());
			session.setAttribute("currentUser", updatedUser);
			redirectAttributes.addFlashAttribute("accountSuccess", "Đã cập nhật thông tin tài khoản thành công!");
		} catch (IllegalArgumentException e) {
			redirectAttributes.addFlashAttribute("accountError", e.getMessage());
		}
		return "redirect:/settings?tab=account";
	}

	@PostMapping("/settings/change-password")
	public String changePasswordInSettings(@ModelAttribute("passwordDTO") ChangePasswordDTO passwordDTO,
			HttpSession session, RedirectAttributes redirectAttributes) {
		User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
		if (currentUser == null)
			return "redirect:/login";

		try {
			authService.changePassword(currentUser.getId(), passwordDTO);
			redirectAttributes.addFlashAttribute("passwordSuccess", "Đổi mật khẩu thành công!");
		} catch (IllegalArgumentException e) {
			redirectAttributes.addFlashAttribute("passwordError", e.getMessage());
		}
		return "redirect:/settings?tab=security";
	}
}