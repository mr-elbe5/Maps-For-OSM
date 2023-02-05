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
    
    var speedDeviation: Double{
        speedAccuracy < 0 ? -1 : speedAccuracy / speed
    }
    
    var horizontallyValid: Bool{
        horizontalAccuracy >= 0 && speedAccuracy >= 0 && horizontalAccuracy < Preferences.shared.minTrackpointHorizontalDelta && speedDeviation < Preferences.shared.maxDeviationFactor
    }
    
    var verticallyValid: Bool{
        verticalAccuracy >= 0 && verticalAccuracy < Preferences.shared.minTrackpointVerticalDelta
    }
    
}
