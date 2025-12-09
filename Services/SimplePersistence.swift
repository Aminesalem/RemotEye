import Foundation

struct SimplePersistence {
    private let key = "visited_landmarks_v1"
    func saveVisitedIDs(_ ids: [String]) {
        UserDefaults.standard.set(ids, forKey: key)
    }
    func loadVisitedIDs() -> [String] {
        UserDefaults.standard.stringArray(forKey: key) ?? []
    }
}
