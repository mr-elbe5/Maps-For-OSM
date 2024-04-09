/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

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
