/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

typealias ImageList = Array<ImageItem>

extension ImageList{
    
    mutating func remove(_ image: ImageItem){
        for idx in 0..<self.count{
            if self[idx] == image{
                self.remove(at: idx)
                return
            }
        }
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

protocol ImageListDelegate: ImageDelegate{
    
}
