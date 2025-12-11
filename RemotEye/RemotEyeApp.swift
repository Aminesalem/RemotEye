import SwiftUI

@main
struct RemotEyeApp: App {
    // Must be an NSObject & UIApplicationDelegate (provided by AppDelegateAdapter.swift)
    @UIApplicationDelegateAdaptor(AppDelegateAdapter.self) var appDelegate

    @StateObject private var appState = AppState()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ContentView()
                        .environmentObject(appState)
                        .onAppear {
                            // Location permission
                            appState.locationManager.requestPermissions()

                            // Local notifications permission
                            NotificationsManager.shared.requestAuthorization()

                            // Install geofences for nearest locked landmarks
                            appState.refreshGeofences()
                        }
                        .onReceive(NotificationCenter.default.publisher(for: .visitedIDsChanged)) { _ in
                            // Rebuild geofences when visited set changes
                            appState.refreshGeofences()
                        }
                } else {
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                        .environmentObject(appState)
                }
            }
        }
    }
}
