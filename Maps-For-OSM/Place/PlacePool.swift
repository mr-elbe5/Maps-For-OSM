/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import UIKit

typealias PlaceList = Array<Place>

extension PlaceList{
    
    mutating func remove(_ place: Place){
        for idx in 0..<self.count{
            if self[idx] == place{
                self.remove(at: idx)
                return
            }
        }
    }
    
    mutating func removeAllOf(_ list: PlaceList){
        for place in list{
            remove(place)
        }
    }
    
}

class PlacePool{
    
    static var storeKey = "places"
    static var oldStoreKey = "locations"
    
    static private var _lock = DispatchSemaphore(value: 1)
    
    static var list = PlaceList()
    
    static var size : Int{
        list.count
    }
    
    static func load(){
        if let list : PlaceList = DataController.shared.load(forKey: PlacePool.storeKey){
            PlacePool.list = list
        }
        else if let list : PlaceList = DataController.shared.load(forKey: PlacePool.oldStoreKey){
            PlacePool.list = list
        }
        else{
            PlacePool.list = PlaceList()
        }
    }
    
    static func save(){
        _lock.wait()
        defer{_lock.signal()}
        DataController.shared.save(forKey: PlacePool.storeKey, value: list)
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
        if let string = FileController.readTextFile(url: url),let data : PlaceList = PlaceList.fromJSON(encoded: string){
            list = data
        }
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
                place.deleteAllMedia()
                list.remove(at: idx)
                return
            }
        }
    }
    
    static func deleteAllPlaces(){
        _lock.wait()
        defer{_lock.signal()}
        for idx in 0..<list.count{
            list[idx].deleteAllMedia()
        }
        list.removeAll()
    }
    
    @discardableResult
    static func assertPlace(coordinate: CLLocationCoordinate2D) -> Place{
        for place in list{
            if place.coordinateRegion.contains(coordinate: coordinate){
                return place
            }
        }
        let place = PlacePool.addPlace(coordinate: coordinate)
        save()
        return place
    }
    
}
