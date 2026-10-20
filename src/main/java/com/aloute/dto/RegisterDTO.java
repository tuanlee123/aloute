package com.aloute.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RegisterDTO {
    private String username;
    private String password;
    private String confirmPassword;
    private String fullName;
    private String email;
}