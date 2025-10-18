// src/main/java/com/fireshield/server/api/dto/InsightsAdvice.java
package com.fireshield.server.api.dto;

import java.util.List;

public record InsightsAdvice(
    String summary,
    List<String> actions,
    String deconReminder
) {}
