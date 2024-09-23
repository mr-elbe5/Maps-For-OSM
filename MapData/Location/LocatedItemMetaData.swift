/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

open class LocatedItemMetaData : Identifiable, Codable{
    
    private enum CodingKeys: CodingKey{
        case type
        case data
    }
    
    public var type : LocatedItemType
    public var data : LocatedItem
    
    public init(item: LocatedItem){
        self.type = item.type
        self.data = item
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decode(LocatedItemType.self, forKey: .type)
        switch type{
        case .audio:
            data = try values.decode(AudioItem.self, forKey: .data)
        case .image:
            data = try values.decode(ImageItem.self, forKey: .data)
        case .video:
            data = try values.decode(VideoItem.self, forKey: .data)
        case .track:
            data = try values.decode(TrackItem.self, forKey: .data)
        case .note:
            data = try values.decode(NoteItem.self, forKey: .data)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(data, forKey: .data)
    }
    
}

extension Array<LocatedItemMetaData>{
    
    public mutating func loadItemList(items: LocatedItemsList){
        removeAll()
        for i in 0..<items.count{
            append(LocatedItemMetaData(item: items[i]))
        }
    }
    
    public func toItemList() -> LocatedItemsList{
        var items = LocatedItemsList()
        for metaItem in self{
            items.append(metaItem.data)
        }
        return items
    }
    
}
