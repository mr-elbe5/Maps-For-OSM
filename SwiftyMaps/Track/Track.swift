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
    
    var id : UUID
    var startTime : Date
    var pauseTime : Date? = nil
    var pauseLength : TimeInterval = 0
    var endTime : Date
    var name : String
    var trackpoints : TrackpointList
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
        trackpoints = TrackpointList()
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
        trackpoints = try values.decodeIfPresent(TrackpointList.self, forKey: .trackpoints) ?? TrackpointList()
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
        var last : Trackpoint? = nil
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
        removeAllRedundant()
    }
    
    func addLocation(_ location: CLLocation) -> Bool{
        let tp = Trackpoint(location: location)
        tp.checkValidity()
        if !tp.horizontallyValid{
            return false
        }
        if let previousTrackpoint = trackpoints.last{
            tp.updateDeltas(from: previousTrackpoint)
            if tp.timeDiff < Preferences.shared.trackpointInterval{
                return false
            }
            if tp.horizontalDistance < Preferences.shared.minHorizontalTrackpointDistance && tp.verticalDistance == 0{
                return false
            }
            //debug("tp.alt = \(tp.altitude)")
            trackpoints.append(tp)
            //debug("vertDist = \(tp.verticalDistance)")
            if removeRedundant(backFrom: trackpoints.count - 1){
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
            trackpoints.append(tp)
            startTime = tp.timestamp
        }
        endTime = tp.timestamp
        return true
    }
    
    func removeRedundant(backFrom last: Int) -> Bool{
        if last < 2 || last >= trackpoints.count{
            return false
        }
        let tp0 = trackpoints[last - 2]
        let tp1 = trackpoints[last - 1]
        let tp2 = trackpoints[last]
        //calculate expected middle coordinated between outer coordinates by triangles
        let expectedLatitude = (tp2.coordinate.latitude - tp0.coordinate.latitude)/(tp2.coordinate.longitude - tp0.coordinate.longitude) * (tp1.coordinate.longitude - tp0.coordinate.longitude) + tp0.coordinate.latitude
        let expectedCoordinate = CLLocationCoordinate2D(latitude: expectedLatitude, longitude: tp1.coordinate.longitude)
        //check for middle coordinate being close to expected coordinate
        if tp1.coordinate.distance(to: expectedCoordinate) < Preferences.shared.maxHorizontalUncertainty{
            trackpoints.remove(at: last - 1)
            tp2.updateDeltas(from: tp0)
            return true
        }
        return false
    }
    
    func removeAllRedundant(){
        Log.info("removing redundant trackpoints starting with \(trackpoints.count)")
        var i = 0
        while i + 2 < trackpoints.count{
            if !removeRedundant(backFrom: i){
                i += 1
            }
        }
        Log.info("removing redundant trackpoints ending with \(trackpoints.count)")
    }
    
}

