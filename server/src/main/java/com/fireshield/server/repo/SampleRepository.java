package com.fireshield.server.repo;

import com.fireshield.server.domain.Sample;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface SampleRepository extends JpaRepository<Sample, Long> {

  /**
   * Averages over the last N hours (computed on the DB side to avoid any JVM/DB clock
   * or timezone binding issues). Returns a single row:
   *   [0] = avg(tvoc_ppb)
   *   [1] = avg(formaldehyde_ppm)
   *   [2] = avg(benzene_ppm)
   */
  @Query(
      value = """
        SELECT
          AVG(tvoc_ppb)         AS avg_tvoc,
          AVG(formaldehyde_ppm) AS avg_ch2o,
          AVG(benzene_ppm)      AS avg_benzene
        FROM samples
        WHERE ts >= now() - make_interval(hours => :hours)
        """,
      nativeQuery = true
  )
  Object[] averagesLastHours(@Param("hours") int hours);
}
