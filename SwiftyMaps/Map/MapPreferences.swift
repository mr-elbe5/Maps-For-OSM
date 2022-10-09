/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import AVKit
import CoreLocation

class MapPreferences: Identifiable, Codable{
    
    static var storeKey = "mapPreferences"
    
    static var instance = MapPreferences()
    
    static var elbe5Url = "https://maps.elbe5.de/carto/{z}/{x}/{y}.png"
    static var elbe5TopoUrl = "https://maps.elbe5.de/topo/{z}/{x}/{y}.png"
    static var osmUrl = "https://tile.openstreetmap.org/{z}/{x}/{y}.png"
    
    static func loadInstance(){
        if let prefs : MapPreferences = DataController.shared.load(forKey: MapPreferences.storeKey){
            instance = prefs
        }
        else{
            instance = MapPreferences()
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case urlTemplate
    }

    var urlTemplate : String = elbe5Url
    
    init(){
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        urlTemplate = try values.decodeIfPresent(String.self, forKey: .urlTemplate) ?? MapPreferences.elbe5Url
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(urlTemplate, forKey: .urlTemplate)
    }
    
    func save(){
        DataController.shared.save(forKey: MapPreferences.storeKey, value: self)
    }
    
    
}
