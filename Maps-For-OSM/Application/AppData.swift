/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit

class AppData{
    
    static var storeKey = "locations"
    static var recordKey = "jsonString"
    static var recordId = CKRecord.ID(recordName: storeKey)
    
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
    
    var tracks: Array<Track>{
        get{
            var trackList = Array<Track>()
            for place in places{
                trackList.append(contentsOf: place.tracks)
            }
            return trackList
        }
    }
    
    var images: Array<Image>{
        get{
            var imageList = Array<Image>()
            for place in places{
                imageList.append(contentsOf: place.images)
            }
            return imageList
        }
    }
    
    var media: Array<MediaItem>{
        get{
            var mediaList = Array<MediaItem>()
            for place in places{
                mediaList.append(contentsOf: place.media)
            }
            return mediaList
        }
    }
    
    var size : Int{
        places.count
    }
    
    func load(){
        if let list : Array<Place> = DataController.shared.load(forKey: AppData.storeKey){
            places = list
        }
        else{
            places = Array<Place>()
        }
    }
    
    func loadFromICloud(){
        CKContainer.loadFromICloud(recordIds: [AppData.recordId], processRecord: readFromICloud)
        let media = media
        var recordIds = Array<CKRecord.ID>()
        for item in media{
            recordIds.append(item.recordId)
        }
        CKContainer.loadFromICloud(recordIds: recordIds, processRecord: readFromICloud)
    }
    
    func readFromICloud(record: CKRecord){
        if let json = record.value(forKey: AppData.recordKey) as? String, let data : Array<Place> = Array<Place>.fromJSON(encoded: json){
            places = data
        }
    }
    
    func save(){
        DataController.shared.save(forKey: AppData.storeKey, value: places)
        saveToICloud()
    }
    
    func saveAsFile() -> URL?{
        let value = places.toJSON()
        let url = FileController.temporaryURL.appendingPathComponent(AppData.storeKey + ".json")
        if FileController.saveFile(text: value, url: url){
            return url
        }
        return nil
    }
    
    func saveToICloud(){
        var records = Array<CKRecord>()
        let record = CKRecord(recordType: CKRecord.jsonType, recordID: AppData.recordId)
        record[AppData.recordKey] = places.toJSON()
        records.append(record)
        let media = media
        for item in media{
            records.append(item.record)
        }
        CKContainer.saveToICloud(records: [record])
    }
    
    func loadFromFile(url: URL){
        if let string = FileController.readTextFile(url: url),let data : Array<Place> = Array<Place>.fromJSON(encoded: string){
            places = data
        }
    }
    
    @discardableResult
    func addPlace(coordinate: CLLocationCoordinate2D) -> Place{
        let place = Place(coordinate: coordinate)
        places.append(place)
        return place
    }
    
    func deletePlace(_ place: Place){
        for idx in 0..<places.count{
            if places[idx] == place{
                place.deleteAllItems()
                places.remove(at: idx)
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
        for place in places{
            if place.coordinateRegion.contains(coordinate: coordinate){
                return place
            }
        }
        return nil
    }
    
    func createPlace(coordinate: CLLocationCoordinate2D) -> Place{
        let place = addPlace(coordinate: coordinate)
        save()
        return place
    }
    
    //deprecated
    func convertNotes(){
        Log.info("converting notes to note items")
        for place in places{
            if !place.note.isEmpty{
                if !{
                    for item in place.notes{
                        if item.text == place.note{
                            return true
                        }
                    }
                    return false
                }(){
                    let noteItem = Note()
                    noteItem.text = place.note
                    noteItem.creationDate = place.timestamp
                    place.addItem(item: noteItem)
                    place.note = ""
                    Log.debug("added note item")
                }
            }
        }
        save()
    }
    
}

extension Array<Place>{
    
    mutating func remove(_ place: Place){
        for idx in 0..<self.count{
            if self[idx] == place{
                self.remove(at: idx)
                return
            }
        }
    }
    
    mutating func removePlaces(of list: Array<Place>){
        for place in list{
            remove(place)
        }
    }
    
    var allSelected: Bool{
        get{
            for item in self{
                if !item.selected{
                    return false
                }
            }
            return true
        }
    }
    
    var allUnselected: Bool{
        get{
            for item in self{
                if item.selected{
                    return false
                }
            }
            return true
        }
    }
    
    mutating func selectAll(){
        for item in self{
            item.selected = true
        }
    }
    
    mutating func deselectAll(){
        for item in self{
            item.selected = false
        }
    }
    
}
