/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import UIKit

class Location : CodableLocation{
    
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case hasPlacemark
        case name
        case address
        case note
        case photos
        case tracks
    }
    
    var id : UUID
    var name : String = ""
    var address : String = ""
    var note : String = ""
    var photos : PhotoList
    
    //deprecated
    private var tracks : TrackList
    
    var hasPhotos : Bool{
        !photos.isEmpty
    }
    
    var hasTracks : Bool{
        !tracks.isEmpty
    }
    
    override init(coordinate: CLLocationCoordinate2D){
        id = UUID()
        photos = PhotoList()
        tracks = TrackList()
        super.init(coordinate: coordinate)
        evaluatePlacemark()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        address = try values.decodeIfPresent(String.self, forKey: .address) ?? ""
        note = try values.decodeIfPresent(String.self, forKey: .note) ?? ""
        photos = try values.decodeIfPresent(PhotoList.self, forKey: .photos) ?? Array<PhotoData>()
        //deprecated
        tracks = try values.decodeIfPresent(TrackList.self, forKey: .tracks) ?? TrackList()
        try super.init(from: decoder)
        if name.isEmpty || address.isEmpty{
            evaluatePlacemark()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(address, forKey: .address)
        try container.encode(note, forKey: .note)
        try container.encode(photos, forKey: .photos)
    }
    
    func evaluatePlacemark(){
        LocationService.instance.getPlacemark(for: self){ result in
            if let placemark = result{
                if self.name.isEmpty, let name = placemark.name{
                    self.name = name
                }
                if self.address.isEmpty{
                    self.address = "\(placemark.thoroughfare ?? "") \(placemark.subThoroughfare ?? "")n\(placemark.postalCode ?? "") \(placemark.locality ?? "")\n\(placemark.country ?? "")"
                }
            }
        }
        
    }
    
    func addPhoto(photo: PhotoData){
        photos.append(photo)
    }
    
    func deletePhoto(photo: PhotoData){
        lock.wait()
        defer{lock.signal()}
        photos.remove(photo)
    }
    
    func deleteAllPhotos(){
        photos.removeAllPhotos()
    }
    
    //deprecated
    func getTracks() -> TrackList{
        tracks
    }
    
}
