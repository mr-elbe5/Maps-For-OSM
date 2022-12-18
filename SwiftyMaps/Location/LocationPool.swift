/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import UIKit

class LocationPool{
    
    static var storeKey = "locations"
    
    static private var _lock = DispatchSemaphore(value: 1)
    
    static var list = LocationList()
    
    static var size : Int{
        list.count
    }
    
    static func load(){
        if let list : LocationList = DataController.shared.load(forKey: LocationPool.storeKey){
            LocationPool.list = list
        }
        else{
            LocationPool.list = LocationList()
        }
    }
    
    static func save(){
        _lock.wait()
        defer{_lock.signal()}
        DataController.shared.save(forKey: LocationPool.storeKey, value: list)
    }
    
    static func location(at idx: Int) -> Location?{
        list[idx]
    }
    
    @discardableResult
    static func addLocation(coordinate: CLLocationCoordinate2D) -> Location{
        _lock.wait()
        defer{_lock.signal()}
        let location = Location(coordinate: coordinate)
        list.append(location)
        return location
    }
    
    static func deleteLocation(_ location: Location){
        _lock.wait()
        defer{_lock.signal()}
        for idx in 0..<list.count{
            if list[idx] == location{
                location.deleteAllMedia()
                list.remove(at: idx)
                return
            }
        }
    }
    
    static func deleteAllLocations(){
        _lock.wait()
        defer{_lock.signal()}
        for idx in 0..<list.count{
            list[idx].deleteAllMedia()
        }
        list.removeAll()
    }
    
    static func locationNextTo(coordinate: CLLocationCoordinate2D, maxDistance: CLLocationDistance) -> Location?{
        var distance : CLLocationDistance = Double.infinity
        var nearestLocation : Location? = nil
        for location in list{
            let dist = location.coordinate.distance(to: coordinate)
            if dist<maxDistance && dist<distance{
                distance = dist
                nearestLocation = location
            }
        }
        return nearestLocation
    }
    
}
