/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import AVKit
import CoreLocation

class TileSources: Identifiable, Codable{
    
    static var storeKey = "tileSources"
    
    static var instance = TileSources()
    
    static var elbe5Url = "https://maps.elbe5.de/carto/{z}/{x}/{y}.png"
    static var elbe5TopoUrl = "https://maps.elbe5.de/topo/{z}/{x}/{y}.png"
    static var osmUrl = "https://tile.openstreetmap.org/{z}/{x}/{y}.png"
    static var openTopoUrl = "https://a.tile.opentopomap.org/{z}/{x}/{y}.png"
    
    static func loadInstance(){
        if let prefs : TileSources = DataController.shared.load(forKey: TileSources.storeKey){
            instance = prefs
        }
        else{
            instance = TileSources()
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case cartoUrlTemplate
        case topoUrlTemplate
    }

    var cartoUrlTemplate : String = elbe5Url
    var topoUrlTemplate : String = elbe5TopoUrl
    
    init(){
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        cartoUrlTemplate = try values.decodeIfPresent(String.self, forKey: .cartoUrlTemplate) ?? TileSources.elbe5Url
        topoUrlTemplate = try values.decodeIfPresent(String.self, forKey: .topoUrlTemplate) ?? TileSources.elbe5TopoUrl
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cartoUrlTemplate, forKey: .cartoUrlTemplate)
        try container.encode(topoUrlTemplate, forKey: .topoUrlTemplate)
    }
    
    func save(){
        DataController.shared.save(forKey: TileSources.storeKey, value: self)
    }
    
    
}
