import Foundation
import MapKit
import SwiftUI
import CoreLocation

final class MapViewController: UIViewController {
    let mapView = MKMapView()
    var appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.frame = view.bounds
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.pointOfInterestFilter = .excludingAll
        
        view.addSubview(mapView)
        
        addLandmarkAnnotations()
    }

    func addLandmarkAnnotations() {
        mapView.removeAnnotations(mapView.annotations)

        for landmark in appState.landmarks {
            let annotation = MKPointAnnotation()
            annotation.coordinate = landmark.coordinate
            annotation.title = landmark.name
            annotation.subtitle = appState.isVisited(landmark.id) ? "visited" : "locked"
            mapView.addAnnotation(annotation)
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    // Custom Marker View
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation { return nil }
        
        let id = "landmark"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView
        
        if view == nil {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)
        }
        
        if let subtitle = annotation.subtitle, subtitle == "visited" {
            view?.glyphText = "✓"
            view?.markerTintColor = .systemYellow
        } else {
            view?.glyphText = "?"
            view?.markerTintColor = .systemRed
        }
        
        view?.canShowCallout = true
        view?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        return view
    }
    
    // User taps the annotation popup
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        
        guard let title = view.annotation?.title ?? nil else { return }
        
        NotificationCenter.default.post(
            name: Notification.Name("LandmarkSelected"),
            object: title
        )
    }


}
