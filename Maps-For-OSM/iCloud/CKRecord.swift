/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit

extension CKRecord{
    
    static var jsonType: CKRecord.RecordType = "json"
    static var fileType: CKRecord.RecordType = "file"
    
    static func createJsonRecord(recordName: String) -> CKRecord {
        return CKRecord(recordType: jsonType, recordID: CKRecord.ID(recordName: recordName))
    }
    
    static func createFileRecord(recordName: String) -> CKRecord {
        return CKRecord(recordType: fileType, recordID: CKRecord.ID(recordName: recordName))
    }
    
}
