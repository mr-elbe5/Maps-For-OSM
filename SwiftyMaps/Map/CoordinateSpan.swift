//
//  CoordinateSpan.swift
//  SwiftyMaps for OSM
//
//  Created by Michael Rönnau on 15.09.22.
//

import Foundation
import CoreLocation

class CoordinateSpan{
    
    var latitudeDelta: CLLocationDegrees
    var longitudeDelta: CLLocationDegrees
    
    init(){
        latitudeDelta = 0
        longitudeDelta = 0
    }
    
    init(latitudeDelta: CLLocationDegrees, longitudeDelta: CLLocationDegrees){
        self.latitudeDelta = latitudeDelta
        self.longitudeDelta = longitudeDelta
    }
    
}
