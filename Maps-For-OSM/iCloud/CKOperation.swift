/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit

extension CKModifyRecordsOperation{
    
    func forUpdate() -> CKModifyRecordsOperation{
        let operationConfiguration = CKOperation.Configuration()
        operationConfiguration.allowsCellularAccess = true
        operationConfiguration.qualityOfService = .userInitiated
        self.configuration = operationConfiguration
        self.savePolicy = .changedKeys
        return self
    }
    
    func forDelete() -> CKModifyRecordsOperation{
        let operationConfiguration = CKOperation.Configuration()
        operationConfiguration.allowsCellularAccess = true
        operationConfiguration.qualityOfService = .userInitiated
        self.configuration = operationConfiguration
        return self
    }
    
}
