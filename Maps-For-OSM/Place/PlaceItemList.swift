/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

typealias PlaceItemList = Array<PlaceItemListItem>
    
extension PlaceItemList{
    
    mutating func append(_ item: PlaceItemData){
        let listItem = PlaceItemListItem(item: item)
        append(listItem)
    }
    
    mutating func remove(_ item: PlaceItemData){
        for idx in 0..<self.count{
            if self[idx].data == item{
                item.deleteResources()
                self.remove(at: idx)
                return
            }
        }
    }
    
    func contains(_ item: PlaceItemData) -> Bool{
        for idx in 0..<self.count{
            if self[idx].data == item{
                return true
            }
        }
        return false
    }
    
    mutating func removeAllItems(){
        for listItem in self{
            listItem.data.deleteResources()
        }
        removeAll()
    }
    
}

class PlaceItemListItem : Identifiable, Codable{
    
    private enum CodingKeys: CodingKey{
        case type
        case data
    }
    
    var type : PlaceItemType
    var data : PlaceItemData
    
    init(item: PlaceItemData){
        self.type = item.type
        self.data = item
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decode(PlaceItemType.self, forKey: .type)
        switch type{
        case .audio:
            data = try values.decode(AudioData.self, forKey: .data)
        case .image:
            data = try values.decode(ImageData.self, forKey: .data)
        case .video:
            data = try values.decode(VideoData.self, forKey: .data)
        case .track:
            data = try values.decode(TrackData.self, forKey: .data)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(data, forKey: .data)
    }
    
}

