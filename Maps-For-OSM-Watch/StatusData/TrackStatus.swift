/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation
import E5Data

@Observable class TrackStatus: NSObject{
    
    var trackpoints: TrackpointList
    var distance : CGFloat
    var isRecording: Bool
    
    var startTime : Date{
        trackpoints.first?.timestamp ?? Date()
    }
    var endTime :Date{
        trackpoints.last?.timestamp ?? Date()
    }
    
    override init(){
        trackpoints = TrackpointList()
        distance = 0
        isRecording = false
    }
    
    func toJSON() -> String{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(trackpoints){
            if let s = String(data:data, encoding: .utf8){
                return s
            }
        }
        return ""
    }
    
    func startRecording(){
        isRecording = true
    }
    
    func pauseRecording(){
        isRecording = false
    }
    
    func resumeRecording(){
        isRecording = true
    }
    
    func addTrackpoint(from location: CLLocation){
        let tp = Trackpoint(location: location)
        if trackpoints.isEmpty{
            trackpoints.append(tp)
            Log.info("starting track at \(tp.coordinate.debugString)")
            return
        }
        let previousTrackpoint = trackpoints.last!
        let timeDiff = previousTrackpoint.timestamp.distance(to: tp.timestamp)
        if timeDiff < Preferences.shared.trackpointInterval{
            return
        }
        let horizontalDiff = previousTrackpoint.coordinate.distance(to: tp.coordinate)
        if horizontalDiff < Preferences.shared.minHorizontalTrackpointDistance{
            return
        }
        Log.info("adding trackpoint at \(tp.coordinate.debugString)")
        trackpoints.append(tp)
        distance += horizontalDiff
        trackpoints.append(Trackpoint(coordinate: location.coordinate, altitude: location.altitude, timestamp: location.timestamp))
        
    }
    
}
