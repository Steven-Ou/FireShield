// domain/Sample.java
package com.fireshield.server.domain;

import jakarta.persistence.*;
import java.time.Instant;

@Entity @Table(name="samples")
public class Sample {
  @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;

  @ManyToOne(optional=false) @JoinColumn(name="device_id")
  private Device device;

  @Column(nullable=false) private Instant ts;
  private Double tvoc_ppb;
  private Double voc_index;
  private Double eco2_ppm;
  private Double hum_rel;
  @Column(name="temp_c") private Double tempC;
  private Double formaldehyde_ppm;
  private Double benzene_ppm;
  @Column(name="created_at", nullable=false) private Instant createdAt = Instant.now();

  public Long getId() { return id; }
  public Device getDevice() { return device; }
  public void setDevice(Device device) { this.device = device; }
  public Instant getTs() { return ts; }
  public void setTs(Instant ts) { this.ts = ts; }
  public Double getTvoc_ppb() { return tvoc_ppb; }
  public void setTvoc_ppb(Double v) { this.tvoc_ppb = v; }
  public Double getVoc_index() { return voc_index; }
  public void setVoc_index(Double v) { this.voc_index = v; }
  public Double getEco2_ppm() { return eco2_ppm; }
  public void setEco2_ppm(Double v) { this.eco2_ppm = v; }
  public Double getHum_rel() { return hum_rel; }
  public void setHum_rel(Double v) { this.hum_rel = v; }
  public Double getTempC() { return tempC; }
  public void setTempC(Double v) { this.tempC = v; }
  public Double getFormaldehyde_ppm() { return formaldehyde_ppm; }
  public void setFormaldehyde_ppm(Double v) { this.formaldehyde_ppm = v; }
  public Double getBenzene_ppm() { return benzene_ppm; }
  public void setBenzene_ppm(Double v) { this.benzene_ppm = v; }
  public Instant getCreatedAt() { return createdAt; }
}
