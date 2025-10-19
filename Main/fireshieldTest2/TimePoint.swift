import Foundation

struct TimePoint: Codable, Identifiable {
    let ts: Date
    let tvoc_ppb: Double?
    var id: Date { ts }
}
