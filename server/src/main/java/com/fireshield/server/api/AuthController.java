package com.fireshield.server.api;

import com.fireshield.server.api.dto.AuthResponse;
import com.fireshield.server.api.dto.LoginRequest;
import com.fireshield.server.api.dto.RegisterRequest;
import com.fireshield.server.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
public class AuthController {
  private final AuthService auth;

  public AuthController(AuthService auth) {
    this.auth = auth;
  }

  @PostMapping("/register")
  public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest body) {
    return ResponseEntity.status(201).body(auth.register(body));
  }

  @PostMapping("/login")
  public AuthResponse login(@Valid @RequestBody LoginRequest body) {
    return auth.login(body);
  }
}
