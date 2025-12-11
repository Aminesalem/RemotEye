import UIKit
import UserNotifications

final class AppDelegateAdapter: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Ensure UNUserNotificationCenter delegate is set early
        _ = NotificationsManager.shared
        return true
    }

    // Optional: handle notification responses if you want to deep-link when tapped.
    // func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult { ... }
}
