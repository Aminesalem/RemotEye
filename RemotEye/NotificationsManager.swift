import Foundation
import UserNotifications

final class NotificationsManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationsManager()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error { print("❌ Notifications auth error:", error) }
            print("🔔 Local notifications granted:", granted)
        }
    }

    func sendLocalNotification(title: String, body: String, identifier: String, userInfo: [AnyHashable: Any] = [:]) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = userInfo

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error { print("❌ Failed to schedule notification:", error) }
        }
    }

    // Present banner/list even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }

    // Handle tap on notification to open the specific landmark
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let info = response.notification.request.content.userInfo
        if let id = info["landmarkID"] as? String {
            // Center the map on the landmark and open its details
            NotificationCenter.default.post(name: .centerOnLandmark, object: id)
            NotificationCenter.default.post(name: .landmarkSelected, object: id)
        }
    }
}
