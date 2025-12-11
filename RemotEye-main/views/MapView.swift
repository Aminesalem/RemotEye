import SwiftUI
import MapKit
import CoreLocation

struct MapView: UIViewRepresentable {
    @EnvironmentObject var appState: AppState

    let landmarksToShow: [Landmark]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator

        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow

        mapView.pointOfInterestFilter = .excludingAll
        mapView.showsCompass = false
        mapView.showsScale = false

        if let first = landmarksToShow.first {
            let center = CLLocationCoordinate2D(latitude: first.latitude,
                                                longitude: first.longitude)
            let region = MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            mapView.setRegion(region, animated: false)
        }

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {

        // remove all except user location
        let toRemove = uiView.annotations.filter { !($0 is MKUserLocation) }
        uiView.removeAnnotations(toRemove)

        var newAnnotations: [LandmarkAnnotation] = []

        for lm in landmarksToShow {
            let coord = CLLocationCoordinate2D(latitude: lm.latitude, longitude: lm.longitude)
            let isVisited = appState.isVisited(lm.id)

            var isNearby = false
            if let userLoc = appState.userLocation {
                let distance = userLoc.distance(from:
                    CLLocation(latitude: lm.latitude, longitude: lm.longitude)
                )
                if distance <= 500 { // 500m highlight
                    isNearby = true
                }
            }

            let ann = LandmarkAnnotation(
                landmarkID: lm.id,
                title: lm.name,
                coordinate: coord,
                isVisited: isVisited,
                isNearby: isNearby
            )
            newAnnotations.append(ann)
        }

        uiView.addAnnotations(newAnnotations)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, appState: appState)
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, MKMapViewDelegate {
        let parent: MapView
        let appState: AppState

        init(_ parent: MapView, appState: AppState) {
            self.parent = parent
            self.appState = appState
        }

        func mapView(_ mapView: MKMapView,
                     viewFor annotation: MKAnnotation) -> MKAnnotationView? {

            // keep the default blue dot
            if annotation is MKUserLocation {
                return nil
            }

            guard let ann = annotation as? LandmarkAnnotation else {
                return nil
            }

            let identifier = "YellowBubble"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if view == nil {
                view = MKAnnotationView(annotation: ann, reuseIdentifier: identifier)
                view?.canShowCallout = false
                view?.centerOffset = CGPoint(x: 0, y: -10)
            } else {
                view?.annotation = ann
            }

            let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
            let image: UIImage?

            if ann.isVisited {
                // Unlocked: yellow checkmark seal
                image = UIImage(systemName: "checkmark.seal.fill", withConfiguration: config)?
                    .withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
            } else {
                // Locked or nearby: yellow question mark
                image = UIImage(systemName: "questionmark.circle.fill", withConfiguration: config)?
                    .withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
            }

            view?.image = image
            view?.layer.shadowColor = UIColor.black.cgColor
            view?.layer.shadowOpacity = 0.25
            view?.layer.shadowRadius = 4
            view?.layer.shadowOffset = CGSize(width: 0, height: 2)

            return view
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let ann = view.annotation as? LandmarkAnnotation else { return }

            if let lm = appState.landmarks.first(where: { $0.id == ann.landmarkID }) {
                NotificationCenter.default.post(
                    name: .landmarkSelected,
                    object: lm.name
                )
            }

            mapView.deselectAnnotation(view.annotation, animated: false)
        }
    }
}
