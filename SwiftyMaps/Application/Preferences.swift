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
    
    static var defaultMinTrackpointTimeDelta: Double = 5
    static var defaultMinTrackpointHorizontalDelta: Double = 5
    static var defaultMinTrackpointVerticalDelta: Double = 2
    static var defaultMaxDeviationFactor: Double = 3
    
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
        case minTrackpointTimeDelta
        case minTrackpointHorizontalDelta
        case minTrackpointVerticalDelta
        case maxDeviationFactor
    }

    var urlTemplate : String = osmUrl
    var followTrack : Bool = false
    var showTrackpoints : Bool = false
    
    var minTrackpointTimeDelta: Double = defaultMinTrackpointTimeDelta
    var minTrackpointHorizontalDelta: Double = defaultMinTrackpointHorizontalDelta
    var minTrackpointVerticalDelta: Double = defaultMinTrackpointVerticalDelta
    var maxDeviationFactor: Double = defaultMaxDeviationFactor
    
    init(){
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        urlTemplate = try values.decodeIfPresent(String.self, forKey: .urlTemplate) ?? Preferences.osmUrl
        followTrack = try values.decodeIfPresent(Bool.self, forKey: .followTrack) ?? false
        showTrackpoints = try values.decodeIfPresent(Bool.self, forKey: .showTrackpoints) ?? false
        minTrackpointTimeDelta = try values.decodeIfPresent(Double.self, forKey: .minTrackpointTimeDelta) ?? Preferences.defaultMinTrackpointTimeDelta
        minTrackpointHorizontalDelta = try values.decodeIfPresent(Double.self, forKey: .minTrackpointHorizontalDelta) ?? Preferences.defaultMinTrackpointHorizontalDelta
        minTrackpointVerticalDelta = try values.decodeIfPresent(Double.self, forKey: .minTrackpointVerticalDelta) ?? Preferences.defaultMinTrackpointVerticalDelta
        maxDeviationFactor = try values.decodeIfPresent(Double.self, forKey: .maxDeviationFactor) ?? Preferences.defaultMaxDeviationFactor
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(urlTemplate, forKey: .urlTemplate)
        try container.encode(followTrack, forKey: .followTrack)
        try container.encode(showTrackpoints, forKey: .showTrackpoints)
        try container.encode(minTrackpointTimeDelta, forKey: .minTrackpointTimeDelta)
        try container.encode(minTrackpointHorizontalDelta, forKey: .minTrackpointHorizontalDelta)
        try container.encode(minTrackpointVerticalDelta, forKey: .minTrackpointVerticalDelta)
        try container.encode(maxDeviationFactor, forKey: .maxDeviationFactor)
    }
    
    func save(){
        DataController.shared.save(forKey: Preferences.storeKey, value: self)
    }
    
    
}
