/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation
import E5Data

open class AppState: CommonAppState{
    
    public static let startCoordinate = CLLocationCoordinate2D(latitude: 53.541905, longitude: 9.683107)
    
    public static var shared = AppState()
    
    public enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }

    public var coordinate : CLLocationCoordinate2D
    
    override public init(){
        self.coordinate = AppState.startCoordinate
        super.init()
    }

    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
         if let lat = try values.decodeIfPresent(Double.self, forKey: .latitude), let lon = try values.decodeIfPresent(Double.self, forKey: .longitude){
            coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        else{
            coordinate = AppState.startCoordinate
        }
        try super.init(from: decoder)
    }
    
    override open func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
    }
    
}

