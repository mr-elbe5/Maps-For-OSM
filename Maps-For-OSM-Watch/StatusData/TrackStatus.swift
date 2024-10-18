/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation
import E5Data

@Observable class TrackStatus: NSObject{
    
    static var shared = TrackStatus()
    
    var trackpoints: TrackpointList
    var trackpointCount: Int = 0
    var distance : CGFloat
    var isTracking: Bool
    var isRecording: Bool
    
    var startTime : Date{
        trackpoints.first?.timestamp ?? Date()
    }
    var endTime :Date{
        trackpoints.last?.timestamp ?? Date()
    }
    
    var duration: Range<Date>{
        startTime..<endTime
    }
    
    var durationString: String{
        duration.formatted(.timeDuration)
    }
    
    override init(){
        trackpoints = TrackpointList()
        distance = 0
        isTracking = false
        isRecording = false
    }
    
    func startTracking(){
        trackpoints.removeAll()
        isTracking = true
        isRecording = true
    }
    
    func startRecording(){
        isRecording = true
    }
    
    func stopRecording(){
        isRecording = false
    }
    
    func resumeRecording(){
        isRecording = true
    }
    
    func stopTracking(){
        stopRecording()
        trackpoints.removeAll()
        isTracking = false
    }
    
    func saveTrack(){
        stopRecording()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(trackpoints){
            if let json = String(data:data, encoding: .utf8){
                PhoneConnector.instance.saveTrack(json: json){ success in
                    if success{
                        self.stopTracking()
                    }
                }
            }
        }
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
        distance += horizontalDiff
        Log.info("adding trackpoint at \(tp.coordinate.debugString)")
        trackpoints.append(Trackpoint(location: location))
        trackpointCount = trackpoints.count
        
    }
    
}

