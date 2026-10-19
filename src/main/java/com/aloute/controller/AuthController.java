package com.aloute.controller;

import com.aloute.dto.LoginDTO;
import com.aloute.dto.RegisterDTO;
import com.aloute.dto.ResetPasswordDTO;
import com.aloute.dto.VerifyOtpDTO;
import com.aloute.entity.User;
import com.aloute.service.AuthService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    // --- 1. ĐĂNG KÝ ---
    @GetMapping("/register")
    public String showRegisterForm(Model model, HttpSession session) {
        if (session.getAttribute("currentUser") != null) return "redirect:/";
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

    // --- 3. ĐĂNG NHẬP / ĐĂNG XUẤT ---
    @GetMapping("/login")
    public String showLoginForm(Model model, HttpSession session) {
        if (session.getAttribute("currentUser") != null) return "redirect:/";
        model.addAttribute("loginDTO", new LoginDTO());
        return "auth/login";
    }

    @PostMapping("/login")
    public String processLogin(@ModelAttribute("loginDTO") LoginDTO loginDTO, HttpSession session, Model model) {
        try {
            User user = authService.login(loginDTO);
            session.setAttribute("currentUser", user);
            return "redirect:/";
        } catch (IllegalArgumentException e) {
            model.addAttribute("error", e.getMessage());
            return "auth/login";
        }
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.removeAttribute("currentUser");
        session.invalidate();
        return "redirect:/login";
    }

    // --- 4. QUÊN MẬT KHẨU ---
    @GetMapping("/forgot-password")
    public String showForgotPasswordForm() {
        return "auth/forgot-password";
    }

    @PostMapping("/forgot-password")
    public String processForgotPassword(@RequestParam("email") String email, Model model) {
        try {
            authService.sendForgotPasswordOtp(email);
            return "redirect:/reset-password?email=" + email;
        } catch (IllegalArgumentException e) {
            model.addAttribute("error", e.getMessage());
            return "auth/forgot-password";
        }
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
}