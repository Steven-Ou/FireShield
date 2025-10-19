# FireShield
<div align="center">
  <h1>FireShield</h1>

  <!-- Replace the image source below with your actual logo file or URL -->
  <img src="[assets/firesheild_logo.png](https://chatgpt.com/backend-api/estuary/content?id=file_00000000ae3c622fa2f487a7f28d470d&ts=489120&p=fs&cid=1&sig=0327fa4cbca770cfc1cd67a8a59448fa839301740e930794a62206de95f82bf1&v=0)" alt="FireShield Logo" width="120" height="120">

  <p>
    FireShield is an iOS application designed to help firefighters and first responders
    monitor toxic exposure, record incident data, and maintain personal health awareness.
  </p>

  <p>
    <a href="https://github.com/Steven-Ou/FireShield/issues">Report Bug</a>
    ·
    <a href="https://github.com/Steven-Ou/FireShield/issues">Request Feature</a>
  </p>

  <p>
    <img src="https://img.shields.io/badge/iOS-16%2B-blue" />
    <img src="https://img.shields.io/badge/Swift-5.9-orange" />
    <img src="https://img.shields.io/github/license/Steven-Ou/FireShield?color=lightgrey" />
  </p>
</div>

---

## 📁 Project Structure

FireShield/

├── Main/
│ ├── ContentView.swift
│ ├── FirestoreManager.swift
│ ├── Incident.swift
│ ├── MonthlySummaryView.swift
│ ├── SettingsView.swift
│ ├── StatisticsView.swift
│ ├── ToxicExposureView.swift
│ ├── User.swift
│ └── FireShieldApp.swift
└── Assets/
└── firesheild_logo.png (placeholder)


---

## 📌 Features

- **User Authentication** (Firebase / Google Sign-In integration planned)
- **Incident Logging** – Users record fire events, exposure type, duration, and equipment used.
- **Toxic Exposure Tracking** – Calculates exposure totals over time.
- **Monthly Summary Dashboard** – Displays hours, incidents, and exposure levels.
- **Personal Statistics & Trends** – Bar charts and cumulative data views.
- **Settings & Data Management** – Profile management, data backup (coming soon).

---

## 🚀 Getting Started

### Prerequisites

- Xcode 15+
- iOS 16 or later
- Swift 5.9
- Firebase account (Firestore enabled)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Steven-Ou/FireShield.git
   cd FireShield
   ```

2. Open the Xcode project:
   ```bash
   open FireShield.xcodeproj
   ```

3. Install Firebase SDK via Swift Package Manager or CocoaPods.

4. Configure Firebase:
- Download your GoogleService-Info.plist from Firebase Console.
- Add it to the Xcode project under the root folder.

5. Build & Run on Simulator or Device.
