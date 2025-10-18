// api/SampleController.java
package com.fireshield.server.api;

import com.fireshield.server.api.dto.*;
import com.fireshield.server.service.IngestService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@RestController
public class SampleController {
  private final IngestService ingest;
  public SampleController(IngestService ingest) { this.ingest = ingest; }

  @PostMapping("/samples")
  public IngestResponse postSamples(@Valid @RequestBody SampleBatchRequest body) {
    return ingest.ingest(body);
  }
}
