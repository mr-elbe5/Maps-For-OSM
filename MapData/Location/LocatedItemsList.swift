/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import E5Data

public typealias LocatedItemsList = Array<LocatedItem>

extension LocatedItemsList{
    
    public mutating func remove(_ item: LocatedItem){
        item.prepareDelete()
        removeAll(where: {
            $0.equals(item)
        })
    }
    
    public mutating func removeAllItems(){
        for item in self{
            item.prepareDelete()
        }
        self.removeAll()
    }
    
    public mutating func removeDuplicates(){
        for item in self{
            let duplicates = getDuplicates(of: item)
            if duplicates.count > 0{
                Log.warn("\(count) duplicates of id \(item.id)")
            }
            for duplicate in duplicates{
                self.remove(duplicate)
            }
        }
    }
    
    public func getDuplicates(of item: LocatedItem) -> LocatedItemsList{
        var list = LocatedItemsList()
        for otherItem in self{
            if item != otherItem, item.equals(otherItem){
                list.append(otherItem)
            }
        }
        return list
    }
    
}

