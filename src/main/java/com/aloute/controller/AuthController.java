package com.aloute.controller;

import com.aloute.dto.ChangePasswordDTO;
import com.aloute.dto.LoginDTO;
import com.aloute.dto.RegisterDTO;
import com.aloute.dto.ResetPasswordDTO;
import com.aloute.dto.UpdateProfileDTO;
import com.aloute.dto.VerifyOtpDTO;
import com.aloute.entity.User;
import com.aloute.service.AuthService;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequiredArgsConstructor
public class AuthController {

	private final AuthService authService;

	// --- 1. ĐĂNG KÝ ---
	@GetMapping("/register")
	public String showRegisterForm(Model model, HttpSession session) {
		if (session != null && session.getAttribute("currentUser") != null) {
			return "redirect:/";
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

	// --- 3. ĐĂNG NHẬP ---
	@GetMapping("/login")
	public String showLoginForm(Model model, HttpSession session) {
		if (session != null && session.getAttribute("currentUser") != null) {
			return "redirect:/";
		}
		model.addAttribute("loginDTO", new LoginDTO());
		return "auth/login";
	}

	@PostMapping("/login")
	public String processLogin(@ModelAttribute("loginDTO") LoginDTO dto, HttpSession session, Model model) {
		try {
			User user = authService.login(dto);
			// Lưu đối tượng user đã đăng nhập vào session
			session.setAttribute("currentUser", user);
			return "redirect:/";
		} catch (IllegalArgumentException e) {
			model.addAttribute("error", e.getMessage());
			return "auth/login";
		}
	}

	// --- 4. ĐĂNG XUẤT ---
	@GetMapping("/logout")
	public String logout(HttpServletRequest request, HttpServletResponse response) {
		// 1. Hủy Session trên máy chủ
		HttpSession session = request.getSession(false);
		if (session != null) {
			session.removeAttribute("currentUser");
			session.invalidate();
		}

		// 2. Ép trình duyệt xóa sạch Cookie JSESSIONID
		Cookie cookie = new Cookie("JSESSIONID", null);
		cookie.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath());
		cookie.setHttpOnly(true);
		cookie.setMaxAge(0);
		response.addCookie(cookie);

		// 3. Header cấm lưu đệm
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
    // 1. TRANG CÁ NHÂN (/profile) - GIAO DIỆN MẠNG XÃ HỘI
    // ==========================================
    @GetMapping("/profile")
    public String showProfilePage(HttpSession session, Model model) {
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            return "redirect:/login?requiredAuth=true";
        }
        model.addAttribute("user", currentUser);
        // Sau này khi làm module Post: model.addAttribute("posts", postService.getPostsByUserId(currentUser.getId()));
        return "profile";
    }

    // Cập nhật Avatar qua modal
    @PostMapping("/profile/update-avatar")
    public String updateAvatar(@RequestParam("avatarUrl") String avatarUrl, 
                               HttpSession session, 
                               RedirectAttributes redirectAttributes) {
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) return "redirect:/login";

        try {
            User updatedUser = authService.updateAvatar(currentUser.getId(), avatarUrl);
            session.setAttribute("currentUser", updatedUser); // Cập nhật session để Navbar đổi theo
            redirectAttributes.addFlashAttribute("successMessage", "Cập nhật ảnh đại diện thành công!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/profile";
    }

    // Cập nhật Ảnh bìa qua modal
    @PostMapping("/profile/update-cover")
    public String updateCover(@RequestParam("coverUrl") String coverUrl, 
                              HttpSession session, 
                              RedirectAttributes redirectAttributes) {
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) return "redirect:/login";

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
    // 2. TRANG CÀI ĐẶT TỔNG HỢP (/settings) - DẠNG TAB
    // ==========================================
    @GetMapping("/settings")
    public String showSettingsPage(@RequestParam(value = "tab", defaultValue = "account") String tab,
                                   HttpSession session, 
                                   Model model) {
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            return "redirect:/login?requiredAuth=true";
        }

        UpdateProfileDTO profileDTO = new UpdateProfileDTO();
        profileDTO.setFullName(currentUser.getFullName());
        
        model.addAttribute("user", currentUser);
        model.addAttribute("profileDTO", profileDTO);
        model.addAttribute("passwordDTO", new ChangePasswordDTO());
        model.addAttribute("activeTab", tab); // Điều hướng mở đúng tab tương ứng

        return "settings";
    }

    // Xử lý cập nhật thông tin trong Settings
    @PostMapping("/settings/update-account")
    public String updateAccountInfo(@ModelAttribute("profileDTO") UpdateProfileDTO profileDTO,
                                    HttpSession session,
                                    RedirectAttributes redirectAttributes) {
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) return "redirect:/login";

        try {
            User updatedUser = authService.updateProfile(currentUser.getId(), profileDTO.getFullName());
            session.setAttribute("currentUser", updatedUser);
            redirectAttributes.addFlashAttribute("accountSuccess", "Đã cập nhật thông tin tài khoản thành công!");
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("accountError", e.getMessage());
        }
        return "redirect:/settings?tab=account";
    }

    // Xử lý đổi mật khẩu trong Settings
    @PostMapping("/settings/change-password")
    public String changePasswordInSettings(@ModelAttribute("passwordDTO") ChangePasswordDTO passwordDTO,
                                          HttpSession session,
                                          RedirectAttributes redirectAttributes) {
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) return "redirect:/login";

        try {
            authService.changePassword(currentUser.getId(), passwordDTO);
            redirectAttributes.addFlashAttribute("passwordSuccess", "Đổi mật khẩu thành công!");
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("passwordError", e.getMessage());
        }
        return "redirect:/settings?tab=security";
    }
}