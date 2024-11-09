/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

protocol LocationDelegate{
    func editLocation(location: Location)
    func showLocationOnMap(coordinate: CLLocationCoordinate2D)
    func locationsChanged()
    func locationChanged(location: Location)
}

extension LocationDelegate{
    
    func editLocation(location: Location){
    }
    
    func showLocationOnMap(coordinate: CLLocationCoordinate2D){
    }
    
    func locationsChanged(){
    }
    
    func locationChanged(location: Location){
        locationsChanged()
    }
}
