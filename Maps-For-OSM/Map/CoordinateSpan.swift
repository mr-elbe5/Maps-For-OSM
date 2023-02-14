/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

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
