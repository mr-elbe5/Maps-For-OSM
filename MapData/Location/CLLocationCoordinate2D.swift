/*
 E5MapData
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

extension CLLocationCoordinate2D : Equatable{
    
    public static var equatorMeters = 40075017.0
    public static var circleMeters = 40007863.0
    
    public static var equatorMetersPerDegree = equatorMeters/360
    public static var circleMetersPerDegree = circleMeters/360
    
    public static var degreeToRadFactor = Double.pi/180
    
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
    
    public func coordinateRegion(radiusMeters: CGFloat) -> CoordinateRegion{
        let angle = latitude/180*Double.pi
        let latMetersPerDegree = 111132.954 - 559.822 * cos( 2 * angle ) + 1.175 * cos( 4 * angle) - 0.0023 * cos( 6 * angle)
        let lonMetersPerDegree = 111132.954 * cos ( latitude*CLLocationCoordinate2D.degreeToRadFactor )
        let longDegreeDiff = abs(radiusMeters/lonMetersPerDegree)
        let latDegreeDiff = abs(radiusMeters/latMetersPerDegree)
        let region = CoordinateRegion(minLatitude: latitude - latDegreeDiff, maxLatitude: latitude + latDegreeDiff, minLongitude: longitude - longDegreeDiff, maxLongitude: longitude + longDegreeDiff)
        return region
    }
    
    public var asString : String{
        let latitudeText = latitude > 0 ? "north".localize(table: "Location") : "south".localize(table: "Location")
        let longitudeText = longitude > 0 ? "east".localize(table: "Location") : "west".localize(table: "Location")
        return String(format: "%.04f", abs(latitude)) + "° " + latitudeText + ", " + String(format: "%.04f", abs(longitude)) + "° "  + longitudeText
    }
    
    public var asShortString : String{
        let latitudeText = latitude > 0 ? "northShort".localize(table: "Location") : "southShort".localize(table: "Location")
        let longitudeText = longitude > 0 ? "eastShort".localize(table: "Location") : "westShort".localize(table: "Location")
        return String(format: "%.04f", abs(latitude)) + "° " + latitudeText + ", " + String(format: "%.04f", abs(longitude)) + "° "  + longitudeText
    }
    
    public var debugString : String{
        "lat: \(String(format: "%.7f", latitude)), lon: \(String(format: "%.7f", longitude))"
    }
    
}
