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
    
    func synchronize() async throws{
        if try await CKContainer.isConnected(), let remotePlaces = try await getRemotePlaces(){
            let remoteApp = AppData()
            remoteApp.places = remotePlaces
            let remoteFileMetaData = try await getRemoteFileMetaData()
            cleanupRemoteFiles(files: remoteFileMetaData, app: remoteApp)
            mergePlaces(fromApp: remoteApp, toApp: AppData.shared)
            for metaRecord in remoteFileMetaData{
                if let fileItem = getMatchingFileItem(record: metaRecord, appData: AppData.shared){
                    if let fileDataRecord = try await getRemoteFileData(metaRecord: metaRecord){
                        downloadFile(record: fileDataRecord, fileItem: fileItem)
                    }
                    else{
                        Log.error("could not download file \(metaRecord.debugString("fileId"))")
                    }
                }
                else{
                    Log.error("file item not found for \(metaRecord.debugString("fileId"))")
                }
            }
        }
        else{
            Log.warn("no places on iCloud")
        }
    }
    
    private func getRemotePlaces() async throws -> Array<Place>?{
        Log.debug("get remote places")
        let query = CKQuery(recordType: CloudSynchronizer.jsonType, predicate: NSPredicate(format: "string != ''"))
        let records = try await CKContainer.privateDatabase.records(matching: query)
        if records.matchResults.isEmpty{
            return nil
        }
        let matchResult = records.matchResults[0]
        let result = matchResult.1
        switch result{
        case .failure(let err):
            Log.error(error: err)
        case .success(let record):
            if let json = record.string("string"), let data : Array<Place> = Array<Place>.fromJSON(encoded: json){
                Log.debug("remote places received")
                return data
            }
        }
        return nil
    }
    
    private func cleanupRemoteFiles(files: Array<CKRecord>, app: AppData){
        var unrelatedRemoteFileData  = Array<CKRecord.ID>()
        for fileData in files{
            if getMatchingFileItem(record: fileData, appData: app) == nil{
                unrelatedRemoteFileData.append(fileData.recordID)
            }
        }
        if unrelatedRemoteFileData.isEmpty{
            Log.debug("nothing to clean up")
            return
        }
        CKContainer.deleteFromICloud(recordIds: unrelatedRemoteFileData){ success in
            if success{
                Log.debug("cleanup of \(unrelatedRemoteFileData.count) remote files successful")
            }
            else{
                Log.error("cleanup of  \(unrelatedRemoteFileData.count) remote files failed")
            }
        }
    }
    
    private func getRemoteFileMetaData() async throws -> Array<CKRecord>{
        var list = Array<CKRecord>()
        let query = CKQuery(recordType: CloudSynchronizer.fileType, predicate: NSPredicate(format: "placeId != ''"))
        let records = try await CKContainer.privateDatabase.records(matching: query, desiredKeys: FileItem.recordMetaKeys)
        Log.debug("\(records.matchResults.count) remote file meta data received")
        for matchResult in records.matchResults{
            let result = matchResult.1
            switch result{
            case .failure(let err):
                Log.error(error: err)
            case .success(let record):
                list.append(record)
            }
        }
        return list
    }
    
    private func getMatchingFileItem(record: CKRecord, appData: AppData) -> FileItem?{
        if let placeId = record.uuid("placeId"), let place = appData.getPlace(id: placeId){
            if let fileId = record.uuid("fileId"), let fileItem = place.getItem(id: fileId) as? FileItem{
                return fileItem
            }
            else{
                Log.error("Inconsistent data: missing file item for id \(record.debugString("fileId"))")
            }
        }
        else{
            Log.error("Inconsistent data: missing place for id \(record.debugString("placeId"))")
        }
        return nil
    }
    
    private func getRemoteFileData(metaRecord: CKRecord) async throws -> CKRecord?{
        if let fileId = metaRecord.string("fileId"){
            let predicate = NSPredicate(format: "fileId == '\(fileId)'")
            let query = CKQuery(recordType: CloudSynchronizer.fileType, predicate: predicate)
            let records = try await CKContainer.privateDatabase.records(matching: query, desiredKeys: FileItem.recordDataKeys)
            if records.matchResults.isEmpty{
                return nil
            }
            let matchResult = records.matchResults[0]
            let result = matchResult.1
            switch result{
            case .failure(let err):
                Log.error(error: err)
            case .success(let record):
                return record
            }
        }
        return nil
    }
    
    private func downloadFile(record: CKRecord, fileItem: FileItem){
        Log.debug("downloading file \(record)")
        if let asset = record.asset("fileAsset"), let sourceURL = asset.fileURL{
            if FileController.copyFile(fromURL: sourceURL, toURL: fileItem.fileURL, replace: true){
                Log.debug("download succeeded")
            }
            else{
                Log.error("download failed")
            }
        }
        else{
            Log.error("Did not get asset for \(record.debugString("fileId"))")
        }
    }
    
    private func mergePlaces(fromApp sourceApp: AppData, toApp targetApp: AppData){
        for sourcePlace in sourceApp.places{
            var found = false
            for targetPlace in targetApp.places{
                if sourcePlace == targetPlace{
                    targetPlace.mergePlace(from: sourcePlace)
                    found = true
                    Log.debug("target place found: \(targetPlace.id)")
                    break;
                }
            }
            if !found{
                targetApp.places.append(sourcePlace)
            }
        }
        for targetPlace in targetApp.places{
            var found = false
            for sourcePlace in sourceApp.places{
                if sourcePlace == targetPlace{
                    found = true
                    break;
                }
            }
            if !found{
                Log.warn("target place not found in source: \(targetPlace.name)")
            }
        }
    }
    
    func synchronizeToICloud(){
        Log.debug("synchronize to iCloud")
        /*var records = Array<CKRecord>()
        let record = CKRecord(recordType: CloudSynchronizer.jsonType, recordID: AppData.recordId)
        record["string"] = localData.places.toJSON()
        records.append(record)
        let media = localData.fileItems
        for item in media{
            records.append(item.fileRecord)
        }
        Log.debug("save to iCloud \(records.count) records")
        CKContainer.saveToICloud(records: records)
         */
    }
    
}

