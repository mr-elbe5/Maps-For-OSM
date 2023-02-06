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
        "lat: \(coordinate.latitude), lon: \(coordinate.longitude), speed: \(speed), course: \(course), time: \(timestamp.timestampString())"
    }
    
    var speedUncertaintyFactor: Double{
        speedAccuracy < 0 ? -1 : speedAccuracy / speed
    }
    
    var horizontallyValid: Bool{
        horizontalAccuracy >= 0 && speedAccuracy >= 0 && horizontalAccuracy < Preferences.shared.maxHorizontalUncertainty && speedUncertaintyFactor < Preferences.shared.maxSpeedUncertaintyFactor
    }
    
    var verticallyValid: Bool{
        verticalAccuracy >= 0 && verticalAccuracy < Preferences.shared.maxVerticalUncertainty
    }
    
}
