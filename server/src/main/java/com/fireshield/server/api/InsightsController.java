// src/main/java/com/fireshield/server/api/InsightsController.java
package com.fireshield.server.api;

import com.fireshield.server.service.InsightsService;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/insights")
public class InsightsController {

  private final InsightsService insights;

  public InsightsController(InsightsService insights) {
    this.insights = insights;
  }

  // GET /insights or /insights?hours=168
  @GetMapping
  public Map<String,Object> insights(@RequestParam(name="hours", required=false) Integer hours) {
    return insights.generateInsights(hours);
  }
}
