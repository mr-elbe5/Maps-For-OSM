/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import UIKit

class Place : Selectable{
    
    private enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case altitude
        case timestamp
        case name
        case address
        case note //deprecated
        case media //deprecated
        case items
    }
    var coordinate: CLLocationCoordinate2D
    var altitude: Double
    var timestamp: Date
    var mapPoint: MapPoint
    var coordinateRegion: CoordinateRegion
    var name : String = ""
    var address : String = ""
    //deprecated
    var note : String = ""
    private var items : PlaceItemList
    
    var itemCount: Int{
        items.count
    }
    
    var imageCount: Int{
        var count = 0
        for item in items{
            if item.type == .image{
                count += 1
            }
        }
        return count
    }
    
    var hasItems : Bool{
        !items.isEmpty
    }
    
    var allItems: PlaceItemList{
        items
    }
    
    var allItemsSelected: Bool{
        items.allSelected
    }
    
    var hasMedia : Bool{
        for item in items{
            if [.image, .video, .audio].contains(item.type){
                return true
            }
        }
        return false
    }
    
    var hasTrack : Bool{
        for item in items{
            if item.type == .track{
                return true
            }
        }
        return false
    }
    
    var tracks: TrackList{
        var list = TrackList()
        for item in items{
            if item.type == .track, let track = item as? TrackItem{
                list.append(track)
            }
        }
        return list
    }
    
    var notes: Array<NoteItem>{
        var list = Array<NoteItem>()
        for item in items{
            if item.type == .note, let note = item as? NoteItem{
                list.append(note)
            }
        }
        return list
    }
    
    var media : PlaceItemList{
        var list = PlaceItemList()
        for item in items{
            if [.image, .video, .audio].contains(item.type){
                list.append(item)
            }
        }
        return list
    }
    
    init(coordinate: CLLocationCoordinate2D){
        items = PlaceItemList()
        mapPoint = MapPoint(coordinate)
        coordinateRegion = coordinate.coordinateRegion(radiusMeters: Preferences.maxPlaceMergeDistance)
        self.coordinate = coordinate
        altitude = 0
        timestamp = Date()
        super.init()
        evaluatePlacemark()
    }
    
    required init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? 0
        let longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? 0
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapPoint = MapPoint(coordinate)
        coordinateRegion = coordinate.coordinateRegion(radiusMeters: Preferences.maxPlaceMergeDistance)
        altitude = try values.decodeIfPresent(CLLocationDistance.self, forKey: .altitude) ?? 0
        timestamp = try values.decodeIfPresent(Date.self, forKey: .timestamp) ?? Date()
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        address = try values.decodeIfPresent(String.self, forKey: .address) ?? ""
        //deprecated
        note = try values.decodeIfPresent(String.self, forKey: .note) ?? ""
        var metaItems = try values.decodeIfPresent(PlaceMetaItemList.self, forKey: .items)
        if metaItems == nil{
            Log.warn("key items not found - trying key media")
            metaItems = try values.decodeIfPresent(PlaceMetaItemList.self, forKey: .media)
        }
        self.items = metaItems?.toItemList() ?? PlaceItemList()
        super.init()
        for item in items{
            item.place = self
        }
        items.sortByCreation()
        if name.isEmpty || address.isEmpty{
            evaluatePlacemark()
        }
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(altitude, forKey: .altitude)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(name, forKey: .name)
        try container.encode(address, forKey: .address)
        var metaList = PlaceMetaItemList()
        metaList.loadItemList(items: self.items)
        try container.encode(metaList, forKey: .items)
    }
    
    func evaluatePlacemark(){
        LocationService.shared.getPlacemark(for: self){ result in
            if let placemark = result{
                if self.name.isEmpty, let name = placemark.name{
                    self.name = name
                }
                if self.address.isEmpty{
                    self.address = "\(placemark.thoroughfare ?? "") \(placemark.subThoroughfare ?? "")\n\(placemark.postalCode ?? "") \(placemark.locality ?? "")\n\(placemark.country ?? "")"
                }
            }
        }
        
    }
    
    func item(at idx: Int) -> PlaceItem{
        items[idx]
    }
    
    func selectAllItems(){
        items.selectAll()
    }
    
    func deselectAllItems(){
        items.deselectAll()
    }
    
    func addItem(item: PlaceItem){
        if !items.contains(item){
            item.place = self
            items.append(item)
        }
    }
    
    func deleteItem(item: PlaceItem){
        item.prepareDelete()
        items.remove(item)
    }
    
    func deleteAllItems(){
        for item in items{
            item.prepareDelete()
        }
        items.removeAllItems()
    }
    
    func sortItems(){
        items.sortByCreation()
    }
    
}
