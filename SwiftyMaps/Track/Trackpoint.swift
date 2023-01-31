/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import UIKit

class Trackpoint: CodableLocation{
    
    enum CodingKeys: String, CodingKey{
        case horizontalAccuracy
        case verticalAccuracy
        case speed
        case speedAccuracy
    }
    
    var timeDiff: CGFloat = 0
    var horizontalDistance: CGFloat = 0
    var verticalDistance: CGFloat = 0
    
    var horizontallyValid: Bool{
        horizontalAccuracy < horizontalDistance && speedAccuracy < speed
    }
    
    var verticallyValid: Bool{
        verticalAccuracy < verticalDistance
    }
    
    var kmhSpeed: Int{
        guard timeDiff > 0 else { return 0}
        // km/h
        let v = horizontalDistance/timeDiff
        return Int(v * 3.6)
    }
    
    // for gpx parser
    override init(coordinate: CLLocationCoordinate2D, altitude: CLLocationDistance, timestamp: Date){
        super.init(coordinate: coordinate, altitude: altitude, timestamp: timestamp)
    }
    
    // for track recorder
    override init(location: CLLocation){
        super.init(location: location)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodableLocation.CodingKeys.self)
        let latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? 0
        let longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? 0
        let coord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let tpvalues = try decoder.container(keyedBy: CodingKeys.self)
        super.init(coordinate: coord,
                   altitude: try values.decodeIfPresent(CLLocationDistance.self, forKey: .altitude) ?? 0,
                   horizontalAccuracy: try tpvalues.decodeIfPresent(Double.self, forKey: .horizontalAccuracy) ?? 0,
                   verticalAccuracy: try tpvalues.decodeIfPresent(Double.self, forKey: .verticalAccuracy) ?? 0,
                   course: 0,
                   courseAccuracy: 0,
                   speed: try tpvalues.decodeIfPresent(Double.self, forKey: .speed) ?? 0,
                   speedAccuracy: try tpvalues.decodeIfPresent(Double.self, forKey: .speedAccuracy) ?? 0,
                   timestamp: try values.decodeIfPresent(Date.self, forKey: .timestamp) ?? Date())
        mapPoint = MapPoint(coord)
    }
    
    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(horizontalAccuracy, forKey: .horizontalAccuracy)
        try container.encode(verticalAccuracy, forKey: .verticalAccuracy)
        try container.encode(speed, forKey: .speed)
        try container.encode(speedAccuracy, forKey: .speedAccuracy)
    }
    
    func updateDeltas(from tp: Trackpoint, distance: CGFloat? = nil){
        timeDiff = tp.timestamp.distance(to: timestamp)
        horizontalDistance = distance ?? tp.coordinate.distance(to: coordinate)
        verticalDistance = altitude - tp.altitude
        if verticalAccuracy > verticalDistance{
            verticalDistance = 0
        }
    }
    
}

