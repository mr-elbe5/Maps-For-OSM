/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

class IdObject : NSObject, Identifiable, Codable{
    
    static func == (lhs: IdObject, rhs: IdObject) -> Bool {
        lhs.equals(rhs)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
    }
    
    var id : UUID
    
    override init(){
        id = UUID()
    }
    
    required init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
    }
    
    func equals(_ obj: IdObject) -> Bool{
        self.id == obj.id
    }
    
}
