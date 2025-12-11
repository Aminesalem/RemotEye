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

    init() {
        visitedIDs = Set(persistence.loadVisitedIDs())

        // Connect LocationManager → AppState
        locationManager.appState = self

        // Listen for "close to unlock" events
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
                self.landmarks = [Landmark.preview]
            }
        } else {
            print("⚠️ landmarks.json not found — using preview.")
            self.landmarks = [Landmark.preview, Landmark.testHome]
        }
    }

    // MARK: Visited Logic
    func markVisited(_ id: String) {
        visitedIDs.insert(id)
        persistence.saveVisitedIDs(Array(visitedIDs))

        NotificationCenter.default.post(name: .visitedIDsChanged, object: nil)
    }

    func isVisited(_ id: String) -> Bool {
        visitedIDs.contains(id)
    }
}

// MARK: Notifications
extension Notification.Name {
    static let visitedIDsChanged = Notification.Name("visitedIDsChanged")
    static let landmarkSelected = Notification.Name("LandmarkSelected")
    static let centerOnLandmark = Notification.Name("centerOnLandmark")
    static let userCloseToUnlock = Notification.Name("userCloseToUnlock")
}
