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
        latitude: 40.8280336,
        longitude: 14.2478336,
        mainImageName: "CdoMain",
        gallery: [
            "CDO1","CDO2","CDO3","CDO4","CDO5","CDO6","CDO7","CDO8",
            "CDO9","CDO10","CDO11","CDO12","CDO13","CDO14","CDO15","CDO16"
        ],
        historicalYear: "1100"
    )

    // Piazza del Plebiscito
    static let piazzaDelPlebiscito = Landmark(
        id: "piazza_del_plebiscito",
        name: "Piazza del Plebiscito",
        description: "Naples’ grand central square, framed by the Royal Palace and the Basilica of San Francesco di Paola.",
        latitude: 40.8357079,
        longitude: 14.2482997,
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
        latitude: 40.8380707,
        longitude: 14.2497815,
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
        latitude: 40.8389949,
        longitude: 14.2516702,
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
        latitude: 40.8426013,
        longitude: 14.2362936,
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
        latitude: 40.8500686,
        longitude: 14.2508083,
        mainImageName: "PdMain", // corrected asset name
        gallery: [
            "PD1","PD2","PD3","PD4","PD5","PD6","PD7","PD8","PD9","PD10","PD11","PD12","PD13","PD14","PD15","PD16","PD17","PD18","PD19"
        ],
        historicalYear: "18th century"
    )
}

