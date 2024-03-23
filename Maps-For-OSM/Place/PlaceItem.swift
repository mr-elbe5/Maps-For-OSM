/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

enum PlaceItemType: String, Codable{
    case audio
    case image
    case video
    case track
    case note
}

class PlaceItem : Selectable{
    
    private enum CodingKeys: String, CodingKey {
        case creationDate
    }
    
    var creationDate : Date
    var type: PlaceItemType{
        get{
            fatalError("not implemented")
        }
    }
    
    override init(){
        creationDate = Date()
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        creationDate = try values.decodeIfPresent(Date.self, forKey: .creationDate) ?? Date()
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(creationDate, forKey: .creationDate)
    }
    
    func prepareDelete(){
    }
    
}

