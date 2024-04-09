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
    
    //runtime
    var place: Place!
    
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

extension Array<PlaceItem>{
    
    mutating func remove(_ item: PlaceItem){
        for idx in 0..<self.count{
            if self[idx] == item{
                item.prepareDelete()
                self.remove(at: idx)
                return
            }
        }
    }
    
    func contains(_ item: PlaceItem) -> Bool{
        for idx in 0..<self.count{
            if self[idx] == item{
                return true
            }
        }
        return false
    }
    
    mutating func removeAllItems(){
        for item in self{
            item.prepareDelete()
        }
        self.removeAll()
    }
    
    mutating func sortByCreation(){
        self.sort(by: {
            $0.creationDate > $1.creationDate
        })
    }
    
    var allSelected: Bool{
        get{
            for item in self{
                if !item.selected{
                    return false
                }
            }
            return true
        }
    }
    
    var allUnselected: Bool{
        get{
            for item in self{
                if item.selected{
                    return false
                }
            }
            return true
        }
    }
    
    mutating func selectAll(){
        for item in self{
            item.selected = true
        }
    }
    
    mutating func deselectAll(){
        for item in self{
            item.selected = false
        }
    }
    
}

extension Array<PlaceItemMetaData>{
    
    mutating func loadItemList(items: Array<PlaceItem>){
        removeAll()
        for i in 0..<items.count{
            append(PlaceItemMetaData(item: items[i]))
        }
    }
    
    func toItemList() -> Array<PlaceItem>{
        var items = Array<PlaceItem>()
        for metaItem in self{
            items.append(metaItem.data)
        }
        return items
    }
    
}

class PlaceItemMetaData : Identifiable, Codable{
    
    private enum CodingKeys: CodingKey{
        case type
        case data
    }
    
    var type : PlaceItemType
    var data : PlaceItem
    
    init(item: PlaceItem){
        self.type = item.type
        self.data = item
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decode(PlaceItemType.self, forKey: .type)
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(data, forKey: .data)
    }
    
}


