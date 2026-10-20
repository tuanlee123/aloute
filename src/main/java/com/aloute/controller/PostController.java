package com.aloute.controller;

import com.aloute.dto.PostCreateDTO;
import com.aloute.entity.Post;
import com.aloute.entity.User;
import com.aloute.service.PostService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequestMapping("/post")
public class PostController {

	@Autowired
	private PostService postService;

	// Xem bảng tin: /post hoặc /post/feed
	@GetMapping({ "", "/feed" })
	public String showFeed(Model model) {
		List<Post> posts = postService.getAllPosts();
		model.addAttribute("posts", posts);
		return "post/feed";
	}

	// Hiển thị trang tạo bài viết riêng biệt (create-post.jsp)
	@GetMapping("/create")
	public String showCreateForm(Model model) {
		model.addAttribute("postCreateDTO", new PostCreateDTO());
		return "post/create-post";
	}

	// 1. Xử lý tạo bài viết: Lấy đúng currentUser từ Session
	@PostMapping("/create")
	public String createPost(@ModelAttribute PostCreateDTO postCreateDTO, HttpSession session) {
		User currentUser = (User) session.getAttribute("currentUser");
		if (currentUser == null) {
			return "redirect:/login";
		}

		try {
			postService.createPost(postCreateDTO, currentUser);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return "redirect:/post/feed";
	}

	// Hiển thị form chỉnh sửa bài viết
	@GetMapping("/edit/{id}")
	public String showEditForm(@PathVariable("id") Long id, Model model) {
		Post post = postService.getPostById(id);
		model.addAttribute("post", post);
		return "post/edit-post";
	}

	// Xử lý cập nhật bài viết
	@PostMapping("/edit/{id}")
	public String updatePost(@PathVariable("id") Long id, @RequestParam("content") String content,
			@RequestParam(value = "privacy", defaultValue = "PUBLIC") String privacy) {
		try {
			postService.updatePost(id, content, privacy);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return "redirect:/post/feed";
	}

	// Xử lý xóa bài viết (quay lại trang hiện tại)
	@PostMapping("/delete/{id}")
	public String deletePost(@PathVariable("id") Long id,
			@RequestHeader(value = "Referer", required = false) String referer) {
		try {
			postService.deletePost(id);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return (referer != null && !referer.isEmpty()) ? "redirect:" + referer : "redirect:/post/feed";
	}

	// Danh sách bài viết đã lưu
	@GetMapping("/saved")
	public String showSavedPosts(HttpSession session, Model model) {
		User currentUser = (User) session.getAttribute("currentUser");
		if (currentUser == null) {
			return "redirect:/login";
		}

		List<Post> savedPosts = postService.getSavedPosts(currentUser);
		model.addAttribute("posts", savedPosts);
		model.addAttribute("isSavedPage", true);
		return "post/saved";
	}

	// Lưu / Bỏ lưu bài viết (Hỗ trợ Ajax)
	@PostMapping("/save/{id}")
	@ResponseBody
	public java.util.Map<String, Object> toggleSave(@PathVariable("id") Long id, HttpSession session) {
		User currentUser = (User) session.getAttribute("currentUser");
		boolean isSaved = postService.toggleSavePost(id, currentUser);
		return java.util.Map.of("success", true, "isSaved", isSaved);
	}

	// 2. Chia sẻ lên Feed của mình: Truyền currentUser để bài chia sẻ gắn vào chính
	// mình
	@PostMapping("/share/{id}")
	public String sharePost(@PathVariable("id") Long id,
			@RequestParam(value = "caption", required = false) String caption,
			@RequestParam(value = "privacy", defaultValue = "PUBLIC") String privacy, HttpSession session) {
		User currentUser = (User) session.getAttribute("currentUser");
		if (currentUser == null) {
			return "redirect:/login";
		}

		try {
			postService.sharePostToFeed(id, caption, privacy, currentUser);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return "redirect:/post/feed";
	}

	// Chia sẻ nhanh cho bạn bè
	@PostMapping("/share/friend/{id}")
	@ResponseBody
	public java.util.Map<String, Object> shareToFriend(@PathVariable("id") Long id) {
		postService.shareToFriend(id);
		return java.util.Map.of("success", true);
	}
}