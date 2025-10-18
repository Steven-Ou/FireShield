package com.fireshield.server.api.dto;

import jakarta.validation.constraints.*;

/**
 * Used for user login.
 */
public record LoginRequest(
    @Email @NotBlank String email,
    @NotBlank String password
) {}
