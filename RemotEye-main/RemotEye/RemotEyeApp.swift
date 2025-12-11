import SwiftUI

@main
struct RemotEyeApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    // SAFE: SwiftUI installed appState by now
                    appState.loadLandmarks()

                    LocationManager.shared.configure(appState: appState)

                    LocationManager.shared.requestPermissions()

                    LocationManager.shared.startTracking()

                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
                        print("Notifications permission:", granted)
                    }
                }
        }
    }
}
