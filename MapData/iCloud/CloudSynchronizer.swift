/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit
import E5Data

public protocol CloudSynchronizerDelegate{
    func setMaxSteps(_ value: Int)
    func nextStep()
}

open class CloudSynchronizer{
    
    public var delegate: CloudSynchronizerDelegate? = nil
    
    public init(){
    }
    
    func sendNextStep(){
        DispatchQueue.main.async {
            self.delegate?.nextStep()
        }
    }
    
    public func synchronizeICloud(replaceLocalData: Bool, replaceICloudData: Bool) async throws{
        AppData.shared.save()
        try await synchronizeFromICloud(deleteLocalData: replaceLocalData)
        AppData.shared.save()
        try await synchronizeToICloud(deleteICloudData: replaceICloudData)
    }
    
    public func synchronizeFromICloud(deleteLocalData: Bool) async throws{
        Log.info("synchronizing from iCloud")
        Log.info("starting download with \(AppData.shared.locations.count) locations and \(AppData.shared.locations.fileItems.count) files")
        if try await CKContainer.isConnected(), let remoteLocations = try await getRemoteLocations(){
            Log.debug("synchronize locations from iCloud")
            let remoteFileMetaDataMap = await getRemoteFileMetaData()
            //locations
            Log.debug("received \(remoteLocations.count) icloud locations")
            var oldLocalFileItems = FileItemList()
            oldLocalFileItems.append(contentsOf: AppData.shared.locations.fileItems)
            //setup local locations
            if deleteLocalData{
                AppData.shared.locations.removeAll()
                AppData.shared.locations.append(contentsOf: remoteLocations)
            }
            else{
                for location in AppData.shared.locations{
                    if remoteLocations.containsEqual(location){
                        Log.debug("local location \(location.id) will be replaced")
                        AppData.shared.locations.remove(obj: location)
                    }
                    else{
                        Log.debug("remote \(location.id) will be added locally")
                    }
                }
                AppData.shared.locations.append(contentsOf: remoteLocations)
            }
            let newLocalFileItems = AppData.shared.locations.fileItems
            for fileItem in oldLocalFileItems{
                if !newLocalFileItems.containsEqual(fileItem){
                    Log.info("deleting local file \(fileItem.id)")
                    fileItem.prepareDelete()
                }
                else{
                    Log.debug("local file \(fileItem.id) does not need download")
                }
            }
            
            DispatchQueue.main.async {
                self.delegate?.setMaxSteps( newLocalFileItems.count)
            }
            for fileItem in newLocalFileItems{
                if !oldLocalFileItems.containsEqual(fileItem), remoteFileMetaDataMap.keys.contains(fileItem.id) {
                    Log.info("downloading remote file \(fileItem.id)")
                    if let fileDataRecord = try await getRemoteFileData(metaRecord: remoteFileMetaDataMap[fileItem.id]!){
                        downloadFile(record: fileDataRecord, fileItem: fileItem)
                        self.sendNextStep()
                    }
                    else{
                        Log.error("could not download file \(fileItem.id)")
                    }
                }
                else{
                    self.sendNextStep()
                }
            }
            AppData.shared.locations.sortAll()
            AppData.shared.cleanupFiles()
        }
        else{
            Log.warn("no places on iCloud")
        }
        Log.info("ending download with \(AppData.shared.locations.count) locations and \(AppData.shared.locations.fileItems.count) files")
    }
    
