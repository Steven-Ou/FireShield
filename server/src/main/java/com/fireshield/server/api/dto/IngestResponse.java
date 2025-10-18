package com.fireshield.server.api.dto;

/**
 * Simple response showing how many samples were accepted/rejected.
 */
public record IngestResponse(
    int accepted,
    int rejected
) {}
