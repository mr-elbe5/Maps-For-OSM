/*
 SwiftyDataExtensions
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

extension Dictionary{
    
    mutating func addAll<K, V>(from src: [K:V]){
        for (k, v) in src {
            if let key = k as? Key, let val = v as? Value {
                self[key] = val
            }
        }
    }
    
    func getTypedObject<K,T>(key: K, type: T.Type) -> T?{
        if let k = key as? Key{
            if let val = self[k] as? T{
                return val
            }
        }
        return nil
    }
    
    func getTypedValues<T>(type: T.Type) -> Array<T>{
        var arr = Array<T>()
        for value in values{
            if let val = value as? T{
                arr.append(val)
            }
        }
        return arr
    }
    
    mutating func remove<T : Equatable>(key : T){
        for k in keys{
            if key == k as? T{
                self[k] = nil
                return
            }
        }
    }
    
    mutating func remove<T : Equatable>(value : T){
        for k in keys{
            if value == self[k] as? T{
                self[k] = nil
                return
            }
        }
    }
    
}
