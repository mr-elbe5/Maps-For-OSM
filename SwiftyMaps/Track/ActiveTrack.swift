/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import UIKit

class ActiveTrack{
    
    static var track : Track? = nil
    static var isTracking : Bool = false
    
    static func startTracking(startPoint: TrackPoint){
        if track == nil{
            track = Track()
            track!.trackpoints.append(TrackPoint(location: startPoint))
        }
        isTracking = true
    }
    
    static func updateTrack(with location: CLLocation){
        if let track = track{
            track.updateTrack(location)
        }
    }
    
    static func pauseTracking(){
        if let track = track{
            track.pauseTracking()
            isTracking = false
        }
    }
    
    static func resumeTracking(){
        if let track = track{
            track.resumeTracking()
            isTracking = true
        }
    }
    
    static func stopTracking(){
        if track != nil{
            isTracking = false
            track = nil
        }
    }
    
}
