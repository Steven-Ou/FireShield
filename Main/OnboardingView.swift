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
            //How It Works & Getting Started
            OnboardingCardView(
                systemImageName: "chart.bar.xaxis",
                title: "Track Your Exposure",
                description: "View real-time (or simulated) exposure data, get alerts for elevated readings, and track trends over time to stay informed.",
                isLastPage: true,
                onGetStarted: {
                    // When the "Get Started" button is tapped,
                    // we set our AppStorage variable to true.
                    hasCompletedOnboarding = true
                }
            )
        }
            .tabViewStyle(.page(indexDisplayMode:.always))
            .background(
                LinearGradient(
                    gradient: Gradient(colors:[Color.red, Color.orange, Color.yellow]),
                    startPoint:.top,
                    endpoint:.bottom
                ).ignoresSafeArea()
            )
    )
}

struct OnboardingCardView: View{
    let systemImageName :String
    let title: String
    let description: String
    var isLastPage:Bool = false
    let onGetStarted: (()-> Void)?
    
    init(systemImageName: String, title: String, description: String, isLastPage: Bool = false, onGetStarted: (() -> Void)? = nil) {
        self.systemImageName = systemImageName
        self.title = title
        self.description = description
        self.isLastPage = isLastPage
        self.onGetStarted = onGetStarted
    }
    
    var body: some View(
        VStack(spacing:20){
            Image(systemName: systemImageName)
                .font(.system(size: 80))
                .foregroundColor(.white)
                .shadow(radius: 5)
            
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal)
            
            if isLastPage {
                Button(action: {
                    onGetStarted?()
                }) {
                    Text("Get Started")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.black)
                        .background(.regularMaterial)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                .padding(.horizontal, 40)
            }
        }
    )
}


