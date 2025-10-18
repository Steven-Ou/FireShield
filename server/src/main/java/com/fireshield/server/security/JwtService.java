package com.fireshield.server.security;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;

@Service
public class JwtService {
  private final byte[] key;
  private final String issuer;
  private final long ttlMinutes;

  public JwtService(
      @Value("${security.jwt.secret}") String secret,
      @Value("${security.jwt.issuer}") String issuer,
      @Value("${security.jwt.ttlMinutes}") long ttlMinutes) {
    this.key = secret.getBytes(StandardCharsets.UTF_8);
    this.issuer = issuer;
    this.ttlMinutes = ttlMinutes;
  }

  public String issue(String subject, String role) {
    var now = Instant.now();
    var exp = now.plusSeconds(ttlMinutes * 60);
    return Jwts.builder()
      .setSubject(subject)
      .setIssuer(issuer)
      .claim("role", role)
      .setIssuedAt(Date.from(now))
      .setExpiration(Date.from(exp))
      .signWith(Keys.hmacShaKeyFor(key))
      .compact();
  }

  public io.jsonwebtoken.Claims parse(String token) {
    return Jwts.parserBuilder()
      .setSigningKey(Keys.hmacShaKeyFor(key))
      .requireIssuer(issuer)
      .build()
      .parseClaimsJws(token)
      .getBody();
  }
}
