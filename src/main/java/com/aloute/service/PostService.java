package com.aloute.service;

import com.aloute.dto.PostCreateDTO;
import com.aloute.entity.Post;
import com.aloute.entity.PostImage;
import com.aloute.entity.User;
import com.aloute.repository.PostRepository;
import com.aloute.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
    
    @Autowired
    private com.aloute.repository.SavedPostRepository savedPostRepository;

    // Lưu / Bỏ lưu bài viết (Toggle)
    @Transactional
    public boolean toggleSavePost(Long postId) {
        Long currentUserId = 1L; // User tạm thời
        if (savedPostRepository.existsByUserIdAndPostId(currentUserId, postId)) {
            savedPostRepository.deleteByUserIdAndPostId(currentUserId, postId);
            return false; // Đã bỏ lưu
        } else {
            User user = userRepository.findById(currentUserId).orElseThrow();
            Post post = getPostById(postId);
            savedPostRepository.save(com.aloute.entity.SavedPost.builder()
                    .user(user)
                    .post(post)
                    .build());
            return true; // Đã lưu
        }
    }

    // Kiểm tra bài viết đã được lưu chưa
    public boolean isPostSaved(Long postId) {
        return savedPostRepository.existsByUserIdAndPostId(1L, postId);
    }

    // Lấy danh sách các bài viết đã lưu
    public List<Post> getSavedPosts() {
        List<com.aloute.entity.SavedPost> list = savedPostRepository.findAllByUserIdOrderByCreatedAtDesc(1L);
        return list.stream().map(com.aloute.entity.SavedPost::getPost).toList();
    }

    // Chia sẻ bài viết lên Feed của mình
    @Transactional
    public Post sharePostToFeed(Long originalPostId, String caption, String privacy) {
        User currentUser = userRepository.findById(1L).orElseThrow();
        Post originalPost = getPostById(originalPostId);

        // Tăng số lượt chia sẻ của bài gốc
        originalPost.setShareCount(originalPost.getShareCount() == null ? 1 : originalPost.getShareCount() + 1);
        postRepository.save(originalPost);

        // Tạo bài viết mới trích dẫn nội dung bài gốc
        String combinedContent = (caption != null && !caption.isBlank() ? caption + "\n\n" : "") 
                + "🔁 [Chia sẻ từ " + (originalPost.getUser().getFullName() != null ? originalPost.getUser().getFullName() : originalPost.getUser().getUsername()) + "]:\n" 
                + originalPost.getContent();

        Post sharedPost = Post.builder()
                .content(combinedContent)
                .privacy(privacy != null ? privacy : "PUBLIC")
                .user(currentUser)
                .build();

        // Kế thừa các ảnh từ bài gốc
        if (originalPost.getImages() != null) {
            for (com.aloute.entity.PostImage img : originalPost.getImages()) {
                sharedPost.getImages().add(com.aloute.entity.PostImage.builder()
                        .imageUrl(img.getImageUrl())
                        .post(sharedPost)
                        .build());
            }
        }
        return postRepository.save(sharedPost);
    }

    // Chia sẻ cho bạn bè (tăng counter)
    @Transactional
    public void shareToFriend(Long postId) {
        Post post = getPostById(postId);
        post.setShareCount(post.getShareCount() == null ? 1 : post.getShareCount() + 1);
        postRepository.save(post);
    }

    // 1. Lấy danh sách toàn bộ bài viết mới nhất
    public List<Post> getAllPosts() {
        return postRepository.findAllByOrderByCreatedAtDesc();
    }

    // 2. Lấy 1 bài viết theo ID
    public Post getPostById(Long id) {
        return postRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy bài viết với ID: " + id));
    }

    // 3. Đăng bài viết mới (hỗ trợ nhiều ảnh qua DTO, tạm gán User ID = 1)
    @Transactional
    public Post createPost(PostCreateDTO dto) throws IOException {
        User user = userRepository.findById(1L)
                .orElseThrow(() -> new RuntimeException("Chưa có User ID = 1 trong Database!"));

        Post post = Post.builder()
                .content(dto.getContent())
                .privacy(dto.getPrivacy() != null ? dto.getPrivacy() : "PUBLIC")
                .user(user)
                .build();

        // Xử lý upload danh sách ảnh lên Cloudinary
        if (dto.getImages() != null && !dto.getImages().isEmpty()) {
            List<String> imageUrls = cloudinaryService.uploadMultipleImages(dto.getImages());
            for (String url : imageUrls) {
                PostImage postImage = PostImage.builder()
                        .imageUrl(url)
                        .post(post)
                        .build();
                post.getImages().add(postImage);
            }
        }

        return postRepository.save(post);
    }

    // 4. Chỉnh sửa nội dung bài viết
    @Transactional
    public Post updatePost(Long id, String newContent, String newPrivacy) {
        Post post = getPostById(id);
        post.setContent(newContent);
        if (newPrivacy != null) {
            post.setPrivacy(newPrivacy);
        }
        return postRepository.save(post);
    }

    // 5. Xóa bài viết
    @Transactional
    public void deletePost(Long id) {
        Post post = getPostById(id);
        postRepository.delete(post);
    }
}