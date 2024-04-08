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
    
    static var privateDatabase = CKContainer(identifier: mapsForOSMContainerName).privateCloudDatabase
    
    static func loadFromICloud(recordIds: Array<CKRecord.ID>? = nil, keys: Array<String>? = nil, processRecord: @escaping (CKRecord) -> Void, completion: ((Bool) -> Void)? = nil){
        let operation = recordIds == nil ? CKFetchRecordsOperation(): CKFetchRecordsOperation(recordIDs: recordIds!)
        if let keys = keys{
            operation.desiredKeys = keys
        }
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
        if let completion = completion{
            operation.fetchRecordsResultBlock = { result in
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
    
    static func saveToICloud(records: Array<CKRecord>){
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil).forUpdate()
        privateDatabase.add(operation)
    }
    
    static func deleteFromICloud(recordIds: Array<CKRecord.ID>){
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIds).forDelete()
        privateDatabase.add(operation)
    }
    
}
