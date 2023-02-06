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
    
    public func distance(to coord: CLLocationCoordinate2D) -> CLLocationDistance{
        let lat = (self.latitude + coord.latitude) / 2
        let latMetersPerDegree = 111.132
        let lonMetersPerDegree = 111.132 * cos(lat/180*Double.pi)
        let latDelta = abs(self.latitude - coord.latitude)
        let lonDelta = abs(self.longitude - coord.longitude)
        return sqrt(pow( latDelta * latMetersPerDegree,2) + pow( lonDelta * lonMetersPerDegree,2))
    }
    
    public func exactDistance(to coord: CLLocationCoordinate2D) -> CLLocationDistance{
        let lat = (self.latitude + coord.latitude) / 2
        let angle = lat/180*Double.pi
        let latMetersPerDegree = 111132.954 - 559.822 * cos( 2 * angle ) + 1.175 * cos( 4 * angle) - 0.0023 * cos( 6 * angle)
        let lonMetersPerDegree = 111132.954 * cos ( latitude/180*Double.pi )
        let latDelta = abs(self.latitude - coord.latitude)
        let lonDelta = abs(self.longitude - coord.longitude)
        return sqrt(pow( latDelta * latMetersPerDegree,2) + pow( lonDelta * lonMetersPerDegree,2))
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
