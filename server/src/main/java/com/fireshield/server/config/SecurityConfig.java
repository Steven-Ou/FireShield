package com.fireshield.server.config;

import com.fireshield.server.security.JwtService;
import io.jsonwebtoken.Claims;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

@Configuration
public class SecurityConfig {

  @Bean
  public SecurityFilterChain filterChain(HttpSecurity http, JwtService jwt) throws Exception {
    http
        .csrf(csrf -> csrf.disable())
        .cors(cors -> {}) // enable default CORS
        .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
        .authorizeHttpRequests(reg -> reg
            .requestMatchers("/actuator/**", "/health").permitAll()
            .requestMatchers("/auth/**").permitAll()
            .requestMatchers(HttpMethod.POST, "/samples").permitAll() // device ingest via X-Device-Key
            .anyRequest().authenticated()
        );

    http.addFilterBefore(new JwtAuthFilter(jwt), UsernamePasswordAuthenticationFilter.class);
    return http.build();
  }

  static class JwtAuthFilter extends OncePerRequestFilter {
    private final JwtService jwt;
    JwtAuthFilter(JwtService jwt) { this.jwt = jwt; }

    @Override
    protected void doFilterInternal(HttpServletRequest req,
                                    HttpServletResponse res,
                                    FilterChain chain) throws ServletException, IOException {
      var auth = req.getHeader("Authorization");
      if (auth != null && auth.startsWith("Bearer ")) {
        try {
          Claims claims = jwt.parse(auth.substring(7));
          String sub = claims.getSubject();
          String role = claims.get("role", String.class);
          var authToken = new UsernamePasswordAuthenticationToken(
              sub, null, List.of(new SimpleGrantedAuthority("ROLE_" + role)));
          SecurityContextHolder.getContext().setAuthentication(authToken);
        } catch (Exception ignored) {}
      }
      chain.doFilter(req, res);
    }
  }
}
