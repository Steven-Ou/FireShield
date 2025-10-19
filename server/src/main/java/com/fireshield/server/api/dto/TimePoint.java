package com.fireshield.server.api.dto;

import java.time.Instant;

public record TimePoint(Instant ts, Double tvoc_ppb) {}
