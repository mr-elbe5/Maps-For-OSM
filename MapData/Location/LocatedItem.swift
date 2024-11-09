/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

enum LocatedItemType: String, Codable{
    case audio
    case image
    case video
    case track
    case note
}

class LocatedItem : UUIDObject, Comparable{

    static func == (lhs: LocatedItem, rhs: LocatedItem) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: LocatedItem, rhs: LocatedItem) -> Bool {
        AppState.shared.sortAscending ? lhs.creationDate < rhs.creationDate : lhs.creationDate > rhs.creationDate
    }
    
    private enum CodingKeys: String, CodingKey {
        case creationDate
    }
    
    var creationDate : Date
    var type: LocatedItemType{
        get{
            fatalError("not implemented")
        }
    }
    
    //runtime
    var location: Location!
    
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
