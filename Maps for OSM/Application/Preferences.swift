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
    static var openTopoUrl = "https://a.tile.opentopomap.org/{z}/{x}/{y}.png"
    
    static var defaultMinLocationAccuracy : CLLocationDistance = 5.0
    static var defaultMaxLocationMergeDistance : CLLocationDistance = 10.0
    
    static var defaultMinTrackingDistance : CGFloat = 5 // [m]
    static var defaultMinTrackingInterval : CGFloat = 5 // [sec]
    
    static func loadInstance(){
        if let prefs : Preferences = DataController.shared.load(forKey: Preferences.storeKey){
            shared = prefs
        }
        else{
            shared = Preferences()
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case cartoUrlTemplate
        case topoUrlTemplate
        
        case minLocationAccuracy
        case maxLocationMergeDistance
        
        case minTrackingDistance
        case minTrackingInterval
    }

    var cartoUrlTemplate : String = elbe5Url
    var topoUrlTemplate : String = elbe5TopoUrl
    
    var minLocationAccuracy : CLLocationDistance = defaultMinLocationAccuracy
    var maxLocationMergeDistance : CLLocationDistance = defaultMaxLocationMergeDistance
    
    var minTrackingDistance : CGFloat = Preferences.defaultMinTrackingDistance
    var minTrackingInterval : CGFloat = Preferences.defaultMinTrackingInterval
    
    init(){
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        cartoUrlTemplate = try values.decodeIfPresent(String.self, forKey: .cartoUrlTemplate) ?? Preferences.elbe5Url
        topoUrlTemplate = try values.decodeIfPresent(String.self, forKey: .topoUrlTemplate) ?? Preferences.elbe5TopoUrl
        
        minLocationAccuracy = try values.decodeIfPresent(CLLocationDistance.self, forKey: .minLocationAccuracy) ?? Preferences.defaultMinLocationAccuracy
        maxLocationMergeDistance = try values.decodeIfPresent(CLLocationDistance.self, forKey: .maxLocationMergeDistance) ?? Preferences.defaultMaxLocationMergeDistance
        
        minTrackingDistance = try values.decodeIfPresent(CLLocationDistance.self, forKey: .minTrackingDistance) ?? Preferences.defaultMinTrackingDistance
        minTrackingInterval = try values.decodeIfPresent(CLLocationDistance.self, forKey: .minTrackingInterval) ?? Preferences.defaultMinTrackingInterval
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cartoUrlTemplate, forKey: .cartoUrlTemplate)
        try container.encode(topoUrlTemplate, forKey: .topoUrlTemplate)
        
        try container.encode(minLocationAccuracy, forKey: .minLocationAccuracy)
        try container.encode(maxLocationMergeDistance, forKey: .maxLocationMergeDistance)
        
        try container.encode(minTrackingDistance, forKey: .minTrackingDistance)
        try container.encode(minTrackingInterval, forKey: .minTrackingInterval)
    }
    
    func save(){
        DataController.shared.save(forKey: Preferences.storeKey, value: self)
    }
    
    
}
