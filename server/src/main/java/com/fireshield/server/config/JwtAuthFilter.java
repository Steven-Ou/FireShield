// src/main/java/com/fireshield/server/config/JwtAuthFilter.java
package com.fireshield.server.config;

import com.fireshield.server.service.JwtService;
import io.jsonwebtoken.Claims;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import org.springframework.http.HttpHeaders;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;

import java.io.IOException;
import java.util.List;

public class JwtAuthFilter extends GenericFilter {

  private final JwtService jwt;

  public JwtAuthFilter(JwtService jwt) { this.jwt = jwt; }

  @Override
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
      throws IOException, ServletException {

    HttpServletRequest req = (HttpServletRequest) request;
    String auth = req.getHeader(HttpHeaders.AUTHORIZATION);
    if (auth != null && auth.startsWith("Bearer ")) {
      String token = auth.substring(7);
      try {
        Claims claims = jwt.parse(token).getBody();
        String role = (String) claims.get("role");
        var authObj = new UsernamePasswordAuthenticationToken(
            claims.getSubject(), null, List.of(new SimpleGrantedAuthority("ROLE_" + role)));
        SecurityContextHolder.getContext().setAuthentication(authObj);
      } catch (Exception ignored) {
        // token invalid or expired -> leave context empty (request will be rejected by security if required)
      }
    }
    chain.doFilter(request, response);
  }
}
