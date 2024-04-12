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
    
    func synchronizeFromICloud() async throws{
        if try await CKContainer.isConnected(), let remotePlaces = try await getRemotePlaces(){
            let remoteApp = AppData()
            remoteApp.places = remotePlaces
            let remoteFileMetaData = await getRemoteFileMetaData()
            let recordIdsToDelete = getRemoteRecordIdsToDelete(allFiles: remoteFileMetaData, app: remoteApp)
            if !recordIdsToDelete.isEmpty{
                try await modifyRecords(recordsToSave: [], recordIdsToDelete: recordIdsToDelete)
            }
            Log.debug("received \(remoteApp.places.count) places")
            if Preferences.shared.mergingSynchronisation{
                AppData.shared.loadLocally()
                mergePlaces(fromApp: remoteApp, toApp: AppData.shared)
            }
            else{
                copyPlaces(fromApp: remoteApp, toApp: AppData.shared)
            }
            Log.debug("merged to \(remoteApp.places.count) places")
            let localFiles = AppData.shared.fileItems
            for metaRecord in remoteFileMetaData{
                if let fileItem = getMatchingFileItem(record: metaRecord, allFiles: localFiles){
                    if !FileController.fileExists(url: fileItem.fileURL){
                        if let fileDataRecord = try await getRemoteFileData(metaRecord: metaRecord){
                            downloadFile(record: fileDataRecord, fileItem: fileItem)
                        }
                        else{
                            Log.error("could not download file \(metaRecord.debugString("uuid"))")
                        }
                    }
                    else{
                        //Log.debug("file exists: \(fileItem.fileURL.lastPathComponent)")
                    }
                }
                else{
                    Log.error("file item not found for \(metaRecord.debugString("uuid"))")
                }
            }
            AppData.shared.cleanupFiles()
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
    
    private func getRemoteRecordIdsToDelete(allFiles: Array<CKRecord>, app: AppData) -> Array<CKRecord.ID>{
        var list = Array<CKRecord.ID>()
        let localFiles = AppData.shared.fileItems
        for fileData in allFiles{
            if getMatchingFileItem(record: fileData, allFiles: localFiles) == nil{
                list.append(fileData.recordID)
            }
        }
        return list
    }
    
    private func getRemoteFileMetaData() async -> Array<CKRecord>{
        var list = Array<CKRecord>()
        let query = CKQuery(recordType: CloudSynchronizer.fileType, predicate: NSPredicate(format: "uuid != ''"))
        do{
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
        catch (let err){
            Log.warn(err.localizedDescription)
            return Array<CKRecord>()
        }
    }
    
    private func getMatchingFileItem(record: CKRecord, allFiles: Array<FileItem>) -> FileItem?{
        if let fileId = record.uuid("uuid"), let fileItem = allFiles.first(where: {
            $0.id == fileId}
        ){
            return fileItem
        }
        else{
            Log.error("Inconsistent data: missing file item for id \(record.debugString("uuid"))")
        }
        return nil
    }
    
    private func getRemoteFileData(metaRecord: CKRecord) async throws -> CKRecord?{
        if let uuidString = metaRecord.string("uuid"){
            let predicate = NSPredicate(format: "uuid == '\(uuidString)'")
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
        //Log.debug("downloading file \(record)")
        if let asset = record.asset("asset"), let sourceURL = asset.fileURL{
            if FileController.copyFile(fromURL: sourceURL, toURL: fileItem.fileURL, replace: true){
                Log.debug("download succeeded for \(fileItem.fileURL.lastPathComponent)")
            }
            else{
                Log.error("download failed")
            }
        }
        else{
            Log.error("Did not get asset for \(record.debugString("uuid"))")
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
    
    private func copyPlaces(fromApp sourceApp: AppData, toApp targetApp: AppData){
        targetApp.places.removeAll()
        for sourcePlace in sourceApp.places{
            targetApp.places.append(sourcePlace)
        }
    }
    
    func synchronizeToICloud() async throws{
        Log.debug("synchronize to iCloud")
        if try await CKContainer.isConnected(){
            let remoteFileMetaData = await getRemoteFileMetaData()
            Log.debug("uploading \(AppData.shared.places.count) places")
            let recordIdsToDelete = getRemoteRecordIdsToDelete(allFiles: remoteFileMetaData, app: AppData.shared)
            Log.debug("deleting \(recordIdsToDelete.count) record(s)")
            var recordsToSave = Array<CKRecord>()
            recordsToSave.append(AppData.shared.dataRecord)
            for fileItem in AppData.shared.fileItems{
                var found = false
                for record in remoteFileMetaData{
                    if fileItem.id == record.uuid("uuid"){
                        found = true
                        break;
                    }
                }
                if !found{
                    recordsToSave.append(fileItem.fileRecord)
                }
            }
            Log.debug("saving \(recordsToSave.count) record(s)")
            try await modifyRecords(recordsToSave: recordsToSave, recordIdsToDelete: recordIdsToDelete)
        }
        else{
            Log.warn("no connection to iCloud")
        }
    }
    
    func modifyRecords(recordsToSave: Array<CKRecord>, recordIdsToDelete: Array<CKRecord.ID>) async throws{
        let fullResult = try await CKContainer.privateDatabase.modifyRecords(saving:recordsToSave, deleting:recordIdsToDelete, savePolicy: .allKeys, atomically: false)
        for saveResult in fullResult.saveResults{
            switch saveResult.value{
            case .failure(let err):
                Log.error(error: err)
            case .success(let result):
                Log.debug("saved \(result.recordID.recordName)")
            }
        }
        for deleteResult in fullResult.deleteResults{
            switch deleteResult.value{
            case .failure(let err):
                Log.error(error: err)
            case .success():
                Log.debug("deleted \(deleteResult.key.recordName)")
            }
        }
    }
    
}

