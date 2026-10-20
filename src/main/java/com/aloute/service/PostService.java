package com.aloute.service;

import com.aloute.dto.PostCreateDTO;
import com.aloute.entity.Post;
import com.aloute.entity.PostImage;
import com.aloute.entity.User;
import com.aloute.repository.PostRepository;
import com.aloute.repository.SavedPostRepository;
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
	private SavedPostRepository savedPostRepository;

	// 1. Lưu / Bỏ lưu bài viết theo người dùng đang đăng nhập
	@Transactional
	public boolean toggleSavePost(Long postId, User currentUser) {
		if (savedPostRepository.existsByUserIdAndPostId(currentUser.getId(), postId)) {
			savedPostRepository.deleteByUserIdAndPostId(currentUser.getId(), postId);
			return false;
		} else {
			Post post = getPostById(postId);
			savedPostRepository.save(com.aloute.entity.SavedPost.builder().user(currentUser).post(post).build());
			return true;
		}
	}

	// 2. Kiểm tra bài viết đã được người dùng lưu chưa
	public boolean isPostSaved(Long postId, User currentUser) {
		if (currentUser == null)
			return false;
		return savedPostRepository.existsByUserIdAndPostId(currentUser.getId(), postId);
	}

	// 3. Lấy danh sách các bài viết đã lưu của người dùng hiện tại
	public List<Post> getSavedPosts(User currentUser) {
		List<com.aloute.entity.SavedPost> list = savedPostRepository
				.findAllByUserIdOrderByCreatedAtDesc(currentUser.getId());
		return list.stream().map(com.aloute.entity.SavedPost::getPost).toList();
	}

	// 4. Chia sẻ bài viết lên Feed của chính người dùng hiện tại
	@Transactional
	public Post sharePostToFeed(Long originalPostId, String caption, String privacy, User currentUser) {
		Post originalPost = getPostById(originalPostId);

		// Tăng số lượt chia sẻ của bài gốc
		originalPost.setShareCount(originalPost.getShareCount() == null ? 1 : originalPost.getShareCount() + 1);
		postRepository.save(originalPost);

		String originalAuthorName = (originalPost.getUser().getFullName() != null
				&& !originalPost.getUser().getFullName().isBlank()) ? originalPost.getUser().getFullName()
						: originalPost.getUser().getUsername();

		// Tạo bài viết mới gán cho currentUser
		String combinedContent = (caption != null && !caption.isBlank() ? caption + "\n\n" : "") + "🔁 [Chia sẻ từ "
				+ originalAuthorName + "]:\n" + originalPost.getContent();

		Post sharedPost = Post.builder().content(combinedContent).privacy(privacy != null ? privacy : "PUBLIC")
				.user(currentUser).build();

		// Kế thừa các ảnh từ bài gốc
		if (originalPost.getImages() != null) {
			for (PostImage img : originalPost.getImages()) {
				sharedPost.getImages().add(PostImage.builder().imageUrl(img.getImageUrl()).post(sharedPost).build());
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

	// Lấy danh sách toàn bộ bài viết mới nhất cho bảng tin
	public List<Post> getAllPosts() {
		return postRepository.findAllByOrderByCreatedAtDesc();
	}

	// Lấy 1 bài viết theo ID
	public Post getPostById(Long id) {
		return postRepository.findById(id)
				.orElseThrow(() -> new RuntimeException("Không tìm thấy bài viết với ID: " + id));
	}

	// 5. Đăng bài viết mới: Gắn trực tiếp cho currentUser đang đăng nhập
	@Transactional
	public Post createPost(PostCreateDTO dto, User currentUser) throws IOException {
		Post post = Post.builder().content(dto.getContent())
				.privacy(dto.getPrivacy() != null ? dto.getPrivacy() : "PUBLIC").user(currentUser).build();

		// Xử lý upload danh sách ảnh lên Cloudinary
		if (dto.getImages() != null && !dto.getImages().isEmpty()) {
			List<String> imageUrls = cloudinaryService.uploadMultipleImages(dto.getImages());
			for (String url : imageUrls) {
				PostImage postImage = PostImage.builder().imageUrl(url).post(post).build();
				post.getImages().add(postImage);
			}
		}

		return postRepository.save(post);
	}

	// Chỉnh sửa nội dung bài viết
	@Transactional
	public Post updatePost(Long id, String newContent, String newPrivacy) {
		Post post = getPostById(id);
		post.setContent(newContent);
		if (newPrivacy != null) {
			post.setPrivacy(newPrivacy);
		}
		return postRepository.save(post);
	}

	// Xóa bài viết
	@Transactional
	public void deletePost(Long id) {
		Post post = getPostById(id);

		// 1. Xóa sạch các bản ghi bài này trong mục "Đã lưu" trước để không bị dính
		// khóa ngoại
		savedPostRepository.deleteByPostId(id);

		// 2. Sau đó mới xóa bài viết chính
		postRepository.delete(post);
	}
}