/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit

extension AppData{
    
    enum Action: String{
        case none
        case download
        case delete
    }
    
    static var mapsForOSMContainerName = "iCloud.MapsForOSM"
    
    static var jsonType: CKRecord.RecordType = "json"
    static var fileType: CKRecord.RecordType = "file"
    
    func loadFromICloud(){
        Log.debug("load from iCloud")
        let query = CKQuery(recordType: AppData.jsonType, predicate: NSPredicate(format: "string != ''"))
        CKContainer.queryFromICloud(query: query, processRecord: { record in
            if let json = record.string("string"), let data : Array<Place> = Array<Place>.fromJSON(encoded: json){
                Log.debug("got places from iCloud")
                if Preferences.shared.mergingSynchronisation{
                    self.mergePlaces(newPlaces: data)
                }
                else{
                    self.places = data
                }
                self.readFilesFromICloud()
            }
        })
    }
    
    func mergePlaces(newPlaces: Array<Place>){
        for newPlace in newPlaces{
            var found = false
            for place in places{
                if newPlace == place{
                    place.mergePlace(newPlace: newPlace)
                    found = true
                    Log.debug("place found: \(place.id)")
                    break;
                }
            }
            if !found{
                places.append(newPlace)
            }
        }
    }
    
    func readFilesFromICloud(){
        var downloadList = Array<CKRecord>()
        var deleteList = Array<CKRecord.ID>()
        let query = CKQuery(recordType: AppData.fileType, predicate: NSPredicate(format: "placeId != ''"))
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
                        let query = CKQuery(recordType: AppData.fileType, predicate: predicate)
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
    
    private func needsAction(record: CKRecord) -> AppData.Action{
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
    
    func saveToICloud(){
        Log.debug("save to iCloud")
        var records = Array<CKRecord>()
        let record = CKRecord(recordType: AppData.jsonType, recordID: AppData.recordId)
        record["string"] = places.toJSON()
        records.append(record)
        let media = media
        for item in media{
            records.append(item.fileRecord)
        }
        Log.debug("save to iCloud \(records.count) records")
        CKContainer.saveToICloud(records: records)
    }
    
    func synchronizeWithICloud(){
        
    }
    
}
