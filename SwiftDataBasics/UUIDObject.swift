/*
 E5Data
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

class UUIDObject : Identifiable, Codable, Selectable{
    
    static func == (lhs: UUIDObject, rhs: UUIDObject) -> Bool {
        lhs.equals(rhs)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
    }
    
    var id : UUID
    
    //runtime
    var selected = false
    
    init(){
        id = UUID()
        selected = false
    }
    
    required init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
    }
    
    func equals(_ obj: UUIDObject) -> Bool{
        self.id == obj.id
    }
    
}
