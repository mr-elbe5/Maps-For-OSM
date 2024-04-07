//
//  CKOperation.swift
//  Maps for OSM
//
//  Created by Michael Rönnau on 07.04.24.
//

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
