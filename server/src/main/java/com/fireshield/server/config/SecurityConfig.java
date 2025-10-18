// src/main/java/com/fireshield/server/config/SecurityConfig.java
package com.fireshield.server.config;

import com.fireshield.server.repo.DeviceRepository;
import com.fireshield.server.service.JwtService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.*;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.*;

import java.util.List;

@Configuration
@EnableWebSecurity
public class SecurityConfig {
  private final JwtService jwt;
  private final DeviceRepository devices;
  private final String ingestHeader;
  private final List<String> allowedOrigins;

  public SecurityConfig(
      JwtService jwt, DeviceRepository devices,
      @Value("${app.ingest.device-header}") String ingestHeader,
      @Value("${app.cors.allowed-origins}") String allowedOriginsCsv
  ) {
    this.jwt = jwt;
    this.devices = devices;
    this.ingestHeader = ingestHeader;
    this.allowedOrigins = List.of(allowedOriginsCsv.split("\\s*,\\s*"));
  }

  @Bean
  SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    http.csrf(csrf -> csrf.disable())
        .cors(cors -> cors.configurationSource(corsSource()))
        .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
        .authorizeHttpRequests(reg -> reg
            .requestMatchers("/health", "/actuator/health").permitAll()
            .requestMatchers(HttpMethod.POST, "/auth/**").permitAll()     // wildcard for auth endpoints
            .requestMatchers(HttpMethod.POST, "/samples").permitAll()     // guarded by DeviceKeyFilter
            .anyRequest().authenticated()
        )
        .addFilterBefore(new DeviceKeyFilter(devices, ingestHeader),
            org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter.class)
        .addFilterBefore(new JwtAuthFilter(jwt),
            org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter.class);
    return http.build();
  }

  private CorsConfigurationSource corsSource() {
    CorsConfiguration cfg = new CorsConfiguration();
    cfg.setAllowedOrigins(allowedOrigins);
    cfg.setAllowedMethods(List.of("GET","POST","PUT","DELETE","OPTIONS"));
    cfg.setAllowedHeaders(List.of("*"));
    cfg.setAllowCredentials(true);
    UrlBasedCorsConfigurationSource src = new UrlBasedCorsConfigurationSource();
    src.registerCorsConfiguration("/**", cfg);
    return src;
  }
}
