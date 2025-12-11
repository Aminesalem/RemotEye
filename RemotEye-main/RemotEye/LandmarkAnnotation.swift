//
//  LandmarkAnnotation.swift
//  RemotEye
//
//  Created by AFP PAR 29 on 07/12/25.
//

import Foundation
import MapKit

final class LandmarkAnnotation: NSObject, MKAnnotation {
    let landmarkID: String
    let title: String?
    let coordinate: CLLocationCoordinate2D

    // extra state for styling
    let isVisited: Bool
    let isNearby: Bool

    init(landmarkID: String,
         title: String,
         coordinate: CLLocationCoordinate2D,
         isVisited: Bool,
         isNearby: Bool) {
        self.landmarkID = landmarkID
        self.title = title
        self.coordinate = coordinate
        self.isVisited = isVisited
        self.isNearby = isNearby
    }
}
