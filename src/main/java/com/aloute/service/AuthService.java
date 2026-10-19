package com.aloute.service;

import com.aloute.dto.LoginDTO;
import com.aloute.dto.RegisterDTO;
import com.aloute.dto.ResetPasswordDTO;
import com.aloute.entity.Role;
import com.aloute.entity.User;
import com.aloute.repository.RoleRepository;
import com.aloute.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.Random;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;

    // Sinh mã OTP 6 chữ số ngẫu nhiên
    private String generateOtp() {
        return String.valueOf(100000 + new Random().nextInt(900000));
    }

    // 1. ĐĂNG KÝ VÀ GỬI OTP KÍCH HOẠT
    public void register(RegisterDTO dto) {
        if (!dto.getPassword().equals(dto.getConfirmPassword())) {
            throw new IllegalArgumentException("Mật khẩu xác nhận không khớp!");
        }
        if (userRepository.existsByUsername(dto.getUsername())) {
            throw new IllegalArgumentException("Tên đăng nhập đã tồn tại!");
        }
        if (userRepository.existsByEmail(dto.getEmail())) {
            throw new IllegalArgumentException("Email đã được sử dụng!");
        }

        Role userRole = roleRepository.findByName("ROLE_USER")
                .orElseGet(() -> roleRepository.save(Role.builder().name("ROLE_USER").build()));

        String otp = generateOtp();

        User newUser = User.builder()
                .username(dto.getUsername().trim())
                .password(passwordEncoder.encode(dto.getPassword()))
                .fullName(dto.getFullName().trim())
                .email(dto.getEmail().trim().toLowerCase())
                .avatar("https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg")
                .active(false) // Chưa kích hoạt tài khoản
                .otpCode(otp)
                .otpExpiryTime(LocalDateTime.now().plusMinutes(5)) // Hiệu lực 5 phút
                .roles(Set.of(userRole))
                .build();

        userRepository.save(newUser);

        // Gửi mail OTP kích hoạt
        emailService.sendOtpEmail(newUser.getEmail(), otp, "Mã kích hoạt tài khoản", "kích hoạt tài khoản");
    }

    // 2. KÍCH HOẠT TÀI KHOẢN QUA OTP
    public void verifyAccount(String email, String otp) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Email không tồn tại!"));

        if (Boolean.TRUE.equals(user.getActive())) {
            throw new IllegalArgumentException("Tài khoản này đã được kích hoạt từ trước!");
        }
        if (user.getOtpCode() == null || !user.getOtpCode().equals(otp.trim())) {
            throw new IllegalArgumentException("Mã OTP không chính xác!");
        }
        if (user.getOtpExpiryTime().isBefore(LocalDateTime.now())) {
            throw new IllegalArgumentException("Mã OTP đã hết hạn! Vui lòng yêu cầu gửi lại mã mới.");
        }

        user.setActive(true);
        user.setOtpCode(null);
        user.setOtpExpiryTime(null);
        userRepository.save(user);
    }

    // Gửi lại mã kích hoạt
    public void resendActivationOtp(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Email không tồn tại!"));

        if (Boolean.TRUE.equals(user.getActive())) {
            throw new IllegalArgumentException("Tài khoản đã được kích hoạt rồi!");
        }

        String otp = generateOtp();
        user.setOtpCode(otp);
        user.setOtpExpiryTime(LocalDateTime.now().plusMinutes(5));
        userRepository.save(user);

        emailService.sendOtpEmail(user.getEmail(), otp, "Gửi lại mã kích hoạt tài khoản", "kích hoạt tài khoản");
    }

    // 3. ĐĂNG NHẬP
    public User login(LoginDTO dto) {
        Optional<User> userOpt = userRepository.findByUsername(dto.getUsernameOrEmail());
        if (userOpt.isEmpty()) {
            userOpt = userRepository.findByEmail(dto.getUsernameOrEmail());
        }

        if (userOpt.isEmpty()) {
            throw new IllegalArgumentException("Tài khoản hoặc mật khẩu không chính xác!");
        }

        User user = userOpt.get();

        if (Boolean.FALSE.equals(user.getActive())) {
            throw new IllegalArgumentException("Tài khoản chưa được kích hoạt hoặc đã bị khóa!");
        }

        if (!passwordEncoder.matches(dto.getPassword(), user.getPassword())) {
            throw new IllegalArgumentException("Tài khoản hoặc mật khẩu không chính xác!");
        }

        return user;
    }

    // 4. QUÊN MẬT KHẨU - GỬI MÃ OTP
    public void sendForgotPasswordOtp(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản với email này!"));

        String otp = generateOtp();
        user.setOtpCode(otp);
        user.setOtpExpiryTime(LocalDateTime.now().plusMinutes(5));
        userRepository.save(user);

        emailService.sendOtpEmail(user.getEmail(), otp, "Mã xác thực đặt lại mật khẩu", "đặt lại mật khẩu");
    }

    // 5. ĐẶT LẠI MẬT KHẨU VỚI OTP
    public void resetPassword(ResetPasswordDTO dto) {
        if (!dto.getNewPassword().equals(dto.getConfirmNewPassword())) {
            throw new IllegalArgumentException("Mật khẩu xác nhận không khớp!");
        }

        User user = userRepository.findByEmail(dto.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("Email không tồn tại!"));

        if (user.getOtpCode() == null || !user.getOtpCode().equals(dto.getOtp().trim())) {
            throw new IllegalArgumentException("Mã OTP không chính xác!");
        }
        if (user.getOtpExpiryTime().isBefore(LocalDateTime.now())) {
            throw new IllegalArgumentException("Mã OTP đã hết hiệu lực!");
        }

        user.setPassword(passwordEncoder.encode(dto.getNewPassword()));
        user.setOtpCode(null);
        user.setOtpExpiryTime(null);
        userRepository.save(user);
    }
}