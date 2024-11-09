/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

class Preferences: Identifiable, Codable{
    
    static var storeKey = "preferences"
    
    static var shared = Preferences()
    
    static var elbe5Url = "https://maps.elbe5.de/carto/{z}/{x}/{y}.png"
    static var elbe5TopoUrl = "https://maps.elbe5.de/topo/{z}/{x}/{y}.png"
    static var osmUrl = "https://tile.openstreetmap.org/{z}/{x}/{y}.png"
    
    static var defaultTrackpointInterval: Double = 5.0
    static var defaultMaxHorizontalUncertainty: Double = 10.0
    
    static var defaultMinHorizontalTrackpointDistance: Double = 10.0
    static var minVerticalTrackpointDistance: Double = 5.0
    static var maxTrackpointInLineDeviation: Double = 3.0
    static var defaultMaxLocationMergeDistance: Double = 10.0
    
    static var defaultMaxSearchResults: Int = 5
    
    static var defaultDeleteLocalDataOnDownload = false
    static var defaultDeleteICloudDataOnUpload = true
    
    enum CodingKeys: String, CodingKey {
        case urlTemplate
        case followTrack
        case trackpointInterval
        case maxHorizontalUncertainty
        case maxSpeedUncertaintyFactor
        case minHorizontalTrackpointDistance
        case maxSearchResults
        case maxLocationMergeDistance
    }

    var urlTemplate : String = osmUrl
    var followTrack : Bool = false
    var showTrackpoints : Bool = false
    
    var trackpointInterval: Double = defaultTrackpointInterval
    var maxHorizontalUncertainty: Double = defaultMaxHorizontalUncertainty
    var minHorizontalTrackpointDistance = defaultMinHorizontalTrackpointDistance
    var maxSearchResults = defaultMaxSearchResults
    var maxLocationMergeDistance: Double = defaultMaxLocationMergeDistance
    
    init(){
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        urlTemplate = try values.decodeIfPresent(String.self, forKey: .urlTemplate) ?? Preferences.osmUrl
        followTrack = try values.decodeIfPresent(Bool.self, forKey: .followTrack) ?? false
        trackpointInterval = try values.decodeIfPresent(Double.self, forKey: .trackpointInterval) ?? Preferences.defaultTrackpointInterval
        maxHorizontalUncertainty = try values.decodeIfPresent(Double.self, forKey: .maxHorizontalUncertainty) ?? Preferences.defaultMaxHorizontalUncertainty
        minHorizontalTrackpointDistance = try values.decodeIfPresent(Double.self, forKey: .minHorizontalTrackpointDistance) ?? Preferences.defaultMinHorizontalTrackpointDistance
        maxSearchResults = try values.decodeIfPresent(Int.self, forKey: .maxSearchResults) ?? Preferences.defaultMaxSearchResults
        maxLocationMergeDistance = try values.decodeIfPresent(Double.self, forKey: .maxLocationMergeDistance) ?? Preferences.defaultMaxLocationMergeDistance
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(urlTemplate, forKey: .urlTemplate)
        try container.encode(followTrack, forKey: .followTrack)
        try container.encode(maxHorizontalUncertainty, forKey: .maxHorizontalUncertainty)
        try container.encode(minHorizontalTrackpointDistance, forKey: .minHorizontalTrackpointDistance)
        try container.encode(maxSearchResults, forKey: .maxSearchResults)
        try container.encode(maxLocationMergeDistance, forKey: .maxLocationMergeDistance)
    }
    
    func save(){
        UserDefaults.standard.save(forKey: Preferences.storeKey, value: self)
    }
    
}

