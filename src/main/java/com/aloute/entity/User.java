package com.aloute.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@Column(length = 6)
	private String otpCode;

	private LocalDateTime otpExpiryTime;

	@Column(nullable = false, unique = true, length = 50)
	private String username;

	@Column(nullable = false, length = 255)
	private String password;

	@Column(nullable = false, length = 100)
	private String fullName;

	@Column(nullable = false, unique = true, length = 100)
	private String email;

	@Column(columnDefinition = "LONGTEXT")
	private String avatar; // Lưu ảnh Base64 hoặc link Cloudinary

	@Column(name = "cover_image", columnDefinition = "LONGTEXT")
	private String coverImage; // Lưu ảnh Base64 hoặc link Cloudinary

	@Column(columnDefinition = "TEXT")
	private String bio;

	// Đếm số lần đăng nhập sai liên tiếp
	@Builder.Default
	@Column(nullable = false)
	private Integer failedAttempt = 0;

	// Thời điểm tài khoản bị tạm khóa (null nếu không bị khóa)
	private LocalDateTime lockTime;

	@Builder.Default
	@Column(nullable = false)
	private Boolean active = true;

	@ManyToMany(fetch = FetchType.EAGER)
	@JoinTable(name = "user_roles", joinColumns = @JoinColumn(name = "user_id"), inverseJoinColumns = @JoinColumn(name = "role_id"))
	@Builder.Default
	private Set<Role> roles = new HashSet<>();

	@CreationTimestamp
	@Column(updatable = false)
	private LocalDateTime createdAt;

	@UpdateTimestamp
	private LocalDateTime updatedAt;
}