package com.fireshield.server.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fireshield.server.api.dto.InsightsReport;
import com.fireshield.server.api.dto.InsightsReport.AiReport;
import com.fireshield.server.api.dto.InsightsAdvice; // keep your existing simple DTO
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;

@Service
public class InsightsService {

  private static final Logger log = LoggerFactory.getLogger(InsightsService.class);

  private final MetricsService metrics;
  private final ObjectMapper mapper = new ObjectMapper();
  private final HttpClient http = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(10)).build();

  private final String primaryModel;
  private final String fallbackModel;
  private final int maxOutputTokens;
  private final double temperature;
  private final String apiKey;

  public InsightsService(
      MetricsService metrics,
      @Value("${app.gemini.model:gemini-2.5-flash}") String model,
      @Value("${app.gemini.maxOutputTokens:512}") int maxOutputTokens,
      @Value("${app.gemini.temperature:0.3}") double temperature,
      @Value("${GOOGLE_API_KEY:}") String apiKeyFromSpring
  ) {
    this.metrics = metrics;
    this.primaryModel = model;
    this.fallbackModel = "gemini-2.0-flash";
    this.maxOutputTokens = maxOutputTokens;
    this.temperature = temperature;

    String envKey = System.getenv("GOOGLE_API_KEY");
    this.apiKey = (apiKeyFromSpring != null && !apiKeyFromSpring.isBlank())
        ? apiKeyFromSpring
        : (envKey == null ? "" : envKey);

    if (this.apiKey.isBlank()) {
      log.warn("[INSIGHTS] GOOGLE_API_KEY is not set; model calls will fall back.");
    }
  }

  // ---------------------------------------------------------------------------
  // OLD endpoint support: /insights (simple advice you already have)
  // ---------------------------------------------------------------------------
  public Map<String, Object> generateInsights(Integer hoursWindow) {
    int hours = (hoursWindow == null || hoursWindow <= 0) ? 24 : hoursWindow;
    Map<String,Object> m = metrics.overviewForHours(hours);
    String severity = String.valueOf(m.get("severity"));

    String compactPrompt = buildCompactPrompt(m, hours);
    String ultraPrompt   = buildUltraPrompt(m, hours);

    try {
      if (apiKey.isBlank()) {
        return wrapSimple(hours, m, fallbackAdvice(severity), false, primaryModel);
      }

      HttpResponse<String> resp1 = callModel(primaryModel, compactPrompt, maxOutputTokens);
      InsightsAdvice adv1 = parseAdviceFromBody(resp1.body(), severity);
      if (resp1.statusCode()/100 == 2 && adv1 != null) {
        return wrapSimple(hours, m, adv1, true, primaryModel);
      }

      HttpResponse<String> resp2 = callModel(primaryModel, ultraPrompt, Math.max(320, maxOutputTokens));
      InsightsAdvice adv2 = parseAdviceFromBody(resp2.body(), severity);
      if (resp2.statusCode()/100 == 2 && adv2 != null) {
        return wrapSimple(hours, m, adv2, true, primaryModel);
      }

      HttpResponse<String> resp3 = callModel(fallbackModel, ultraPrompt, 320);
      InsightsAdvice adv3 = parseAdviceFromBody(resp3.body(), severity);
      if (resp3.statusCode()/100 == 2 && adv3 != null) {
        return wrapSimple(hours, m, adv3, true, fallbackModel);
      }

      return wrapSimple(hours, m, fallbackAdvice(severity), false, primaryModel);

    } catch (Exception e) {
      log.warn("[INSIGHTS] exception calling Gemini; using fallback. {}", e.toString());
      return wrapSimple(hours, m, fallbackAdvice(severity), false, primaryModel);
    }
  }

  // ---------------------------------------------------------------------------
  // NEW endpoint support: /insights/report (rich awareness report)
  // ---------------------------------------------------------------------------
  public InsightsReport generateAwarenessReport(Integer hoursWindow) {
    int hours = (hoursWindow == null || hoursWindow <= 0) ? 24 : hoursWindow;

    Map<String,Object> m = metrics.detailedMetrics(hours);
    String severity = String.valueOf(m.get("severity"));
    String prompt = buildReportPrompt(m, hours);

    try {
      AiReport ai = null;
      String modelUsed = primaryModel;

      if (!apiKey.isBlank()) {
        HttpResponse<String> resp = callModel(primaryModel, prompt, Math.max(640, maxOutputTokens));
        ai = parseReport(resp.body());
        if (!(resp.statusCode()/100 == 2 && ai != null)) {
          HttpResponse<String> resp2 = callModel(fallbackModel, prompt, 640);
          ai = parseReport(resp2.body());
          modelUsed = fallbackModel;
        }
      }
      if (ai == null) ai = fallbackReport(severity);

      return new InsightsReport(hours, m, ai, modelUsed, (apiKey.isBlank() ? "fallback" : "model"));

    } catch (Exception e) {
      log.warn("[INSIGHTS] report error; using fallback. {}", e.toString());
      return new InsightsReport(hours, m, fallbackReport(severity), primaryModel, "fallback");
    }
  }

  // ---------------------- PROMPTS ----------------------

  /** Old compact JSON advice prompt */
  private String buildCompactPrompt(Map<String,Object> m, int hours) {
    return """
      Strict JSON only. Keys: summary, actions, deconReminder.
      No markdown, no extra text.

      Inputs (last %d h):
      avg_tvoc_ppb=%s
      avg_formaldehyde_ppm=%s
      avg_benzene_ppm=%s
      severity=%s

      Rules:
      - summary: 2 short sentences max.
      - actions: 3 bullets, short and practical.
      - deconReminder: include only if severity is ELEVATED or CRITICAL.
      """.formatted(hours, m.get("avg_tvoc_ppb"), m.get("avg_formaldehyde_ppm"),
          m.get("avg_benzene_ppm"), m.get("severity"));
  }

  /** Old ultra-minified retry prompt */
  private String buildUltraPrompt(Map<String,Object> m, int hours) {
    return """
      Output one line of MINIFIED JSON only: {"summary":"...","actions":["...","...","..."],"deconReminder":"..."}
      Constraints: summary<=160 chars; each action<=80 chars; deconReminder<=120 chars; omit deconReminder unless severity is ELEVATED or CRITICAL.
      Inputs: tvoc=%s, ch2o=%s, benzene=%s, severity=%s.
      """.formatted(m.get("avg_tvoc_ppb"), m.get("avg_formaldehyde_ppm"),
          m.get("avg_benzene_ppm"), m.get("severity"));
  }

  /** NEW: richer awareness report prompt */
  private String buildReportPrompt(Map<String,Object> m, int hours) {
    return """
      STRICT JSON ONLY. Structure:
      {
        "summary": "2-3 sentences; mention severity and key numbers",
        "riskScore": 0-100,
        "keyFindings": ["...", "...", "..."],
        "recommendations": ["...", "...", "..."],
        "deconChecklist": ["...", "...", "..."],
        "policySuggestion": "short paragraph (optional)"
      }

      Context (last %d h):
      severity=%s
      samplesCount=%s
      avg_tvoc_ppb=%s
      min_tvoc_ppb=%s
      max_tvoc_ppb=%s
      stddev_tvoc_ppb=%s
      tvoc_slope_ppb_per_hr=%s
      fraction_time_elevated=%s
      fraction_time_critical=%s
      elevated_threshold_ppb=%s
      critical_threshold_ppb=%s
      avg_formaldehyde_ppm=%s
      avg_benzene_ppm=%s

      Rules:
      - Firefighter-facing tone; concise & actionable.
      - riskScore reflects average, peaks, and time above thresholds.
      - keyFindings: spikes, trend direction, unsafe time.
      - recommendations: concrete, near-term actions.
      - deconChecklist: 3–6 short items.
      - policySuggestion: include if severity is ELEVATED/CRITICAL or unsafe time > 0.10.
      """.formatted(
        hours,
        m.get("severity"),
        m.get("samplesCount"),
        m.get("avg_tvoc_ppb"),
        m.get("min_tvoc_ppb"),
        m.get("max_tvoc_ppb"),
        m.get("stddev_tvoc_ppb"),
        m.get("tvoc_slope_ppb_per_hr"),
        m.get("fraction_time_elevated"),
        m.get("fraction_time_critical"),
        m.get("elevated_threshold_ppb"),
        m.get("critical_threshold_ppb"),
        m.get("avg_formaldehyde_ppm"),
        m.get("avg_benzene_ppm")
      );
  }

  // ---------------------- PARSERS ----------------------

  /** Old simple advice parser (kept) */
  private InsightsAdvice parseAdviceFromBody(String body, String severity) {
    try {
      JsonNode root = mapper.readTree(body);
      String modelText = extractPrimaryText(root);
      String cleaned = stripCodeFences(modelText);
      if (cleaned == null || cleaned.isBlank()) return null;

      InsightsAdvice adv = tryParseAdvice(cleaned, severity);
      if (adv != null) return adv;

      String repaired = repairJson(cleaned);
      if (repaired != null) {
        adv = tryParseAdvice(repaired, severity);
        if (adv != null) return adv;
      }

      String json = extractFirstJsonObject(cleaned);
      return (json != null) ? tryParseAdvice(json, severity) : null;

    } catch (Exception e) {
      return null;
    }
  }

  private InsightsAdvice tryParseAdvice(String raw, String severity) {
    try {
      if (raw == null || raw.isBlank()) return null;
      JsonNode node = mapper.readTree(raw);

      String summary = safeText(node.get("summary"), null);
      if (summary == null) summary = safeText(node.get("overview"), null);
      if (summary == null) summary = safeText(node.get("message"), null);

      List<String> actions = null;
      if (node.has("actions")) {
        JsonNode a = node.get("actions");
        if (a.isArray()) {
          actions = mapper.convertValue(
              a, mapper.getTypeFactory().constructCollectionType(List.class, String.class));
        } else if (a.isTextual()) {
          actions = Arrays.stream(a.asText().split("\\n|;|\\|"))
              .map(String::trim).filter(s -> !s.isBlank()).toList();
        }
      }
      if (actions == null || actions.isEmpty()) {
        for (String key : new String[]{"bullets", "action_points", "recommendations", "tips"}) {
          if (node.has(key)) {
            JsonNode a = node.get(key);
            if (a.isArray()) {
              actions = mapper.convertValue(
                  a, mapper.getTypeFactory().constructCollectionType(List.class, String.class));
              break;
            } else if (a.isTextual()) {
              actions = Arrays.stream(a.asText().split("\\n|;|\\|"))
                  .map(String::trim).filter(s -> !s.isBlank()).toList();
              break;
            }
          }
        }
      }

      String deconReminder = null;
      if ("ELEVATED".equalsIgnoreCase(severity) || "CRITICAL".equalsIgnoreCase(severity)) {
        deconReminder = safeText(node.get("deconReminder"), null);
        if (deconReminder == null) deconReminder = safeText(node.get("reminder"), null);
      }

      if (summary == null || actions == null || actions.isEmpty()) return null;
      if (actions.size() > 3) actions = actions.subList(0, 3);

      return new InsightsAdvice(summary, actions, deconReminder);
    } catch (Exception e) {
      return null;
    }
  }

  /** NEW report parser */
  private AiReport parseReport(String body) {
    try {
      JsonNode root = mapper.readTree(body);
      String modelText = extractPrimaryText(root);
      String cleaned = stripCodeFences(modelText);
      if (cleaned == null || cleaned.isBlank()) return null;

      AiReport r = tryParseReport(cleaned);
      if (r != null) return r;

      String repaired = repairJson(cleaned);
      if (repaired != null) {
        r = tryParseReport(repaired);
        if (r != null) return r;
      }

      String json = extractFirstJsonObject(cleaned);
      return (json != null) ? tryParseReport(json) : null;

    } catch (Exception e) {
      return null;
    }
  }

  private AiReport tryParseReport(String json) {
    try {
      JsonNode n = mapper.readTree(json);

      String summary = safeText(n.get("summary"), null);
      Integer risk = (n.has("riskScore") && n.get("riskScore").canConvertToInt())
          ? n.get("riskScore").asInt() : null;

      List<String> findings = extractStringList(n, "keyFindings");
      List<String> recs     = extractStringList(n, "recommendations");
      List<String> decon    = extractStringList(n, "deconChecklist");
      String policy         = safeText(n.get("policySuggestion"), null);

      if (summary == null) return null;
      if (findings == null || findings.isEmpty()) return null;
      if (recs == null || recs.isEmpty()) return null;
      if (decon == null || decon.isEmpty()) {
        decon = List.of("Bag & isolate PPE", "Vent apparatus bay", "Wipe contact surfaces", "Shower within 1 hour");
      }

      if (risk == null) risk = 50;
      risk = Math.max(0, Math.min(100, risk));

      // soft caps for list sizes
      if (findings.size() > 5) findings = findings.subList(0, 5);
      if (recs.size() > 5)     recs     = recs.subList(0, 5);
      if (decon.size() > 6)    decon    = decon.subList(0, 6);

      return new AiReport(summary, risk, findings, recs, decon, policy);

    } catch (Exception e) {
      return null;
    }
  }

  private List<String> extractStringList(JsonNode n, String key) {
    if (!n.has(key)) return null;
    JsonNode a = n.get(key);
    if (a.isArray()) {
      return mapper.convertValue(a, mapper.getTypeFactory().constructCollectionType(List.class, String.class));
    } else if (a.isTextual()) {
      return Arrays.stream(a.asText().split("\\n|;|\\|")).map(String::trim).filter(s -> !s.isBlank()).toList();
    }
    return null;
  }

  // ---------------------- FALLBACKS & WRAPPERS ----------------------

  private Map<String,Object> wrapSimple(int hours, Map<String,Object> m, InsightsAdvice advice, boolean fromModel, String modelUsed) {
    Map<String, Object> out = new LinkedHashMap<>();
    out.put("windowHours", hours);
    out.put("model", modelUsed);
    out.put("metrics", m);
    out.put("advice", advice);
    out.put("source", fromModel ? "model" : "fallback");
    return out;
  }

  private AiReport fallbackReport(String severity) {
    String sev = (severity == null) ? "SAFE" : severity.toUpperCase();
    switch (sev) {
      case "CRITICAL":
        return new AiReport(
            "CRITICAL: Sustained high VOCs and peaks indicate dangerous residual contamination. Ventilate aggressively and prioritize PPE decon.",
            90,
            List.of("TVOC near/above critical threshold", "Peaks suggest hotspots (bay/turnout storage)", "Immediate mitigation needed"),
            List.of("Run high-flow ventilation 45–60 min", "Bag/relocate PPE outside living spaces", "Launder gear and wipe surfaces today"),
            List.of("Mask up when re-entering", "Open bay doors for crossflow", "Bag PPE & keep out of dorms", "Shower within the hour"),
            "Adopt post-call ventilation cycles and PPE isolation; review VOC logs weekly to adjust SOPs."
        );
      case "ELEVATED":
        return new AiReport(
            "ELEVATED: Residual VOCs present; improve ventilation and complete decon steps before next shift.",
            70,
            List.of("Significant time above elevated threshold", "Trend suggests lingering contamination", "Potential carryback into quarters"),
            List.of("Vent spaces 15–30 min", "Keep PPE outside living areas", "Schedule gear cleaning"),
            List.of("Open doors/windows", "Bag PPE", "Wipe high-touch surfaces", "Shower within 1 hour"),
            "Track post-call ventilation and adopt 'clean cab' practices; keep PPE out of dorm/kitchen."
        );
      default:
        return new AiReport(
            "SAFE: Averages within acceptable range. Maintain routine ventilation and post-call hygiene.",
            25,
            List.of("Averages below elevated threshold", "No major peaks detected", "Current practices effective"),
            List.of("Continue routine ventilation", "Store PPE away from living spaces", "Maintain decon discipline"),
            List.of("Air out bay", "Store PPE sealed", "Wash hands before meals"),
            null
        );
    }
  }

  // ---------------------- HTTP & JSON UTIL ----------------------

  private HttpResponse<String> callModel(String model, String prompt, int outTokens) throws Exception {
    String url = "https://generativelanguage.googleapis.com/v1/models/" + model + ":generateContent?key=" + apiKey;
    String bodyJson = buildRequestJson(prompt, outTokens);
    HttpRequest req = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Content-Type", "application/json; charset=UTF-8")
                .POST(HttpRequest.BodyPublishers.ofString(bodyJson, StandardCharsets.UTF_8))
                .build();

        // --- MODIFICATION ---
        // Use sendAsync and enforce a 5-second timeout on getting the result.
        // This prevents the thread from hanging indefinitely.
        CompletableFuture<HttpResponse<String>> future = http.sendAsync(req, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        return future.get(5, TimeUnit.SECONDS); // This will throw a TimeoutException if it takes too long
  }

  private String buildRequestJson(String prompt, int outTokens) throws Exception {
    Map<String, Object> content = Map.of(
        "role", "user",
        "parts", new Object[] { Map.of("text", prompt) }
    );
    Map<String, Object> genCfg = new LinkedHashMap<>();
    genCfg.put("temperature", temperature);
    genCfg.put("maxOutputTokens", outTokens);

    Map<String, Object> root = new LinkedHashMap<>();
    root.put("contents", new Object[]{ content });
    root.put("generationConfig", genCfg);
    return mapper.writeValueAsString(root);
  }

  private String extractPrimaryText(JsonNode root) {
    try {
      JsonNode candidates = root.path("candidates");
      if (!candidates.isArray() || candidates.size() == 0) return "";
      JsonNode first = candidates.get(0);

      JsonNode parts = first.path("content").path("parts");
      if (parts.isArray() && parts.size() > 0) {
        StringBuilder sb = new StringBuilder();
        for (JsonNode p : parts) {
          JsonNode t = p.get("text");
          if (t != null && t.isTextual()) {
            if (sb.length() > 0) sb.append('\n');
            sb.append(t.asText());
          }
        }
        String out = sb.toString().trim();
        if (!out.isBlank()) return out;
      }
      String direct = first.path("content").path("text").asText("");
      if (!direct.isBlank()) return direct.trim();
      return "";
    } catch (Exception e) {
      log.warn("[INSIGHTS] extractPrimaryText error: {}", e.toString());
      return "";
    }
  }

  private String stripCodeFences(String s) {
    if (s == null) return null;
    String t = s.trim();
    if (t.startsWith("```")) {
      int firstNl = t.indexOf('\n');
      if (firstNl >= 0) t = t.substring(firstNl + 1);
      int lastFence = t.lastIndexOf("```");
      if (lastFence >= 0) t = t.substring(0, lastFence);
      t = t.trim();
    }
    return t;
  }

  private String extractFirstJsonObject(String s) {
    if (s == null) return null;
    int depth = 0, start = -1; boolean inStr = false; char prev = 0;
    for (int i = 0; i < s.length(); i++) {
      char c = s.charAt(i);
      if (c == '"' && prev != '\\') inStr = !inStr;
      if (!inStr) {
        if (c == '{') { if (depth == 0) start = i; depth++; }
        else if (c == '}') { depth--; if (depth == 0 && start != -1) return s.substring(start, i + 1); }
      }
      prev = c;
    }
    return null;
  }

  private String repairJson(String s) {
    if (s == null) return null;
    String t = s.trim();
    t = stripCodeFences(t);
    while (t.endsWith("```") || t.endsWith("`")) t = t.substring(0, t.length() - 1).trim();
    t = t.replaceAll(",\\s*(\\]|\\})", "$1");
    if (t.endsWith(",")) t = t.substring(0, t.length() - 1);

    int openCurly = 0, openSquare = 0;
    boolean inStr = false; char prev = 0;
    for (int i = 0; i < t.length(); i++) {
      char c = t.charAt(i);
      if (c == '"' && prev != '\\') inStr = !inStr;
      if (!inStr) {
        if (c == '{') openCurly++;
        else if (c == '}') openCurly = Math.max(0, openCurly - 1);
        else if (c == '[') openSquare++;
        else if (c == ']') openSquare = Math.max(0, openSquare - 1);
      }
      prev = c;
    }
    StringBuilder sb = new StringBuilder(t);
    for (int i = 0; i < openSquare; i++) sb.append(']');
    for (int i = 0; i < openCurly; i++) sb.append('}');
    return sb.toString();
  }

  private static String safeText(JsonNode node, String fallback) {
    if (node == null || !node.isTextual()) return fallback;
    String v = node.asText();
    return (v == null || v.isBlank()) ? fallback : v;
  }

  // ---------------------- SIMPLE ADVICE FALLBACK ----------------------

  private InsightsAdvice fallbackAdvice(String severity) {
    String sev = (severity == null) ? "SAFE" : severity.toUpperCase();
    switch (sev) {
      case "CRITICAL":
        return new InsightsAdvice(
            "Average VOC levels are in a critical range. Limit time in affected areas, escalate ventilation, and prioritize thorough gear decontamination.",
            List.of("Mask up when re-entering contaminated zones.",
                    "Run high-flow ventilation and air scrubbers if available.",
                    "Initiate full gear laundering and bay decon today."),
            "Reminder: Decon early and often—reduce VOC carryback into quarters."
        );
      case "ELEVATED":
        return new InsightsAdvice(
            "Average VOC levels are elevated. Increase ventilation, isolate contaminated gear, and complete decon steps promptly.",
            List.of("Keep gear bagged outside living spaces.",
                    "Vent apparatus bay and turnout storage areas.",
                    "Schedule gear cleaning before next shift."),
            "Reminder: Perform gross decon and clean gear ASAP."
        );
      default:
        return new InsightsAdvice(
            "Average VOC levels appear within a safe range. Maintain routine ventilation and post-call hygiene to minimize residual exposure.",
            List.of("Store PPE away from dorms and kitchens.",
                    "Air out apparatus bay after each call.",
                    "Follow handwashing and shower-within-the-hour."),
            null
        );
    }
  }
}
