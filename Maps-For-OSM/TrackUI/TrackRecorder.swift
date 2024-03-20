/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import UIKit

class TrackRecorder{
    
    static var track : TrackData? = nil
    static var isRecording : Bool = false
    
    static func startRecording(startLocation: CLLocation){
        if track == nil{
            track = TrackData()
            track!.trackpoints.append(Trackpoint(location: startLocation))
        }
        isRecording = true
    }
    
    static func updateTrack(with location: CLLocation) -> Bool{
        if let track = track{
            return track.addLocation(location)
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
