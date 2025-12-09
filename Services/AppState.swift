import Foundation
import CoreLocation
import Combine

final class AppState: ObservableObject {

    // MARK: - Published Properties
    @Published var landmarks: [Landmark] = []
    @Published var visitedIDs: Set<String> = []
    @Published var userLocation: CLLocation?
    @Published var canUnlockLandmarkID: String? = nil


    private let persistence = SimplePersistence()

    // MARK: - Initialization
    init() {
        visitedIDs = Set(persistence.loadVisitedIDs())

        // 1. When user enters unlock radius (~30m)
        NotificationCenter.default.addObserver(
            forName: .userCloseToUnlock,
            object: nil,
            queue: .main
        ) { notif in
            if let id = notif.object as? String {
                self.canUnlockLandmarkID = id
            }
        }

        // 2. When the LocationManager updates user GPS
        NotificationCenter.default.addObserver(
            forName: Notification.Name("UserLocationUpdated"),
            object: nil,
            queue: .main
        ) { notif in
            if let loc = notif.object as? CLLocation {
                self.userLocation = loc
                print("📦 AppState stored userLocation:", loc.coordinate)
            }
        }
    }



    // MARK: - Load Landmarks
    func loadLandmarks() {
        if let url = Bundle.main.url(forResource: "landmarks", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            do {
                let decoded = try JSONDecoder().decode([Landmark].self, from: data)
                self.landmarks = decoded
            } catch {
                print("❌ Error decoding landmarks.json:", error)
                self.landmarks = [Landmark.preview]
            }
        } else {
            print("⚠️ landmarks.json not found — using preview landmark.")
            self.landmarks = [Landmark.preview, Landmark.testHome]
        }
    }

    // MARK: - Visited Logic
    func markVisited(_ id: String) {
        visitedIDs.insert(id)
        persistence.saveVisitedIDs(Array(visitedIDs))

        // Notify MapViewController and any observers that visited status changed
        NotificationCenter.default.post(name: .visitedIDsChanged, object: nil)
    }

    func isVisited(_ id: String) -> Bool {
        visitedIDs.contains(id)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    /// Posted when visitedIDs changes (used by MapViewController to refresh pins)
    static let visitedIDsChanged = Notification.Name("visitedIDsChanged")

    /// Posted when user taps an annotation (sent from MapViewController)
    static let landmarkSelected = Notification.Name("LandmarkSelected")
}
extension Notification.Name {
    static let centerOnLandmark = Notification.Name("centerOnLandmark")
}
