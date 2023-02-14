/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import AVKit
import CoreLocation

class AppState: Identifiable, Codable{
    
    static var storeKey = "state"
    
    static let currentVersion : Int = 2
    static let startCoordinate = CLLocationCoordinate2D(latitude: 53.541905, longitude: 9.683107)
    static let startZoom : Int = 4
    static let startScale : Double = World.zoomScaleFromWorld(to : startZoom)
    
    static var shared = AppState()
    
    static func loadInstance(){
        if let state : AppState = DataController.shared.load(forKey: AppState.storeKey){
            shared = state
        }
        else{
            shared = AppState()
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case version
        case scale
        case latitude
        case longitude
        case showLocations
        case showCross
    }

    var version: Int
    var scale : Double
    var coordinate : CLLocationCoordinate2D
    var showLocations : Bool = true
    var showCross : Bool = false
    
    init(){
        version = 1
        self.scale = AppState.startScale
        self.coordinate = AppState.startCoordinate
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        version = try values.decodeIfPresent(Int.self, forKey: .version) ?? 1
        scale = try values.decodeIfPresent(Double.self, forKey: .scale) ?? AppState.startScale
        if let lat = try values.decodeIfPresent(Double.self, forKey: .latitude), let lon = try values.decodeIfPresent(Double.self, forKey: .longitude){
            coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        else{
            coordinate = AppState.startCoordinate
        }
        showLocations = try values.decodeIfPresent(Bool.self, forKey: .showLocations) ?? true
        showCross = try values.decodeIfPresent(Bool.self, forKey: .showCross) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(scale, forKey: .scale)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(showLocations, forKey: .showLocations)
        try container.encode(showCross, forKey: .showCross)
    }
    
    func resetPosition(){
        coordinate = AppState.startCoordinate
        scale = AppState.startScale
    }
    
    func save(){
        DataController.shared.save(forKey: AppState.storeKey, value: self)
    }
    
    
}
