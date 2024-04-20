/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit

class CloudSynchronizer{
    
    func synchronizeICloud(replaceLocalData: Bool, replaceICloudData: Bool) async throws{
        AppData.shared.saveLocally()
        Task{
            try await synchronizeFromICloud(replaceLocalData: replaceLocalData)
            AppData.shared.saveLocally()
            try await synchronizeToICloud(replaceICloudData: replaceICloudData)
        }
    }
    
    func synchronizeFromICloud(replaceLocalData: Bool) async throws{
        Log.debug("synchronize from iCloud")
        if try await CKContainer.isConnected(), let remotePlaces = try await getRemotePlaces(){
            Log.debug("synchronize places from iCloud")
            let remoteFileMetaDataMap = await getRemoteFileMetaData()
            //cleanup of icloud
            let recordIdsToDelete = getUnreferencedRecordIds(allFiles: remoteFileMetaDataMap, fileItems: remotePlaces.fileItems)
            if !recordIdsToDelete.isEmpty{
                try await modifyRecords(recordsToSave: [], recordIdsToDelete: recordIdsToDelete)
            }
            //places
            Log.debug("received \(remotePlaces.count) icloud places")
            //setup local places
            if replaceLocalData{
                Log.debug("copying icloud places")
                //remove stale local places - only iCloud places stay
                let remotePlaceIds = remotePlaces.placeIds
                for place in AppData.shared.places{
                    if !remotePlaceIds.contains(place.id){
                        Log.debug("found stale local place \(place.id)")
                        AppData.shared.deletePlace(place)
                    }
                }
                //remove stale local files - only remote files stay
                //most should already have been removed by places
                let localFiles = AppData.shared.places.fileItems
                for fileItem in localFiles{
                    if !remoteFileMetaDataMap.keys.contains(fileItem.id){
                        Log.debug("deleting stale local file \(fileItem.fileName)")
                        fileItem.prepareDelete()
                    }
                }
                AppData.shared.places = remotePlaces
            }
            else{
                Log.debug("merging icloud places with \(AppData.shared.places.count) local places")
                mergePlaces(fromPlaces: remotePlaces, toPlaces: &AppData.shared.places)
                Log.debug("merged to \(AppData.shared.places.count) local places")
                //download new files
                let localFileItems = AppData.shared.places.fileItems
                for uuid in remoteFileMetaDataMap.keys{
                    if let fileItem = getMatchingFileItem(uuid: uuid, fileItems: localFileItems){
                        if !FileController.fileExists(url: fileItem.fileURL){
                            if let fileDataRecord = try await getRemoteFileData(metaRecord: remoteFileMetaDataMap[uuid]!){
                                downloadFile(record: fileDataRecord, fileItem: fileItem)
                            }
                            else{
                                Log.error("could not download file \(uuid.uuidString)")
                            }
                        }
                    }
                    else{
                        //should never happen after merge
                        Log.error("file item not found for \(uuid.uuidString)")
                    }
                }
            }
            AppData.shared.cleanupFiles()
        }
        else{
            Log.warn("no places on iCloud")
        }
    }
    
    func synchronizeToICloud(replaceICloudData: Bool) async throws{
        Log.debug("synchronize to iCloud")
        if try await CKContainer.isConnected(){
            var recordsToSave = Array<CKRecord>()
            var recordsToDelete = Array<CKRecord.ID>()
            let remotePlaceMetaData = await getRemotePlaceIds()
            let remoteFileMetaData = await getRemoteFileMetaData()
            //places
            Log.debug("having \(AppData.shared.places.count) local places")
            //setup remote places
            if replaceICloudData{
                Log.debug("copying local places")
                //remove stale iCloud places - only local places stay
                let localPlaceIds = AppData.shared.places.placeIds
                for uuid in remotePlaceMetaData{
                    if !localPlaceIds.contains(uuid){
                        Log.debug("found stale icloud place \(uuid)")
                        recordsToDelete.append(CKRecord.ID(recordName: uuid.uuidString))
                    }
                }
                //remove stale icloud files - only local files stay
                let localFileIds = AppData.shared.places.fileItemIds
                for uuid in remoteFileMetaData.keys{
                    if !localFileIds.contains(uuid){
                        Log.debug("found stale icloud file \(uuid)")
                        recordsToDelete.append(CKRecord.ID(recordName: uuid.uuidString))
                    }
                }
            }
            else{
                var remotePlaces = try await getRemotePlaces()
                if remotePlaces == nil{
                    remotePlaces = PlaceList()
                }
                Log.debug("merging local places with \(remotePlaces!.count) iCloud places")
                mergePlaces(fromPlaces: AppData.shared.places, toPlaces: &remotePlaces!)
                Log.debug("merged to \(remotePlaces!.count) remote places")
                
            }
            for place in AppData.shared.places{
                if !remotePlaceMetaData.contains(place.id){
                    Log.debug("setting place \(place.id) for upload")
                    recordsToSave.append(place.dataRecord)
                }
            }
            let localFileItems = AppData.shared.places.fileItems
            for fileItem in localFileItems{
                if !remoteFileMetaData.keys.contains(fileItem.id){
                    Log.debug("setting file \(fileItem.fileName) for upload")
                    recordsToSave.append(fileItem.fileRecord)
                }
            }
            Log.debug("saving \(recordsToSave.count) record(s) to iCloud")
            Log.debug("deleting \(recordsToDelete.count) record(s) from iCloud")
            if recordsToSave.count > 0 || recordsToDelete.count > 0{
                try await modifyRecords(recordsToSave: recordsToSave, recordIdsToDelete: recordsToDelete)
            }
        }
        else{
            Log.warn("no connection to iCloud")
        }
    }
    
