import Foundation
import CoreLocation
import Combine
import UIKit

final class AppState: ObservableObject {

    @Published var landmarks: [Landmark] = []
    @Published var visitedIDs: Set<String> = []
    @Published var userLocation: CLLocation?
    @Published var canUnlockLandmarkID: String? = nil

    // Persisted last photos per landmark (JPEG data)
    @Published var lastPhotos: [String: Data] = [:]

    private let persistence = SimplePersistence()

    // 🔥 Location manager is part of AppState
    let locationManager = LocationManager()

    // Persistence keys
    private let lastPhotosKey = "last_photos_v1"

    // MARK: Geofencing configuration
    private let geofenceRadius: CLLocationDistance = 100.0 // ~100m for reliable region entry
    private let maxRegions = 20

    init() {
        visitedIDs = Set(persistence.loadVisitedIDs())

        // Load persisted last photos
        if let data = UserDefaults.standard.data(forKey: lastPhotosKey),
           let dict = try? JSONDecoder().decode([String: Data].self, from: data) {
            self.lastPhotos = dict
        }

        // Connect LocationManager → AppState
        locationManager.appState = self

        // Listen for "close to unlock" events (optional in-app hook)
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

        // After loading landmarks, ensure geofences reflect current set
        refreshGeofences()
    }

    // Hardcoded fallback list
    private static let defaultLandmarks: [Landmark] = [
        .preview,
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

        // Rebuild geofences so we stop monitoring visited IDs
        refreshGeofences()
    }

    func isVisited(_ id: String) -> Bool {
        visitedIDs.contains(id)
    }

    // MARK: Profile/Progress helpers
    func resetVisited() {
        // Clear visited IDs
        visitedIDs.removeAll()
        persistence.saveVisitedIDs([])
        NotificationCenter.default.post(name: .visitedIDsChanged, object: nil)

        // Clear last taken photos and persistence
        lastPhotos.removeAll()
        // Either overwrite with empty dict or remove key entirely; we do both for safety.
        persistLastPhotos()
        UserDefaults.standard.removeObject(forKey: lastPhotosKey)

        // Rebuild geofences
        refreshGeofences()
    }

    // MARK: - Last Photo Persistence (single photo per landmark)

    // Save a compressed JPEG (~0.6 quality) to minimize storage
    func saveLastPhoto(_ image: UIImage, for id: String) {
        // Downscale large images to a reasonable max dimension to save more space
        let maxDimension: CGFloat = 1280
        let resized = resize(image: image, maxDimension: maxDimension)
        let quality: CGFloat = 0.6
        if let jpeg = resized.jpegData(compressionQuality: quality) {
            lastPhotos[id] = jpeg
            persistLastPhotos()
        }
    }

    func loadLastPhoto(for id: String) -> UIImage? {
        guard let data = lastPhotos[id] else { return nil }
        return UIImage(data: data)
    }

    private func persistLastPhotos() {
        if let encoded = try? JSONEncoder().encode(lastPhotos) {
            UserDefaults.standard.set(encoded, forKey: lastPhotosKey)
        }
    }

    private func resize(image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let longest = max(size.width, size.height)
        guard longest > maxDimension else { return image }

        let scale = maxDimension / longest
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result ?? image
    }

    // MARK: - Geofencing support

    // Install geofences for up to maxRegions nearest locked landmarks.
    func refreshGeofences() {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            print("❌ Region monitoring not available.")
            return
        }

        // Clear existing regions first
        locationManager.stopAllMonitoredRegions()

        // Determine locked landmarks
        let locked = landmarks.filter { !isVisited($0.id) }
        guard !locked.isEmpty else {
            print("ℹ️ No locked landmarks to fence.")
            return
        }

        // Sort by distance from current user location if available
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

        // Start monitoring up to maxRegions
        for lm in sorted.prefix(maxRegions) {
            let center = CLLocationCoordinate2D(latitude: lm.latitude, longitude: lm.longitude)
            let region = CLCircularRegion(center: center, radius: geofenceRadius, identifier: lm.id)
            region.notifyOnEntry = true
            region.notifyOnExit = false

            locationManager.startMonitoring(region: region)
        }

        print("🧭 Monitoring \(min(sorted.count, maxRegions)) regions.")
    }

    // Called by LocationManager when entering a monitored region
    func handleDidEnterRegion(identifier: String) {
        guard let lm = landmarks.first(where: { $0.id == identifier }) else { return }
        guard !isVisited(lm.id) else { return }

        let title = "You’re near \(lm.name)"
        let body = "Open the app and capture it to unlock!"
        NotificationsManager.shared.sendLocalNotification(
            title: title,
            body: body,
            identifier: "enter_\(lm.id)",
            userInfo: ["landmarkID": lm.id]
        )

        // Optional in-app notification hook
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
