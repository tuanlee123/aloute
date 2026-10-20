package com.aloute.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
public class CloudinaryService {

    @Autowired
    private Cloudinary cloudinary;

    // Upload 1 ảnh đơn lẻ
    public String uploadImage(MultipartFile file) throws IOException {
        if (file == null || file.isEmpty()) {
            return null;
        }
        Map<?, ?> uploadResult = cloudinary.uploader().upload(file.getBytes(), ObjectUtils.asMap(
                "folder", "aloute_posts"
        ));
        return uploadResult.get("secure_url").toString();
    }

    // Upload danh sách nhiều ảnh cùng lúc
    public List<String> uploadMultipleImages(List<MultipartFile> files) throws IOException {
        List<String> imageUrls = new ArrayList<>();
        if (files != null && !files.isEmpty()) {
            for (MultipartFile file : files) {
                if (file != null && !file.isEmpty()) {
                    String url = uploadImage(file);
                    if (url != null) {
                        imageUrls.add(url);
                    }
                }
            }
        }
        return imageUrls;
    }
}