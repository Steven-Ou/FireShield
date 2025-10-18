package com.fireshield.server.api.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import jakarta.validation.constraints.*;
import java.time.Instant;

/**
 * One individual VOC reading (sample).
 */
public record SamplePoint(
    @NotNull Instant ts,
    @PositiveOrZero Double tvoc_ppb,
    Double voc_index,
    Double eco2_ppm,
    Double hum_rel,
    // Accept both "tempC" and "temp_c" JSON field names
    @JsonAlias("temp_c") Double tempC,
    Double formaldehyde_ppm,
    Double benzene_ppm
) {}
