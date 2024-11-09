/*
 E5MapData
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation

class CoordinateRegion{
    
    var minLatitude : CLLocationDegrees
    var maxLatitude : CLLocationDegrees
    var minLongitude : CLLocationDegrees
    var maxLongitude : CLLocationDegrees
    
    var center: CLLocationCoordinate2D{
        CLLocationCoordinate2D(latitude: (minLatitude + maxLatitude)/2, longitude: (minLongitude + maxLongitude)/2)
    }
    
    init(topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D){
        maxLatitude = topLeft.latitude
        minLatitude = bottomRight.latitude
        minLongitude = topLeft.longitude
        maxLongitude = bottomRight.longitude
    }
    
    init(minLatitude: CLLocationDegrees, maxLatitude: CLLocationDegrees, minLongitude: CLLocationDegrees, maxLongitude: CLLocationDegrees){
        self.minLatitude = minLatitude
        self.maxLatitude = maxLatitude
        self.minLongitude = minLongitude
        self.maxLongitude = maxLongitude
    }
    
    func contains(coordinate: CLLocationCoordinate2D) -> Bool{
        coordinate.latitude >= minLatitude && coordinate.latitude <= maxLatitude && coordinate.longitude >= minLongitude && coordinate.longitude <= maxLongitude
    }
    
    var string : String{
        "minLatitude = \(minLatitude), maxLatitude = \(maxLatitude), minLongitude = \(minLongitude), maxLongitude = \(maxLongitude)"
    }
    
}
