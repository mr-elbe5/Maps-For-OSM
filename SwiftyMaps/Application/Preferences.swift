/*
 SwiftyMaps
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
    static var defaultMaxVerticalUncertainty: Double = 1.5
    static var defaultMaxSpeedUncertaintyFactor: Double = 2
    
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
        case maxVerticalUncertainty
        case maxSpeedUncertaintyFactor
    }

    var urlTemplate : String = osmUrl
    var followTrack : Bool = false
    var showTrackpoints : Bool = false
    
    var trackpointInterval: Double = defaultTrackpointInterval
    var maxHorizontalUncertainty: Double = defaultMaxHorizontalUncertainty
    var maxVerticalUncertainty: Double = defaultMaxVerticalUncertainty
    var maxSpeedUncertaintyFactor: Double = defaultMaxSpeedUncertaintyFactor
    
    init(){
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        urlTemplate = try values.decodeIfPresent(String.self, forKey: .urlTemplate) ?? Preferences.osmUrl
        followTrack = try values.decodeIfPresent(Bool.self, forKey: .followTrack) ?? false
        showTrackpoints = try values.decodeIfPresent(Bool.self, forKey: .showTrackpoints) ?? false
        trackpointInterval = try values.decodeIfPresent(Double.self, forKey: .trackpointInterval) ?? Preferences.defaultTrackpointInterval
        maxHorizontalUncertainty = try values.decodeIfPresent(Double.self, forKey: .maxHorizontalUncertainty) ?? Preferences.defaultMaxHorizontalUncertainty
        maxVerticalUncertainty = try values.decodeIfPresent(Double.self, forKey: .maxVerticalUncertainty) ?? Preferences.defaultMaxVerticalUncertainty
        maxSpeedUncertaintyFactor = try values.decodeIfPresent(Double.self, forKey: .maxSpeedUncertaintyFactor) ?? Preferences.defaultMaxSpeedUncertaintyFactor
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(urlTemplate, forKey: .urlTemplate)
        try container.encode(followTrack, forKey: .followTrack)
        try container.encode(showTrackpoints, forKey: .showTrackpoints)
        try container.encode(trackpointInterval, forKey: .trackpointInterval)
        try container.encode(maxHorizontalUncertainty, forKey: .maxHorizontalUncertainty)
        try container.encode(maxVerticalUncertainty, forKey: .maxVerticalUncertainty)
        try container.encode(maxSpeedUncertaintyFactor, forKey: .maxSpeedUncertaintyFactor)
    }
    
    func save(){
        DataController.shared.save(forKey: Preferences.storeKey, value: self)
    }
    
    
}
