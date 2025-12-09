import SwiftUI

@main
struct RemotEyeApp: App {
    @StateObject private var appState = AppState()

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ContentView()
                        .environmentObject(appState)
                        .onAppear {
                            // 🔥 Request location permission after onboarding
                            appState.locationManager.requestPermissions()
                        }
                } else {
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                        .environmentObject(appState)
                }
            }
        }
    }
}
