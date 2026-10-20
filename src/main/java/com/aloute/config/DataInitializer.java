package com.aloute.config;

import com.aloute.entity.Role;
import com.aloute.repository.RoleRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;

@Configuration
public class DataInitializer {

    @Bean
    public CommandLineRunner initRoles(RoleRepository roleRepository, JdbcTemplate jdbcTemplate) {
        return args -> {
            // 1. Tự động nâng cấp cột avatar và cover_image lên LONGTEXT nếu database chưa cập nhật
            try {
                jdbcTemplate.execute("ALTER TABLE users MODIFY COLUMN avatar LONGTEXT");
                jdbcTemplate.execute("ALTER TABLE users MODIFY COLUMN cover_image LONGTEXT");
                System.out.println(">>> [DB Migration] Đã kiểm tra và cập nhật avatar/cover_image thành LONGTEXT thành công!");
            } catch (Exception e) {
                // Bỏ qua nếu cột đã là LONGTEXT hoặc bảng users chưa được tạo
                System.out.println(">>> [DB Migration] Lưu ý cấu trúc bảng users: " + e.getMessage());
            }

            // 2. Khởi tạo quyền mặc định hệ thống
            if (roleRepository.findByName("ROLE_USER").isEmpty()) {
                roleRepository.save(Role.builder().name("ROLE_USER").build());
            }
            if (roleRepository.findByName("ROLE_ADMIN").isEmpty()) {
                roleRepository.save(Role.builder().name("ROLE_ADMIN").build());
            }
        };
    }
}