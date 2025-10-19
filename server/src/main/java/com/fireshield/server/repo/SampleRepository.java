package com.fireshield.server.repo;

import com.fireshield.server.domain.Sample;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface SampleRepository extends JpaRepository<Sample, Long> {

  /** Simple averages used by /metrics and /insights */
    @Query(
        value = """
        SELECT
            AVG(tvoc_ppb)         AS avg_tvoc,
            AVG(formaldehyde_ppm) AS avg_ch2o,
            AVG(benzene_ppm)      AS avg_benzene
        FROM samples
        WHERE ts >= CURRENT_TIMESTAMP - (:hours || ' hours')::interval
        """,
        nativeQuery = true
    )
    Object[] averagesLastHours(@Param("hours") int hours);

    /**
     * Rich stats for report (COALESCE avoids nulls; interval uses a robust cast).
     * Row order:
     * [0] samples_count (bigint)
     * [1] window_start  (timestamptz)
     * [2] window_end    (timestamptz)
     * [3] avg_tvoc
     * [4] min_tvoc
     * [5] max_tvoc
     * [6] stddev_tvoc
     * [7] avg_ch2o
     * [8] avg_benzene
     * [9] cnt_elevated
     * [10] cnt_critical
     */
    @Query(value = """
    WITH stats AS (
        SELECT
            COUNT(*)                                                                 AS samples_count,
            MIN(ts)                                                                  AS window_start,
            MAX(ts)                                                                  AS window_end,
            AVG(tvoc_ppb)                                                            AS avg_tvoc,
            MIN(tvoc_ppb)                                                            AS min_tvoc,
            MAX(tvoc_ppb)                                                            AS max_tvoc,
            STDDEV_SAMP(tvoc_ppb)                                                    AS stddev_tvoc,
            AVG(formaldehyde_ppm)                                                    AS avg_ch2o,
            AVG(benzene_ppm)                                                         AS avg_benzene,
            SUM(CASE WHEN tvoc_ppb >= :elev THEN 1 ELSE 0 END)                       AS cnt_elevated,
            SUM(CASE WHEN tvoc_ppb >= :crit THEN 1 ELSE 0 END)                       AS cnt_critical
        FROM samples
        WHERE ts >= CURRENT_TIMESTAMP - (:hours || ' hours')::interval
    )
    SELECT
        COALESCE(samples_count, 0)::bigint,
        COALESCE(window_start, CURRENT_TIMESTAMP - (:hours || ' hours')::interval),
        COALESCE(window_end, CURRENT_TIMESTAMP),
        COALESCE(avg_tvoc, 0),
        COALESCE(min_tvoc, 0),
        COALESCE(max_tvoc, 0),
        COALESCE(stddev_tvoc, 0),
        COALESCE(avg_ch2o, 0),
        COALESCE(avg_benzene, 0),
        COALESCE(cnt_elevated, 0),
        COALESCE(cnt_critical, 0)
    FROM stats
    """, nativeQuery = true)
    Object[] detailedStats(@Param("hours") int hours,
                        @Param("elev") double tvocElev,
                        @Param("crit") double tvocCrit);

    /** First/second half averages to estimate slope. */
    @Query(value = """
    WITH bounds AS (
        SELECT
        CURRENT_TIMESTAMP - (:hours || ' hours')::interval AS start_ts,
        CURRENT_TIMESTAMP                                  AS end_ts
    )
    SELECT
        (SELECT AVG(s.tvoc_ppb)
        FROM samples s, bounds b
        WHERE s.ts >= b.start_ts
            AND s.ts <  b.start_ts + ((b.end_ts - b.start_ts)/2.0)) AS avg_first_half,
        (SELECT AVG(s.tvoc_ppb)
        FROM samples s, bounds b
        WHERE s.ts >= b.start_ts + ((b.end_ts - b.start_ts)/2.0)
            AND s.ts <= b.end_ts)                                    AS avg_second_half
    """, nativeQuery = true)
    Object[] tvocHalves(@Param("hours") int hours);
}