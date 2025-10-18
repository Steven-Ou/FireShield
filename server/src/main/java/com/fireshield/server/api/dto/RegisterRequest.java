package com.fireshield.server.api.dto;

import jakarta.validation.constraints.*;

/**
 * Used for user registration.
 */
public record RegisterRequest(
    @Email @NotBlank String email,
    @NotBlank @Size(min = 3, max = 80) String displayName,
    @NotBlank @Size(min = 8, max = 200) String password
) {}
