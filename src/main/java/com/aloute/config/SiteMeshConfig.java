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
                // Chỉ khai báo tên file "main.jsp"
                // SiteMesh tự động nối thành: /WEB-INF/decorators/main.jsp
            	builder.addDecoratorPath("/*", "main.jsp");

            	// Loại trừ decorator cho màn hình đăng nhập, đăng ký
            	builder.addExcludedPath("/login");
            	builder.addExcludedPath("/register");

            	builder.addExcludedPath("/static/**");
            	builder.addExcludedPath("/css/**");
            	builder.addExcludedPath("/js/**");
            	builder.addExcludedPath("/images/**");
            	builder.addExcludedPath("/api/**");
            	
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