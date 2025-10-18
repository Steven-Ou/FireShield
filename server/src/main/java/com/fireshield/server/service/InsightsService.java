package com.fireshield.server.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fireshield.server.api.dto.InsightsAdvice;
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
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class InsightsService {

  private static final Logger log = LoggerFactory.getLogger(InsightsService.class);

  private final MetricsService metrics;
  private final ObjectMapper mapper = new ObjectMapper();
  private final HttpClient http = HttpClient.newBuilder()
      .connectTimeout(Duration.ofSeconds(10))
      .build();

  private final String primaryModel;
  private final String fallbackModel;
  private final int maxOutputTokens;
  private final double temperature;
  private final String apiKey;

  public InsightsService(
      MetricsService metrics,
      @Value("${app.gemini.model:gemini-2.5-flash}") String model,
      @Value("${app.gemini.maxOutputTokens:256}") int maxOutputTokens,
      @Value("${app.gemini.temperature:0.2}") double temperature,
      @Value("${GOOGLE_API_KEY:}") String apiKeyFromSpring
  ) {
    this.metrics = metrics;
    this.primaryModel = model;
    this.fallbackModel = "gemini-2.0-flash"; // lighter "thinking"
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

  public Map<String, Object> generateInsights(Integer hoursWindow) {
    int hours = (hoursWindow == null || hoursWindow <= 0) ? 24 : hoursWindow;
    Map<String,Object> m = metrics.overviewForHours(hours);
    String severity = String.valueOf(m.get("severity"));

    String compactPrompt = buildCompactPrompt(m, hours);
    String ultraPrompt   = buildUltraPrompt(m, hours);

    try {
      if (apiKey.isBlank()) {
        return wrap(hours, m, fallbackAdvice(severity), false, primaryModel);
      }

      // Attempt 1 — primary model, compact prompt
      HttpResponse<String> resp1 = callModel(primaryModel, compactPrompt, maxOutputTokens);
      log.info("[INSIGHTS] Gemini status={} body={}", resp1.statusCode(), preview(resp1.body(), 4000));
      InsightsAdvice adv1 = parseAdviceFromBody(resp1.body(), severity);
      if (resp1.statusCode() / 100 == 2 && adv1 != null) {
        return wrap(hours, m, adv1, true, primaryModel);
      }

      // Attempt 2 — same model, ultra-compact prompt, bigger output budget
      String finish1 = extractFinishReason(resp1.body());
      boolean hitMaxTokens = "MAX_TOKENS".equalsIgnoreCase(finish1);
      if (hitMaxTokens || adv1 == null) {
        HttpResponse<String> resp2 = callModel(primaryModel, ultraPrompt, Math.max(320, maxOutputTokens));
        log.info("[INSIGHTS] Gemini RETRY-1 status={} body={}", resp2.statusCode(), preview(resp2.body(), 4000));
        InsightsAdvice adv2 = parseAdviceFromBody(resp2.body(), severity);
        if (resp2.statusCode() / 100 == 2 && adv2 != null) {
          return wrap(hours, m, adv2, true, primaryModel);
        }
      }

      // Attempt 3 — fallback model, ultra-compact prompt, generous out tokens
      HttpResponse<String> resp3 = callModel(fallbackModel, ultraPrompt, 320);
      log.info("[INSIGHTS] Gemini RETRY-2 ({}) status={} body={}", fallbackModel, resp3.statusCode(), preview(resp3.body(), 4000));
      InsightsAdvice adv3 = parseAdviceFromBody(resp3.body(), severity);
      if (resp3.statusCode() / 100 == 2 && adv3 != null) {
        return wrap(hours, m, adv3, true, fallbackModel);
      }

      // Fallback
      return wrap(hours, m, fallbackAdvice(severity), false, primaryModel);

    } catch (Exception e) {
      log.warn("[INSIGHTS] exception calling Gemini; using fallback. {}", e.toString());
      return wrap(hours, m, fallbackAdvice(severity), false, primaryModel);
    }
  }

  // --- HTTP helpers ---

  private HttpResponse<String> callModel(String model, String prompt, int outTokens) throws Exception {
    String url = "https://generativelanguage.googleapis.com/v1/models/" + model + ":generateContent?key=" + apiKey;
    String bodyJson = buildRequestJson(prompt, outTokens);

    HttpRequest req = HttpRequest.newBuilder()
        .uri(URI.create(url))
        .timeout(Duration.ofSeconds(30))
        .header("Content-Type", "application/json; charset=UTF-8")
        .POST(HttpRequest.BodyPublishers.ofString(bodyJson, StandardCharsets.UTF_8))
        .build();

    return http.send(req, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
  }

  private String buildRequestJson(String prompt, int outTokens) throws Exception {
    Map<String, Object> root = new LinkedHashMap<>();
    Map<String, Object> content = Map.of(
        "role", "user",
        "parts", new Object[] { Map.of("text", prompt) }
    );
    Map<String, Object> genCfg = new LinkedHashMap<>();
    genCfg.put("temperature", temperature);
    genCfg.put("maxOutputTokens", outTokens); // no responseMimeType on v1 endpoint

    root.put("contents", new Object[]{ content });
    root.put("generationConfig", genCfg);
    return mapper.writeValueAsString(root);
  }

  private String extractFinishReason(String body) {
    try {
      JsonNode root = mapper.readTree(body);
      JsonNode candidates = root.path("candidates");
      if (candidates.isArray() && candidates.size() > 0) {
        return candidates.get(0).path("finishReason").asText("");
      }
    } catch (Exception ignore) {}
    return "";
  }

  // --- Response parsing ---

  private InsightsAdvice parseAdviceFromBody(String body, String severity) {
    try {
      JsonNode root = mapper.readTree(body);

      // safety block
      String finish = extractFinishReason(body);
      if ("SAFETY".equalsIgnoreCase(finish)) {
        String block = root.path("promptFeedback").path("blockReason").asText("(unknown)");
        log.warn("[INSIGHTS] SAFETY block: {}", block);
        return null;
      }

      String modelText = extractPrimaryText(root);
      log.info("[INSIGHTS] modelText(raw) preview={}", preview(modelText, 400));
      if (modelText == null || modelText.isBlank()) return null;

      String cleaned = stripCodeFences(modelText);
      log.info("[INSIGHTS] modelText(cleaned) preview={}", preview(cleaned, 400));

      // try direct JSON
      InsightsAdvice parsed = tryParseAdvice(cleaned, severity);
      if (parsed != null) return parsed;

      // repair minor truncations, then parse again
      String repaired = repairJson(cleaned);
      if (repaired != null && !repaired.equals(cleaned)) {
        log.info("[INSIGHTS] modelText(repaired) preview={}", preview(repaired, 400));
        InsightsAdvice parsedRepaired = tryParseAdvice(repaired, severity);
        if (parsedRepaired != null) return parsedRepaired;
      }

      // last resort: extract first {...}
      String json = extractFirstJsonObject(cleaned);
      return (json != null) ? tryParseAdvice(json, severity) : null;

    } catch (Exception e) {
      log.debug("[INSIGHTS] parseAdviceFromBody error: {}", e.toString());
      return null;
    }
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

  // --- Prompt builders ---

  /** Short, clear, minimal tokens. */
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
      """.formatted(hours, m.get("avg_tvoc_ppb"), m.get("avg_formaldehyde_ppm"), m.get("avg_benzene_ppm"), m.get("severity"));
  }

  /** Ultra-compact & minified for retries. */
  private String buildUltraPrompt(Map<String,Object> m, int hours) {
    return """
      Output one line of MINIFIED JSON only: {"summary":"...","actions":["...","...","..."],"deconReminder":"..."}
      Constraints: summary<=160 chars; each action<=80 chars; deconReminder<=120 chars; omit deconReminder unless severity is ELEVATED or CRITICAL.
      Inputs: tvoc=%s, ch2o=%s, benzene=%s, severity=%s.
      """.formatted(m.get("avg_tvoc_ppb"), m.get("avg_formaldehyde_ppm"), m.get("avg_benzene_ppm"), m.get("severity"));
  }

  // --- JSON coercion helpers ---

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

  /** Strip ```json fences (or ```). */
  private String stripCodeFences(String s) {
    if (s == null) return null;
    String trimmed = s.trim();
    if (trimmed.startsWith("```")) {
      int firstNl = trimmed.indexOf('\n');
      if (firstNl >= 0) trimmed = trimmed.substring(firstNl + 1);
      int lastFence = trimmed.lastIndexOf("```");
      if (lastFence >= 0) trimmed = trimmed.substring(0, lastFence);
      trimmed = trimmed.trim();
    }
    return trimmed;
  }

  /** Extract first {...} block if extra text surrounds JSON. */
  private String extractFirstJsonObject(String s) {
    if (s == null) return null;
    int depth = 0, start = -1;
    boolean inStr = false; char prev = 0;
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

  /** Best-effort repair for truncated/minor-bad JSON (unbalanced braces, trailing comma). */
  private String repairJson(String s) {
    if (s == null) return null;
    String t = s.trim();

    t = stripCodeFences(t);
    while (t.endsWith("```") || t.endsWith("`")) t = t.substring(0, t.length() - 1).trim();

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

    t = t.replaceAll(",\\s*(\\]|\\})", "$1");
    if (t.endsWith(",")) t = t.substring(0, t.length() - 1);

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

  private static String preview(String s, int max) {
    if (s == null) return "";
    return (s.length() > max) ? s.substring(0, max) + "...(truncated)" : s;
  }

  private Map<String,Object> wrap(int hours, Map<String,Object> m, InsightsAdvice advice, boolean fromModel, String modelUsed) {
    Map<String, Object> out = new LinkedHashMap<>();
    out.put("windowHours", hours);
    out.put("model", modelUsed);
    out.put("metrics", m);
    out.put("advice", advice);
    out.put("source", fromModel ? "model" : "fallback");
    return out;
  }

  // --- severity fallback ---

  private InsightsAdvice fallbackAdvice(String severity) {
    String sev = (severity == null) ? "SAFE" : severity.toUpperCase();
    switch (sev) {
      case "CRITICAL":
        return new InsightsAdvice(
            "Average VOC levels are in a critical range. Limit time in affected areas, escalate ventilation, and prioritize thorough gear decontamination.",
            List.of(
                "Mask up when re-entering contaminated zones.",
                "Run high-flow ventilation and air scrubbers if available.",
                "Initiate full gear laundering and bay decon today."
            ),
            "Reminder: Decon early and often—reduce VOC carryback into quarters."
        );
      case "ELEVATED":
        return new InsightsAdvice(
            "Average VOC levels are elevated. Increase ventilation, isolate contaminated gear, and complete decon steps promptly.",
            List.of(
                "Keep gear bagged outside living spaces.",
                "Vent apparatus bay and turnout storage areas.",
                "Schedule gear cleaning before next shift."
            ),
            "Reminder: Perform gross decon and clean gear ASAP."
        );
      default:
        return new InsightsAdvice(
            "Average VOC levels appear within a safe range. Maintain routine ventilation and post-call hygiene to minimize residual exposure.",
            List.of(
                "Store PPE away from dorms and kitchens.",
                "Air out apparatus bay after each call.",
                "Follow handwashing and shower-within-the-hour."
            ),
            null
        );
    }
  }
}
