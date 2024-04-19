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
           $0 == item
        })
    }
    
    mutating func removeAllItems(){
        for item in self{
            item.prepareDelete()
        }
        self.removeAll()
    }
    
    mutating func sortByCreation(){
        self.sort(by: {
            $0.creationDate > $1.creationDate
        })
    }
    
    var allSelected: Bool{
        get{
            !contains(where: {
                !$0.selected
            })
        }
    }
    
    var allUnselected: Bool{
        get{
            !contains(where: {
                $0.selected
            })
        }
    }
    
    mutating func selectAll(){
        for item in self{
            item.selected = true
        }
    }
    
    mutating func deselectAll(){
        for item in self{
            item.selected = false
        }
    }
    
}

