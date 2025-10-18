// service/IngestService.java
package com.fireshield.server.service;

import com.fireshield.server.api.dto.*;
import com.fireshield.server.domain.Device;
import com.fireshield.server.domain.Sample;
import com.fireshield.server.repo.DeviceRepository;
import com.fireshield.server.repo.SampleRepository;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class IngestService {
  private final DeviceRepository devices;
  private final SampleRepository samples;

  public IngestService(DeviceRepository devices, SampleRepository samples) {
    this.devices = devices; this.samples = samples;
  }

  public IngestResponse ingest(SampleBatchRequest body) {
    UUID deviceId = UUID.fromString(body.deviceId());
    Device device = devices.findById(deviceId).orElseThrow(() -> new RuntimeException("Device not found"));

    int ok = 0, bad = 0;
    for (SamplePoint p : body.samples()) {
      try {
        Sample s = new Sample();
        s.setDevice(device);
        s.setTs(p.ts());
        s.setTvoc_ppb(p.tvoc_ppb());
        s.setVoc_index(p.voc_index());
        s.setEco2_ppm(p.eco2_ppm());
        s.setHum_rel(p.hum_rel());
        s.setTempC(p.tempC());  // mapped from tempC or temp_c (see DTO alias)
        s.setFormaldehyde_ppm(p.formaldehyde_ppm());
        s.setBenzene_ppm(p.benzene_ppm());
        samples.save(s);
        ok++;
      } catch (Exception e) { bad++; }
    }
    return new IngestResponse(ok, bad);
  }
}
