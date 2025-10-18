import SwiftUI

struct Slide: Identifiable {
    let id = UUID()
    let symbolName: String   // SF Symbol or asset name
    let title: String
    let description: String
    // optional: per-slide tint
    let backgroundColor: Color?
}

extension Slide {
    static func sampleSlides() -> [Slide] {
        [
            Slide(symbolName: "flame.fill",
                  title: "Protecting Firefighters",
                  description: "FireShield monitors VOC exposure after every call so you can take action.",
                  backgroundColor: nil),
            Slide(symbolName: "waveform.path.ecg",
                  title: "Real-time Awareness",
                  description: "Get instant alerts when TVOC, benzene, or formaldehyde exceed safe levels.",
                  backgroundColor: nil),
            Slide(symbolName: "chart.bar.fill",
                  title: "Track Trends",
                  description: "View 24-hour and 7-day trends to understand long-term exposure patterns.",
                  backgroundColor: nil),
            Slide(symbolName: "shield.checkerboard",
                  title: "Actionable Insights",
                  description: "Receive safety recommendations and steps to reduce exposure after each call.",
                  backgroundColor: nil)
        ]
    }
}
