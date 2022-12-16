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
        case media
        case photos
        case tracks
    }
    
    var id : UUID
    var name : String = ""
    var address : String = ""
    var note : String = ""
    var media : MediaList
    var tracks : TrackList
    
    var hasMedia : Bool{
        !media.isEmpty
    }
    
    var hasTracks : Bool{
        !tracks.isEmpty
    }
    
    override init(coordinate: CLLocationCoordinate2D){
        id = UUID()
        media = MediaList()
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
        media = try values.decodeIfPresent(MediaList.self, forKey: .media) ?? MediaList()
        // start deprecated
        if let photoList = try values.decodeIfPresent(Array<ImageFile>.self, forKey: .photos){
            for photo in photoList{
                media.append(photo)
            }
        }
        tracks = try values.decodeIfPresent(TrackList.self, forKey: .tracks) ?? TrackList()
        // end deprectaed
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
        try container.encode(media, forKey: .media)
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
    
    func addMedia(file: MediaFile){
        media.append(file)
    }
    
    func deleteMedia(file: MediaFile){
        lock.wait()
        defer{lock.signal()}
        media.remove(file)
    }
    
    func deleteAllMedia(){
        media.removeAllFiles()
    }
    
    //deprecated
    func getTracks() -> TrackList{
        tracks
    }
    
}
