/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation

class AppState: CommonAppState{
    
    static let startCoordinate = CLLocationCoordinate2D(latitude: 53.541905, longitude: 9.683107)
    
    static var shared = AppState()
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }

    var coordinate : CLLocationCoordinate2D
    
    override init(){
        self.coordinate = AppState.startCoordinate
        super.init()
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
         if let lat = try values.decodeIfPresent(Double.self, forKey: .latitude), let lon = try values.decodeIfPresent(Double.self, forKey: .longitude){
            coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        else{
            coordinate = AppState.startCoordinate
        }
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
    }
    
}

