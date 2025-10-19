package com.fireshield.server.api;

import com.fireshield.server.api.dto.TimePoint;
import com.fireshield.server.service.SeriesService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/series")
public class SeriesController {
  private final SeriesService svc;

  public SeriesController(SeriesService svc) {
    this.svc = svc;
  }

  // GET /series?hours=24&bucket=hour
  @GetMapping
  public List<TimePoint> series(
      @RequestParam(name = "hours", required = false) Integer hours,
      @RequestParam(name = "bucket", required = false) String bucket
  ) {
    return svc.getSeries(hours, bucket);
  }
    // GET /series/daily?days=7
  @GetMapping("/daily")
  public List<TimePoint> seriesDaily(
      @RequestParam(name = "days", required = false) Integer days
  ) {
    return svc.getSeriesDaily(days);
  }
}
