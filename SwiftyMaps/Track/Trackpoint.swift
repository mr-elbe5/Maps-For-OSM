/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import UIKit

class Trackpoint: Codable, Identifiable{
    
    enum CodingKeys: String, CodingKey{
        case latitude
        case longitude
        case altitude
        case timestamp
        case horizontalAccuracy
        case verticalAccuracy
        case speed
        case speedAccuracy
    }
    
    var coordinate: CLLocationCoordinate2D
    var altitude: Double
    var timestamp: Date
    var mapPoint: MapPoint
    var horizontalAccuracy: Double = 0
    var verticalAccuracy: Double = 0
    var speed: Double = 0
    var speedAccuracy: Double = 0
    
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
    init(coordinate: CLLocationCoordinate2D, altitude: CLLocationDistance, timestamp: Date){
        self.coordinate = coordinate
        self.altitude = altitude
        self.timestamp = timestamp
        mapPoint = MapPoint(coordinate)
    }
    
    // for track recorder
    init(location: CLLocation){
        mapPoint = MapPoint(location.coordinate)
        coordinate = location.coordinate
        altitude = location.altitude
        timestamp = location.timestamp
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? 0
        let longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? 0
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapPoint = MapPoint(coordinate)
        altitude = try values.decodeIfPresent(CLLocationDistance.self, forKey: .altitude) ?? 0
        timestamp = try values.decodeIfPresent(Date.self, forKey: .timestamp) ?? Date()
        horizontalAccuracy = try values.decodeIfPresent(Double.self, forKey: .horizontalAccuracy) ?? 0
        verticalAccuracy = try values.decodeIfPresent(Double.self, forKey: .verticalAccuracy) ?? 0
        speed = try values.decodeIfPresent(Double.self, forKey: .speed) ?? 0
        speedAccuracy = try values.decodeIfPresent(Double.self, forKey: .speedAccuracy) ?? 0
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(altitude, forKey: .altitude)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(horizontalAccuracy, forKey: .horizontalAccuracy)
        try container.encode(verticalAccuracy, forKey: .verticalAccuracy)
        try container.encode(speed, forKey: .speed)
        try container.encode(speedAccuracy, forKey: .speedAccuracy)
    }
    
    init(coordinate: CLLocationCoordinate2D){
        mapPoint = MapPoint(coordinate)
        self.coordinate = coordinate
        altitude = 0
        timestamp = Date()
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

