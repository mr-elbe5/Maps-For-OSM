/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit

class CloudSynchronizer{
    
    static var mapsForOSMContainerName = "iCloud.MapsForOSM"
    
    static var jsonType: CKRecord.RecordType = "json"
    static var fileType: CKRecord.RecordType = "file"
    
    var localData = AppData.shared
    var remoteData = AppData()
    
    func synchronize(){
        
        
        
    }
    
    private func getRemoteData(){
        
    }
    
    func synchronizeFromICloud(){
        Log.debug("load from iCloud")
        let query = CKQuery(recordType: CloudSynchronizer.jsonType, predicate: NSPredicate(format: "string != ''"))
        CKContainer.queryFromICloud(query: query, processRecord: { record in
            if let json = record.string("string"), let data : Array<Place> = Array<Place>.fromJSON(encoded: json){
                Log.debug("got places from iCloud")
                if Preferences.shared.mergingSynchronisation{
                    self.mergePlaces(newPlaces: data)
                }
                else{
                    self.localData.places = data
                }
                self.synchronizeFilesFromICloud()
            }
        })
    }
    
    private func mergePlaces(newPlaces: Array<Place>){
        for newPlace in newPlaces{
            var found = false
            for place in localData.places{
                if newPlace == place{
                    place.mergePlace(newPlace: newPlace)
                    found = true
                    Log.debug("place found: \(place.id)")
                    break;
                }
            }
            if !found{
                localData.places.append(newPlace)
            }
        }
    }
    
    private func synchronizeFilesFromICloud(){
        var downloadList = Array<FileDownLoadData>()
        var deleteList = Array<CKRecord.ID>()
        let query = CKQuery(recordType: CloudSynchronizer.fileType, predicate: NSPredicate(format: "placeId != ''"))
        // get all records
        CKContainer.queryFromICloud(query: query, keys: FileItem.recordMetaKeys, processRecord: { record in
            var found = false
            if let placeId = record.uuid("placeId"),
               let place = self.localData.getPlace(id: placeId){
                if let fileId = record.uuid("fileId"),
                   let fileItem = place.getItem(id: fileId) as? FileItem{
                    found = true
                    if !FileController.fileExists(url: fileItem.fileURL){
                        downloadList.append(FileDownLoadData(fileItem: fileItem, record: record))
                    }
                }
                else{
                    Log.debug("Did not find file for \(record.debugString("fileId"))")
                }
            }
            else{
                Log.debug("Did not find place for \(record.debugString("placeId"))")
            }
            if !found{
                Log.debug("File not found for \(record.debugString("fileId"))")
                deleteList.append(record.recordID)
            }
        }, completion: { success in
            if success{
                //delete first if file has moved
                CKContainer.deleteFromICloud(recordIds: deleteList){ success in
                    for data in downloadList{
                        if let fileId = data.record.string("fileId"){
                            let predicate = NSPredicate(format: "fileId == '\(fileId)'")
                            let query = CKQuery(recordType: CloudSynchronizer.fileType, predicate: predicate)
                            CKContainer.queryFromICloud(query: query, keys: FileItem.recordDataKeys, processRecord: { record in
                                self.downloadFile(data: data)
                            }){ success in
                                Log.debug("\(fileId) download ready")
                            }
                        }
                    }
                }
            }
        })
    }
    
    private func downloadFile(data: FileDownLoadData){
        Log.debug("downloading file \(data.record)")
        if let asset = data.record.asset("fileAsset"),
           let sourceURL = asset.fileURL{
            if FileController.copyFile(fromURL: sourceURL, toURL: data.fileItem.fileURL, replace: true){
                Log.debug("download succeeded")
            }
            else{
                Log.error("download failed")
            }
        }
        else{
            Log.error("Did not get asset for \(data.record.debugString("fileId"))")
        }
    }
    
    func synchronizeToICloud(){
        Log.debug("synchronize to iCloud")
        var records = Array<CKRecord>()
        let record = CKRecord(recordType: CloudSynchronizer.jsonType, recordID: AppData.recordId)
        record["string"] = localData.places.toJSON()
        records.append(record)
        let media = localData.fileItems
        for item in media{
            records.append(item.fileRecord)
        }
        Log.debug("save to iCloud \(records.count) records")
        CKContainer.saveToICloud(records: records)
    }
    
}

struct FileDownLoadData{
    
    var fileItem: FileItem
    var record: CKRecord
    
}
