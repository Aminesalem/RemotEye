import Foundation
import CoreLocation

final class LocationManager: NSObject, CLLocationManagerDelegate {

    let manager = CLLocationManager()
    weak var appState: AppState?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 5
        manager.pausesLocationUpdatesAutomatically = false
    }

    // MARK: Request Permissions
    func requestPermissions() {
        print("🔵 Requesting location permissions")

        manager.requestWhenInUseAuthorization()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.manager.requestAlwaysAuthorization()
        }

        manager.startUpdatingLocation()
    }

    // MARK: Delegate Methods

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            print("✅ Location authorized")
            manager.startUpdatingLocation()
        case .denied:
            print("❌ Location denied")
        case .restricted, .notDetermined:
            print("ℹ️ Location not determined yet")
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }

        print("📍 Updated Location:", loc.coordinate.latitude, loc.coordinate.longitude)
        appState?.userLocation = loc
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error:", error.localizedDescription)
    }
}
