package com.fireshield.server.api;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/samples") // this maps to /api/v1/samples due to your context-path
public class IngestController {
  private static final Logger log = LoggerFactory.getLogger(IngestController.class);

  public record SampleDto(String ts, Double tvoc_ppb, Double formaldehyde_ppm, Double benzene_ppm, Double hum_rel, Double temp_c) {}
  public record IngestRequest(String deviceId, SampleDto[] samples) {}

  @PostMapping
  public ResponseEntity<?> ingest(
      @RequestHeader(value = "X-Device-Key", required = false) String deviceKey,
      @RequestBody IngestRequest body) {

    log.info("POST /samples key={}, deviceId={}, count={}",
        deviceKey, body.deviceId(), body.samples() == null ? 0 : body.samples().length);

    // DEV sanity: accept only DEV_KEY; return 403 otherwise (so we can see it work)
    if (!"DEV_KEY".equals(deviceKey)) {
      return ResponseEntity.status(403).body(Map.of("error", "Invalid device key"));
    }
    return ResponseEntity.ok(Map.of("status", "ok"));
  }
}
