/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation
import E5Data
import E5Data

open class AppState: Identifiable, Codable{
    
    public static var storeKey = "state"
    
    public static let currentVersion : Int = 3
    public static let startCoordinate = CLLocationCoordinate2D(latitude: 53.541905, longitude: 9.683107)
    public static let startZoom : Int = 4
    public static let startScale : Double = World.zoomScaleFromWorld(to : startZoom)
    public static let defaultSearchRadius : Double = 100
    public static let defaultSortAscending = false
    
    public static var shared = AppState()
    
    public enum CodingKeys: String, CodingKey {
        case version
        case zoom
        case latitude
        case longitude
        case showLocations
        case showCross
        case searchString
        case searchTarget
        case searchRegion
        case searchRadius
        case sortAscending
    }

    public var version: Int
    public var zoom : Int
    public var coordinate : CLLocationCoordinate2D
    public var showLocations : Bool = true
    public var showCross : Bool = false
    public var searchString : String = ""
    public var searchTarget : SearchQuery.SearchTarget = .any
    public var searchRegion : SearchQuery.SearchRegion = .unlimited
    public var searchRadius : Double = defaultSearchRadius
    public var sortAscending = defaultSortAscending
    
    public init(){
        version = 1
        self.zoom = AppState.startZoom
        self.coordinate = AppState.startCoordinate
    }

    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        version = try values.decodeIfPresent(Int.self, forKey: .version) ?? 1
        zoom = try values.decodeIfPresent(Int.self, forKey: .zoom) ?? AppState.startZoom
        if let lat = try values.decodeIfPresent(Double.self, forKey: .latitude), let lon = try values.decodeIfPresent(Double.self, forKey: .longitude){
            coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        else{
            coordinate = AppState.startCoordinate
        }
        showLocations = try values.decodeIfPresent(Bool.self, forKey: .showLocations) ?? true
        showCross = try values.decodeIfPresent(Bool.self, forKey: .showCross) ?? false
        searchString = try values.decodeIfPresent(String.self, forKey: .searchString) ?? ""
        var i = try values.decodeIfPresent(Int.self, forKey: .searchTarget) ?? 0
        searchTarget = SearchQuery.SearchTarget(rawValue: i) ?? .any
        i = try values.decodeIfPresent(Int.self, forKey: .searchRegion) ?? 0
        searchRegion = SearchQuery.SearchRegion(rawValue: i) ?? .unlimited
        searchRadius = try values.decodeIfPresent(Double.self, forKey: .searchRadius) ?? AppState.defaultSearchRadius
        sortAscending = try values.decodeIfPresent(Bool.self, forKey: .sortAscending) ?? AppState.defaultSortAscending
    }
    
    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(zoom, forKey: .zoom)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(showLocations, forKey: .showLocations)
        try container.encode(showCross, forKey: .showCross)
        try container.encode(searchString, forKey: .searchString)
        try container.encode(searchTarget.rawValue, forKey: .searchTarget)
        try container.encode(searchRegion.rawValue, forKey: .searchRegion)
        try container.encode(searchRadius, forKey: .searchRadius)
        try container.encode(sortAscending, forKey: .sortAscending)
    }
    
    public func resetPosition(){
        coordinate = AppState.startCoordinate
        zoom = AppState.startZoom
    }
    
    open func save(){
        UserDefaults.standard.save(forKey: AppState.storeKey, value: self)
    }
    
}