// Unlocked overview texts to show after a landmark is visited
extension Landmark {
    static let unlockedOverviewByID: [String: String] = [
        "castel_ovo": """
Castel dell'Ovo is the oldest castle in Naples and is located on the islet of Megaride, now connected to the seafront on Via Partenope. Its name comes from a legend according to which the poet Virgil hid a magical egg in its foundations: if it broke, the city would suffer serious misfortunes.

The first fortress of Castel dell'Ovo was built by the Normans in the 12th century, taking advantage of the ancient Roman and Greek structures present on the site. Over the centuries, the castle was expanded and transformed by various rulers from the Swabians to the Angevins, up to the Aragonese and served not only as a military fortress, but also as a royal residence and prison for important historical figures.

As reported by various chronicles, during the time of Queen Joanna the Castle suffered serious damage due to the collapse of the arch that connects the two rocks on which it stands and which the Queen was practically obliged to officially declare that she had replaced the egg to prevent fears and fears of new and harmful disasters from spreading throughout the city.

The Castle is located in the Via Caracciolo area, a very charming part of Naples: in the morning, people come alive with people going to work and a chaos of cars lined up, while in the evening, the dim lights of the metropolis come on, everything seems to stop and you immerse yourself in an atmosphere of times gone by, with the sea shining, caressed by the fixed eye of the moon. From the stands of the Castle and its terraces you can fully enjoy this enchanting scenery.

The castle has gone from being a living and functional military structure to becoming a historical monument and panoramic icon, adapted to contemporary tourist and cultural needs.
the avenue where we can stop today, in the past it was a natural corridor.
Compared to the past, there has been the addition of an artificial bridge and the sailors' village that surrounds it today.

Additions:
It was not only a castle, but also a crystal and mirror factory under Charles of Bourbon, a prison for historical figures such as Conradin of Swabia, and even a wine-producing center.
Furthermore, this place is linked to the mermaid Parthenope whose remains are said to be in the foundations, intertwining myths and esoteric legends
""",
        "piazza_del_plebiscito": """
Piazza del Plebiscito, among the largest and most monumental Italian squares, was born as a large space in front of the Royal Palace of Naples. Until the 16th century, the area was a densely populated neighborhood; its gradual opening began with the Spanish viceroys, who wanted to create a representative area near the royal residence.

The real leap, however, took place between the 18th and 19th centuries. Under Napoleonic rule, Joachim Murat launched an ambitious urban planning project to transform the area into a scenic imperial-style square. After the Bourbon restoration, Ferdinand I completed the work by building the Basilica of San Francesco di Paola, inspired by the Roman Pantheon, which became the architectural hub of the entire space.

In 1860 the square changed from being called Largo di Palazzo to Piazza del Plebiscito in honor of the plebiscite that sanctioned the annexation of the Kingdom of the Two Sicilies to the Kingdom of Italy. During the twentieth century, the space changed function several times: from a ceremonial place to an urban parking lot, which impoverished its monumental value. Only in the ’90s, thanks to a major redevelopment project, was the square completely pedestrianized, restoring its celebratory character.

Today, Piazza del Plebiscito is a symbolic place for Naples: it hosts cultural events, concerts, civil celebrations, and open-air exhibitions. The equestrian statues of Charles III and Ferdinand I, works by Canova and his pupil Calì, complete the scenographic layout of the square, which represents a crossroads of history, art and city life.

Additions:
One of the most evocative legends linked to Piazza del Plebiscito narrates that Queen Margherita granted freedom to prisoners who managed to walk across the square blindfolded, walking in a perfect straight line between the two equestrian statues of Charles of Bourbon and Ferdinand. However, no one ever succeeded, fueling the belief that the sovereign had cast some sort of curse.

To attempt the feat, the prisoners had to start from a door of the Royal Palace and walk about 170 meters in a straight line until they passed exactly between the two statues. The difficulty was not only symbolic: the large size of the square, devoid of obvious landmarks, confuses the test taker, while the irregular paving and the slight natural slope of the terrain prevent maintaining a perfectly straight trajectory, inevitably causing it to deviate to the right or left. Furthermore, the human body naturally tends to lean in one direction, further accentuating the deviation and making the task virtually impossible.
""",
        "piazza_dante": """
Piazza Dante is one of the most important squares in Naples and is located in the historic city center.
It was originally known as llario ’or Mercatiello (Largo del Mercatello), since one of the city's two markets had been held there since 1588, differentiating itself with the diminutive mercatello from the larger and older one in Piazza del Mercato. Until the mid-nineteenth century, the grain pit building stood to the north and the oil cisterns to the south, for centuries the main warehouses of the city.

The square took on its current structure in the second half of the eighteenth century, with the intervention of the architect Luigi Vanvitelli; the "Foro Carolino" commissioned from him was intended to be a monument celebrating the sovereign Charles of Bourbon. The works lasted from 1757 to 1765, and the result was a large hemicycle, tangent to the Aragonese walls, which, when viewed horizontally, incorporated Port'Alba to the west, and flanked the church of San Michele to the east.

In the center of the square stands a large statue of Dante Alighieri, the work of sculptors Tito Angelini and Tommaso Solari junior, inaugurated on July 13, 1871 (the date from which the square is named after the great poet) and placed on a base designed by engineer Gherardo Rega. In the 1950s the square underwent a restyling, with well-kept gardens and planters installed. The square was redesigned, eliminating the green areas, and redecorated during the metro works, completed in 2002. The entire hemicycle has thus become a pedestrian area. Today, on its more secluded sides are the windows of the exits of metro line 1. The restyling, however, faced criticism due to the elimination of the green areas and the grey appearance that the square presents after the 2002-2003 restyling.

Furthermore, near the square there are four monumental churches: counterclockwise from the north, that of the Immaculate Conception of the Health Workers, of Santa Maria di Caravaggio, of San Domenico Soriano and of San Michele a Port'Alba.

Additions:
During the plague of 1656, Largo del Mercatello became a lazaretto and a mass grave. The event was immortalized by Micco Spadaro in a famous painting, "The Plague off the Mercatello", a painting preserved at the Certosa di San Martino.

The Cisterns under the Feet: The streets overlooking the square, such as Via Cisterna dell'Olio, take their name from the ancient grain pits and oil cisterns present in the 16th century. You literally walk above the history of agricultural storage.
""",
        "galleria_umberto": """
The Galleria Umberto I is a shopping arcade built in Naples between 1887 and 1890. It is named after Umberto I of Italy, as a tribute to the King and in memory of his generous presence during the cholera epidemic of 1884, which demonstrated the need for the city's redevelopment.

The area on which the tunnel stands was already intensively urbanized in the 16th century and was characterized by a tangle of parallel streets connected by short alleys, which led from Via Toledo to Castel Nuovo. These alleys enjoyed a bad reputation as taverns, houses of ill repute were located there and crimes of all kinds were committed there. The fame achieved by the area over the centuries was maintained for almost the entire nineteenth century.

In the 1880s, the degradation of the area reached extreme points: six-story buildings stood in the alleys, the hygiene situation was terrible and it is no wonder that between 1835 and 1884, nine cholera epidemics had occurred in this area. Under public pressure, government intervention began to be considered after the 1884 epidemic.

In 1885, the law for the redevelopment of the city of Naples was approved, thanks to which the area received a new territorial definition. Various proposals were presented, the winning project being that of engineer Emmanuele Rocco.  This design included a four-branched gallery that intersected in an octagonal transept covered by a dome. Demolitions of the pre-existing buildings began on May 1, 1887, and the foundation stone of the building was laid on November 5 of the same year. Within three years, on November 19, 1890 to be precise, the new gallery was inaugurated.

On the afternoon of July 5, 2014, part of the cornice of the gallery's rose window collapsed near the entrance on Via Toledo: a thirteen-year-old boy, Salvatore Giordano, was seriously injured by the collapse, dying at the Loreto Mare hospital after four days of agony. 
Today, at the entrance overlooking Via Toledo there is a plaque commemorating this boy. 

Additions:
The structure has four main entrances (Via San Carlo, Via Santa Brigida, Via Toledo and Vico Rotto San Carlo), symbol of the four cardinal points. Under the dome are zodiac mosaics, connected to an ancient superstitious rite: visitors spin their sign three times to ensure they return to Naples. The allegorical statues enrich the whole, representing the four continents, the four seasons and values such as Science, Work, Commerce and Industry, expressing an idea of progress and optimism. Finally, on the dome there is a Star of David, linked to the Rothschild family and Freemasonry, which is believed to have contributed to the financing of the project.

For over fifty years, the Gallery was the kingdom of the “sciuscià”, the shoe shiners made famous by Vittorio De Sica's film, which became a true institution of the time. At the same time, the Salone Margherita, an underground venue that symbolizes nightlife, has hosted illustrious figures such as D'Annunzio and Matilde Serao, becoming a place rich in artistic and social legends.
""",
        "castel_nuovo": """
The construction of its ancient nucleus, now partially resurfaced following restoration and archaeological exploration interventions, is due to the initiative of Charles I of Anjou, who in 1266, having defeated the Swabians, ascended the throne of Sicily and established the transfer of the capital from Palermo to the Neapolitan city.

The presence of an external monarchy had established Naples' urban planning around the center of royal power, constituting an alternative urban hub, formed by the port and the two main castles adjacent to it, Castel Capuano and Castel dell'Ovo. This relationship between the royal court and the city's urban planning had already manifested itself with Frederick II, who in the 13th century, in the Swabian statute, had concentrated the greatest attention on the castles, neglecting the city walls at all. To the two existing castles the Angevins added the main one, Castel Nuovo (Chastiau neuf), which was not only fortification but above all their grandiose palace.

The complex, once a royal residence and center of power, has progressively transformed its function until today it becomes a place of remembrance, a museum and an important cultural hub of the city. It was originally a private and royal space, intended for sovereigns and the court, while today it is open to the public, housing the Civic Museum with art collections ranging from the 15th to the 20th century, as well as spaces dedicated to exhibitions and cultural events.

Architecturally, the building retains Gothic elements, but also displays the city's two historic faces: the Angevin and the Aragonese. Among its most famous features are the Arc de Triomphe, with a clear Renaissance influence, the towers that testify to its defensive power and the Palatine Chapel, which has remained intact over time.

Once exclusive, reserved for sovereigns and the court, the complex is now accessible to everyone, tourists and citizens alike, thanks to guided tours and ticketed tours. It also offers a panoramic view of the Gulf of Naples, making the visit both a cultural and landscape experience.

Additions:
One of the most curious and legendary episodes linked to the complex is that of the Crocodile. The beast, originally from Egypt, was kept in the moat pit, where prisoners or uncomfortable lovers of Joanna II ended up, transforming the animal into a feared symbol of power and revenge. According to tradition, Ferrante of Aragon managed to capture him by poisoning a horse's thigh, which he used to lure him; after killing him, he stuffed the crocodile and displayed it at the entrance as a trophy, a testament to his authority. During the subway excavations, bones attributed to the creature were found, although there is no shortage of doubt about their true provenance, thus fueling the mystery and legend.

Alongside these more earthly stories, the complex also holds symbolic and esoteric ties, such as those linked to the Holy Grail. The Arc de Triomphe and the Hall of the Barons are rich in symbols that hark back to the legendary Chalice, reflecting Alfonso of Aragon's desire to identify with the knights engaged in his quest. The phenomenon of sunlight is particularly striking: during the summer solstice, the sun's rays penetrate the large window of the Hall of the Barons and illuminate exactly where the throne once stood, reinforcing the idea of an esoteric link between earthly and sacred power.
""",
        "castel_santelmo": """
originally, there was a small church dedicated to Sant'Erasmo. The name, due to the popular Neapolitan pronunciation, was later transformed into 'Sant'Elmo’.

The structure we see today, with its unmistakable six-pointed star plan, is the result of centuries of stratification and renovation, especially after its construction in 1329. In the 16th century, the Spanish transformed it into an impregnable military fortress, With those enormous pointed bastions that had to withstand the new artillery, the quintessential example is the Castellano Tower. The star shape is not only an aesthetic quirk, but a brilliant military solution. It allowed fire to be crossed from all sides without dead corners. It wasn't just a military zone, it also became a feared prison.

In the early 1900s, Castel Sant'Elmo was still fully operational as a military prison. Despite its imposing size and regal history, its walls were filled with stories of imprisonment and isolation. It was a tough, severe place. Naples at that time saw this fortress as a symbol of power and authority. Only after the Second World War did it lose its purpose as a military and prison structure did the castle begin its slow transformation into what it is today: a cultural reference and, above all, a lookout point that dominates the Gulf of Naples today, walking on the enormous entrance known as Piazzale delle Armi is an experience with strong art value.

Inside, there is proof that in Naples, even fortresses can become art, as an example is the Scala del Ragno. The intricate internal path that allowed access to the upper levels. Its shape, with radiating vaults and arches, made access complex but extremely functional for rapid movement within the fortress. 

 Fun fact:
 The explosion caused by lightning: On December 13, 1546, lightning fell on the castle's powder magazine, causing an explosion so violent that it destroyed almost half the structure and killed more than 100 people (some sources speak of 150). The explosion was so strong that it also damaged many buildings in the city, including churches such as Santa Maria La Nova and Santa Chiara. This event highlights its function as a military fortress and the vulnerability related to the conservation of ammunition.
"""
    ]
}
