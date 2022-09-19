//
//  Tracks.swift
//  SwiftyMaps for OSM
//
//  Created by Michael Rönnau on 19.09.22.
//

import Foundation

typealias TrackList = Array<Track>

extension TrackList{
    
    static var storeKey = "tracks"
    
    static func load() -> TrackList{
        if let list : TrackList = DataController.shared.load(forKey: TrackList.storeKey){
            return list
        }
        else{
            var list = TrackList()
            for place in Places.list{
                for track in place.getTracks(){
                    list.append(track)
                }
            }
            save(list)
            return list
        }
    }
    
    static func save(_ list: TrackList){
        DataController.shared.save(forKey: TrackList.storeKey, value: list)
    }
    
    mutating func remove(_ track: Track){
        for idx in 0..<self.count{
            if self[idx] == track{
                self.remove(at: idx)
                return
            }
        }
    }
    
}

class Tracks{
    
    static var list = TrackList.load()
    
    static private var _lock = DispatchSemaphore(value: 1)
    
    static var trackCount : Int{
        list.count
    }
    
    static func track(at idx: Int) -> Track?{
        list[idx]
    }
    
    static func addTrack(track: Track){
        _lock.wait()
        defer{_lock.signal()}
        list.append(track)
    }
    
    static func deleteTrack(_ track: Track){
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
    
    static func saveTracks(){
        _lock.wait()
        defer{_lock.signal()}
        TrackList.save(list)
    }
    
}