    public func synchronizeToICloud(deleteICloudData: Bool) async throws{
        Log.info("synchronizing to iCloud")
        if try await CKContainer.isConnected(){
            var recordsToSave = Array<CKRecord>()
            var recordsToDelete = Array<CKRecord.ID>()
            let oldRemoteLocationIds = await getRemoteLocationIds()
            let oldRemoteFileMetaData = await getRemoteFileMetaData()
            //locations
            Log.debug("getting \(oldRemoteLocationIds.count) remote locations")
            //setup remote locations
            if deleteICloudData{
                for uuid in oldRemoteLocationIds{
                    if !AppData.shared.locations.contains(where: { location in
                        location.id == uuid
                    }){
                        //Log.debug("setting remote location \(uuid) for delete")
                        recordsToDelete.append(CKRecord.ID(recordName: uuid.uuidString))
                    }
                    else{
                        //Log.debug("remote location \(uuid) will be replaced")
                    }
                }
                for location in AppData.shared.locations{
                    recordsToSave.append(location.dataRecord)
                }
            }
            else{
                for location in AppData.shared.locations{
                    recordsToSave.append(location.dataRecord)
                }
            }
            let localFileItems = AppData.shared.locations.fileItems
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
                DispatchQueue.main.async {
                    self.delegate?.setMaxSteps(2)
                    self.sendNextStep()
                }
                try await modifyRecords(recordsToSave: recordsToSave, recordIdsToDelete: recordsToDelete)
                sendNextStep()
            }
        }
        else{
            Log.warn("no connection to iCloud")
        }
    }
    
    public func cleanupICloud() async throws{
        Log.debug("cleanup iCloud")
        if try await CKContainer.isConnected(), let remoteLocations = try await getRemoteLocations(){
            let remoteFileMetaDataMap = await getRemoteFileMetaData()
            let recordIdsToDelete = getUnreferencedRecordIds(allFiles: remoteFileMetaDataMap, fileItems: remoteLocations.fileItems)
            if !recordIdsToDelete.isEmpty{
                DispatchQueue.main.async {
                    self.delegate?.setMaxSteps(2)
                    self.sendNextStep()
                }
                try await modifyRecords(recordsToSave: [], recordIdsToDelete: recordIdsToDelete)
            }
        }
    }
    
    // private funcs
    
    private func getRemoteLocations() async throws -> LocationList?{
        Log.debug("get remote locations")
        var locations = LocationList()
        let query = CKQuery(recordType: CKRecord.locationType, predicate: NSPredicate(format: "json != ''"))
        let records = try await CKContainer.privateDatabase.records(matching: query, desiredKeys: Location.recordDataKeys)
        if records.matchResults.isEmpty{
            return nil
        }
        for matchResult in records.matchResults{
            let result = matchResult.1
            switch result{
            case .failure(let err):
                Log.error(error: err)
            case .success(let record):
                if let json = record.string("json"), let data : Location = Location.fromJSON(encoded: json){
                    locations.append(data)
                }
            }
        }
        //Log.debug("\(locations.count) remote locations received")
        return locations
    }
    
    private func mergeLocations(fromLocations sourceLocations: LocationList, toLocations targetLocations: inout LocationList){
        for sourceLocation in sourceLocations{
            var found = false
            for targetLocation in targetLocations{
                if sourceLocation.equals(targetLocation){
                    targetLocation.mergeLocation(from: sourceLocation)
                    found = true
                    //Log.debug("target location found: \(targetLocation.id)")
                    break;
                }
            }
            if !found{
                targetLocations.append(sourceLocation)
            }
        }
    }
    
    private func getRemoteLocationIds() async -> Array<UUID>{
        Log.debug("getting remote location ids")
        var list = Array<UUID>()
        let query = CKQuery(recordType: CKRecord.locationType, predicate: NSPredicate(format: "uuid != ''"))
        do{
            let records = try await CKContainer.privateDatabase.records(matching: query, desiredKeys: Location.recordMetaKeys)
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
            Log.debug("\(list.count) remote location ids received")
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
        Log.debug("downloading file \(fileItem.id)")
        if let asset = record.asset("asset"), let sourceURL = asset.fileURL{
            if FileManager.default.copyFile(fromURL: sourceURL, toURL: fileItem.fileURL, replace: true){
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
    
    public func modifyRecords(recordsToSave: Array<CKRecord>, recordIdsToDelete: Array<CKRecord.ID>) async throws{
        let fullResult = try await CKContainer.privateDatabase.modifyRecords(saving:recordsToSave, deleting:recordIdsToDelete, savePolicy: .allKeys, atomically: false)
        for saveResult in fullResult.saveResults{
            switch saveResult.value{
            case .failure(let err):
                Log.error(error: err)
            case .success(let result):
                Log.debug("saved \(result.recordID.recordName) to iCloud")
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
                Log.debug("deleted \(deleteResult.key.recordName) from iCloud")
                break
            }
        }
        if !fullResult.deleteResults.isEmpty{
            Log.info("deleted \(fullResult.deleteResults.count) items from iCloud")
        }
    }
    
}