    // private funcs
    
    private func getRemotePlaces() async throws -> PlaceList?{
        Log.debug("get remote places")
        var places = PlaceList()
        let query = CKQuery(recordType: CKRecord.placeType, predicate: NSPredicate(format: "json != ''"))
        let records = try await CKContainer.privateDatabase.records(matching: query, desiredKeys: Place.recordDataKeys)
        if records.matchResults.isEmpty{
            return nil
        }
        for matchResult in records.matchResults{
            let result = matchResult.1
            switch result{
            case .failure(let err):
                Log.error(error: err)
            case .success(let record):
                if let json = record.string("json"), let data : Place = Place.fromJSON(encoded: json){
                    places.append(data)
                }
            }
        }
        Log.debug("\(places.count) remote places received")
        return places
    }
    
    private func mergePlaces(fromPlaces sourcePlaces: PlaceList, toPlaces targetPlaces: inout PlaceList){
        for sourcePlace in sourcePlaces{
            var found = false
            for targetPlace in targetPlaces{
                if sourcePlace == targetPlace{
                    targetPlace.mergePlace(from: sourcePlace)
                    found = true
                    Log.debug("target place found: \(targetPlace.id)")
                    break;
                }
            }
            if !found{
                targetPlaces.append(sourcePlace)
            }
        }
        for targetPlace in targetPlaces{
            var found = false
            for sourcePlace in sourcePlaces{
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
    
    private func getRemotePlaceIds() async -> Array<UUID>{
        Log.debug("getting remote place ids")
        var list = Array<UUID>()
        let query = CKQuery(recordType: CKRecord.placeType, predicate: NSPredicate(format: "uuid != ''"))
        do{
            let records = try await CKContainer.privateDatabase.records(matching: query, desiredKeys: Place.recordMetaKeys)
            for matchResult in records.matchResults{
                let result = matchResult.1
                switch result{
                case .failure(let err):
                    Log.error(error: err)
                case .success(let record):
                    if let uuid = record.uuid("uuid"){
                        list.append(uuid)
                    }
                }
            }
            Log.debug("\(list.count) remote place ids received")
            return list
        }
        catch (let err){
            Log.warn(err.localizedDescription)
            return list
        }
    }
    
    private func getRemoteFileMetaData() async -> Dictionary<UUID, CKRecord>{
        Log.debug("getting remote file meta data")
        var map = Dictionary<UUID, CKRecord>()
        let query = CKQuery(recordType: CKRecord.fileType, predicate: NSPredicate(format: "uuid != ''"))
        do{
            let records = try await CKContainer.privateDatabase.records(matching: query, desiredKeys: FileItem.recordMetaKeys)
            Log.debug("\(records.matchResults.count) remote file meta data received")
            for matchResult in records.matchResults{
                let result = matchResult.1
                switch result{
                case .failure(let err):
                    Log.error(error: err)
                case .success(let record):
                    if let uuid = record.uuid("uuid"){
                        map[uuid] = record
                    }
                    else{
                        // this should never happen -> query
                        Log.error("remote file record has no uuid")
                    }
                }
            }
            return map
        }
        catch (let err){
            Log.warn(err.localizedDescription)
            return map
        }
    }
    
    private func getUnreferencedRecordIds(allFiles: Dictionary<UUID, CKRecord>, fileItems: FileItemList) -> Array<CKRecord.ID>{
        var list = Array<CKRecord.ID>()
        for uuid in allFiles.keys{
            let record = allFiles[uuid]!
            if getMatchingFileItem(uuid: uuid, fileItems: fileItems) == nil{
                list.append(record.recordID)
            }
        }
        return list
    }
    
    private func getMatchingFileItem(uuid: UUID, fileItems: FileItemList) -> FileItem?{
        if let fileItem = fileItems.first(where: {
            $0.id == uuid}
        ){
            return fileItem
        }
        return nil
    }
    
    private func getRemoteFileData(metaRecord: CKRecord) async throws -> CKRecord?{
        if let uuidString = metaRecord.string("uuid"){
            let predicate = NSPredicate(format: "uuid == '\(uuidString)'")
            let query = CKQuery(recordType: CKRecord.fileType, predicate: predicate)
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
        Log.debug("downloading file \(record.recordID)")
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
    
    func modifyRecords(recordsToSave: Array<CKRecord>, recordIdsToDelete: Array<CKRecord.ID>) async throws{
        let fullResult = try await CKContainer.privateDatabase.modifyRecords(saving:recordsToSave, deleting:recordIdsToDelete, savePolicy: .allKeys, atomically: false)
        for saveResult in fullResult.saveResults{
            switch saveResult.value{
            case .failure(let err):
                Log.error(error: err)
            case .success(let result):
                Log.debug("saved \(result.recordID.recordName) to iCloud")
            }
        }
        for deleteResult in fullResult.deleteResults{
            switch deleteResult.value{
            case .failure(let err):
                Log.error(error: err)
            case .success():
                Log.debug("deleted \(deleteResult.key.recordName) from iCloud")
            }
        }
    }
    
}

