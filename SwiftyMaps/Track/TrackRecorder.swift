/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import UIKit

class TrackRecorder{
    
    static var track : Track? = nil
    static var isRecording : Bool = false
    
    static func startRecording(startPoint: TrackPoint){
        if track == nil{
            track = Track()
            track!.trackpoints.append(TrackPoint(location: startPoint))
        }
        isRecording = true
    }
    
    static func updateTrack(with location: CLLocation) -> Bool{
        if let track = track{
            return track.updateTrack(location)
        }
        return false
    }
    
    static func pauseRecording(){
        if let track = track{
            track.pauseTracking()
            isRecording = false
        }
    }
    
    static func resumeRecording(){
        if let track = track{
            track.resumeTracking()
            isRecording = true
        }
    }
    
    static func stopRecording(){
        if track != nil{
            isRecording = false
            track = nil
        }
    }
    
}
