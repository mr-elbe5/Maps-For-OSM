//
//  CLLocation.swift
//  SwiftyMaps for OSM
//
//  Created by Michael Rönnau on 19.09.22.
//

import Foundation
import CoreLocation

extension CLLocation{
    
    var string: String{
        "lat: \(coordinate.latitude), lon: \(coordinate.longitude), acc: \(horizontalAccuracy), speed: \(speed), course: \(course), time: \(timestamp.timestampString())"
    }
    
    func distanceTo(location: CLLocation) -> CLLocationDistance{
        coordinate.distance(to: location.coordinate)
    }
    
}
