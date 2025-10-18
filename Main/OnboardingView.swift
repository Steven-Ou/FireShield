//
//  OnboardingView.swift
//  Main
//
//  Created by Steve Ou on 10/18/25.
//

import SwiftUI

struct OnboardingView: View{
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View(
        TabView{
            // The Problem
            OnboardingView(
                systemImageName: "exclamationmark.triangle.fill",
                title: "The Invisible Threat",
                description: "After a fire, gear and stations remain contaminated with toxic Volatile Organic Compounds (VOCs) like benzene and formaldehyde, posing long-term cancer risks."
            )
            
            //The Solution
            OnboardingCardView(
                systemImageName: "shield.lefthalf.filled",
                title: "FireShield VOC",
                description: "Our platform helps you visualize and understand your exposure to cancer-causing VOCs, making the invisible visible."
            )
        }
    )
}

