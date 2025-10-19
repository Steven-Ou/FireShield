import Foundation

// MARK: - Offline demo data (matches deployed demo@example.com)

enum FallbackData {

    // MARK: - 24h hourly TVOC pattern (avg 575 ppb, peaks ~1100 ppb, 60% elevated)
    static func series24h() -> [TimePoint] {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        var points: [TimePoint] = []

        // Simulate 24 hourly points from oldest → newest
        for h in (0..<24).reversed() {
            guard let ts = calendar.date(byAdding: .hour, value: -h, to: now) else { continue }
            // 60% elevated (>500 ppb), 5% critical (>900 ppb)
            let base = 480.0 + sin(Double(h) * .pi / 6) * 100.0 + Double.random(in: -40...40)
            let spike = (h == 5 || h == 13 || h == 20) ? Double.random(in: 350...500) : 0
            let tvoc = min(1125.0, max(280.0, base + spike))
            points.append(TimePoint(ts: ts, tvoc_ppb: tvoc))
        }
        return points
    }

    // MARK: - Report with identical averages/severity to demo@example.com
    static func demoReport() -> InsightsReport {
        var metrics: [String: AnyCodable] = [:]
        metrics["windowHours"] = AnyCodable(24)
        metrics["samplesCount"] = AnyCodable(296)
        metrics["windowStart"] = AnyCodable("2025-10-18T13:27:07.288257Z")
        metrics["windowEnd"] = AnyCodable("2025-10-19T13:07:07.288257Z")
        metrics["avg_tvoc_ppb"] = AnyCodable(574.756)
        metrics["min_tvoc_ppb"] = AnyCodable(280.0)
        metrics["max_tvoc_ppb"] = AnyCodable(1123.306)
        metrics["stddev_tvoc_ppb"] = AnyCodable(169.993)
        metrics["avg_formaldehyde_ppm"] = AnyCodable(0.031)
        metrics["avg_benzene_ppm"] = AnyCodable(0.004)
        metrics["severity"] = AnyCodable("ELEVATED")
        metrics["tvoc_slope_ppb_per_hr"] = AnyCodable(1.487)
        metrics["fraction_time_elevated"] = AnyCodable(0.595)
        metrics["fraction_time_critical"] = AnyCodable(0.047)
        metrics["elevated_threshold_ppb"] = AnyCodable(500.0)
        metrics["critical_threshold_ppb"] = AnyCodable(900.0)

        return InsightsReport(
            windowHours: 24,
            metrics: metrics,
            aiReport: .init(
                summary: """
                Elevated TVOC levels detected. 296 samples show an average TVOC of 574.8 ppb, \
                with peaks exceeding 1123 ppb and nearly 60 % of the time above the elevated threshold.
                """,
                riskScore: 75,
                keyFindings: [
                    "TVOC levels spiked to 1123 ppb.",
                    "TVOC levels trending upwards at 1.49 ppb/hr.",
                    "Elevated levels persisted for ~60 % of the past 24 hours; critical levels for ~5 %."
                ],
                recommendations: [
                    "Increase ventilation immediately.",
                    "Identify and remove potential TVOC sources.",
                    "Monitor levels continuously and report new spikes."
                ],
                deconChecklist: [
                    "Ventilate gear thoroughly.",
                    "Wash exposed skin with soap and water.",
                    "Monitor for any symptoms (headache, dizziness).",
                    "Report any unusual symptoms to medical personnel."
                ],
                policySuggestion: """
                Given the elevated TVOC levels and time above thresholds, \
                review ventilation protocols and increase monitoring frequency. \
                Ensure all personnel follow decon procedures strictly.
                """
            ),
            model: "gemini-2.0-flash",
            source: "fallback"
        )
    }
}
