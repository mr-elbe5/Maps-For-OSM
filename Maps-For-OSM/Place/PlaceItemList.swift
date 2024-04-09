/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

extension Array<PlaceItem>{
    
    mutating func remove(_ item: PlaceItem){
        for idx in 0..<self.count{
            if self[idx] == item{
                item.prepareDelete()
                self.remove(at: idx)
                return
            }
        }
    }
    
    func contains(_ item: PlaceItem) -> Bool{
        for idx in 0..<self.count{
            if self[idx] == item{
                return true
            }
        }
        return false
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
            for item in self{
                if !item.selected{
                    return false
                }
            }
            return true
        }
    }
    
    var allUnselected: Bool{
        get{
            for item in self{
                if item.selected{
                    return false
                }
            }
            return true
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

