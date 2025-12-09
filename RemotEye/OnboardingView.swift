//
//  OnboardingView.swift
//  RemotEye
//
//  Created by AFP PAR 29 on 09/12/25.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage: Int = 0

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(.systemIndigo), Color(.systemBlue), Color(.systemTeal)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                // App title at top
                VStack(spacing: 4) {
                    Text("RemotEye")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)

                    Text("Discover Naples in a new way")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 40)

                Spacer(minLength: 20)

                // Paged content
                TabView(selection: $currentPage) {
                    OnboardingPageView(
                        systemImage: "map.fill",
                        title: "Explore the City",
                        subtitle: "See historical hotspots around you on a live map of Naples."
                    )
                    .tag(0)

                    OnboardingPageView(
                        systemImage: "camera.viewfinder",
                        title: "Capture & Unlock",
                        subtitle: "Walk to a place, take a photo, and unlock its story and archive images."
                    )
                    .tag(1)

                    OnboardingPageView(
                        systemImage: "book.closed.fill",
                        title: "Build Your Diary",
                        subtitle: "Every unlocked place is saved as part of your personal travel diary."
                    )
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .frame(maxHeight: 420)

                Spacer()

                // Bottom buttons
                VStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.spring()) {
                            if currentPage < 2 {
                                currentPage += 1
                            } else {
                                hasCompletedOnboarding = true
                            }
                        }
                    }) {
                        Text(currentPage < 2 ? "Continue" : "Start Exploring")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(Color(.systemIndigo))
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }

                    if currentPage < 2 {
                        Button(action: {
                            withAnimation {
                                hasCompletedOnboarding = true
                            }
                        }) {
                            Text("Skip for now")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 36)
            }
        }
    }
}

// MARK: - Single onboarding page

struct OnboardingPageView: View {
    let systemImage: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 24) {
            // Icon + glow circle
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 180, height: 180)
                    .blur(radius: 0)

                Image(systemName: systemImage)
                    .font(.system(size: 64, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 10)

            Text(title)
                .font(.title2.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(.body)
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }
}
