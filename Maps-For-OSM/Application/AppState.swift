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
    
    static let currentVersion : Int = 3
    static let startCoordinate = CLLocationCoordinate2D(latitude: 53.541905, longitude: 9.683107)
    static let startZoom : Int = 4
    static let startScale : Double = World.zoomScaleFromWorld(to : startZoom)
    static let defaultSearchRadius : Double = 100
    
    static var shared = AppState()
    
    enum CodingKeys: String, CodingKey {
        case version
        case scale
        case latitude
        case longitude
        case showLocations
        case showCross
        case placeFilter
        case searchString
        case searchTarget
        case searchRegion
        case searchRadius
    }

    var version: Int
    var scale : Double
    var coordinate : CLLocationCoordinate2D
    var showLocations : Bool = true
    var showCross : Bool = false
    var placeFilter : PlaceFilter = .all
    var searchString : String = ""
    var searchTarget : SearchQuery.SearchTarget = .any
    var searchRegion : SearchQuery.SearchRegion = .unlimited
    var searchRadius : Double = defaultSearchRadius
    
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
        let s = try values.decodeIfPresent(String.self, forKey: .placeFilter) ?? PlaceFilter.all.rawValue
        placeFilter = PlaceFilter(rawValue: s) ?? .all
        searchString = try values.decodeIfPresent(String.self, forKey: .searchString) ?? ""
        var i = try values.decodeIfPresent(Int.self, forKey: .searchTarget) ?? 0
        searchTarget = SearchQuery.SearchTarget(rawValue: i) ?? .any
        i = try values.decodeIfPresent(Int.self, forKey: .searchRegion) ?? 0
        searchRegion = SearchQuery.SearchRegion(rawValue: i) ?? .unlimited
        searchRadius = try values.decodeIfPresent(Double.self, forKey: .searchRadius) ?? AppState.defaultSearchRadius
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(scale, forKey: .scale)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(showLocations, forKey: .showLocations)
        try container.encode(showCross, forKey: .showCross)
        try container.encode(placeFilter.rawValue, forKey: .placeFilter)
        try container.encode(searchString, forKey: .searchString)
        try container.encode(searchTarget.rawValue, forKey: .searchTarget)
        try container.encode(searchRegion.rawValue, forKey: .searchRegion)
        try container.encode(searchRadius, forKey: .searchRadius)
    }
    
    func resetPosition(){
        coordinate = AppState.startCoordinate
        scale = AppState.startScale
    }
    
    func save(){
        DataController.shared.save(forKey: AppState.storeKey, value: self)
    }
    
    static func saveAsFile() -> URL?{
        let value = shared.toJSON()
        let url = FileController.temporaryURL.appendingPathComponent(storeKey + ".json")
        if FileController.saveFile(text: value, url: url){
            return url
        }
        return nil
    }
    
    static func loadFromFile(url: URL){
        if let string = FileController.readTextFile(url: url),let data : AppState = AppState.fromJSON(encoded: string){
            shared = data
        }
    }
    
}

