//
//  MainApp.swift
//  Main
//
//  Created by Steve Ou on 10/18/25.
//

import SwiftUI

@main
struct MainApp: App {
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding{
                LoginView()
            }else{
                OnboardingView()
            }
        }
    }
}
