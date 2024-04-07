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
    private var items : Array<PlaceItem>
    
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
    
    var allItems: Array<PlaceItem>{
        items
    }
    
    var allItemsSelected: Bool{
        items.allSelected
    }
    
    var hasMedia : Bool{
        items.first(where: {
            [.image, .video, .audio].contains($0.type)
        }) != nil
    }
    
    var hasTrack : Bool{
        items.first(where: {
            $0.type == .track
        }) != nil
    }
    
    var hasNote : Bool{
        items.first(where: {
            $0.type == .note
        }) != nil
    }
    
    var tracks: Array<Track>{
        items.filter({
            $0.type == .track
        }) as! Array<Track>
    }
    
    var images: Array<Image>{
        items.filter({
            $0.type == .image
        }) as! Array<Image>
    }
    
    var notes: Array<Note>{
        items.filter({
            $0.type == .note
        }) as! Array<Note>
    }
    
    var media : Array<MediaItem>{
        items.filter({
            [.image, .video, .audio].contains($0.type)
        }) as! Array<MediaItem>
    }
    
    init(coordinate: CLLocationCoordinate2D){
        items = Array<PlaceItem>()
        mapPoint = MapPoint(coordinate)
        coordinateRegion = coordinate.coordinateRegion(radiusMeters: Preferences.shared.maxPlaceMergeDistance)
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
        coordinateRegion = coordinate.coordinateRegion(radiusMeters: Preferences.shared.maxPlaceMergeDistance)
        altitude = try values.decodeIfPresent(CLLocationDistance.self, forKey: .altitude) ?? 0
        timestamp = try values.decodeIfPresent(Date.self, forKey: .timestamp) ?? Date()
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        address = try values.decodeIfPresent(String.self, forKey: .address) ?? ""
        //deprecated
        note = try values.decodeIfPresent(String.self, forKey: .note) ?? ""
        var metaItems = try values.decodeIfPresent(Array<PlaceItemMetaData>.self, forKey: .items)
        if metaItems == nil{
            Log.warn("key items not found - trying key media")
            metaItems = try values.decodeIfPresent(Array<PlaceItemMetaData>.self, forKey: .media)
        }
        self.items = metaItems?.toItemList() ?? Array<PlaceItem>()
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
        var metaList = Array<PlaceItemMetaData>()
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

protocol PlaceDelegate{
    func placeChanged(place: Place)
    func placesChanged()
    func showPlaceOnMap(place: Place)
    func viewTrackItem(item: Track)
    func showTrackItemOnMap(item: Track)
}
