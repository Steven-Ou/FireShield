package com.fireshield.server.api.dto;

import jakarta.validation.constraints.*;
import java.util.List;

/**
 * Request body for posting multiple VOC readings from one device.
 */
public record SampleBatchRequest(
    @NotBlank String deviceId,
    @Size(min = 1, max = 1000) List<SamplePoint> samples
) {}
