/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import UIKit

class Places{
    
    static private var _lock = DispatchSemaphore(value: 1)
    
    static var list : PlaceList = PlaceList.load()
    
    static var size : Int{
        list.count
    }
    
    static func location(at idx: Int) -> Place?{
        list[idx]
    }
    
    @discardableResult
    static func addLocation(coordinate: CLLocationCoordinate2D) -> Place{
        _lock.wait()
        defer{_lock.signal()}
        let location = Place(coordinate: coordinate)
        list.append(location)
        return location
    }
    
    static func deleteLocation(_ location: Place){
        _lock.wait()
        defer{_lock.signal()}
        for idx in 0..<list.count{
            if list[idx] == location{
                location.deleteAllPhotos()
                list.remove(at: idx)
                return
            }
        }
    }
    
    static func deleteAllLocations(){
        _lock.wait()
        defer{_lock.signal()}
        for idx in 0..<list.count{
            list[idx].deleteAllPhotos()
        }
        list.removeAll()
    }
    
    static func locationNextTo(coordinate: CLLocationCoordinate2D, maxDistance: CLLocationDistance) -> Place?{
        var distance : CLLocationDistance = Double.infinity
        var nextLocation : Place? = nil
        for location in list{
            let dist = location.coordinate.distance(to: coordinate)
            if dist<maxDistance && dist<distance{
                distance = dist
                nextLocation = location
            }
        }
        return nextLocation
    }
    
    static func save(){
        _lock.wait()
        defer{_lock.signal()}
        PlaceList.save(list)
    }
    
}
