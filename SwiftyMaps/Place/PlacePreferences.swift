/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import AVKit
import CoreLocation

class PlacePreferences: Identifiable, Codable{
    
    static var storeKey = "placePreferences"
    
    static var instance = PlacePreferences()
    
    static var defaultMinLocationAccuracy : CLLocationDistance = 5.0
    static var defaultMaxLocationMergeDistance : CLLocationDistance = 10.0
    
    static func loadInstance(){
        if let prefs : PlacePreferences = DataController.shared.load(forKey: PlacePreferences.storeKey){
            instance = prefs
        }
        else{
            instance = PlacePreferences()
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case minLocationAcciuracy
        case maxLocationMergeDistance
    }

    var minLocationAcciuracy : CLLocationDistance = defaultMinLocationAccuracy
    var maxLocationMergeDistance : CLLocationDistance = defaultMaxLocationMergeDistance
    
    init(){
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        minLocationAcciuracy = try values.decodeIfPresent(CLLocationDistance.self, forKey: .minLocationAcciuracy) ?? PlacePreferences.defaultMinLocationAccuracy
        maxLocationMergeDistance = try values.decodeIfPresent(CLLocationDistance.self, forKey: .maxLocationMergeDistance) ?? PlacePreferences.defaultMaxLocationMergeDistance
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(minLocationAcciuracy, forKey: .minLocationAcciuracy)
        try container.encode(maxLocationMergeDistance, forKey: .maxLocationMergeDistance)
    }
    
    func save(){
        DataController.shared.save(forKey: PlacePreferences.storeKey, value: self)
    }
    
    
}
