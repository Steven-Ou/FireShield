// domain/Alert.java
package com.fireshield.server.domain;

import jakarta.persistence.*;
import java.time.Instant;

@Entity @Table(name="alerts")
public class Alert {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
  @ManyToOne(optional=false) @JoinColumn(name="device_id") private Device device;
  @Column(nullable=false) private String level;
  @Column(nullable=false) private String message;
  @Column(nullable=false) private Instant ts = Instant.now();
  public Long getId() { return id; }
  public Device getDevice() { return device; }
  public void setDevice(Device device) { this.device = device; }
  public String getLevel() { return level; }
  public void setLevel(String level) { this.level = level; }
  public String getMessage() { return message; }
  public void setMessage(String message) { this.message = message; }
  public Instant getTs() { return ts; }
  public void setTs(Instant ts) { this.ts = ts; }
}
