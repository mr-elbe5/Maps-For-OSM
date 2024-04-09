/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit

class AppData{
    
    static var storeKey = "locations"
    
    static var recordId = CKRecord.ID(recordName: CKContainer.appDataKey)
    
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
    
    var tracks: Array<TrackItem>{
        get{
            var trackList = Array<TrackItem>()
            for place in places{
                trackList.append(contentsOf: place.tracks)
            }
            trackList.sortByDate()
            return trackList
        }
    }
    
    var images: Array<ImageItem>{
        get{
            var imageList = Array<ImageItem>()
            for place in places{
                imageList.append(contentsOf: place.images)
            }
            imageList.sortByDate()
            return imageList
        }
    }
    
    var media: Array<FileItem>{
        get{
            var mediaList = Array<FileItem>()
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
        Log.debug("load from iCloud")
        CKContainer.fetchFromICloud(recordId: AppData.recordId, processRecord: { record in
            if let json = record.value(forKey: CKContainer.appDataKey) as? String, let data : Array<Place> = Array<Place>.fromJSON(encoded: json){
                Log.debug("got places from iCloud")
                self.places = data
                self.readFilesFromICloud()
            }
        })
    }
    
    func readFilesFromICloud(){
        var updateList = Array<CKRecord.ID>()
        let query = CKQuery(recordType: CKContainer.fileType, predicate: NSPredicate(value: true))
        // get all records
        CKContainer.queryFromICloud(query: query, keys: FileItem.recordMetaKeys, processRecord: { record in
            if self.needsUpdate(record: record){
                Log.debug("needs update \(record.recordID)")
                updateList.append(record.recordID)
            }
            else{
                Log.debug("needs no update \(record.recordID)")
            }
        }, completion: { success in
            if success{
                Log.debug("num needs update \(updateList.count)")
                CKContainer.fetchFromICloud(recordIds: updateList, keys: FileItem.recordDataKeys, processRecord: { record in
                    self.updateFile(record: record)
                }){ success in
                    Log.debug("all updated")
                }
            }
        })
    }
    
    private func needsUpdate(record: CKRecord) -> Bool{
        if let placeId = UUID(uuidString: record.value(forKey: CKContainer.placeIdKey) as? String ?? ""),
           let place = self.getPlace(id: placeId),
           let fileId = UUID(uuidString: record.value(forKey: CKContainer.fileIdKey) as? String ?? ""),
           let fileItem = place.getItem(id: fileId) as? FileItem,
           let modificationDate = record.modificationDate{
            return fileItem.changeDate < modificationDate
        }
        Log.warn("Did not find item for \(record.debugDescription)")
        return false
    }
    
    private func updateFile(record: CKRecord){
        if let placeId = UUID(uuidString: record.value(forKey: CKContainer.placeIdKey) as? String ?? ""){
            if let place = self.getPlace(id: placeId),
               let fileId = UUID(uuidString: record.value(forKey: CKContainer.fileIdKey) as? String ?? ""),
               let fileItem = place.getItem(id: fileId) as? FileItem,
               let asset = record.value(forKey: CKContainer.fileAssetKey) as? CKAsset,
               let sourceURL = asset.fileURL{
                Log.debug("source url = \(sourceURL)")
                if FileController.copyFile(fromURL: sourceURL, toURL: fileItem.fileURL){
                    if let modificationDate = record.modificationDate{
                        Log.debug("updating change date")
                        fileItem.changeDate = modificationDate
                    }
                }
                else{
                    Log.debug("download failed")
                }
            }
        }
    }
    
    func save(){
        DataController.shared.save(forKey: AppData.storeKey, value: places)
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
        Log.debug("save to iCloud")
        var records = Array<CKRecord>()
        let record = CKRecord(recordType: CKContainer.jsonType, recordID: AppData.recordId)
        record[CKContainer.appDataKey] = places.toJSON()
        records.append(record)
        let media = media
        for item in media{
            records.append(item.fileRecord)
        }
        Log.debug("save to iCloud \(records.count) records")
        CKContainer.saveToICloud(records: records)
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
        places.first(where:{
            $0.coordinateRegion.contains(coordinate: coordinate)
        })
    }
    
    func getPlace(id: UUID) -> Place?{
        places.first(where:{
            $0.id == id
        })
    }
    
    func createPlace(coordinate: CLLocationCoordinate2D) -> Place{
        let place = addPlace(coordinate: coordinate)
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
                    let noteItem = NoteItem()
                    noteItem.text = place.note
                    noteItem.creationDate = place.timestamp
                    place.addItem(item: noteItem)
                    place.note = ""
                    Log.debug("added note item")
                }
            }
        }
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
