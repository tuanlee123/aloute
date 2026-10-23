package com.aloute.repository;

import com.aloute.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
    Optional<User> findByEmail(String email);
    Boolean existsByUsername(String username);
    Boolean existsByEmail(String email);

    // Tìm kiếm người dùng theo họ tên hoặc username (danh sách)
    List<User> findByFullNameContainingIgnoreCaseOrUsernameContainingIgnoreCase(String name, String username);
    
    // Tìm kiếm người dùng có phân trang (dùng cho thanh tìm kiếm bạn bè / người dùng)
    Page<User> findByFullNameContainingIgnoreCaseOrUsernameContainingIgnoreCase(String name, String username, Pageable pageable);

    // 1. Dành cho Admin: Lấy danh sách thành viên (loại trừ Admin) có phân trang
    @Query("SELECT u FROM User u WHERE LOWER(u.username) NOT LIKE '%admin%' ORDER BY u.createdAt DESC")
    Page<User> findAllRegularUsers(Pageable pageable);

    // 2. Dành cho Admin: Tìm kiếm thành viên theo từ khóa (họ tên, username, email) có phân trang
    @Query("SELECT u FROM User u WHERE LOWER(u.username) NOT LIKE '%admin%' " +
           "AND (:keyword IS NULL OR :keyword = '' " +
           "OR LOWER(u.fullName) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
           "OR LOWER(u.username) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
           "OR LOWER(u.email) LIKE LOWER(CONCAT('%', :keyword, '%')))")
    Page<User> searchUsersForAdmin(@Param("keyword") String keyword, Pageable pageable);

    long countByActive(boolean active);
}