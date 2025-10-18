// service/AuthService.java
package com.fireshield.server.service;

import com.fireshield.server.api.dto.*;
import com.fireshield.server.domain.User;
import com.fireshield.server.repo.UserRepository;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {
  private final UserRepository users;
  private final JwtService jwt;
  private final BCryptPasswordEncoder bCrypt = new BCryptPasswordEncoder();

  public AuthService(UserRepository users, JwtService jwt) {
    this.users = users; this.jwt = jwt;
  }

  public AuthResponse register(RegisterRequest req) {
    users.findByEmail(req.email()).ifPresent(u -> { throw new RuntimeException("Email already in use"); });
    User u = new User();
    u.setEmail(req.email());
    u.setDisplayName(req.displayName());
    u.setPasswordHash(bCrypt.encode(req.password()));
    users.save(u);
    String token = jwt.issue(u.getId(), u.getEmail(), u.getRole());
    return new AuthResponse(token, u.getId().toString(), u.getDisplayName(), u.getEmail());
  }

  public AuthResponse login(LoginRequest req) {
    User u = users.findByEmail(req.email()).orElseThrow(() -> new RuntimeException("Invalid login"));
    if (!bCrypt.matches(req.password(), u.getPasswordHash())) throw new RuntimeException("Invalid login");
    String token = jwt.issue(u.getId(), u.getEmail(), u.getRole());
    return new AuthResponse(token, u.getId().toString(), u.getDisplayName(), u.getEmail());
  }
}
