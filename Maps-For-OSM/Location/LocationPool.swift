/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import UIKit

typealias LocationList = Array<Location>

extension LocationList{
    
    mutating func remove(_ location: Location){
        for idx in 0..<self.count{
            if self[idx] == location{
                self.remove(at: idx)
                return
            }
        }
    }
    
    mutating func removeAllOf(_ list: LocationList){
        for location in list{
            remove(location)
        }
    }
    
}

class LocationPool{
    
    static var storeKey = "locations"
    
    static var maxMergeDistance = 10.0
    
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
    
    static func saveAsFile() -> URL?{
        let value = list.toJSON()
        let url = FileController.temporaryURL.appendingPathComponent(storeKey + ".json")
        if FileController.saveFile(text: value, url: url){
            return url
        }
        return nil
    }
    
    static func loadFromFile(url: URL){
        if let string = FileController.readTextFile(url: url),let data : LocationList = LocationList.fromJSON(encoded: string){
            list = data
        }
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
    
    static func locationNextTo(coordinate: CLLocationCoordinate2D) -> Location?{
        var distance : CLLocationDistance = Double.infinity
        var nearestLocation : Location? = nil
        for location in list{
            let dist = location.coordinate.distance(to: coordinate)
            if dist<maxMergeDistance && dist<distance{
                distance = dist
                nearestLocation = location
            }
        }
        return nearestLocation
    }
    
}
