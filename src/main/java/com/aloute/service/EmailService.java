package com.aloute.service;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username}")
    private String fromEmail;

    public void sendOtpEmail(String toEmail, String otpCode, String subject, String messageType) {
        System.out.println("--------------------------------------------------");
        System.out.println(">> [DEBUG] TIẾN HÀNH GỬI MAIL OTP:");
        System.out.println(">> Người gửi (From): " + fromEmail);
        System.out.println(">> Người nhận (To)  : " + toEmail);
        System.out.println(">> Mã OTP sinh ra   : " + otpCode);
        System.out.println("--------------------------------------------------");

        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(fromEmail); // Đặt rõ ràng email người gửi
        message.setTo(toEmail);     // Email người đăng ký nhận được từ form
        message.setSubject("[ALOUTE] - " + subject);
        message.setText("Xin chào,\n\n"
                + "Mã xác thực OTP của bạn cho thao tác " + messageType + " là: " + otpCode + "\n"
                + "Mã này có hiệu lực trong vòng 5 phút. Vui lòng không chia sẻ mã này cho bất kỳ ai.\n\n"
                + "Trân trọng,\nĐội ngũ phát triển ALOUTE");
        
        mailSender.send(message);
    }
}