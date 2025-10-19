package com.fireshield.server.service;

import com.fireshield.server.api.dto.TimePoint;
import com.fireshield.server.repo.SampleRepository;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@Service
public class SeriesService {
  private final SampleRepository repo;

  public SeriesService(SampleRepository repo) {
    this.repo = repo;
  }

    public List<TimePoint> getSeriesDaily(Integer daysParam) {
    int days = (daysParam == null || daysParam <= 0) ? 7 : daysParam;
    List<Object[]> rows = repo.seriesDays(days);
    List<TimePoint> out = new ArrayList<>(rows.size());
    for (Object[] r : rows) {
        Instant ts = ((java.sql.Timestamp) r[0]).toInstant();
        Double v = (r[1] == null) ? null : ((Number) r[1]).doubleValue();
        out.add(new TimePoint(ts, v));
    }
    return out;
    }


  public List<TimePoint> getSeries(Integer hoursParam, String bucketParam) {
    int hours = (hoursParam == null || hoursParam <= 0) ? 24 : hoursParam;
    String bucket = (bucketParam == null) ? "hour" : bucketParam;
    if (!bucket.equals("minute") && !bucket.equals("hour") && !bucket.equals("day")) {
      bucket = "hour";
    }
    

    List<Object[]> rows = repo.series(hours, bucket);
    List<TimePoint> out = new ArrayList<>(rows.size());
    for (Object[] r : rows) {
      // r[0] -> timestamp (bucketed), r[1] -> avg_tvoc
      Instant ts = (r[0] instanceof Timestamp t) ? t.toInstant() : Instant.parse(String.valueOf(r[0]));
      Double v = (r[1] == null) ? null : ((Number) r[1]).doubleValue();
      out.add(new TimePoint(ts, v));
    }
    return out;
  }
}
