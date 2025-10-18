// src/main/java/com/fireshield/server/config/DeviceKeyFilter.java
package com.fireshield.server.config;

import com.fireshield.server.repo.DeviceRepository;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import org.springframework.http.HttpStatus;

import java.io.IOException;

public class DeviceKeyFilter extends GenericFilter {

  private final DeviceRepository devices;
  private final String headerName;

  public DeviceKeyFilter(DeviceRepository devices, String headerName) {
    this.devices = devices;
    this.headerName = headerName;
  }

  @Override
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
      throws IOException, ServletException {

    HttpServletRequest req = (HttpServletRequest) request;
    HttpServletResponse res = (HttpServletResponse) response;

    // Only guard POST /samples
    String path = req.getServletPath(); // safer than getRequestURI for context-path situations
    if ("POST".equalsIgnoreCase(req.getMethod()) && "/samples".equals(path)) {
      String key = req.getHeader(headerName);
      if (key == null || key.isBlank()) {
        res.sendError(HttpStatus.UNAUTHORIZED.value(), "Missing device key");
        return;
      }
      if (devices.findByDeviceKey(key).isEmpty()) {
        res.sendError(HttpStatus.UNAUTHORIZED.value(), "Invalid device key");
        return;
      }
    }
    chain.doFilter(request, response);
  }
}
