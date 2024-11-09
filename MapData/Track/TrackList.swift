/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation

typealias TrackList = Array<TrackItem>

extension TrackList{
    
    mutating func remove(_ track: TrackItem){
        for idx in 0..<self.count{
            if self[idx].equals(track){
                self.remove(at: idx)
                return
            }
        }
    }
    
    mutating func sortByDate(){
        self.sort(by: { $0.startTime < $1.startTime})
    }
    
}

