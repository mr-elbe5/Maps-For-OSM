/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import CoreLocation

class CoordinateRegion{
    
    var minLatitude : CLLocationDegrees
    var maxLatitude : CLLocationDegrees
    var minLongitude : CLLocationDegrees
    var maxLongitude : CLLocationDegrees
    
    var center: CLLocationCoordinate2D{
        CLLocationCoordinate2D(latitude: (minLatitude + maxLatitude)/2, longitude: (minLongitude + maxLongitude)/2)
    }
    
    var mapRect : MapRect{
        let topLeft = MapPoint(CLLocationCoordinate2D(latitude: maxLatitude, longitude: minLongitude))
        let bottomRight = MapPoint(CLLocationCoordinate2D(latitude: minLatitude, longitude: maxLongitude))
        return MapRect(x: topLeft.x, y: topLeft.y, width: bottomRight.x - topLeft.x, height: topLeft.y - bottomRight.y)
    }
    
    init(topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D){
        maxLatitude = topLeft.latitude
        minLatitude = bottomRight.latitude
        minLongitude = topLeft.longitude
        maxLongitude = bottomRight.longitude
    }
    
    var string : String{
        "minLatitude = \(minLatitude), maxLatitude = \(maxLatitude), minLongitude = \(minLongitude), maxLongitude = \(maxLongitude)"
    }
    
}
