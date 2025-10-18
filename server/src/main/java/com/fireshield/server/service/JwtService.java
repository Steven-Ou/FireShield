// service/JwtService.java
package com.fireshield.server.service;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.time.Instant;
import java.util.Date;
import java.util.Map;
import java.util.UUID;

@Service
public class JwtService {
  private final SecretKey key;
  private final long expirySeconds;

  public JwtService(
      @Value("${app.jwt.secret}") String secret,
      @Value("${app.jwt.expirySeconds}") long expirySeconds
  ) {
    this.key = Keys.hmacShaKeyFor(secret.getBytes());
    this.expirySeconds = expirySeconds;
  }

  public String issue(UUID userId, String email, String role) {
    Instant now = Instant.now();
    return Jwts.builder()
      .setSubject(userId.toString())
      .addClaims(Map.of("email", email, "role", role))
      .setIssuedAt(Date.from(now))
      .setExpiration(Date.from(now.plusSeconds(expirySeconds)))
      .signWith(key, SignatureAlgorithm.HS256)
      .compact();
  }

  public Jws<Claims> parse(String token) {
    return Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token);
  }
}
