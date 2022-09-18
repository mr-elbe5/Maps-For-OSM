/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import UIKit

class Place : Hashable, Codable{
    
    static func == (lhs: Place, rhs: Place) -> Bool {
        lhs.id == rhs.id
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case latitude
        case longitude
        case hasPlacemark
        case name
        case street
        case zipCode
        case city
        case country
        case description
        case photos
        case tracks
    }
    
    var id : UUID
    var coordinate : CLLocationCoordinate2D
    var planetPosition : CGPoint
    var hasPlacemark : Bool
    var name : String = ""
    var street : String = ""
    var zipCode : String = ""
    var city : String = ""
    var country : String = ""
    var description : String
    var photos : PhotoList
    var tracks : TrackList
    
    var cllocation : CLLocation{
        CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    private var lock = DispatchSemaphore(value: 1)
    
    var locationString : String{
        var s = name
        if !s.isEmpty{
            s += " - "
        }
        if !street.isEmpty{
            s += street
            s += ", "
        }
        if !zipCode.isEmpty{
            s += zipCode
            s += " "
        }
        if !city.isEmpty{
            s += city
        }
        return s
    }
    
    var coordinateString : String{
        let latitudeText = coordinate.latitude > 0 ? "north".localize() : "south".localize()
        let longitudeText = coordinate.longitude > 0 ? "east".localize() : "west".localize()
        return String(format: "%.04f", abs(coordinate.latitude)) + "° " + latitudeText + ", " + String(format: "%.04f", abs(coordinate.longitude)) + "° "  + longitudeText
    }
    
    var hasPhotos : Bool{
        !photos.isEmpty
    }
    
    var hasTracks : Bool{
        !tracks.isEmpty
    }
    
    init(){
        id = UUID()
        coordinate = CLLocationCoordinate2D()
        planetPosition = CGPoint()
        hasPlacemark = false
        description = ""
        photos = PhotoList()
        tracks = TrackList()
    }
    
    init(coordinate: CLLocationCoordinate2D){
        id = UUID()
        self.coordinate = coordinate
        planetPosition = World.planetPointFromCoordinate(coordinate: coordinate)
        hasPlacemark = false
        description = ""
        photos = PhotoList()
        tracks = TrackList()
        LocationService.shared.getPlacemarkInfo(for: self)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        let latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? 0
        let longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? 0
        hasPlacemark = try values.decodeIfPresent(Bool.self, forKey: .hasPlacemark) ?? false
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        street = try values.decodeIfPresent(String.self, forKey: .street) ?? ""
        zipCode = try values.decodeIfPresent(String.self, forKey: .zipCode) ?? ""
        city = try values.decodeIfPresent(String.self, forKey: .city) ?? ""
        country = try values.decodeIfPresent(String.self, forKey: .country) ?? ""
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        planetPosition = World.planetPointFromCoordinate(coordinate: coordinate)
        description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
        photos = try values.decodeIfPresent(PhotoList.self, forKey: .photos) ?? Array<PhotoData>()
        tracks = try values.decodeIfPresent(TrackList.self, forKey: .tracks) ?? TrackList()
        for track in tracks{
            track.startLocation = self
        }
        if !hasPlacemark{
            LocationService.shared.getPlacemarkInfo(for: self)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(hasPlacemark, forKey: .hasPlacemark)
        try container.encode(name, forKey: .name)
        try container.encode(street, forKey: .street)
        try container.encode(zipCode, forKey: .zipCode)
        try container.encode(city, forKey: .city)
        try container.encode(country, forKey: .country)
        try container.encode(description, forKey: .description)
        try container.encode(photos, forKey: .photos)
        try container.encode(tracks, forKey: .tracks)
    }
    
    func addPlacemarkInfo(placemark: CLPlacemark){
        street = placemark.thoroughfare ?? ""
        if let number = placemark.subThoroughfare{
            if !street.isEmpty{
                street += " "
            }
            street += number
        }
        if let name = placemark.name{
            self.name = (name == street) ? "" : name
        }
        zipCode = placemark.postalCode ?? ""
        city = placemark.locality ?? ""
        country = placemark.country ?? ""
        hasPlacemark = true
    }
    
    func assertDescription(){
        if description.isEmpty{
            description = locationString
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
    
    func addTrack(track: TrackData){
        tracks.append(track)
    }
    
    //unused
    func deleteTrack(track: TrackData){
        lock.wait()
        defer{lock.signal()}
        tracks.remove(track)
    }
    
    //unused
    func deleteAllTracks(){
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
