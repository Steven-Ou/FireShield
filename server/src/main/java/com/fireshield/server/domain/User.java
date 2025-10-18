// domain/User.java
package com.fireshield.server.domain;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity @Table(name="users")
public class User {
  @Id @GeneratedValue private UUID id;
  @Column(nullable=false, unique=true) private String email;
  @Column(name="password_hash", nullable=false) private String passwordHash;
  @Column(name="display_name", nullable=false) private String displayName;
  @Column(nullable=false) private String role = "USER";
  @Column(name="created_at", nullable=false) private Instant createdAt = Instant.now();
  public UUID getId() { return id; }
  public String getEmail() { return email; }
  public void setEmail(String email) { this.email = email; }
  public String getPasswordHash() { return passwordHash; }
  public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
  public String getDisplayName() { return displayName; }
  public void setDisplayName(String displayName) { this.displayName = displayName; }
  public String getRole() { return role; }
  public void setRole(String role) { this.role = role; }
  public Instant getCreatedAt() { return createdAt; }
}
