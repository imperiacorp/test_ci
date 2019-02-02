//
//  PlaceAnnotation.swift
//  CodingTask
//
//  Created by Dmitriy Gonchar on 6/28/18.
//  Copyright © 2018 Dmitriy Gonchar. All rights reserved.
//

import MapKit

class PlaceAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let placeId: String

    init(placeId: String, title: String, locationName: String?, coordinate: CLLocationCoordinate2D) {
        self.placeId = placeId
        self.title = title
        self.subtitle = locationName
        self.coordinate = coordinate

        super.init()
    }
}
