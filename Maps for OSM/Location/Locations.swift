/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import UIKit

class Locations{
    
    static var storeKey = "locations"
    
    static private var _lock = DispatchSemaphore(value: 1)
    
    static var list = LocationList()
    
    static var size : Int{
        list.count
    }
    
    static func load(){
        if let list : LocationList = DataController.shared.load(forKey: Locations.storeKey){
            Locations.list = list
        }
        else{
            Locations.list = LocationList()
        }
    }
    
    static func save(){
        _lock.wait()
        defer{_lock.signal()}
        DataController.shared.save(forKey: Locations.storeKey, value: list)
    }
    
    static func place(at idx: Int) -> Location?{
        list[idx]
    }
    
    @discardableResult
    static func addPlace(coordinate: CLLocationCoordinate2D) -> Location{
        _lock.wait()
        defer{_lock.signal()}
        let place = Location(coordinate: coordinate)
        list.append(place)
        return place
    }
    
    static func deletePlace(_ place: Location){
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
    
    static func placeNextTo(coordinate: CLLocationCoordinate2D, maxDistance: CLLocationDistance) -> Location?{
        var distance : CLLocationDistance = Double.infinity
        var nearestPlace : Location? = nil
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
