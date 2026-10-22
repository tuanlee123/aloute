package com.aloute.config;

import org.sitemesh.builder.SiteMeshFilterBuilder;
import org.sitemesh.config.ConfigurableSiteMeshFilter;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SiteMeshConfig {

    @Bean
    public FilterRegistrationBean<ConfigurableSiteMeshFilter> siteMeshFilter() {
        FilterRegistrationBean<ConfigurableSiteMeshFilter> filter = new FilterRegistrationBean<>();
        filter.setFilter(new ConfigurableSiteMeshFilter() {
            @Override
            protected void applyCustomConfiguration(SiteMeshFilterBuilder builder) {
                // Áp dụng decorator "main.jsp" cho các trang mạng xã hội
                builder.addDecoratorPath("/*", "main.jsp");

                // LOẠI TRỪ TRANG ADMIN (Để Admin đứng độc lập, không bị dính menu mạng xã hội)
                builder.addExcludedPath("/admin");
                builder.addExcludedPath("/admin/**");

                // Loại trừ tài nguyên tĩnh
                builder.addExcludedPath("/static/**");
                builder.addExcludedPath("/css/**");
                builder.addExcludedPath("/js/**");
                builder.addExcludedPath("/images/**");
                builder.addExcludedPath("/api/**");

                // Loại trừ các trang xác thực
                builder.addExcludedPath("/login");
                builder.addExcludedPath("/register");
                builder.addExcludedPath("/verify-otp");
                builder.addExcludedPath("/resend-otp");
                builder.addExcludedPath("/forgot-password");
                builder.addExcludedPath("/reset-password");
            }
        });
        filter.addUrlPatterns("/*");
        return filter;
    }
}