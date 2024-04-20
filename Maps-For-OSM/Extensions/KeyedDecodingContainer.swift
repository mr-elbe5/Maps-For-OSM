//
//  KeyedDecodingContainer.swift
//  Maps for OSM
//
//  Created by Michael Rönnau on 20.04.24.
//

import Foundation

extension KeyedDecodingContainer{
    
    func decodeIfPresent<T>(_ type:T.Type, forKeys keys: Array<K>) throws -> T?  where T : Decodable{
        for key in keys{
            if let obj = try self.decodeIfPresent(type, forKey: key){
                return obj
            }
        }
        return nil
    }
    
}
