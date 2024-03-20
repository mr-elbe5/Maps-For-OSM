/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import UIKit

class Place : NSObject, Codable, Identifiable{
    
    static func == (lhs: Place, rhs: Place) -> Bool {
        lhs.id == rhs.id
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case latitude
        case longitude
        case altitude
        case timestamp
        case name
        case address
        case note
        case media //deprecated
        case items
    }
    var id : UUID
    var coordinate: CLLocationCoordinate2D
    var altitude: Double
    var timestamp: Date
    var mapPoint: MapPoint
    var coordinateRegion: CoordinateRegion
    var name : String = ""
    var address : String = ""
    var note : String = ""
    var items : PlaceItemList
    
    var hasItems : Bool{
        !items.isEmpty
    }
    
    init(coordinate: CLLocationCoordinate2D){
        id = UUID()
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
        id = try values.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        let latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? 0
        let longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? 0
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapPoint = MapPoint(coordinate)
        coordinateRegion = coordinate.coordinateRegion(radiusMeters: Preferences.maxPlaceMergeDistance)
        altitude = try values.decodeIfPresent(CLLocationDistance.self, forKey: .altitude) ?? 0
        timestamp = try values.decodeIfPresent(Date.self, forKey: .timestamp) ?? Date()
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        address = try values.decodeIfPresent(String.self, forKey: .address) ?? ""
        note = try values.decodeIfPresent(String.self, forKey: .note) ?? ""
        var items = try values.decodeIfPresent(PlaceItemList.self, forKey: .items)
        if items == nil{
            print("key items not found - trying key media")
            items = try values.decodeIfPresent(PlaceItemList.self, forKey: .media)
        }
        self.items = items ?? PlaceItemList()
        super.init()
        if name.isEmpty || address.isEmpty{
            evaluatePlacemark()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(altitude, forKey: .altitude)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(name, forKey: .name)
        try container.encode(address, forKey: .address)
        try container.encode(note, forKey: .note)
        try container.encode(items, forKey: .items)
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
    
    func addItem(file: MediaData){
        items.append(file)
    }
    
    func deleteItem(file: MediaData){
        items.remove(file)
    }
    
    func deleteAllItems(){
        items.removeAllItems()
    }
    
}
