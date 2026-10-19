package com.aloute.service;

import com.aloute.entity.Post;
import com.aloute.entity.PostImage;
import com.aloute.entity.User;
import com.aloute.repository.PostRepository;
import com.aloute.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@Service
public class PostService {

    @Autowired
    private PostRepository postRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private CloudinaryService cloudinaryService;

    // Lấy tất cả bài viết mới nhất ra bảng tin
    public List<Post> getAllPosts() {
        return postRepository.findAllByOrderByCreatedAtDesc();
    }

    // Đăng bài viết mới (tạm thời gán User ID = 1)
    @Transactional
    public Post createPost(String content, MultipartFile file) throws IOException {
        User user = userRepository.findById(1L)
                .orElseThrow(() -> new RuntimeException("Chưa có User ID = 1 trong Database. Vui lòng tạo 1 user trước!"));

        Post post = Post.builder()
                .content(content)
                .user(user)
                .privacy("PUBLIC")
                .build();

        // Nếu có tải ảnh lên thì upload qua Cloudinary và lưu vào PostImage
        if (file != null && !file.isEmpty()) {
            String imageUrl = cloudinaryService.uploadImage(file);
            if (imageUrl != null) {
                PostImage postImage = PostImage.builder()
                        .imageUrl(imageUrl)
                        .post(post)
                        .build();
                post.getImages().add(postImage);
            }
        }

        return postRepository.save(post);
    }
}