package com.fireshield.server.api.dto;

/**
 * Response returned after login or registration.
 */
public record AuthResponse(
    String token,
    String userId,
    String displayName,
    String email
) {}
