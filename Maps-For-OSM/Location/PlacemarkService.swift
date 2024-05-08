/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class PlacemarkService{
    
    static var shared = PlacemarkService()
    
    private let geocoder = CLGeocoder()
    
    func getPlacemark(for location: Place, result: @escaping(CLPlacemark?) -> Void){
        geocoder.reverseGeocodeLocation(CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), completionHandler: { (placemarks, error) in
            if error == nil, let placemark =  placemarks?[0]{
                result(placemark)
            }
            else{
                result(nil)
            }
        })
    }
    
    func getPlacemark(for location: CLLocation, result: @escaping(CLPlacemark?) -> Void){
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            if error == nil, let placemark =  placemarks?[0]{
                result(placemark)
            }
            else{
                result(nil)
            }
        })
    }
    
}

