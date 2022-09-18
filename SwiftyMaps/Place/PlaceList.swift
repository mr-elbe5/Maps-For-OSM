/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

typealias PlaceList = Array<Place>
    
extension PlaceList{
    
    static var storeKey = "locations"
    
    static func load() -> PlaceList{
        if let locations : PlaceList = DataController.shared.load(forKey: PlaceList.storeKey){
            return locations
        }
        else{
            return PlaceList()
        }
    }
    
    static func save(_ list: PlaceList){
        DataController.shared.save(forKey: PlaceList.storeKey, value: list)
    }
    
}

