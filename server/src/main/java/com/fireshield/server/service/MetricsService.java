package com.fireshield.server.service;

import com.fireshield.server.repo.SampleRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.LinkedHashMap;
import java.util.Map;

@Service
public class MetricsService {

  private static final Logger log = LoggerFactory.getLogger(MetricsService.class);

  // Tunable thresholds (ppb)
  private static final double TVOC_ELEVATED = 500.0;
  private static final double TVOC_CRITICAL = 900.0;

  // Default rounding precision
  private static final int ROUND_DECIMALS = 3;

  private final SampleRepository samples;

  public MetricsService(SampleRepository samples) {
    this.samples = samples;
  }

  /** Default 24h overview (used by /metrics) */
  @Transactional(readOnly = true)
  public Map<String, Object> overview() {
    return overviewForHours(24);
  }

  /** Simple overview for a caller-specified window (used by /insights) */
  @Transactional(readOnly = true)
  public Map<String, Object> overviewForHours(int windowHours) {
    if (windowHours <= 0) windowHours = 24;

    Object raw = samples.averagesLastHours(windowHours);
    Object[] row = normalizeRow(raw);

    log.info("[DEBUG] averagesLastHours({}): [[{}, {}, {}]]",
        windowHours, safe(row, 0), safe(row, 1), safe(row, 2));

    Double avgTvoc = round(toNumber(row, 0), ROUND_DECIMALS);
    Double avgForm = round(toNumber(row, 1), ROUND_DECIMALS);
    Double avgBenz = round(toNumber(row, 2), ROUND_DECIMALS);

    String severity = classifyTvoc(avgTvoc);

    Map<String, Object> out = new LinkedHashMap<>();
    out.put("windowHours", windowHours);
    out.put("avg_tvoc_ppb", avgTvoc);
    out.put("avg_formaldehyde_ppm", avgForm);
    out.put("avg_benzene_ppm", avgBenz);
    out.put("severity", severity);
    return out;
  }

  /** Rich metrics for awareness report (used by /insights/report) */
  @Transactional(readOnly = true)
  public Map<String, Object> detailedMetrics(int windowHours) {
    if (windowHours <= 0) windowHours = 24;

    final double ELEV = TVOC_ELEVATED;
    final double CRIT = TVOC_CRITICAL;

    // ✅ Unwrap possible nested array (Object[][] -> Object[])
    Object[] row = normalizeRow(samples.detailedStats(windowHours, ELEV, CRIT));
    long samplesCount = toLong(safe(row, 0));

    // --- FIX STARTS HERE ---
    // Crude slope from halves (also unwrap)
    Double slope = null;
    if (samplesCount > 1) { // Only calculate slope if there's data
        Object[] halves = normalizeRow(samples.tvocHalves(windowHours));
        Double avgFirst  = (halves != null && halves.length >= 1) ? toDouble(halves[0]) : null;
        Double avgSecond = (halves != null && halves.length >= 2) ? toDouble(halves[1]) : null;
        if (avgFirst != null && avgSecond != null) {
            slope = round((avgSecond - avgFirst) / (windowHours / 2.0), 3); // ppb per hour
        }
    }
    // --- FIX ENDS HERE ---

    Double avgTvoc = round(toNumber(row, 3), 3);
    Double minTvoc = round(toNumber(row, 4), 3);
    Double maxTvoc = round(toNumber(row, 5), 3);
    Double stdTvoc = round(toNumber(row, 6), 3);
    Double avgForm = round(toNumber(row, 7), 3);
    Double avgBenz = round(toNumber(row, 8), 3);

    long cntElev = toLong(safe(row, 9));
    long cntCrit = toLong(safe(row, 10));

    double fracElev = (samplesCount > 0) ? ((double) cntElev / samplesCount) : 0.0;
    double fracCrit = (samplesCount > 0) ? ((double) cntCrit / samplesCount) : 0.0;

    String severity = classifyTvoc(avgTvoc);

    Map<String, Object> out = new LinkedHashMap<>();
    out.put("windowHours", windowHours);
    out.put("samplesCount", samplesCount);
    out.put("windowStart", safe(row, 1)); // timestamptz
    out.put("windowEnd",   safe(row, 2)); // timestamptz

    out.put("avg_tvoc_ppb", avgTvoc);
    out.put("min_tvoc_ppb", minTvoc);
    out.put("max_tvoc_ppb", maxTvoc);
    out.put("stddev_tvoc_ppb", stdTvoc);
    out.put("avg_formaldehyde_ppm", avgForm);
    out.put("avg_benzene_ppm", avgBenz);

    out.put("severity", severity);
    out.put("tvoc_slope_ppb_per_hr", slope);
    out.put("fraction_time_elevated", round(fracElev, 3));
    out.put("fraction_time_critical", round(fracCrit, 3));
    out.put("elevated_threshold_ppb", ELEV);
    out.put("critical_threshold_ppb", CRIT);
    return out;
  }

  // ---------------- helpers ----------------

  /** Unwrap possible nested array shape from native query */
  private static Object[] normalizeRow(Object raw) {
    if (raw == null) return new Object[0];

    if (raw instanceof Object[] arr) {
      // Some drivers return a single row wrapped inside another Object[]
      if (arr.length == 1 && arr[0] instanceof Object[] inner) {
        return inner;
      }
      return arr;
    }
    // Unexpected: single scalar — wrap as 1-length row
    return new Object[]{ raw };
  }

  /** Classify severity from average TVOC */
  private static String classifyTvoc(Double avgTvoc) {
    if (avgTvoc == null) return "SAFE";
    if (avgTvoc >= TVOC_CRITICAL) return "CRITICAL";
    if (avgTvoc >= TVOC_ELEVATED) return "ELEVATED";
    return "SAFE";
  }

  /** Safely extract numeric from row[idx]; returns null on NaN or parse errors */
  private static Double toNumber(Object[] row, int idx) {
    if (row == null || idx < 0 || idx >= row.length) return null;
    Object v = row[idx];
    if (v == null) return null;
    if (v instanceof Number n) {
      double d = n.doubleValue();
      return Double.isNaN(d) ? null : d;
    }
    try {
      double d = Double.parseDouble(String.valueOf(v));
      return Double.isNaN(d) ? null : d;
    } catch (Exception ignore) {
      return null;
    }
  }

  /** Round to given decimals; returns null if input null/NaN/Inf */
  private static Double round(Double value, int decimals) {
    if (value == null) return null;
    if (Double.isNaN(value) || Double.isInfinite(value)) return null;
    if (decimals <= 0) return (double) Math.round(value);
    double scale = Math.pow(10, decimals);
    return Math.round(value * scale) / scale;
  }

  private static long toLong(Object o) {
    if (o == null) return 0L;
    if (o instanceof Number n) return n.longValue();
    try { return Long.parseLong(String.valueOf(o)); } catch (Exception e) { return 0L; }
  }

  private static Double toDouble(Object o) {
    if (o == null) return null;
    if (o instanceof Number n) return n.doubleValue();
    try { return Double.parseDouble(String.valueOf(o)); } catch (Exception e) { return null; }
  }

  private static Object safe(Object[] row, int idx) {
    return (row != null && idx >= 0 && idx < row.length) ? row[idx] : null;
  }
}