/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

extension CLLocationCoordinate2D : Equatable{
    
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    public static func getLatitudeDistanceFactor(latitude: CLLocationDegrees) -> Double{
        let latMetersPerDegree = 111132.954 - 559.822 * cos( 2 * latitude ) + 1.175 * cos( 4 * latitude)
        let lonMetersPerDegree = 111132.954 * cos ( latitude )
        return latMetersPerDegree/lonMetersPerDegree
    }
    
    public func distance(to coord: CLLocationCoordinate2D) -> CLLocationDistance{
        let latMid = (self.latitude + coord.latitude) / 2
        let latMetersPerDegree = 111132.954 - 559.822 * cos( 2 * latMid ) + 1.175 * cos( 4 * latMid)
        let lonMetersPerDegree = 111132.954 * cos ( latMid )
        let latDelta = abs(self.latitude - coord.latitude)
        let lonDelta = abs(self.longitude - coord.longitude)
        return sqrt(pow( latDelta * latMetersPerDegree,2) + pow( lonDelta * lonMetersPerDegree,2))
    }
    
    public func direction(to coord: CLLocationCoordinate2D) -> Int{
        let latMid = (self.latitude + coord.latitude) / 2
        return direction(to: coord, latDistFactor: CLLocationCoordinate2D.getLatitudeDistanceFactor(latitude: latMid))
    }
    
    public func direction(to coord: CLLocationCoordinate2D, latDistFactor: Double) -> Int{
        if coord.longitude == self.longitude{
            return coord.latitude > self.latitude ? 90 : 270
        }
        let londiff = coord.longitude - self.longitude
        let tan = (coord.latitude - self.latitude)*latDistFactor/londiff
        var atan = atan(tan)
        if londiff < 0{
            atan += Double.pi
        }
        return Int(round(atan * 180 / Double.pi)) + 90
    }
    
    public var asString : String{
        let latitudeText = latitude > 0 ? "north".localize() : "south".localize()
        let longitudeText = longitude > 0 ? "east".localize() : "west".localize()
        return String(format: "%.04f", abs(latitude)) + "° " + latitudeText + ", " + String(format: "%.04f", abs(longitude)) + "° "  + longitudeText
    }
    
    public var shortString : String{
        "lat: \(String(format: "%.7f", latitude)), lon: \(String(format: "%.7f", longitude))"
    }
    
}
