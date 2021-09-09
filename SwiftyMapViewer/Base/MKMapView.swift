//
//  MKMapView.swift
//
//  Created by Michael Rönnau on 10.08.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension MKMapView {
    
    var zoomLevel : Int{
        get{
            Int(round(log2(Double(360 * frame.size.width) / (region.span.longitudeDelta * 128))))
        }
    }
    
    func centerToLocation(_ location: Location,regionRadius: CLLocationDistance = Settings.shared.mapStartSize.rawValue) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
    
}
