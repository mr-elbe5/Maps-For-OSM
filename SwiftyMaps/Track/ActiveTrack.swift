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
    
    static func startTracking(startLocation: Place){
        if track == nil{
            Log.log("Tracking started at \(startLocation.coordinate.shortString)")
            track = Track()
            track!.trackpoints.append(TrackPoint(location: startLocation))
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
            Log.log("Tracking stopped after \(String(format: "%.1f",track!.duration))sec")
            isTracking = false
            track = nil
        }
    }
    
}
