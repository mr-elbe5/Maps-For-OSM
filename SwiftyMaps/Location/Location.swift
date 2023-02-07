/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import UIKit

class Location : NSObject, Codable, Identifiable{
    
    static func == (lhs: Location, rhs: Location) -> Bool {
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
        case media
        case photos
        case tracks
    }
    
    var id : UUID
    var coordinate: CLLocationCoordinate2D
    var altitude: Double
    var timestamp: Date
    var mapPoint: MapPoint
    var name : String = ""
    var address : String = ""
    var note : String = ""
    var media : MediaList
    
    var hasMedia : Bool{
        !media.isEmpty
    }
    
    init(coordinate: CLLocationCoordinate2D){
        id = UUID()
        media = MediaList()
        mapPoint = MapPoint(coordinate)
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
        altitude = try values.decodeIfPresent(CLLocationDistance.self, forKey: .altitude) ?? 0
        timestamp = try values.decodeIfPresent(Date.self, forKey: .timestamp) ?? Date()
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        address = try values.decodeIfPresent(String.self, forKey: .address) ?? ""
        note = try values.decodeIfPresent(String.self, forKey: .note) ?? ""
        media = try values.decodeIfPresent(MediaList.self, forKey: .media) ?? MediaList()
        super.init()
        if AppState.shared.version < AppState.currentVersion{
            try transferOldPhotosAndTracks(values: values)
        }
        if name.isEmpty || address.isEmpty{
            evaluatePlacemark()
        }
    }
    
    private func transferOldPhotosAndTracks(values: KeyedDecodingContainer<CodingKeys>) throws{
        Log.info("Location transferring old data")
        if let photoList = try values.decodeIfPresent(Array<ImageFile>.self, forKey: .photos){
            Log.info("Location moving photos to media")
            for photo in photoList{
                let oldFileName = "img_\(photo.id)_\(photo.creationDate.shortFileDate()).jpg"
                let oldURL = FileController.getURL(dirURL: FileController.oldImageDirURL,fileName: oldFileName)
                if FileController.fileExists(url: oldURL){
                    if FileController.copyFile(fromURL: oldURL, toURL: photo.fileURL){
                        Log.info("copied old photo \(photo.fileName) to media directory")
                    }
                    if FileController.deleteFile(url: oldURL){
                        Log.info("deleted old photo \(photo.fileName)")
                    }
                    media.append(photo)
                    //Log.debug("photo file \(photo.fileName) exists: \(photo.fileExists())")
                }
            }
        }
        if let tracks = try values.decodeIfPresent(TrackList.self, forKey: .tracks), !tracks.isEmpty{
            Log.info("Location moving tracks to Tracks")
            for track in tracks{
                if TrackPool.addTrack(track: track){
                    Log.info("added old track from location to track pool")
                }
            }
            Log.info("saving track pool including old tracks")
            TrackPool.save()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        media.remove(file)
    }
    
    func deleteAllMedia(){
        media.removeAllFiles()
    }
    
}
