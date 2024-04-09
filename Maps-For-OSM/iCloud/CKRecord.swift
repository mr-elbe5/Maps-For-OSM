//
//  CKRecord.swift
//  Maps for OSM
//
//  Created by Michael Rönnau on 09.04.24.
//

import Foundation
import CloudKit

extension CKRecord{
    
    func string(_ key: String) -> String?{
        value(forKey: key) as? String
    }
    
    func debugString(_ key: String) -> String{
        string(key) ?? "none"
    }
    
    func uuid(_ key: String) -> UUID?{
        if let uuidstring = string(key){
            return UUID(uuidString: uuidstring)
        }
        return nil
    }
    
    func asset(_ key: String) -> CKAsset?{
        value(forKey: key) as? CKAsset
    }
    
}
