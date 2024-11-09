/*
 E5Data
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

class IdObject : Identifiable, Codable, Selectable{
    
    static func == (lhs: IdObject, rhs: IdObject) -> Bool {
        lhs.equals(rhs)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
    }
    
    var id : Int
    var selected = false
    
    init(){
        id = IdProvider.shared.nextId
    }
    
    required init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
    }
    
    func equals(_ obj: IdObject) -> Bool{
        self.id == obj.id
    }
    
}
