import Foundation
import CoreLocation

struct Landmark: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let latitude: Double
    let longitude: Double
    let mainImageName: String
    let gallery: [String]
    let historicalYear: String?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension Landmark {
    // Preview / fallback if JSON fails
    static let preview = Landmark(
        id: "castel_ovo",
        name: "Castel dell’Ovo",
        description: "Historic castle located on the former island of Megaride.",
        latitude: 40.826089,
        longitude: 14.251480,
        mainImageName: "castel_main",
        gallery: ["castel_1"],
        historicalYear: "1100",
    )
    static let testHome = Landmark(
        id: "test_home",
        name: "Test Monument (Near You)",
        description: "This is a test landmark placed near your location so you can test unlock behavior.",
        latitude: 40.84735,
        longitude: 14.26789,
        mainImageName: "test_main",
        gallery: [],
        historicalYear: "2024"
    )


}
