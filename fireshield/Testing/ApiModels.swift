import Foundation

// === DTOs from your backend ===
struct AuthResponse: Codable {
    let token: String
    let userId: String
    let displayName: String
    let email: String
}

struct InsightsReport: Codable {
    let windowHours: Int
    let metrics: [String: AnyCodable]
    let aiReport: AiReport
    let model: String
    let source: String

    struct AiReport: Codable {
        let summary: String
        let riskScore: Int?
        let keyFindings: [String]
        let recommendations: [String]
        let deconChecklist: [String]
        let policySuggestion: String?
    }
}

// === Loose JSON helper for metrics map ===
struct AnyCodable: Codable {
    let value: Any
    init(_ value: Any) { self.value = value }

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let v = try? c.decode(Double.self) { value = v; return }
        if let v = try? c.decode(Int.self)    { value = v; return }
        if let v = try? c.decode(String.self) { value = v; return }
        if let v = try? c.decode(Bool.self)   { value = v; return }
        if let v = try? c.decode([String: AnyCodable].self) { value = v.mapValues{$0.value}; return }
        if let v = try? c.decode([AnyCodable].self) { value = v.map{$0.value}; return }
        value = NSNull()
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch value {
        case let v as Double: try c.encode(v)
        case let v as Int:    try c.encode(v)
        case let v as String: try c.encode(v)
        case let v as Bool:   try c.encode(v)
        case let v as [String: Any]: try c.encode(v.mapValues(AnyCodable.init))
        case let v as [Any]:         try c.encode(v.map(AnyCodable.init))
        default: try c.encodeNil()
        }
    }
}

// Convenience accessors
extension InsightsReport {
    var severity: String { (metrics["severity"]?.value as? String) ?? "SAFE" }
    var avgTVOC: Double? { metrics["avg_tvoc_ppb"]?.value as? Double }
    var maxTVOC: Double? { metrics["max_tvoc_ppb"]?.value as? Double }
    var fracCritical: Double? { metrics["fraction_time_critical"]?.value as? Double }
}