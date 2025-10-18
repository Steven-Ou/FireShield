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

  // Default rounding precision for averages
  private static final int ROUND_DECIMALS = 3;

  private final SampleRepository samples;

  public MetricsService(SampleRepository samples) {
    this.samples = samples;
  }

  /** Default 24h overview */
  @Transactional(readOnly = true)
  public Map<String, Object> overview() {
    return overviewForHours(24);
  }

  /** Overview for a caller-specified window (in hours) */
  @Transactional(readOnly = true)
  public Map<String, Object> overviewForHours(int windowHours) {
    if (windowHours <= 0) windowHours = 24;

    // Native query sometimes returns Object[][] (one row) instead of flat Object[]
    Object raw = samples.averagesLastHours(windowHours);
    Object[] row = normalizeRow(raw);

    log.info("[DEBUG] averagesLastHours({}): {}", windowHours, java.util.Arrays.deepToString(new Object[][]{row}));

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

  /** Unwrap possible nested array shape from native query */
  private static Object[] normalizeRow(Object raw) {
    if (raw == null) return new Object[0];

    // Case 1: already a flat row
    if (raw instanceof Object[] arr) {
      // If it's a single element that itself is an Object[], unwrap it
      if (arr.length == 1 && arr[0] instanceof Object[] inner) {
        return inner;
      }
      return arr;
    }

    // Unexpected: single scalar (shouldn't happen for 3 columns) — return scalar as a 1-length row
    return new Object[]{raw};
  }

  /** Classify severity from TVOC average; null -> SAFE */
  private static String classifyTvoc(Double avgTvoc) {
    if (avgTvoc == null) return "SAFE";
    if (avgTvoc >= TVOC_CRITICAL) return "CRITICAL";
    if (avgTvoc >= TVOC_ELEVATED) return "ELEVATED";
    return "SAFE";
  }

  /** Safely extract a numeric value from a native query row; returns null on NaN or non-numeric */
  private static Double toNumber(Object[] row, int idx) {
    if (row == null || idx < 0 || idx >= row.length) return null;
    Object v = row[idx];
    if (v == null) return null;

    if (v instanceof Number n) {
      double d = n.doubleValue();
      return Double.isNaN(d) ? null : d;
    }
    try {
      double d = Double.parseDouble(v.toString());
      return Double.isNaN(d) ? null : d;
    } catch (Exception ignore) {
      return null;
    }
  }

  /** Round to given decimals; returns null if input null */
  private static Double round(Double value, int decimals) {
    if (value == null) return null;
    if (Double.isNaN(value) || Double.isInfinite(value)) return null;
    if (decimals <= 0) return (double) Math.round(value);
    double scale = Math.pow(10, decimals);
    return Math.round(value * scale) / scale;
  }
}
