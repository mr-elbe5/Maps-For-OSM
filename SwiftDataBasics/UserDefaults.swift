/*
 E5Data
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

extension UserDefaults{
    
    func save(forKey key: String, value: Codable) {
        let storeString = value.toJSON()
        set(storeString, forKey: key)
    }
    
    func load<T : Codable>(forKey key: String) -> T? {
        if let storedString = value(forKey: key) as? String {
            return T.fromJSON(encoded: storedString)
        }
        return nil
    }
    
    func remove(forKey key: String){
        removeObject(forKey: key)
    }
    
}
