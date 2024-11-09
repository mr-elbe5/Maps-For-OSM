/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation

class Trackpoint: Codable, Identifiable, Selectable{
    
    enum CodingKeys: String, CodingKey{
        case latitude
        case longitude
        case altitude
        case timestamp
    }
    
    var coordinate: CLLocationCoordinate2D
    var altitude: Double
    var timestamp: Date
    var mapPoint: CGPoint
    //runtime
    var selected: Bool = false
    
    // for gpx parser
    init(coordinate: CLLocationCoordinate2D, altitude: CLLocationDistance, timestamp: Date){
        self.coordinate = coordinate
        self.altitude = altitude
        self.timestamp = timestamp
        selected = false
        mapPoint = CGPoint(coordinate)
    }
    
    // for track recorder
    init(location: CLLocation){
        mapPoint = CGPoint(location.coordinate)
        coordinate = location.coordinate
        altitude = location.altitude
        timestamp = location.timestamp.toLocalDate()
        selected = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? 0
        let longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? 0
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapPoint = CGPoint(coordinate)
        altitude = try values.decodeIfPresent(CLLocationDistance.self, forKey: .altitude) ?? 0
        timestamp = try values.decodeIfPresent(Date.self, forKey: .timestamp) ?? Date.localDate
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(altitude, forKey: .altitude)
        try container.encode(timestamp, forKey: .timestamp)
    }
    
}

