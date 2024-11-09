/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation
import CloudKit

class Location : UUIDObject, Comparable{
    
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: Location, rhs: Location) -> Bool {
        AppState.shared.sortAscending ? lhs.creationDate < rhs.creationDate : lhs.creationDate > rhs.creationDate
    }
    
    static var recordMetaKeys = ["uuid"]
    static var recordDataKeys = ["uuid", "json"]
    
    private enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case altitude
        case creationDate
        case name
        case address
        case items
    }
    var coordinate: CLLocationCoordinate2D
    var altitude: Double
    var creationDate: Date
    var mapPoint: CGPoint
    var name : String = ""
    var address : String = ""
    var items : LocatedItemsList
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
                _coordinateRegion = coordinate.coordinateRegion(radiusMeters: Preferences.shared.maxLocationMergeDistance)
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
            let record = CKRecord(recordType: CKRecord.locationType, recordID: recordId)
            record["uuid"] = id.uuidString
            record["json"] = self.toJSON()
            return record
        }
    }
    
    init(coordinate: CLLocationCoordinate2D){
        items = LocatedItemsList()
        mapPoint = CGPoint(coordinate)
        self.coordinate = coordinate
        altitude = 0
        creationDate = Date.localDate
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
        creationDate = try values.decodeIfPresent(Date.self, forKey: .creationDate) ?? Date.localDate
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        address = try values.decodeIfPresent(String.self, forKey: .address) ?? ""
        self.items = try values.decodeIfPresent(Array<LocatedItemMetaData>.self, forKey: .items)?.toItemList() ?? LocatedItemsList()
        try super.init(from: decoder)
        for item in items{
            item.location = self
        }
        items.sort()
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
        var metaList = Array<LocatedItemMetaData>()
        metaList.loadItemList(items: self.items)
        try container.encode(metaList, forKey: .items)
    }
    
    func assertPlacemark(){
        if name.isEmpty || address.isEmpty{
            evaluatePlacemark()
        }
    }
    
    func evaluatePlacemark(){
        //print("getting placemark for \(name)")
        CLPlacemark.getPlacemark(for: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)){ result in
            if let placemark = result{
                self.name = placemark.nameString ?? ""
                //Log.debug("name is \(self.name)")
                self.address = placemark.locationString
                AppData.shared.save()
            }
            else{
                Log.error("no placemark result for \(self.name)")
            }
        }
    }
    
    func resetCoordinateRegion(){
        _coordinateRegion = nil
    }
    
    func item(at idx: Int) -> LocatedItem{
        items[idx]
    }
    
    func selectAllItems(){
        items.selectAll()
    }
    
    func deselectAllItems(){
        items.deselectAll()
    }
    
    func addItem(item: LocatedItem){
        if !items.containsEqual(item){
            item.location = self
            items.append(item)
        }
    }
    
    func getItem(id: UUID) -> LocatedItem?{
        items.first(where:{
            $0.id == id
        })
    }
    
    func deleteItem(item: LocatedItem){
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
    
    func mergeLocation(from sourceLocation: Location){
        for sourceItem in sourceLocation.items{
            if !items.containsEqual(sourceItem){
                items.append(sourceItem)
            }
        }
        items.sort()
    }
    
}

