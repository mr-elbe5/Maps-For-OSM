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
        let query = CKQuery(recordType: CKContainer.jsonType, predicate: NSPredicate(format: "string != ''"))
        CKContainer.queryFromICloud(query: query, processRecord: { record in
            if let json = record.string("string"), let data : Array<Place> = Array<Place>.fromJSON(encoded: json){
                Log.debug("got places from iCloud")
                self.places = data
                for place in self.places{
                    Log.debug(place.id.uuidString)
                }
                self.readFilesFromICloud()
            }
        })
    }
    
    func readFilesFromICloud(){
        var downloadList = Array<CKRecord>()
        var deleteList = Array<CKRecord.ID>()
        let query = CKQuery(recordType: CKContainer.fileType, predicate: NSPredicate(format: "placeId != ''"))
        // get all records
        CKContainer.queryFromICloud(query: query, keys: FileItem.recordMetaKeys, processRecord: { record in
            switch self.needsAction(record: record){
            case .download:
                downloadList.append(record)
                Log.debug("needs update \(record)")
            case .delete:
                deleteList.append(record.recordID)
                Log.debug("needs delete \(record)")
            case .none:
                Log.debug("no action needed \(record)")
                break
            }
        }, completion: { success in
            if success{
                for record in downloadList{
                    if let fileId = record.string("fileId"){
                        let predicate = NSPredicate(format: "fileId == '\(fileId)'")
                        let query = CKQuery(recordType: CKContainer.fileType, predicate: predicate)
                        CKContainer.queryFromICloud(query: query, keys: FileItem.recordDataKeys, processRecord: { record in
                            self.downloadFile(record: record)
                        }){ success in
                            Log.debug("\(fileId) download ready")
                        }
                    }
                }
                CKContainer.deleteFromICloud(recordIds: deleteList)
            }
        })
    }
    
    private func needsAction(record: CKRecord) -> CKContainer.Action{
        if let placeId = record.uuid("placeId"),
           let place = self.getPlace(id: placeId){
            if let fileId = record.uuid("fileId"),
               let fileItem = place.getItem(id: fileId) as? FileItem{
                return FileController.fileExists(url: fileItem.fileURL) ? .none : .download
            }
            else{
                Log.warn("Did not find file for \(record.debugString("fileId"))")
            }
        }
        else{
            Log.warn("Did not find place for \(record.debugString("placeId"))")
        }
        return .delete
    }
    
    private func downloadFile(record: CKRecord){
        Log.debug("downloading file \(record)")
        if let placeId = record.uuid("placeId"),
           let place = self.getPlace(id: placeId){
            if let fileId = record.uuid("fileId"),
               let fileItem = place.getItem(id: fileId) as? FileItem{
                if let asset = record.asset("fileAsset"),
                   let sourceURL = asset.fileURL{
                    if FileController.copyFile(fromURL: sourceURL, toURL: fileItem.fileURL, replace: true){
                        Log.debug("download succeeded")
                    }
                    else{
                        Log.debug("download failed")
                    }
                }
                else{
                    Log.warn("Did not get asset for \(record.debugString("fileId"))")
                }
            }
            else{
                Log.warn("Did not find file for \(record.debugString("fileId"))")
            }
            
        }
        else{
            Log.warn("Did not find place for \(record.debugString("placeId"))")
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
        record["string"] = places.toJSON()
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
