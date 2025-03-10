/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation

class CommonAppState: Identifiable, Codable{
    
    static var storeKey = "state"
    
    static let currentVersion : Int = 3
    static let startZoom : Int = 4
    static let startScale : Double = World.zoomScaleFromWorld(to : startZoom)
    static let defaultSearchRadius : Double = 100
    static let defaultSortAscending = false
    
    enum CodingKeys: String, CodingKey {
        case version
        case zoom
        case showLocations
        case showCross
        case searchString
        case searchTarget
        case searchRegion
        case searchRadius
        case sortAscending
    }

    var version: Int
    var zoom : Int
    var showLocations : Bool = true
    var showCross : Bool = false
    var searchString : String = ""
    var searchTarget : SearchQuery.SearchTarget = .any
    var searchRegion : SearchQuery.SearchRegion = .unlimited
    var searchRadius : Double = defaultSearchRadius
    var sortAscending = defaultSortAscending
    
    init(){
        version = 1
        self.zoom = AppState.startZoom
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        version = try values.decodeIfPresent(Int.self, forKey: .version) ?? 1
        zoom = try values.decodeIfPresent(Int.self, forKey: .zoom) ?? AppState.startZoom
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(zoom, forKey: .zoom)
        try container.encode(showLocations, forKey: .showLocations)
        try container.encode(showCross, forKey: .showCross)
        try container.encode(searchString, forKey: .searchString)
        try container.encode(searchTarget.rawValue, forKey: .searchTarget)
        try container.encode(searchRegion.rawValue, forKey: .searchRegion)
        try container.encode(searchRadius, forKey: .searchRadius)
        try container.encode(sortAscending, forKey: .sortAscending)
    }
    
    func resetPosition(){
        zoom = AppState.startZoom
    }
    
    func save(){
        UserDefaults.standard.save(forKey: AppState.storeKey, value: self)
    }
    
}

