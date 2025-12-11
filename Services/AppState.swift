import Foundation
import CoreLocation
import Combine

final class AppState: ObservableObject {

    @Published var landmarks: [Landmark] = []
    @Published var visitedIDs: Set<String> = []
    @Published var userLocation: CLLocation?
    @Published var canUnlockLandmarkID: String? = nil

    private let persistence = SimplePersistence()

    // 🔥 Location manager is part of AppState
    let locationManager = LocationManager()

    // Keep a cache of which landmark IDs have active geofences
    private var fencedIDs: Set<String> = []

    // iOS allows ~20 regions. Choose radius generous enough for wake-up, e.g., 75–150m.
    private let geofenceRadius: CLLocationDistance = 100.0
    private let maxRegions = 20

    init() {
        visitedIDs = Set(persistence.loadVisitedIDs())

        // Connect LocationManager → AppState
        locationManager.appState = self

        // Listen for "close to unlock" events if used elsewhere
        NotificationCenter.default.addObserver(
            forName: .userCloseToUnlock,
            object: nil,
            queue: .main
        ) { notif in
            if let id = notif.object as? String {
                self.canUnlockLandmarkID = id
            }
        }
    }

    // MARK: Load Landmarks
    func loadLandmarks() {
        if let url = Bundle.main.url(forResource: "landmarks", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            do {
                let decoded = try JSONDecoder().decode([Landmark].self, from: data)
                self.landmarks = decoded
            } catch {
                print("❌ Error decoding landmarks.json:", error)
                // Fall back to hardcoded set
                self.landmarks = AppState.defaultLandmarks
            }
        } else {
            print("⚠️ landmarks.json not found — using hardcoded landmarks.")
            self.landmarks = AppState.defaultLandmarks
        }
    }

    // Hardcoded fallback list
    private static let defaultLandmarks: [Landmark] = [
        .preview,
        .testHome,
        .piazzaDelPlebiscito,
        .galleriaUmberto,
        .castelNuovo,
        .castelSantElmo,
        .piazzaDante
    ]

    // MARK: Visited Logic
    func markVisited(_ id: String) {
        visitedIDs.insert(id)
        persistence.saveVisitedIDs(Array(visitedIDs))

        NotificationCenter.default.post(name: .visitedIDsChanged, object: nil)

        // If visited, rebuild geofences so we don't monitor it anymore
        refreshGeofences()
    }

    func isVisited(_ id: String) -> Bool {
        visitedIDs.contains(id)
    }

    // MARK: Profile/Progress helpers
    func resetVisited() {
        visitedIDs.removeAll()
        persistence.saveVisitedIDs([])
        NotificationCenter.default.post(name: .visitedIDsChanged, object: nil)
        refreshGeofences()
    }

    // MARK: Geofencing

    // Call this after onboarding, and whenever landmarks/visited change
    func refreshGeofences() {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            print("❌ Region monitoring not available.")
            return
        }

        // Clear existing regions
        locationManager.stopAllMonitoredRegions()
        fencedIDs.removeAll()

        // Choose up to maxRegions nearest locked landmarks to monitor
        let locked = landmarks.filter { !isVisited($0.id) }
        guard !locked.isEmpty else {
            print("ℹ️ No locked landmarks to fence.")
            return
        }

        // Sort by distance from current location if available; otherwise keep order
        let sorted: [Landmark]
        if let user = userLocation {
            sorted = locked.sorted {
                let d1 = user.distance(from: CLLocation(latitude: $0.latitude, longitude: $0.longitude))
                let d2 = user.distance(from: CLLocation(latitude: $1.latitude, longitude: $1.longitude))
                return d1 < d2
            }
        } else {
            sorted = locked
        }

        for lm in sorted.prefix(maxRegions) {
            let center = CLLocationCoordinate2D(latitude: lm.latitude, longitude: lm.longitude)
            let region = CLCircularRegion(center: center, radius: geofenceRadius, identifier: lm.id)
            region.notifyOnEntry = true
            region.notifyOnExit = false

            locationManager.startMonitoring(region: region)
            fencedIDs.insert(lm.id)
        }

        print("🧭 Monitoring \(fencedIDs.count) landmark regions.")
    }

    // Called by LocationManager when entering a region
    func handleDidEnterRegion(identifier: String) {
        guard let lm = landmarks.first(where: { $0.id == identifier }) else { return }
        guard !isVisited(lm.id) else { return }

        let title = "You’re near \(lm.name)"
        let body = "Open the app and capture it to unlock!"
        NotificationsManager.shared.sendLocalNotification(
            title: title,
            body: body,
            identifier: "enter_\(lm.id)"
        )

        // Optional: in-app hook if the app is foregrounded later
        NotificationCenter.default.post(name: .userCloseToUnlock, object: lm.id)
    }
}

// MARK: Notifications
extension Notification.Name {
    static let visitedIDsChanged = Notification.Name("visitedIDsChanged")
    static let landmarkSelected = Notification.Name("LandmarkSelected")
    static let centerOnLandmark = Notification.Name("centerOnLandmark")
    static let userCloseToUnlock = Notification.Name("userCloseToUnlock")
}
