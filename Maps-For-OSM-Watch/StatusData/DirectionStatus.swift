//
//  DirectionStatus.swift
//  Maps For OSM Watch
//
//  Created by Michael Rönnau on 14.10.24.
//

import Foundation
import CoreLocation

@Observable class DirectionStatus: NSObject{
    
    var direction: CLLocationDirection = LocationManager.startDirection
    
}
