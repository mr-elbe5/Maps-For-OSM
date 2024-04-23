/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

typealias PlaceItemList = Array<PlaceItem>

extension PlaceItemList{
    
    mutating func remove(_ item: PlaceItem){
        item.prepareDelete()
        removeAll(where: {
            $0.equals(item)
        })
    }
    
    mutating func removeAllItems(){
        for item in self{
            item.prepareDelete()
        }
        self.removeAll()
    }
    
    mutating func removeDuplicates(){
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
    
    func getDuplicates(of item: PlaceItem) -> PlaceItemList{
        var list = PlaceItemList()
        for otherItem in self{
            if item != otherItem, item.equals(otherItem){
                list.append(otherItem)
            }
        }
        return list
    }
    
}

