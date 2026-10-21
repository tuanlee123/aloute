package com.aloute.controller;

import com.aloute.entity.User;
import com.aloute.service.SearchService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequiredArgsConstructor
public class SearchController {

    private final SearchService searchService;

    @GetMapping("/search")
    public String search(@RequestParam(name = "q", defaultValue = "") String q,
                         HttpSession session, Model model) {
        User current = (User) session.getAttribute("currentUser");
        model.addAttribute("keyword", q);
        model.addAttribute("users", searchService.searchUsers(q));
        model.addAttribute("posts", searchService.searchPosts(q, current.getId()));
        return "admin/search-results";
    }
}
