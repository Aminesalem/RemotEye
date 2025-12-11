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
        mainImageName: "CdoMain",
        gallery: [
            "CDO1","CDO2","CDO3","CDO4","CDO5","CDO6","CDO7","CDO8",
            "CDO9","CDO10","CDO11","CDO12","CDO13","CDO14","CDO15","CDO16"
        ],
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
        mainImageName: "PdpMain",
        gallery: [
            "PDP1","PDP2","PDP3","PDP4","PDP5","PDP6","PDP7","PDP8","PDP9",
            // Skipping PDP10 as requested
            "PDP11","PDP12","PDP13","PDP14","PDP15","PDP16","PDP17","PDP18","PDP19",
            "PDP20","PDP21","PDP22","PDP23","PDP24","PDP25","PDP26","PDP27","PDP28","PDP29",
            "PDP30","PDP31","PDP32","PDP33","PDP34","PDP35","PDP36"
        ],
        historicalYear: "1800s"
    )

    // Galleria Umberto I
    static let galleriaUmberto = Landmark(
        id: "galleria_umberto",
        name: "Galleria Umberto I",
        description: "A 19th‑century public shopping gallery with a stunning glass dome and ornate architecture.",
        latitude: 40.837992,
        longitude: 14.249585,
        mainImageName: "GuMain",
        gallery: [
            "GU1","GU2","GU3","GU4","GU5","GU6","GU7","GU8","GU9","GU10","GU11","GU12","GU13"
        ],
        historicalYear: "1890"
    )
    
    // Castel Nuovo (Maschio Angioino)
    static let castelNuovo = Landmark(
        id: "castel_nuovo",
        name: "Castel Nuovo",
        description: "A medieval castle and one of Naples’ most iconic landmarks, overlooking the port.",
        latitude: 40.838650,
        longitude: 14.254779,
        mainImageName: "CnMain",
        gallery: [
            "CN1","CN2","CN3","CN4","CN5","CN6","CN7","CN8","CN9","CN10","CN11","CN12",
            "CN13","CN14","CN15","CN16","CN17","CN18","CN19","CN20","CN21","CN22","CN23","CN24"
        ],
        historicalYear: "1279"
    )

    // Castel Sant’Elmo
    static let castelSantElmo = Landmark(
        id: "castel_santelmo",
        name: "Castel Sant’Elmo",
        description: "A star‑shaped fortress on Vomero hill with panoramic views over Naples and the bay.",
        latitude: 40.842596,
        longitude: 14.236369,
        mainImageName: "CseMain",
        gallery: [
            "CSE1","CSE2","CSE3","CSE4","CSE5","CSE6","CSE7","CSE8","CSE9","CSE10","CSE11","CSE12","CSE13"
        ],
        historicalYear: "1329"
    )

    // Piazza Dante (replacing Castel Capuano)
    static let piazzaDante = Landmark(
        id: "piazza_dante",
        name: "Piazza Dante",
        description: "A historic square in Naples dedicated to Dante Alighieri, a lively hub near Via Toledo.",
        latitude: 40.8493,
        longitude: 14.2516,
        mainImageName: "PdMain", // corrected asset name
        gallery: [
            "PD1","PD2","PD3","PD4","PD5","PD6","PD7","PD8","PD9","PD10","PD11","PD12","PD13","PD14","PD15","PD16","PD17","PD18","PD19"
        ],
        historicalYear: "18th century"
    )
}
