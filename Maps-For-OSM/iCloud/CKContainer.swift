/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit

extension CKContainer{
    
    static var container = CKContainer(identifier: CloudSynchronizer.mapsForOSMContainerName)
    static var privateDatabase = container.privateCloudDatabase
    
    static func checkConncted(completion: @escaping (Bool) -> Void){
        container.accountStatus(completionHandler: { status, error in
            completion(error == nil && status == .available)
        })
    }
    
    static func isConnected() async throws -> Bool{
        return try await container.accountStatus() == .available
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
