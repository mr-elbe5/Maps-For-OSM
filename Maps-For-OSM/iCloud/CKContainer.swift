/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit

extension CKContainer{
    
    static var privateDatabase = CKContainer(identifier: CloudSynchronizer.mapsForOSMContainerName).privateCloudDatabase
    
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
                switch operationResult{
                case .failure:
                    completion(false)
                case .success(let cursor):
                    completion(cursor == nil)
                }
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
    
    static func deleteFromICloud(recordIds: Array<CKRecord.ID>, completion: ((Bool) -> Void)? = nil){
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIds).forDelete()
        if let completion = completion{
            operation.modifyRecordsResultBlock = { (result: Result<Void, any Error>) in
                switch result{
                case .failure:
                    completion(false)
                case .success():
                    completion(true)
                }
            }
        }
        privateDatabase.add(operation)
    }
    
}
