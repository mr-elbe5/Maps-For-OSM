//
//  CodableLocation.swift
//  SwiftyMaps for OSM
//
//  Created by Michael Rönnau on 19.09.22.
//

import Foundation
import CoreLocation

class CodableLocation : CLLocation, Codable{
    
    var lock = DispatchSemaphore(value: 1)
    
    private enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case altitude
        case timestamp
    }
    
    var mapPoint: MapPoint
    
    var coordinateString : String{
        coordinate.coordinateString
    }

    init(coordinate: CLLocationCoordinate2D){
        mapPoint = MapPoint(coordinate)
        super.init(coordinate: coordinate, altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())
    }
    
    init(coordinate: CLLocationCoordinate2D, altitude: CLLocationDistance, timestamp: Date){
        mapPoint = MapPoint(coordinate)
        super.init(coordinate: coordinate, altitude: altitude, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: timestamp)
    }
    
    init(location: CLLocation){
        mapPoint = MapPoint(location.coordinate)
        super.init(coordinate: location.coordinate, altitude: location.altitude, horizontalAccuracy: location.horizontalAccuracy, verticalAccuracy: location.verticalAccuracy, course: location.course, courseAccuracy: location.courseAccuracy, speed: location.speed, speedAccuracy: location.speedAccuracy, timestamp: location.timestamp)
    }
    
    required init?(coder: NSCoder) {
        mapPoint = MapPoint()
        super.init(coder: coder)
        mapPoint = MapPoint(coordinate)
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? 0
        let longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? 0
        let coord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapPoint = MapPoint(coord)
        super.init(coordinate: coord,
                   altitude: try values.decodeIfPresent(CLLocationDistance.self, forKey: .altitude) ?? 0,
                   horizontalAccuracy: 0,
                   verticalAccuracy: 0,
                   timestamp: try values.decodeIfPresent(Date.self, forKey: .timestamp) ?? Date())
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(altitude, forKey: .altitude)
        try container.encode(timestamp, forKey: .timestamp)
    }
    
}
