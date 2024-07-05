/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation
import E5Data
import E5MapData

class TrackRecorder: Codable{
    
    public static var storeKey = "recordedTrack"
    
    public static var instance: TrackRecorder? = nil
    
    public static func load(){
        if let recorder: TrackRecorder = UserDefaults.standard.load(forKey: TrackRecorder.storeKey){
            instance = recorder
            instance?.interrupted = true
            Log.info("interrupted track loaded")
            UserDefaults.standard.removeObject(forKey: TrackRecorder.storeKey)
        }
    }
    
    public static func startTracking(){
        instance = TrackRecorder()
    }
    
    @discardableResult
    public static func stopTracking() -> Track?{
        if let trackRecorder = instance{
            let track = trackRecorder.track
            instance = nil
            return track
        }
        return nil
    }
    
    public static var isRecording: Bool{
        instance != nil && instance!.isRecording
    }
    
    enum CodingKeys: String, CodingKey{
        case track
        case speed
        case horizontalAccuracy
    }
    
    public var track: Track
    public var isRecording: Bool
    
    public var lastSaved = Date()
    public var interrupted: Bool = false
    
    public var speed: Double
    public var horizontalAccuracy: Double
    
    public var kmhSpeed: Int{
        return Int(speed * 3.6)
    }
    
    public init(){
        track = Track()
        isRecording = false
        speed = 0
        horizontalAccuracy = 0
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        track = try values.decodeIfPresent(Track.self, forKey: .track) ?? Track()
        speed = try values.decodeIfPresent(Double.self, forKey: .speed) ?? 0
        horizontalAccuracy = try values.decodeIfPresent(Double.self, forKey: .horizontalAccuracy) ?? 0
        isRecording = false
    }
    
    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(track, forKey: .track)
        try container.encode(speed, forKey: .speed)
        try container.encode(horizontalAccuracy, forKey: .horizontalAccuracy)
    }
    
    public func startRecording(){
        isRecording = true
    }
    
    public func pauseRecording(){
        track.pauseTracking()
        isRecording = false
    }
    
    public func resumeRecording(){
        track.resumeTracking()
        isRecording = true
    }
    
    public func addTrackpoint(from location: CLLocation){
        track.addTrackpoint(from: location)
        speed = location.speed
        horizontalAccuracy = location.horizontalAccuracy
        if lastSaved.timeIntervalSinceReferenceDate > 5*60{
            save()
            Log.info("track saved")
            lastSaved = Date()
        }
    }
    
    public func save(){
        UserDefaults.standard.save(forKey: TrackRecorder.storeKey, value: self)
        Log.info("interrupted track saved")
    }
    
}
