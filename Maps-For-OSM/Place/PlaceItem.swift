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
}

class PlaceItem : NSObject, Codable, Identifiable{
    
    static func == (lhs: PlaceItem, rhs: PlaceItem) -> Bool {
        lhs.id == rhs.id
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
    }
    
    var id : UUID
    var type: PlaceItemType{
        get{
            fatalError("not implemented")
        }
    }
    
    override init(){
        id = UUID()
    }
    
    required init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        super.init()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
    }
    
    func prepareDelete(){
    }
    
}

