/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation
import CloudKit
import E5Data

open class Location : UUIDObject, Comparable{
    
    public static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
    
    public static func < (lhs: Location, rhs: Location) -> Bool {
        AppState.shared.sortAscending ? lhs.creationDate < rhs.creationDate : lhs.creationDate > rhs.creationDate
    }
    
    public static var recordMetaKeys = ["uuid"]
    public static var recordDataKeys = ["uuid", "json"]
    
    private enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case altitude
        case creationDate
        case name
        case address
        case items
    }
    public var coordinate: CLLocationCoordinate2D
    public var altitude: Double
    public var creationDate: Date
    public var mapPoint: CGPoint
    public var name : String = ""
    public var address : String = ""
    public var items : LocatedItemsList
    public var _coordinateRegion: CoordinateRegion? = nil
    
    public var itemCount: Int{
        items.count
    }
    
    public var imageCount: Int{
        var count = 0
        for item in items{
            if item.type == .image{
                count += 1
            }
        }
        return count
    }
    
    public var hasItems : Bool{
        !items.isEmpty
    }
    
    public var allItemsSelected: Bool{
        items.allSelected
    }
    
    public var hasMedia : Bool{
        items.first(where: {
            [.image, .video, .audio].contains($0.type)
        }) != nil
    }
    
    public var hasTrack : Bool{
        items.first(where: {
            $0.type == .track
        }) != nil
    }
    
    public var hasNote : Bool{
        items.first(where: {
            $0.type == .note
        }) != nil
    }
    
    public var tracks: TrackList{
        items.filter({
            $0.type == .track
        }) as! Array<Track>
    }
    
    public var images: ImageList{
        items.filter({
            $0.type == .image
        }) as! Array<Image>
    }
    
    public var notes: Array<Note>{
        items.filter({
            $0.type == .note
        }) as! Array<Note>
    }
    
    public var fileItems : FileItemList{
        items.filter({
            $0 is FileItem
        }) as! FileItemList
    }
    
    public var coordinateRegion: CoordinateRegion{
        get{
            if _coordinateRegion == nil{
                _coordinateRegion = coordinate.coordinateRegion(radiusMeters: Preferences.shared.maxLocationMergeDistance)
            }
            return _coordinateRegion!
        }
    }
    
    public var recordId : CKRecord.ID{
        get{
            CKRecord.ID(recordName: id.uuidString)
        }
    }
    
    public var dataRecord: CKRecord{
        get{
            let record = CKRecord(recordType: CKRecord.locationType, recordID: recordId)
            record["uuid"] = id.uuidString
            record["json"] = self.toJSON()
            return record
        }
    }
    
    public init(coordinate: CLLocationCoordinate2D){
        items = LocatedItemsList()
        mapPoint = CGPoint(coordinate)
        self.coordinate = coordinate
        altitude = 0
        creationDate = Date.localDate
        super.init()
        evaluatePlacemark()
    }
    
    required public init(from decoder: Decoder) throws {
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
    
    override public func encode(to encoder: Encoder) throws {
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
    
    public func assertPlacemark(){
        if name.isEmpty || address.isEmpty{
            evaluatePlacemark()
        }
    }
    
    public func evaluatePlacemark(){
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
    
    public func resetCoordinateRegion(){
        _coordinateRegion = nil
    }
    
    public func item(at idx: Int) -> LocatedItem{
        items[idx]
    }
    
    public func selectAllItems(){
        items.selectAll()
    }
    
    public func deselectAllItems(){
        items.deselectAll()
    }
    
    public func addItem(item: LocatedItem){
        if !items.containsEqual(item){
            item.location = self
            items.append(item)
        }
    }
    
    public func getItem(id: UUID) -> LocatedItem?{
        items.first(where:{
            $0.id == id
        })
    }
    
    public func deleteItem(item: LocatedItem){
        item.prepareDelete()
        items.remove(item)
    }
    
    public func deleteAllItems(){
        for item in items{
            item.prepareDelete()
        }
        items.removeAllItems()
    }
    
    public func sortItems(){
        items.sort()
    }
    
    public func mergeLocation(from sourceLocation: Location){
        for sourceItem in sourceLocation.items{
            if !items.containsEqual(sourceItem){
                items.append(sourceItem)
            }
        }
        items.sort()
    }
    
}

