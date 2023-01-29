/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import UIKit

class Track : Hashable, Codable{
    
    static func == (lhs: Track, rhs: Track) -> Bool {
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
    
    static var minTrackingInterval = 5.0 // seconds
    static var maxHorizontalDeviation = 3.0 // meters
    static var maxVerticalDeviation = 1.0 // meters
    
    var id : UUID
    var startTime : Date
    var pauseTime : Date? = nil
    var pauseLength : TimeInterval = 0
    var endTime : Date
    var name : String
    var trackpoints : TrackPointList
    var distance : CGFloat
    var upDistance : CGFloat
    var downDistance : CGFloat
    
    var duration : TimeInterval{
        if let pauseTime = pauseTime{
            return startTime.distance(to: pauseTime) - pauseLength
        }
        return startTime.distance(to: endTime) - pauseLength
    }
    
    var durationUntilNow : TimeInterval{
        if let pauseTime = pauseTime{
            return startTime.distance(to: pauseTime) - pauseLength
        }
        return startTime.distance(to: Date()) - pauseLength
    }
    
    init(){
        id = UUID()
        name = "trk"
        startTime = Date()
        endTime = Date()
        trackpoints = TrackPointList()
        distance = 0
        upDistance = 0
        downDistance = 0
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        startTime = try values.decodeIfPresent(Date.self, forKey: .startTime) ?? Date()
        endTime = try values.decodeIfPresent(Date.self, forKey: .endTime) ?? Date()
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        trackpoints = try values.decodeIfPresent(TrackPointList.self, forKey: .trackpoints) ?? TrackPointList()
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
    
    func pauseTracking(){
        pauseTime = Date()
    }
    
    func resumeTracking(){
        if let pauseTime = pauseTime{
            pauseLength += pauseTime.distance(to: Date())
            self.pauseTime = nil
        }
    }
    
    //todo treat as normal trackpoints
    func evaluateImportedTrackpoints(){
        distance = 0
        upDistance = 0
        downDistance = 0
        if let time = trackpoints.first?.timestamp{
            startTime = time
        }
        if let time = trackpoints.last?.timestamp{
            endTime = time
        }
        var last : TrackPoint? = nil
        for tp in trackpoints{
            if let last = last{
                distance += last.coordinate.distance(to: tp.coordinate)
                let vDist = tp.altitude - last.altitude
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
    
    func addLocation(_ location: CLLocation) -> Bool{
        if let lastTP = trackpoints.last{
            let interval = lastTP.timestamp.distance(to: location.timestamp)
            if interval < Track.minTrackingInterval{
                return false
            }
            let distance = lastTP.distance(from: lastTP)
            if distance < Track.maxHorizontalDeviation{
                return false
            }
            var trackpointsChanged = false
            let tp = TrackPoint(location: location)
            trackpoints.append(tp)
            if removeRedundant(backFrom: trackpoints.count - 1){
                trackpointsChanged = true
            }
            if trackpointsChanged{
                self.distance = trackpoints.distance
                upDistance = trackpoints.upDistance
                downDistance = trackpoints.downDistance
            }
            else{
                self.distance += tp.horizontalDistance
                if tp.verticalDistance > 0{
                    upDistance += tp.verticalDistance
                }
                else{
                    //invert negative
                    downDistance -= tp.verticalDistance
                }
            }
        }
        else{
            let tp = TrackPoint(location: location)
            trackpoints.append(tp)
        }
        endTime = location.timestamp
        return true
    }
    
    func removeRedundant(backFrom last: Int) -> Bool{
        if last < 2 || last + 2 >= trackpoints.count{
            return false
        }
        let tp0 = trackpoints[last - 2]
        let tp1 = trackpoints[last - 1]
        let tp2 = trackpoints[last]
        //calculate expected middle coordinated between outer coordinates by triangles
        let expectedLatitude = (tp2.coordinate.latitude - tp0.coordinate.latitude)/(tp2.coordinate.longitude - tp0.coordinate.longitude) * (tp1.coordinate.longitude - tp0.coordinate.longitude) + tp0.coordinate.latitude
        let expectedCoordinate = CLLocationCoordinate2D(latitude: expectedLatitude, longitude: tp1.coordinate.longitude)
        //check for middle coordinate being close to expected coordinate
        if tp1.coordinate.distance(to: expectedCoordinate) < Track.maxHorizontalDeviation{
            trackpoints.remove(at: last - 1)
            tp2.horizontalDistance = tp0.coordinate.distance(to: tp2.coordinate)
            tp2.verticalDistance = tp2.altitude - tp0.altitude
            return true
        }
        return false
    }
    
    func smoothen(){
        debug("removing redundant trackpoints starting with \(trackpoints.count)")
        var i = 0
        while i + 2 < trackpoints.count{
            if !removeRedundant(backFrom: i){
                i += 1
            }
        }
        debug("removing redundant trackpoints ending with \(trackpoints.count)")
    }
    
}

