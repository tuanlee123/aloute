package com.aloute.service;

import com.aloute.dto.ChangePasswordDTO;
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

	private static final int MAX_FAILED_ATTEMPTS = 5;
	private static final long LOCK_TIME_DURATION_MINUTES = 15;

	// Sinh mã OTP 6 chữ số ngẫu nhiên
	private String generateOtp() {
		return String.valueOf(100000 + new Random().nextInt(900000));
	}

	// Kiểm tra chính sách mật khẩu: 8-16 ký tự, không dấu tiếng Việt, không khoảng trắng
	private void validatePasswordPolicy(String password) {
		if (password == null || password.length() < 8 || password.length() > 16) {
			throw new IllegalArgumentException("Mật khẩu phải có độ dài từ 8 đến 16 ký tự!");
		}
		if (!password.matches("^[\\x21-\\x7E]+$")) {
			throw new IllegalArgumentException("Mật khẩu không được chứa dấu tiếng Việt hoặc khoảng trắng!");
		}
	}

	// --- 1. CẬP NHẬT HỌ VÀ TÊN HIỂN THỊ ---
	public User updateProfile(Long userId, String newFullName) {
		if (newFullName == null || newFullName.trim().isEmpty()) {
			throw new IllegalArgumentException("Họ và tên không được để trống!");
		}

		User user = userRepository.findById(userId)
				.orElseThrow(() -> new IllegalArgumentException("Không tìm thấy thông tin tài khoản!"));

		user.setFullName(newFullName.trim());
		return userRepository.save(user);
	}

	// --- 2. ĐỔI MẬT KHẨU KHI ĐANG ĐĂNG NHẬP ---
	public void changePassword(Long userId, ChangePasswordDTO dto) {
		User user = userRepository.findById(userId)
				.orElseThrow(() -> new IllegalArgumentException("Không tìm thấy thông tin tài khoản!"));

		// Kiểm tra mật khẩu hiện tại có đúng không
		if (!passwordEncoder.matches(dto.getCurrentPassword(), user.getPassword())) {
			throw new IllegalArgumentException("Mật khẩu hiện tại không chính xác!");
		}

		// Validate mật khẩu mới theo chuẩn 8-16 ký tự, không dấu, không khoảng trắng
		String newPass = dto.getNewPassword();
		if (newPass == null || newPass.length() < 8 || newPass.length() > 16) {
			throw new IllegalArgumentException("Mật khẩu mới phải từ 8 đến 16 ký tự!");
		}
		if (newPass.contains(" ")) {
			throw new IllegalArgumentException("Mật khẩu không được chứa khoảng trắng!");
		}
		if (newPass.matches(".*[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ].*")) {
			throw new IllegalArgumentException("Mật khẩu không được chứa ký tự tiếng Việt có dấu!");
		}

		// Kiểm tra khớp xác nhận mật khẩu
		if (!newPass.equals(dto.getConfirmPassword())) {
			throw new IllegalArgumentException("Mật khẩu xác nhận không trùng khớp!");
		}

		// Không cho phép mật khẩu mới trùng mật khẩu cũ
		if (passwordEncoder.matches(newPass, user.getPassword())) {
			throw new IllegalArgumentException("Mật khẩu mới không được trùng với mật khẩu hiện tại!");
		}

		user.setPassword(passwordEncoder.encode(newPass));
		userRepository.save(user);
	}

	// --- 3. ĐĂNG KÝ VÀ GỬI OTP KÍCH HOẠT ---
	public void register(RegisterDTO dto) {
		if (!dto.getPassword().equals(dto.getConfirmPassword())) {
			throw new IllegalArgumentException("Mật khẩu xác nhận không khớp!");
		}

		// Ràng buộc chính sách mật khẩu phía Backend
		validatePasswordPolicy(dto.getPassword());

		if (userRepository.existsByUsername(dto.getUsername().trim())) {
			throw new IllegalArgumentException("Tên đăng nhập đã tồn tại!");
		}
		if (userRepository.existsByEmail(dto.getEmail().trim().toLowerCase())) {
			throw new IllegalArgumentException("Email đã được sử dụng!");
		}

		Role userRole = roleRepository.findByName("ROLE_USER")
				.orElseGet(() -> roleRepository.save(Role.builder().name("ROLE_USER").build()));

		String otp = generateOtp();

		User newUser = User.builder().username(dto.getUsername().trim())
				.password(passwordEncoder.encode(dto.getPassword())).fullName(dto.getFullName().trim())
				.email(dto.getEmail().trim().toLowerCase())
				.avatar("https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg").active(false)
				.failedAttempt(0).otpCode(otp).otpExpiryTime(LocalDateTime.now().plusMinutes(5))
				.roles(Set.of(userRole)).build();

		userRepository.save(newUser);

		// Gửi mail OTP kích hoạt
		emailService.sendOtpEmail(newUser.getEmail(), otp, "Mã kích hoạt tài khoản", "kích hoạt tài khoản");
	}

	// --- 4. KÍCH HOẠT TÀI KHOẢN QUA OTP ---
	public void verifyAccount(String email, String otp) {
		User user = userRepository.findByEmail(email.trim().toLowerCase())
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

	// --- 5. GỬI LẠI MÃ KÍCH HOẠT ---
	public void resendActivationOtp(String email) {
		User user = userRepository.findByEmail(email.trim().toLowerCase())
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

	// --- 6. ĐĂNG NHẬP (CÓ ĐẾM SỐ LẦN SAI & KHÓA 15 PHÚT) ---
	public User login(LoginDTO dto) {
		String loginId = dto.getUsernameOrEmail().trim();
		Optional<User> userOpt = userRepository.findByUsername(loginId);
		if (userOpt.isEmpty()) {
			userOpt = userRepository.findByEmail(loginId.toLowerCase());
		}

		if (userOpt.isEmpty()) {
			throw new IllegalArgumentException("Tài khoản hoặc mật khẩu không chính xác!");
		}

		User user = userOpt.get();

		if (Boolean.FALSE.equals(user.getActive())) {
			throw new IllegalArgumentException("Tài khoản chưa được kích hoạt qua mã OTP hoặc đã bị khóa!");
		}

		// Kiểm tra xem tài khoản có đang bị tạm khóa không
		if (user.getLockTime() != null) {
			LocalDateTime unlockTime = user.getLockTime().plusMinutes(LOCK_TIME_DURATION_MINUTES);
			if (LocalDateTime.now().isBefore(unlockTime)) {
				long minutesLeft = java.time.Duration.between(LocalDateTime.now(), unlockTime).toMinutes() + 1;
				throw new IllegalArgumentException(
						"Tài khoản đã bị tạm khóa do nhập sai quá nhiều lần. Vui lòng thử lại sau " + minutesLeft
								+ " phút!");
			} else {
				// Đã hết 15 phút -> Mở khóa tự động
				user.setLockTime(null);
				user.setFailedAttempt(0);
				userRepository.save(user);
			}
		}

		// Kiểm tra mật khẩu
		if (!passwordEncoder.matches(dto.getPassword(), user.getPassword())) {
			int currentFailed = (user.getFailedAttempt() == null ? 0 : user.getFailedAttempt()) + 1;
			user.setFailedAttempt(currentFailed);

			if (currentFailed >= MAX_FAILED_ATTEMPTS) {
				user.setLockTime(LocalDateTime.now());
				userRepository.save(user);
				throw new IllegalArgumentException(
						"Bạn đã nhập sai mật khẩu 5 lần. Tài khoản bị tạm khóa trong 15 phút!");
			} else {
				userRepository.save(user);
				int attemptsLeft = MAX_FAILED_ATTEMPTS - currentFailed;
				throw new IllegalArgumentException(
						"Mật khẩu không chính xác! Bạn còn " + attemptsLeft + " lần thử trước khi bị khóa tài khoản.");
			}
		}

		// Đăng nhập thành công -> Đặt số lần sai về 0
		if (user.getFailedAttempt() != null && user.getFailedAttempt() > 0) {
			user.setFailedAttempt(0);
			user.setLockTime(null);
			userRepository.save(user);
		}

		return user;
	}

	// --- 7. QUÊN MẬT KHẨU - GỬI MÃ OTP (CHỐNG DÒ QUÉT EMAIL) ---
	public void sendForgotPasswordOtp(String email) {
		Optional<User> userOpt = userRepository.findByEmail(email.trim().toLowerCase());

		if (userOpt.isPresent()) {
			User user = userOpt.get();
			String otp = generateOtp();
			user.setOtpCode(otp);
			user.setOtpExpiryTime(LocalDateTime.now().plusMinutes(5));
			userRepository.save(user);

			emailService.sendOtpEmail(user.getEmail(), otp, "Mã xác thực đặt lại mật khẩu", "đặt lại mật khẩu");
		}
	}

	// --- 8. ĐẶT LẠI MẬT KHẨU VỚI OTP ---
	public void resetPassword(ResetPasswordDTO dto) {
		if (!dto.getNewPassword().equals(dto.getConfirmNewPassword())) {
			throw new IllegalArgumentException("Mật khẩu xác nhận không khớp!");
		}

		// Ràng buộc chính sách mật khẩu phía Backend
		validatePasswordPolicy(dto.getNewPassword());

		User user = userRepository.findByEmail(dto.getEmail().trim().toLowerCase())
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

		// Mở khóa tài khoản ngay lập tức khi xác thực đổi mật khẩu thành công
		user.setLockTime(null);
		user.setFailedAttempt(0);

		userRepository.save(user);
	}
	
	// Cập nhật Avatar
    public User updateAvatar(Long userId, String avatarUrl) {
        if (avatarUrl == null || avatarUrl.trim().isEmpty()) {
            throw new IllegalArgumentException("Đường dẫn ảnh đại diện không hợp lệ!");
        }
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy người dùng!"));
        user.setAvatar(avatarUrl.trim());
        return userRepository.save(user);
    }

    // Cập nhật Ảnh bìa
    public User updateCoverImage(Long userId, String coverUrl) {
        if (coverUrl == null || coverUrl.trim().isEmpty()) {
            throw new IllegalArgumentException("Đường dẫn ảnh bìa không hợp lệ!");
        }
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy người dùng!"));
        user.setCoverImage(coverUrl.trim());
        return userRepository.save(user);
    }
}