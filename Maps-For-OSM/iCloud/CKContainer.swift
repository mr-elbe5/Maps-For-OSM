//
//  CKContainer.swift
//  Maps for OSM
//
//  Created by Michael Rönnau on 07.04.24.
//

import Foundation
import CloudKit

extension CKContainer{
    
    static var mapsForOSMContainerName = "iCloud.MapsForOSM"
    
    static var jsonType: CKRecord.RecordType = "json"
    static var fileType: CKRecord.RecordType = "file"
    
    static var appDataKey = "appData"
    static var stringKey = "string"
    
    static var placeIdKey = "placeId"
    static var fileIdKey = "fileId"
    static var fileNameKey = "fileName"
    static var fileAssetKey = "fileAsset"
    
    static var privateDatabase = CKContainer(identifier: mapsForOSMContainerName).privateCloudDatabase
    
    static func fetchFromICloud(recordId: CKRecord.ID, processRecord: @escaping (CKRecord) -> Void){
        let operation = CKFetchRecordsOperation(recordIDs: [recordId])
        operation.perRecordResultBlock = { (id: CKRecord.ID, result: Result<CKRecord, any Error>) in
            do{
                switch result {
                case .failure(let error):
                    Log.error(error: error)
                case .success:
                    let firstResult = try result.get()
                    processRecord(firstResult)
                }
            }
            catch (let err) {
                Log.error(error: err)
            }
        }
        privateDatabase.add(operation)
    }
    
    static func fetchFromICloud(recordIds: [CKRecord.ID], keys: Array<String>, processRecord: @escaping (CKRecord) -> Void, completion: @escaping ((Bool) -> Void)){
        let operation = CKFetchRecordsOperation(recordIDs: recordIds)
        operation.desiredKeys = keys
        operation.perRecordResultBlock = { (id: CKRecord.ID, result: Result<CKRecord, any Error>) in
            switch result {
            case .failure(let error):
                Log.error(error: error)
            case .success(let record):
                processRecord(record)
            }
        }
        operation.fetchRecordsResultBlock = { result in
            switch result{
            case .failure:
                completion(false)
            case .success():
                completion(true)
            }
        }
        privateDatabase.add(operation)
    }
    
    static func queryFromICloud(query: CKQuery, keys: Array<String>? = nil, processRecord: @escaping (CKRecord) -> Void, completion: ((Bool) -> Void)? = nil){
        let operation = CKQueryOperation(query: query)
        if let keys = keys{
            operation.desiredKeys = keys
        }
        operation.recordMatchedBlock = { (recordId: CKRecord.ID, result: Result<CKRecord, (any Error)>) in
            switch result {
            case .failure(let error):
                Log.error(error: error)
            case .success(let record):
                processRecord(record)
            }
        }
        if let completion = completion{
            operation.queryResultBlock = { (operationResult: Result<CKQueryOperation.Cursor?, any Error>) in
                completion(true)
            }
        }
        privateDatabase.add(operation)
    }
    
    static func saveToICloud(records: Array<CKRecord>){
        Log.debug("container: saving \(records.count) records")
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil).forUpdate()
        operation.perRecordSaveBlock = { (resultId: CKRecord.ID, result : Result<CKRecord, any Error>) in
            switch result{
            case .failure(let err):
                Log.error(error: err)
            case .success(let record):
                Log.debug("saved \(record.recordID)")
            }
        }
        privateDatabase.add(operation)
    }
    
    static func deleteFromICloud(recordIds: Array<CKRecord.ID>){
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIds).forDelete()
        privateDatabase.add(operation)
    }
    
}
