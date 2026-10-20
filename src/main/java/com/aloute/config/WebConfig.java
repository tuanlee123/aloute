package com.aloute.config;

import com.aloute.interceptor.AuthInterceptor;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
@RequiredArgsConstructor
public class WebConfig implements WebMvcConfigurer {

    private final AuthInterceptor authInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(authInterceptor)
                // Áp dụng kiểm tra bảo vệ cho toàn bộ hệ thống
                .addPathPatterns("/**")
                // Loại trừ các đường dẫn công khai (không bắt buộc đăng nhập)
                .excludePathPatterns(
                        "/login",
                        "/logout",            // Cho phép logout chạy thẳng vào Controller để hủy session triệt để
                        "/register",
                        "/verify-otp",
                        "/resend-otp",
                        "/forgot-password",
                        "/reset-password",
                        "/error",             // Trang xử lý lỗi mặc định của Spring Boot

                        // Loại trừ tài nguyên tĩnh (CSS, JS, Hình ảnh, Font)
                        "/static/**",
                        "/css/**",
                        "/js/**",
                        "/images/**",
                        "/assets/**",
                        "/webjars/**",
                        "/favicon.ico"
                );
    }
}	