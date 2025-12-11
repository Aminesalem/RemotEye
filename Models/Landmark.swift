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
        historicalYear: "1100"
    )

    static let testHome = Landmark(
        id: "test_home",
        name: "Test Monument (Near You)",
        description: "This is a test landmark placed near your location so you can test unlock behavior.",
        latitude: 40.84735,
        longitude: 14.26789,
        mainImageName: "test_main",
        gallery: ["castel_1"],
        historicalYear: "2024"
    )

    // Five additional Naples landmarks with precise coordinates

    // Piazza del Plebiscito
    static let piazzaDelPlebiscito = Landmark(
        id: "piazza_del_plebiscito",
        name: "Piazza del Plebiscito",
        description: "Naples’ grand central square, framed by the Royal Palace and the Basilica of San Francesco di Paola.",
        latitude: 40.835674,
        longitude: 14.247965,
        mainImageName: "plebiscito_main",
        gallery: ["plebiscito_1", "plebiscito_2"],
        historicalYear: "1800s"
    )

    // Galleria Umberto I
    static let galleriaUmberto = Landmark(
        id: "galleria_umberto",
        name: "Galleria Umberto I",
        description: "A 19th‑century public shopping gallery with a stunning glass dome and ornate architecture.",
        latitude: 40.837992,
        longitude: 14.249585,
        mainImageName: "galleria_main",
        gallery: ["galleria_1", "galleria_2"],
        historicalYear: "1890"
    )

    // Castel Nuovo (Maschio Angioino)
    static let castelNuovo = Landmark(
        id: "castel_nuovo",
        name: "Castel Nuovo (Maschio Angioino)",
        description: "A medieval castle and one of Naples’ most iconic landmarks, overlooking the port.",
        latitude: 40.838650,
        longitude: 14.254779,
        mainImageName: "castel_nuovo_main",
        gallery: ["castel_nuovo_1", "castel_nuovo_2"],
        historicalYear: "1279"
    )

    // Castel Sant’Elmo
    static let castelSantElmo = Landmark(
        id: "castel_santelmo",
        name: "Castel Sant’Elmo",
        description: "A star‑shaped fortress on Vomero hill with panoramic views over Naples and the bay.",
        latitude: 40.842596,
        longitude: 14.236369,
        mainImageName: "santelmo_main",
        gallery: ["santelmo_1", "santelmo_2"],
        historicalYear: "1329"
    )

    // Castel Capuano
    static let castelCapuano = Landmark(
        id: "castel_capuano",
        name: "Castel Capuano",
        description: "An ancient castle that later served as Naples’ courthouse, near Porta Capuana.",
        latitude: 40.852999,
        longitude: 14.268676,
        mainImageName: "capuano_main",
        gallery: ["capuano_1", "capuano_2"],
        historicalYear: "12th century"
    )
}

