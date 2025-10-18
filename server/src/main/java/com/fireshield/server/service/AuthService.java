// src/main/java/com/fireshield/server/service/AuthService.java
package com.fireshield.server.service;

import com.fireshield.server.api.dto.AuthResponse;
import com.fireshield.server.api.dto.LoginRequest;
import com.fireshield.server.api.dto.RegisterRequest;
import com.fireshield.server.domain.User;
import com.fireshield.server.repo.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class AuthService {

  private final UserRepository users;
  private final JwtService jwt;
  private final BCryptPasswordEncoder bCrypt = new BCryptPasswordEncoder();

  public AuthService(UserRepository users, JwtService jwt) {
    this.users = users;
    this.jwt = jwt;
  }

  /**
   * Registers a new user. Returns 409 CONFLICT if the email already exists.
   */
  public AuthResponse register(RegisterRequest req) {
    users.findByEmail(req.email()).ifPresent(u -> {
      throw new ResponseStatusException(HttpStatus.CONFLICT, "Email already in use");
    });

    User u = new User();
    u.setEmail(req.email());
    u.setDisplayName(req.displayName());
    u.setPasswordHash(bCrypt.encode(req.password()));
    // role defaults to "USER" in your entity

    users.save(u);

    String token = jwt.issue(u.getId(), u.getEmail(), u.getRole());
    return new AuthResponse(token, u.getId().toString(), u.getDisplayName(), u.getEmail());
  }

  /**
   * Logs in an existing user. Returns 401 UNAUTHORIZED on bad credentials.
   */
  public AuthResponse login(LoginRequest req) {
    User u = users.findByEmail(req.email())
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid email or password"));

    if (!bCrypt.matches(req.password(), u.getPasswordHash())) {
      throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid email or password");
    }

    String token = jwt.issue(u.getId(), u.getEmail(), u.getRole());
    return new AuthResponse(token, u.getId().toString(), u.getDisplayName(), u.getEmail());
  }
}
