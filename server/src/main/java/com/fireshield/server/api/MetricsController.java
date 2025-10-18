// api/MetricsController.java
package com.fireshield.server.api;

import com.fireshield.server.service.MetricsService;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
public class MetricsController {
  private final MetricsService metrics;
  public MetricsController(MetricsService metrics) { this.metrics = metrics; }

  @GetMapping("/metrics")
  public Map<String,Object> metrics() { return metrics.overview(); }

  @GetMapping("/health")
  public Map<String, Object> health() { return Map.of("status","UP"); }
}
