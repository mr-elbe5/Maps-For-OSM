/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

extension CLLocationCoordinate2D : Equatable{
    
    static var equatorMeters = 40075017.0
    static var circleMeters = 40007863.0
    
    static var equatorMetersPerDegree = equatorMeters/360
    static var circleMetersPerDegree = circleMeters/360
    
    static var degreeToRadFactor = Double.pi/180
    
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    public func distance(to coord: CLLocationCoordinate2D) -> CLLocationDistance{
        let lat = (self.latitude + coord.latitude) / 2
        let latMetersPerDegree = CLLocationCoordinate2D.circleMetersPerDegree
        let lonMetersPerDegree = CLLocationCoordinate2D.equatorMetersPerDegree * cos(lat*CLLocationCoordinate2D.degreeToRadFactor)
        let latDelta = abs(self.latitude - coord.latitude)
        let lonDelta = abs(self.longitude - coord.longitude)
        return sqrt(pow( latDelta * latMetersPerDegree,2) + pow( lonDelta * lonMetersPerDegree,2))
    }
    
    public func exactDistance(to coord: CLLocationCoordinate2D) -> CLLocationDistance{
        let lat = (self.latitude + coord.latitude) / 2
        let angle = lat/180*Double.pi
        let latMetersPerDegree = 111132.954 - 559.822 * cos( 2 * angle ) + 1.175 * cos( 4 * angle) - 0.0023 * cos( 6 * angle)
        let lonMetersPerDegree = 111132.954 * cos ( latitude*CLLocationCoordinate2D.degreeToRadFactor )
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
