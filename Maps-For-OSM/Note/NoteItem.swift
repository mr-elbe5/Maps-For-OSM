/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

class NoteItem : PlaceItem{
    
    private enum CodingKeys: CodingKey{
        case note
    }
    
    override var type : PlaceItemType{
        .note
    }
    
    var note: String
    
    override init(){
        note = ""
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        note = try values.decode(String.self, forKey: .note)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(note, forKey: .note)
    }
    
}
