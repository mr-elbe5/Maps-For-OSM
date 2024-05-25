/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import E5Data

enum PlaceItemType: String, Codable{
    case audio
    case image
    case video
    case track
    case note
}

class PlaceItem : UUIDObject, Comparable{

    static func == (lhs: PlaceItem, rhs: PlaceItem) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: PlaceItem, rhs: PlaceItem) -> Bool {
        AppState.shared.sortAscending ? lhs.creationDate < rhs.creationDate : lhs.creationDate > rhs.creationDate
    }
    
    private enum CodingKeys: String, CodingKey {
        case creationDate
    }
    
    var creationDate : Date
    var type: PlaceItemType{
        get{
            fatalError("not implemented")
        }
    }
    
    //runtime
    var place: Place!
    
    override init(){
        creationDate = Date.localDate
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        creationDate = try values.decodeIfPresent(Date.self, forKey: .creationDate) ?? Date.localDate
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
