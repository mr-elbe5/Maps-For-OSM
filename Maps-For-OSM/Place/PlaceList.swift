/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

extension Array<Place>{
    
    mutating func remove(_ place: Place){
        removeAll(where: {
           $0 == place
        })
    }
    
    mutating func removePlaces(of list: Array<Place>){
        for place in list{
            remove(place)
        }
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
