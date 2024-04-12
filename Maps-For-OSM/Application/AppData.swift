/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit

class AppData{
    
    static var storeKey = "locations"
    
    static var recordId = CKRecord.ID(recordName: "appData")
    
    static var shared = AppData()
    
    var places = Array<Place>()
    
    var filteredPlaces : Array<Place>{
        switch AppState.shared.placeFilter{
        case .all: return places
        case .media:
            return places.filter({
                $0.hasMedia
            })
        case .track:
            return places.filter({
                $0.hasTrack
            })
        case .note:
            return places.filter({
                $0.hasNote
            })
        }
    }
    
    var trackItems: Array<TrackItem>{
        get{
            var trackList = Array<TrackItem>()
            for place in places{
                trackList.append(contentsOf: place.tracks)
            }
            trackList.sortByDate()
            return trackList
        }
    }
    
    var imageItems: Array<ImageItem>{
        get{
            var imageList = Array<ImageItem>()
            for place in places{
                imageList.append(contentsOf: place.images)
            }
            imageList.sortByDate()
            return imageList
        }
    }
    
    var fileItems: Array<FileItem>{
        get{
            var fileList = Array<FileItem>()
            for place in places{
                fileList.append(contentsOf: place.media)
            }
            return fileList
        }
    }
    
    var size : Int{
        places.count
    }
    
    var dataRecordId : CKRecord.ID{
        get{
            CKRecord.ID(recordName: "string")
        }
    }
    
    var dataRecord: CKRecord{
        get{
            let record = CKRecord(recordType: CloudSynchronizer.jsonType, recordID: AppData.recordId)
            record["string"] = places.toJSON()
            return record
        }
    }
    
    func resetCoordinateRegions() {
        for place in places{
            place.resetCoordinateRegion()
        }
    }
    
    func createPlace(coordinate: CLLocationCoordinate2D) -> Place{
        let place = addPlace(coordinate: coordinate)
        return place
    }
    
    func addPlace(coordinate: CLLocationCoordinate2D) -> Place{
        let place = Place(coordinate: coordinate)
        places.append(place)
        return place
    }
    
    func deletePlace(_ place: Place){
        for idx in 0..<places.count{
            if places[idx] == place{
                place.deleteAllItems()
                places.remove(place)
                return
            }
        }
    }
    
    func deleteAllPlaces(){
        for idx in 0..<places.count{
            places[idx].deleteAllItems()
        }
        places.removeAll()
    }
    
    func getPlace(coordinate: CLLocationCoordinate2D) -> Place?{
        places.first(where:{
            $0.coordinateRegion.contains(coordinate: coordinate)
        })
    }
    
    func getPlace(id: UUID) -> Place?{
        places.first(where:{
            $0.id == id
        })
    }
    
    // local persistance
    
    func loadLocally(){
        if let list : Array<Place> = DataController.shared.load(forKey: AppData.storeKey){
            places = list
        }
        else{
            places = Array<Place>()
        }
    }
    
    func saveLocally(){
        DataController.shared.save(forKey: AppData.storeKey, value: places)
    }
    
    // file persistance
    
    func saveAsFile() -> URL?{
        let value = places.toJSON()
        let url = FileController.temporaryURL.appendingPathComponent(AppData.storeKey + ".json")
        if FileController.saveFile(text: value, url: url){
            return url
        }
        return nil
    }
    
    func loadFromFile(url: URL){
        if let string = FileController.readTextFile(url: url),let data : Array<Place> = Array<Place>.fromJSON(encoded: string){
            places = data
        }
    }
    
    func cleanupFiles(){
        let fileURLs = FileController.listAllURLs(dirURL: FileController.mediaDirURL)
        var itemURLs = Array<URL>()
        var count = 0
        for item in fileItems{
            itemURLs.append(item.fileURL)
        }
        for url in fileURLs{
            if !itemURLs.contains(url){
                Log.debug("deleting local file \(url.lastPathComponent)")
                FileController.deleteFile(url: url)
                count += 1
            }
        }
        Log.info("deleted \(count) unreferenced files")
    }
    
    //deprecated
    func convertNotes(){
        Log.info("converting notes to note items")
        for place in places{
            if let note = place.note{
                if !{
                    for item in place.notes{
                        if item.text == note{
                            return true
                        }
                    }
                    return false
                }(){
                    let noteItem = NoteItem()
                    noteItem.text = note
                    noteItem.creationDate = place.timestamp
                    place.addItem(item: noteItem)
                    place.note = ""
                    Log.debug("added note item")
                }
            }
        }
    }
    
}

