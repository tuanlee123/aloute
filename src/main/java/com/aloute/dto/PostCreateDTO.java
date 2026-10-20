package com.aloute.dto;

import lombok.Getter;
import lombok.Setter;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Getter
@Setter
public class PostCreateDTO {
    private String content;
    private String privacy = "PUBLIC";
    private List<MultipartFile> images;
}