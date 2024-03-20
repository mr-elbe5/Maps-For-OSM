/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

typealias TrackList = Array<TrackData>

extension TrackList{
    
    mutating func remove(_ track: TrackData){
        for idx in 0..<self.count{
            if self[idx] == track{
                self.remove(at: idx)
                return
            }
        }
    }
    
}

class TrackPool{
    
    static var storeKey = "tracks"
    
    static var list = TrackList()
    
    static var visibleTrack : TrackData? = nil
    
    static private var _lock = DispatchSemaphore(value: 1)
    
    static var trackCount : Int{
        list.count
    }
    
    static func load(){
        if let list : TrackList = DataController.shared.load(forKey: storeKey){
            TrackPool.list = list
        }
    }
    
    static func save(){
        _lock.wait()
        defer{_lock.signal()}
        DataController.shared.save(forKey: storeKey, value: list)
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
        if let string = FileController.readTextFile(url: url),let data : TrackList = TrackList.fromJSON(encoded: string){
            list = data
        }
    }
    
    static func track(at idx: Int) -> TrackData?{
        list[idx]
    }
    
    @discardableResult
    static func addTrack(track: TrackData) -> Bool{
        _lock.wait()
        defer{_lock.signal()}
        if !list.contains(track){
            list.append(track)
            return true
        }
        return false
    }
    
    static func deleteTrack(_ track: TrackData){
        _lock.wait()
        defer{_lock.signal()}
        for idx in 0..<list.count{
            if list[idx] == track{
                list.remove(at: idx)
                return
            }
        }
    }
    
    static func deleteAllTracks(){
        _lock.wait()
        defer{_lock.signal()}
        list.removeAll()
    }
    
    static func addTracksToPlaces(){
        for track in list{
            if let coordinate = track .startCoordinate{
                let place = PlacePool.assertPlace(coordinate: coordinate)
                if !place.items.contains(track){
                    place.items.append(track)
                }
            }
        }
    }
    
}
