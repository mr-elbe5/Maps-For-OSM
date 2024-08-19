/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation
import E5Data

public typealias TrackList = Array<Track>

extension TrackList{
    
    public mutating func remove(_ track: Track){
        for idx in 0..<self.count{
            if self[idx].equals(track){
                self.remove(at: idx)
                return
            }
        }
    }
    
    public mutating func sortByDate(){
        self.sort(by: { $0.startTime < $1.startTime})
    }
    
}

