/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation

class TrackRecorder: Codable{
    
    static var storeKey = "recordedTrack"
    
    static var instance: TrackRecorder? = nil
    
    static func load(){
        if let recorder: TrackRecorder = UserDefaults.standard.load(forKey: TrackRecorder.storeKey){
            instance = recorder
            instance?.interrupted = true
            Log.info("interrupted track loaded")
            UserDefaults.standard.removeObject(forKey: TrackRecorder.storeKey)
        }
    }
    
    static func startTracking(){
        instance = TrackRecorder()
    }
    
    @discardableResult
    static func stopTracking() -> TrackItem?{
        if let trackRecorder = instance{
            let track = trackRecorder.track
            instance = nil
            return track
        }
        return nil
    }
    
    static var isRecording: Bool{
        instance != nil && instance!.isRecording
    }
    
    enum CodingKeys: String, CodingKey{
        case track
        case speed
        case horizontalAccuracy
    }
    
    var track: TrackItem
    var isRecording: Bool
    
    var lastSaved = Date()
    var interrupted: Bool = false
    
    var speed: Double
    var horizontalAccuracy: Double
    
    var kmhSpeed: Int{
        return Int(speed * 3.6)
    }
    
    init(){
        track = TrackItem()
        isRecording = false
        speed = 0
        horizontalAccuracy = 0
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        track = try values.decodeIfPresent(TrackItem.self, forKey: .track) ?? TrackItem()
        speed = try values.decodeIfPresent(Double.self, forKey: .speed) ?? 0
        horizontalAccuracy = try values.decodeIfPresent(Double.self, forKey: .horizontalAccuracy) ?? 0
        isRecording = false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(track, forKey: .track)
        try container.encode(speed, forKey: .speed)
        try container.encode(horizontalAccuracy, forKey: .horizontalAccuracy)
    }
    
    func startRecording(){
        isRecording = true
    }
    
    func pauseRecording(){
        track.pauseTracking()
        isRecording = false
    }
    
    func resumeRecording(){
        track.resumeTracking()
        isRecording = true
    }
    
    func addTrackpoint(from location: CLLocation){
        track.addTrackpoint(from: location)
        speed = location.speed
        horizontalAccuracy = location.horizontalAccuracy
        if lastSaved.timeIntervalSinceReferenceDate > 5*60{
            save()
            Log.info("track saved")
            lastSaved = Date()
        }
    }
    
    func save(){
        UserDefaults.standard.save(forKey: TrackRecorder.storeKey, value: self)
        Log.info("interrupted track saved")
    }
    
}
