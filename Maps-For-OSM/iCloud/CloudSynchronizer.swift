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
        try await synchronizeFromICloud(deleteLocalData: replaceLocalData)
        AppData.shared.saveLocally()
        try await synchronizeToICloud(deleteICloudData: replaceICloudData)
    }
    
    func synchronizeFromICloud(deleteLocalData: Bool) async throws{
        Log.info("synchronizing from iCloud")
        Log.info("starting download with \(AppData.shared.places.count) places and \(AppData.shared.places.fileItems.count) files")
        if try await CKContainer.isConnected(), let remotePlaces = try await getRemotePlaces(){
            //Log.debug("synchronize places from iCloud")
            let remoteFileMetaDataMap = await getRemoteFileMetaData()
            //places
            //Log.debug("received \(remotePlaces.count) icloud places")
            var oldLocalFileItems = FileItemList()
            oldLocalFileItems.append(contentsOf: AppData.shared.places.fileItems)
            //setup local places
            if deleteLocalData{
                AppData.shared.places.removeAll()
                AppData.shared.places.append(contentsOf: remotePlaces)
            }
            else{
                for place in AppData.shared.places{
                    if remotePlaces.containsEqual(place){
                        //Log.debug("local place \(place.id) will be replaced")
                        AppData.shared.places.remove(obj: place)
                    }
                    else{
                        //Log.debug("remote \(place.id) will be added locally")
                    }
                }
                AppData.shared.places.append(contentsOf: remotePlaces)
            }
            let newLocalFileItems = AppData.shared.places.fileItems
            for fileItem in oldLocalFileItems{
                if !newLocalFileItems.containsEqual(fileItem){
                    Log.info("deleting local file \(fileItem.id)")
                    fileItem.prepareDelete()
                }
                else{
                    //Log.debug("local file \(fileItem.id) does not need download")
                }
            }
            for fileItem in newLocalFileItems{
                if !oldLocalFileItems.containsEqual(fileItem), remoteFileMetaDataMap.keys.contains(fileItem.id) {
                    Log.info("downloading remote file \(fileItem.id)")
                    if let fileDataRecord = try await getRemoteFileData(metaRecord: remoteFileMetaDataMap[fileItem.id]!){
                        downloadFile(record: fileDataRecord, fileItem: fileItem)
                    }
                    else{
                        Log.error("could not download file \(fileItem.id)")
                    }
                }
            }
            AppData.shared.places.sortAll()
            AppData.shared.cleanupFiles()
        }
        else{
            Log.warn("no places on iCloud")
        }
        Log.info("ending download with \(AppData.shared.places.count) places and \(AppData.shared.places.fileItems.count) files")
    }
    
    func synchronizeToICloud(deleteICloudData: Bool) async throws{
        Log.info("synchronizing to iCloud")
        if try await CKContainer.isConnected(){
            var recordsToSave = Array<CKRecord>()
            var recordsToDelete = Array<CKRecord.ID>()
            let oldRemotePlaceIds = await getRemotePlaceIds()
            let oldRemoteFileMetaData = await getRemoteFileMetaData()
            //places
            //Log.debug("getting \(oldRemotePlaceIds.count) remote places")
            //setup remote places
            if deleteICloudData{
                for uuid in oldRemotePlaceIds{
                    if !AppData.shared.places.contains(where: { place in
                        place.id == uuid
                    }){
                        //Log.debug("setting remote place \(uuid) for delete")
                        recordsToDelete.append(CKRecord.ID(recordName: uuid.uuidString))
                    }
                    else{
                        //Log.debug("remote place \(uuid) will be replaced")
                    }
                }
                for place in AppData.shared.places{
                    recordsToSave.append(place.dataRecord)
                }
            }
            else{
                for place in AppData.shared.places{
                    recordsToSave.append(place.dataRecord)
                }
            }
            let localFileItems = AppData.shared.places.fileItems
            for uuid in oldRemoteFileMetaData.keys{
                if !localFileItems.contains(where: { fileItem in
                    fileItem.id == uuid
                }){
                    //Log.debug("setting remote file \(uuid) for delete")
                    recordsToDelete.append(oldRemoteFileMetaData[uuid]!.recordID)
                }
            }
            for fileItem in localFileItems{
                if !oldRemoteFileMetaData.keys.contains(where:{ uuid in
                    uuid == fileItem.id
                }){
                    //Log.debug("setting local file \(fileItem.id) for upload")
                    recordsToSave.append(fileItem.fileRecord)
                }
            }
            if !recordsToSave.isEmpty{
                Log.info("setting \(recordsToSave.count) record(s) for upload to iCloud")
            }
            if !recordsToDelete.isEmpty{
                Log.info("setting \(recordsToDelete.count) record(s) for delete from iCloud")
            }
            if recordsToSave.count > 0 || recordsToDelete.count > 0{
                try await modifyRecords(recordsToSave: recordsToSave, recordIdsToDelete: recordsToDelete)
            }
        }
        else{
            Log.warn("no connection to iCloud")
        }
    }
    
    func cleanupICloud() async throws{
        //Log.debug("cleanup iCloud")
        if try await CKContainer.isConnected(), let remotePlaces = try await getRemotePlaces(){
            let remoteFileMetaDataMap = await getRemoteFileMetaData()
            let recordIdsToDelete = getUnreferencedRecordIds(allFiles: remoteFileMetaDataMap, fileItems: remotePlaces.fileItems)
            if !recordIdsToDelete.isEmpty{
                try await modifyRecords(recordsToSave: [], recordIdsToDelete: recordIdsToDelete)
            }
        }
    }
    
    // private funcs
    
    private func getRemotePlaces() async throws -> PlaceList?{
        //Log.debug("get remote places")
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
        //Log.debug("\(places.count) remote places received")
        return places
    }
    
    private func mergePlaces(fromPlaces sourcePlaces: PlaceList, toPlaces targetPlaces: inout PlaceList){
        for sourcePlace in sourcePlaces{
            var found = false
            for targetPlace in targetPlaces{
                if sourcePlace.equals(targetPlace){
                    targetPlace.mergePlace(from: sourcePlace)
                    found = true
                    //Log.debug("target place found: \(targetPlace.id)")
                    break;
                }
            }
            if !found{
                targetPlaces.append(sourcePlace)
            }
        }
    }
    
    private func getRemotePlaceIds() async -> Array<UUID>{
        //Log.debug("getting remote place ids")
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
            //Log.debug("\(list.count) remote place ids received")
            return list
        }
        catch (let err){
            Log.warn(err.localizedDescription)
            return list
        }
    }
    
    private func getRemoteFileMetaData() async -> Dictionary<UUID, CKRecord>{
        //Log.debug("getting remote file meta data")
        var map = Dictionary<UUID, CKRecord>()
        let query = CKQuery(recordType: CKRecord.fileType, predicate: NSPredicate(format: "uuid != ''"))
        do{
            let records = try await CKContainer.privateDatabase.records(matching: query, desiredKeys: FileItem.recordMetaKeys)
            //Log.debug("\(records.matchResults.count) remote file meta data received")
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
        //Log.debug("downloading file \(fileItem.id)")
        if let asset = record.asset("asset"), let sourceURL = asset.fileURL{
            if FileController.copyFile(fromURL: sourceURL, toURL: fileItem.fileURL, replace: true){
                //Log.debug("download succeeded for \(fileItem.fileURL.lastPathComponent)")
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
            case .success(_):
                //Log.debug("saved \(result.recordID.recordName) to iCloud")
                break
            }
        }
        if !fullResult.saveResults.isEmpty{
            Log.info("saved \(fullResult.saveResults.count) items to iCloud")
        }
        for deleteResult in fullResult.deleteResults{
            switch deleteResult.value{
            case .failure(let err):
                Log.error(error: err)
            case .success():
                //Log.debug("deleted \(deleteResult.key.recordName) from iCloud")
                break
            }
        }
        if !fullResult.deleteResults.isEmpty{
            Log.info("deleted \(fullResult.deleteResults.count) items from iCloud")
        }
    }
    
}

