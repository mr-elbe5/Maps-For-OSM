/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import AVKit
import CoreLocation

class Preferences: Identifiable, Codable{
    
    static var storeKey = "preferences"
    
    static var shared = Preferences()
    
    static var elbe5Url = "https://maps.elbe5.de/carto/{z}/{x}/{y}.png"
    static var elbe5TopoUrl = "https://maps.elbe5.de/topo/{z}/{x}/{y}.png"
    static var osmUrl = "https://tile.openstreetmap.org/{z}/{x}/{y}.png"
    
    static var defaultTrackpointInterval: Double = 3
    static var defaultMaxHorizontalUncertainty: Double = 3
    static var defaultMaxSpeedUncertaintyFactor: Double = 2
    
    static var defaultMinHorizontalTrackpointDistance: Double = 3
    static var defaultMinVerticalTrackpointDistance: Double = 1.5
    
    static var defaultMaxTrackpointInLineDeviation: Double = 2.0
    
    static func loadInstance(){
        if let prefs : Preferences = DataController.shared.load(forKey: Preferences.storeKey){
            shared = prefs
        }
        else{
            shared = Preferences()
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case urlTemplate
        case followTrack
        case showTrackpoints
        case trackpointInterval
        case maxHorizontalUncertainty
        case maxSpeedUncertaintyFactor
        case minHorizontalTrackpointDistance
        case minVerticalTrackpointDistance
        case maxTrackpointInLineDeviation
    }

    var urlTemplate : String = osmUrl
    var followTrack : Bool = false
    var showTrackpoints : Bool = false
    
    var trackpointInterval: Double = defaultTrackpointInterval
    var maxHorizontalUncertainty: Double = defaultMaxHorizontalUncertainty
    var maxSpeedUncertaintyFactor: Double = defaultMaxSpeedUncertaintyFactor
    var minHorizontalTrackpointDistance = defaultMinHorizontalTrackpointDistance
    var minVerticalTrackpointDistance = defaultMinVerticalTrackpointDistance
    var maxTrackpointInLineDeviation = defaultMaxTrackpointInLineDeviation
    
    init(){
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        urlTemplate = try values.decodeIfPresent(String.self, forKey: .urlTemplate) ?? Preferences.osmUrl
        followTrack = try values.decodeIfPresent(Bool.self, forKey: .followTrack) ?? false
        showTrackpoints = try values.decodeIfPresent(Bool.self, forKey: .showTrackpoints) ?? false
        trackpointInterval = try values.decodeIfPresent(Double.self, forKey: .trackpointInterval) ?? Preferences.defaultTrackpointInterval
        maxHorizontalUncertainty = try values.decodeIfPresent(Double.self, forKey: .maxHorizontalUncertainty) ?? Preferences.defaultMaxHorizontalUncertainty
        maxSpeedUncertaintyFactor = try values.decodeIfPresent(Double.self, forKey: .maxSpeedUncertaintyFactor) ?? Preferences.defaultMaxSpeedUncertaintyFactor
        minHorizontalTrackpointDistance = try values.decodeIfPresent(Double.self, forKey: .minHorizontalTrackpointDistance) ?? Preferences.defaultMinHorizontalTrackpointDistance
        minVerticalTrackpointDistance = try values.decodeIfPresent(Double.self, forKey: .minVerticalTrackpointDistance) ?? Preferences.defaultMinVerticalTrackpointDistance
        maxTrackpointInLineDeviation = try values.decodeIfPresent(Double.self, forKey: .maxTrackpointInLineDeviation) ?? Preferences.defaultMaxTrackpointInLineDeviation
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(urlTemplate, forKey: .urlTemplate)
        try container.encode(followTrack, forKey: .followTrack)
        try container.encode(showTrackpoints, forKey: .showTrackpoints)
        try container.encode(trackpointInterval, forKey: .trackpointInterval)
        try container.encode(maxHorizontalUncertainty, forKey: .maxHorizontalUncertainty)
        try container.encode(maxSpeedUncertaintyFactor, forKey: .maxSpeedUncertaintyFactor)
        try container.encode(minHorizontalTrackpointDistance, forKey: .minHorizontalTrackpointDistance)
        try container.encode(minVerticalTrackpointDistance, forKey: .minVerticalTrackpointDistance)
        try container.encode(maxTrackpointInLineDeviation, forKey: .maxTrackpointInLineDeviation)
    }
    
    func save(){
        DataController.shared.save(forKey: Preferences.storeKey, value: self)
    }
    
    static func saveAsFile() -> URL?{
        let value = shared.toJSON()
        let url = FileController.temporaryURL.appendingPathComponent(storeKey + ".json")
        if FileController.saveFile(text: value, url: url){
            return url
        }
        return nil
    }
    
}
