//
//  CoordinateRegion.swift
//  SwiftyMaps for OSM
//
//  Created by Michael Rönnau on 15.09.22.
//

import Foundation
import CoreLocation

class CoordinateRegion{
    
    var center : CLLocationCoordinate2D
    var span : CoordinateSpan
    
    init(){
        center = CLLocationCoordinate2D()
        span = CoordinateSpan()
    }
    
    init(center : CLLocationCoordinate2D, span : CoordinateSpan){
        self.center = center
        self.span = span
    }
    
}
