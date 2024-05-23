/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation
import UIKit
import CommonBasics
import IOSBasics

class Trackpoint: Codable, Identifiable{
    
    enum CodingKeys: String, CodingKey{
        case latitude
        case longitude
        case altitude
        case timestamp
        case speed
        case valid
    }
    
    var coordinate: CLLocationCoordinate2D
    var altitude: Double
    var timestamp: Date
    var mapPoint: CGPoint
    var valid: Bool = true
    
    var horizontalDistance: CGFloat = 0
    var verticalDistance: CGFloat = 0
    var timeDiff: CGFloat = 0
    
    // gps values
    var horizontalAccuracy: Double = 0
    var speed: Double = 0
    var speedAccuracy: Double = 0
    
    var horizontallyValid: Bool{
        horizontalAccuracy != -1 && (speed == 0 || speedAccuracy != -1) && horizontalAccuracy < Preferences.shared.maxHorizontalUncertainty
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
        mapPoint = CGPoint(coordinate)
    }
    
    // for track recorder
    init(location: CLLocation){
        mapPoint = CGPoint(location.coordinate)
        coordinate = location.coordinate
        altitude = location.altitude
        timestamp = location.timestamp
        horizontalAccuracy = location.horizontalAccuracy
        speed = location.speed
        speedAccuracy = location.speedAccuracy
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? 0
        let longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? 0
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapPoint = CGPoint(coordinate)
        altitude = try values.decodeIfPresent(CLLocationDistance.self, forKey: .altitude) ?? 0
        timestamp = try values.decodeIfPresent(Date.self, forKey: .timestamp) ?? Date.localDate
        valid = try values.decodeIfPresent(Bool.self, forKey: .valid) ?? true
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(altitude, forKey: .altitude)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(valid, forKey: .valid)
    }
    
    func checkValidity(){
        valid = horizontalAccuracy != -1 && (speed != 0 && speedAccuracy != -1) && horizontalAccuracy < Preferences.shared.maxHorizontalUncertainty
    }
    
    func updateDeltas(from tp: Trackpoint, distance: CGFloat? = nil){
        timeDiff = tp.timestamp.distance(to: timestamp)
        horizontalDistance = distance ?? tp.coordinate.distance(to: coordinate)
        verticalDistance = altitude - tp.altitude
        if abs(verticalDistance) < Preferences.shared.minVerticalTrackpointDistance{
            altitude = tp.altitude
            verticalDistance = 0
        }
    }
    
}

