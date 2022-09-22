/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import UIKit

class Places{
    
    static var storeKey = "locations"
    
    static private var _lock = DispatchSemaphore(value: 1)
    
    static var list = PlaceList()
    
    static var size : Int{
        list.count
    }
    
    static func load(){
        if let list : PlaceList = DataController.shared.load(forKey: Places.storeKey){
            Places.list = list
        }
        else{
            Places.list = PlaceList()
        }
    }
    
    static func save(){
        _lock.wait()
        defer{_lock.signal()}
        DataController.shared.save(forKey: Places.storeKey, value: list)
    }
    
    static func place(at idx: Int) -> Place?{
        list[idx]
    }
    
    @discardableResult
    static func addPlace(coordinate: CLLocationCoordinate2D) -> Place{
        _lock.wait()
        defer{_lock.signal()}
        let place = Place(coordinate: coordinate)
        list.append(place)
        return place
    }
    
    static func deletePlace(_ place: Place){
        _lock.wait()
        defer{_lock.signal()}
        for idx in 0..<list.count{
            if list[idx] == place{
                place.deleteAllPhotos()
                list.remove(at: idx)
                return
            }
        }
    }
    
    static func deleteAllPlaces(){
        _lock.wait()
        defer{_lock.signal()}
        for idx in 0..<list.count{
            list[idx].deleteAllPhotos()
        }
        list.removeAll()
    }
    
    static func placeNextTo(coordinate: CLLocationCoordinate2D, maxDistance: CLLocationDistance) -> Place?{
        var distance : CLLocationDistance = Double.infinity
        var nearestPlace : Place? = nil
        for location in list{
            let dist = location.coordinate.distance(to: coordinate)
            if dist<maxDistance && dist<distance{
                distance = dist
                nearestPlace = location
            }
        }
        return nearestPlace
    }
    
}
