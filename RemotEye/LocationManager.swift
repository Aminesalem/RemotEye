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

    // MARK: Region Monitoring

    func startMonitoring(region: CLCircularRegion) {
        // Ensure Always or WhenInUse with monitor allowed
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            manager.startMonitoring(for: region)
            print("🟡 Started monitoring region:", region.identifier)
        } else {
            print("❌ Region monitoring not available on this device.")
        }
    }

    func stopAllMonitoredRegions() {
        for region in manager.monitoredRegions {
            manager.stopMonitoring(for: region)
            print("⚪️ Stopped monitoring region:", region.identifier)
        }
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

    // Called when entering a monitored region (works background/terminated)
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let circular = region as? CLCircularRegion else { return }
        print("🟢 didEnterRegion:", circular.identifier)
        appState?.handleDidEnterRegion(identifier: circular.identifier)
    }
}

