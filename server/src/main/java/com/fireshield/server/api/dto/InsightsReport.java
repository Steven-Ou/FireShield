package com.fireshield.server.api.dto;

import java.util.List;
import java.util.Map;

public record InsightsReport(
    int windowHours,
    Map<String, Object> metrics,   // computed metrics fed to the model
    AiReport aiReport,             // structured Gemini output
    String model,                  // model actually used
    String source                  // "model" or "fallback"
) {
  public record AiReport(
      String summary,                 // 2–3 sentences
      Integer riskScore,              // 0–100
      List<String> keyFindings,       // 3–5 bullets
      List<String> recommendations,   // 3–5 bullets
      List<String> deconChecklist,    // 3–6 items
      String policySuggestion         // optional paragraph (may be null)
  ) {}
}
