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
    
    mutating func removePlaces(of list: PlaceList){
        for place in list{
            remove(place)
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

class PlacePool{
    
    static var storeKey = "locations"
    
    static private var _lock = DispatchSemaphore(value: 1)
    
    static var places = PlaceList()
    
    static var tracks: Array<Track>{
        get{
            var trackList = Array<Track>()
            for place in places{
                trackList.append(contentsOf: place.tracks)
            }
            return trackList
        }
    }
    
    static var images: Array<Image>{
        get{
            var imageList = Array<Image>()
            for place in places{
                imageList.append(contentsOf: place.images)
            }
            return imageList
        }
    }
    
    static var size : Int{
        places.count
    }
    
    static func load(){
        if let list : PlaceList = DataController.shared.load(forKey: PlacePool.storeKey){
            PlacePool.places = list
        }
        else{
            PlacePool.places = PlaceList()
        }
    }
    
    static func save(){
        _lock.wait()
        defer{_lock.signal()}
        DataController.shared.save(forKey: PlacePool.storeKey, value: places)
    }
    
    static func saveAsFile() -> URL?{
        let value = places.toJSON()
        let url = FileController.temporaryURL.appendingPathComponent(storeKey + ".json")
        if FileController.saveFile(text: value, url: url){
            return url
        }
        return nil
    }
    
    static func loadFromFile(url: URL){
        if let string = FileController.readTextFile(url: url),let data : PlaceList = PlaceList.fromJSON(encoded: string){
            places = data
        }
    }
    
    @discardableResult
    static func addPlace(coordinate: CLLocationCoordinate2D) -> Place{
        _lock.wait()
        defer{_lock.signal()}
        let place = Place(coordinate: coordinate)
        places.append(place)
        return place
    }
    
    static func deletePlace(_ place: Place){
        _lock.wait()
        defer{_lock.signal()}
        for idx in 0..<places.count{
            if places[idx] == place{
                place.deleteAllItems()
                places.remove(at: idx)
                return
            }
        }
    }
    
    static func deleteAllPlaces(){
        _lock.wait()
        defer{_lock.signal()}
        for idx in 0..<places.count{
            places[idx].deleteAllItems()
        }
        places.removeAll()
    }
    
    @discardableResult
    static func assertPlace(coordinate: CLLocationCoordinate2D) -> Place{
        for place in places{
            if place.coordinateRegion.contains(coordinate: coordinate){
                return place
            }
        }
        let place = PlacePool.addPlace(coordinate: coordinate)
        save()
        return place
    }
    
    static func addNotesToPlaces(){
        Log.info("converting notes to note items")
        for place in places{
            if !place.note.isEmpty{
                if !{
                    for item in place.notes{
                        if item.text == place.note{
                            return true
                        }
                    }
                    return false
                }(){
                    let noteItem = Note()
                    noteItem.text = place.note
                    noteItem.creationDate = place.timestamp
                    place.addItem(item: noteItem)
                    place.note = ""
                    Log.debug("added note item")
                }
            }
        }
        save()
    }
    
}
