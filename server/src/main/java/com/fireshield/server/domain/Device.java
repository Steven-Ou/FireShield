// domain/Device.java
package com.fireshield.server.domain;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity @Table(name="devices")
public class Device {
  @Id @GeneratedValue private UUID id;
  @Column(nullable=false) private String name;
  @Column(name="device_key", nullable=false, unique=true) private String deviceKey;
  @ManyToOne @JoinColumn(name="owner_id") private User owner;
  @Column(name="created_at", nullable=false) private Instant createdAt = Instant.now();
  public UUID getId() { return id; }
  public String getName() { return name; }
  public void setName(String name) { this.name = name; }
  public String getDeviceKey() { return deviceKey; }
  public void setDeviceKey(String deviceKey) { this.deviceKey = deviceKey; }
  public User getOwner() { return owner; }
  public void setOwner(User owner) { this.owner = owner; }
  public Instant getCreatedAt() { return createdAt; }
}
