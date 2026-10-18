package com.aloute.repository;

import com.aloute.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
    Optional<User> findByEmail(String email);
    Boolean existsByUsername(String username);
    Boolean existsByEmail(String email);

    // Tìm kiếm người dùng theo họ tên hoặc username
    List<User> findByFullNameContainingIgnoreCaseOrUsernameContainingIgnoreCase(String name, String username);
}