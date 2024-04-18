/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

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
    var name : String = ""
    var address : String = ""
    //deprecated
    var note : String? = nil
    private var items : Array<PlaceItem>
    private var _coordinateRegion: CoordinateRegion? = nil
    
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
    
    var tracks: Array<TrackItem>{
        items.filter({
            $0.type == .track
        }) as! Array<TrackItem>
    }
    
    var images: Array<ImageItem>{
        items.filter({
            $0.type == .image
        }) as! Array<ImageItem>
    }
    
    var notes: Array<NoteItem>{
        items.filter({
            $0.type == .note
        }) as! Array<NoteItem>
    }
    
    var media : Array<FileItem>{
        items.filter({
            [.image, .video, .audio].contains($0.type)
        }) as! Array<FileItem>
    }
    
    var coordinateRegion: CoordinateRegion{
        get{
            if _coordinateRegion == nil{
                _coordinateRegion = coordinate.coordinateRegion(radiusMeters: Preferences.shared.maxPlaceMergeDistance)
            }
            return _coordinateRegion!
        }
    }
    
    init(coordinate: CLLocationCoordinate2D){
        items = Array<PlaceItem>()
        mapPoint = MapPoint(coordinate)
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
        altitude = try values.decodeIfPresent(CLLocationDistance.self, forKey: .altitude) ?? 0
        timestamp = try values.decodeIfPresent(Date.self, forKey: .timestamp) ?? Date()
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        address = try values.decodeIfPresent(String.self, forKey: .address) ?? ""
        //deprecated
        note = try values.decodeIfPresent(String.self, forKey: .note)
        var metaItems = try values.decodeIfPresent(Array<PlaceItemMetaData>.self, forKey: .items)
        if metaItems == nil{
            Log.warn("key items not found - trying key media")
            metaItems = try values.decodeIfPresent(Array<PlaceItemMetaData>.self, forKey: .media)
        }
        self.items = metaItems?.toItemList() ?? Array<PlaceItem>()
        try super.init(from: decoder)
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
        PlacemarkService.shared.getPlacemark(for: self){ result in
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
    
    func resetCoordinateRegion(){
        _coordinateRegion = nil
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
    
    func getItem(id: UUID) -> PlaceItem?{
        items.first(where:{
            $0.id == id
        })
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
    
    func mergePlace(from sourcePlace: Place){
        if coordinate != sourcePlace.coordinate{
            Log.warn("coordinates dont match for \(id)")
        }
        for sourceItem in sourcePlace.items{
            var found = false
            for targetItem in items{
                if sourceItem == targetItem{
                    targetItem.mergeItem(from: sourceItem)
                    Log.debug("item found: \(targetItem.id)")
                    found = true
                    break
                }
            }
            if !found{
                items.append(sourceItem)
            }
        }
        for targetItem in items{
            var found = false
            for sourceItem in sourcePlace.items{
                if sourceItem == targetItem{
                    found = true
                    break
                }
            }
            if !found{
                Log.warn("item not found in source place: \(targetItem.id)")
            }
        }
        items.sortByCreation()
    }
    
}

protocol PlaceDelegate{
    func placeChanged(place: Place)
    func placesChanged()
    func showPlaceOnMap(place: Place)
}
