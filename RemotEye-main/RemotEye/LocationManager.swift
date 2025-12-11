import Foundation
import CoreLocation
import UserNotifications
import Combine


final class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()

    private let locationManager = CLLocationManager()

    // notify at ~500 m
    private let notifyRadius: Double = 50000.0
    // unlock allowed at ~30 m
    private let unlockRadius: Double = 30000.0

    private var appState: AppState?

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = true
    }

    func configure(appState: AppState) {
        self.appState = appState
    }

    func requestPermissions() {
        locationManager.requestWhenInUseAuthorization()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.locationManager.requestAlwaysAuthorization()
        }
    }


    func startTracking() {
        locationManager.startUpdatingLocation()
        setupGeofencesForLandmarks()
    }

    private func setupGeofencesForLandmarks() {
        guard let landmarks = appState?.landmarks else { return }

        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }

        for lm in landmarks {
            let region = CLCircularRegion(center: lm.coordinate, radius: notifyRadius, identifier: lm.id)
            region.notifyOnEntry = true
            region.notifyOnExit = false
            locationManager.startMonitoring(for: region)
        }
    }

    private func handleProximityChecks(_ location: CLLocation) {
        guard let appState = appState else { return }

        for lm in appState.landmarks {
            let distance = location.distance(from: CLLocation(latitude: lm.latitude, longitude: lm.longitude))

            if distance <= unlockRadius {
                NotificationCenter.default.post(
                    name: .userCloseToUnlock,
                    object: lm.id
                )
            }
        }
    }

    private func sendProximityNotification(for landmark: Landmark) {
        let content = UNMutableNotificationContent()
        content.title = "Sei vicino a \(landmark.name)"
        content.body = "Apri RemotEye per scoprire questo luogo storico."
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let appState = appState,
              let lm = appState.landmarks.first(where: { $0.id == region.identifier }) else { return }

        sendProximityNotification(for: lm)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        appState?.userLocation = loc
        handleProximityChecks(loc)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error:", error.localizedDescription)
    }
}

extension Notification.Name {
    static let userCloseToUnlock = Notification.Name("userCloseToUnlock")
}
