/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation
import CloudKit
import CommonBasics

class Place : Selectable, Comparable{
    
    static func < (lhs: Place, rhs: Place) -> Bool {
        AppState.shared.sortAscending ? lhs.creationDate < rhs.creationDate : lhs.creationDate > rhs.creationDate
    }
    
    static var recordMetaKeys = ["uuid"]
    static var recordDataKeys = ["uuid", "json"]
    
    private enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case altitude
        case creationDate
        case timestamp //deprecated
        case name
        case address
        case note //deprecated
        case media //deprecated
        case items
    }
    var coordinate: CLLocationCoordinate2D
    var altitude: Double
    var creationDate: Date
    var mapPoint: CGPoint
    var name : String = ""
    var address : String = ""
    //deprecated
    var note : String? = nil
    var items : PlaceItemList
    var _coordinateRegion: CoordinateRegion? = nil
    
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
    
    var tracks: TrackList{
        items.filter({
            $0.type == .track
        }) as! Array<TrackItem>
    }
    
    var images: ImageList{
        items.filter({
            $0.type == .image
        }) as! Array<ImageItem>
    }
    
    var notes: Array<NoteItem>{
        items.filter({
            $0.type == .note
        }) as! Array<NoteItem>
    }
    
    var fileItems : FileItemList{
        items.filter({
            $0 is FileItem
        }) as! FileItemList
    }
    
    var coordinateRegion: CoordinateRegion{
        get{
            if _coordinateRegion == nil{
                _coordinateRegion = coordinate.coordinateRegion(radiusMeters: Preferences.shared.maxPlaceMergeDistance)
            }
            return _coordinateRegion!
        }
    }
    
    var recordId : CKRecord.ID{
        get{
            CKRecord.ID(recordName: id.uuidString)
        }
    }
    
    var dataRecord: CKRecord{
        get{
            let record = CKRecord(recordType: CKRecord.placeType, recordID: recordId)
            record["uuid"] = id.uuidString
            record["json"] = self.toJSON()
            return record
        }
    }
    
    init(coordinate: CLLocationCoordinate2D){
        items = PlaceItemList()
        mapPoint = CGPoint(coordinate)
        self.coordinate = coordinate
        altitude = 0
        creationDate = Date()
        super.init()
        evaluatePlacemark()
    }
    
    required init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? 0
        let longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? 0
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapPoint = CGPoint(coordinate)
        altitude = try values.decodeIfPresent(CLLocationDistance.self, forKey: .altitude) ?? 0
        creationDate = try values.decodeIfPresent(Date.self, forKeys: [.creationDate, .timestamp]) ?? Date.localDate
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        address = try values.decodeIfPresent(String.self, forKey: .address) ?? ""
        self.items = try values.decodeIfPresent(Array<PlaceItemMetaData>.self, forKeys: [.items, .media])?.toItemList() ?? PlaceItemList()
        //deprecated
        note = try values.decodeIfPresent(String.self, forKey: .note)
        try super.init(from: decoder)
        for item in items{
            item.place = self
        }
        items.sort()
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
        try container.encode(creationDate, forKey: .creationDate)
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
        if !items.containsEqual(item){
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
        items.sort()
    }
    
    func mergePlace(from sourcePlace: Place){
        for sourceItem in sourcePlace.items{
            if !items.containsEqual(sourceItem){
                items.append(sourceItem)
            }
        }
        items.sort()
    }
    
}

protocol PlaceDelegate{
    func placeChanged(place: Place)
    func placesChanged()
    func showPlaceOnMap(place: Place)
}
