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
    var distance : CGFloat
    var isRecording: Bool
    
    var isTracking: Bool{
        trackpoints.count > 0
    }
    
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
        isRecording = false
    }
    
    func startTracking(at location: CLLocation){
        addTrackpoint(from: location)
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
    
    func saveTrack(){
        isRecording = false
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(trackpoints){
            if let json = String(data:data, encoding: .utf8){
                PhoneConnector.instance.saveTrack(json: json){ success in
                    if success{
                        self.trackpoints.removeAll()
                    }
                }
            }
        }
    }
    
    func cancelTrack(){
        isRecording = false
        trackpoints.removeAll()
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
