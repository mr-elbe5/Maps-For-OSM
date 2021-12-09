/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import UIKit

class TrackData : Hashable, Codable{
    
    static func == (lhs: TrackData, rhs: TrackData) -> Bool {
        lhs.id == rhs.id
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case startTime
        case endTime
        case name
        case trackpoints
        case distance
        case upDistance
        case downDistance
    }
    
    var id : UUID
    var startTime : Date
    var pauseTime : Date? = nil
    var pauseLength : TimeInterval = 0
    var endTime : Date
    var name : String
    var trackpoints : Array<TrackPoint>
    var distance : CGFloat
    var upDistance : CGFloat
    var downDistance : CGFloat
    
    var startLocation : Location!
    
    var duration : TimeInterval{
        get{
            if let pauseTime = pauseTime{
                return startTime.distance(to: pauseTime) - pauseLength
            }
            return startTime.distance(to: endTime) - pauseLength
        }
    }
    
    var durationUntilNow : TimeInterval{
        get{
            if let pauseTime = pauseTime{
                return startTime.distance(to: pauseTime) - pauseLength
            }
            return startTime.distance(to: Date()) - pauseLength
        }
    }
    
    init(startLocation: Location){
        id = UUID()
        name = "trk"
        startTime = Date()
        endTime = Date()
        trackpoints = Array<TrackPoint>()
        distance = 0
        upDistance = 0
        downDistance = 0
        self.startLocation = startLocation
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        startTime = try values.decodeIfPresent(Date.self, forKey: .startTime) ?? Date()
        endTime = try values.decodeIfPresent(Date.self, forKey: .endTime) ?? Date()
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        trackpoints = try values.decodeIfPresent(Array<TrackPoint>.self, forKey: .trackpoints) ?? Array<TrackPoint>()
        distance = try values.decodeIfPresent(CGFloat.self, forKey: .distance) ?? 0
        upDistance = try values.decodeIfPresent(CGFloat.self, forKey: .upDistance) ?? 0
        downDistance = try values.decodeIfPresent(CGFloat.self, forKey: .downDistance) ?? 0
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(name, forKey: .name)
        try container.encode(trackpoints, forKey: .trackpoints)
        try container.encode(distance, forKey: .distance)
        try container.encode(upDistance, forKey: .upDistance)
        try container.encode(downDistance, forKey: .downDistance)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func updateTrack(_ location: CLLocation){
        let lastTP = trackpoints.last
        if let tp = lastTP{
            if tp.coordinate.distance(to: location.coordinate) < 10{
                //print("too close")
                return
            }
            if tp.location.timestamp.distance(to: location.timestamp) < 2{
                //print("too soon")
                return
            }
        }
        trackpoints.append(TrackPoint(location: location))
        if let lastLoc = lastTP?.location{
            distance += lastLoc.coordinate.distance(to: location.coordinate)
            let vDist = location.altitude - lastLoc.altitude
            if vDist > 0{
                upDistance += vDist
            }
            else{
                //invert negative
                downDistance -= vDist
            }
            endTime = location.timestamp
        }
    }
    
    func pauseTracking(){
        pauseTime = Date()
    }
    
    func resumeTracking(){
        if let pauseTime = pauseTime{
            pauseLength += pauseTime.distance(to: Date())
            self.pauseTime = nil
        }
    }
    
    func evaluateTrackpoints(){
        distance = 0
        upDistance = 0
        downDistance = 0
        if let time = trackpoints.first?.location.timestamp{
            startTime = time
        }
        if let time = trackpoints.last?.location.timestamp{
            endTime = time
        }
        var last : TrackPoint? = nil
        for tp in trackpoints{
            if let last = last{
                distance += last.coordinate.distance(to: tp.coordinate)
                let vDist = tp.location.altitude - last.location.altitude
                if vDist > 0{
                    upDistance += vDist
                }
                else{
                    //invert negative
                    downDistance -= vDist
                }
            }
            last = tp
        }
    }
    
}

