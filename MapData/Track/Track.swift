/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif
import E5Data

open class Track : LocatedItem{
    
    public static var previewSize: CGFloat = 512
    
    private enum CodingKeys: String, CodingKey {
        case startTime
        case endTime
        case name
        case trackpoints
        case distance
        case upDistance
        case downDistance
        case note
    }
    
    public static var visibleTrack : Track? = nil
    
    public var startTime : Date
    public var pauseTime : Date? = nil
    public var pauseLength : TimeInterval = 0
    public var endTime : Date
    public var name : String
    public var trackpoints : TrackpointList
    public var distance : CGFloat
    public var upDistance : CGFloat
    public var downDistance : CGFloat
    public var note : String
    
    public var lastAltitude = 0.0
    
    override public var type : LocatedItemType{
        get{
            return .track
        }
    }
    
    var fileName: String{
        "track_\(id).jpg"
    }
    
    var previewURL: URL{
        FileManager.previewsDirURL.appendingPathComponent(fileName)
    }
    
    public var duration : TimeInterval{
        if let pauseTime = pauseTime{
            return startTime.distance(to: pauseTime) - pauseLength
        }
        return startTime.distance(to: endTime) - pauseLength
    }
    
    public var durationUntilNow : TimeInterval{
        if let pauseTime = pauseTime{
            return startTime.distance(to: pauseTime) - pauseLength
        }
        return startTime.distance(to: Date.localDate) - pauseLength
    }
    
    public var startCoordinate: CLLocationCoordinate2D?{
        trackpoints.first?.coordinate
    }
    
    public var endCoordinate: CLLocationCoordinate2D?{
        trackpoints.last?.coordinate
    }
    
    override public init(){
        name = "trk"
        startTime = Date.localDate
        endTime = Date.localDate
        trackpoints = TrackpointList()
        distance = 0
        upDistance = 0
        downDistance = 0
        note = ""
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        startTime = try values.decodeIfPresent(Date.self, forKey: .startTime) ?? Date.localDate
        endTime = try values.decodeIfPresent(Date.self, forKey: .endTime) ?? Date.localDate
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        trackpoints = try values.decodeIfPresent(TrackpointList.self, forKey: .trackpoints) ?? TrackpointList()
        distance = try values.decodeIfPresent(CGFloat.self, forKey: .distance) ?? 0
        upDistance = try values.decodeIfPresent(CGFloat.self, forKey: .upDistance) ?? 0
        downDistance = try values.decodeIfPresent(CGFloat.self, forKey: .downDistance) ?? 0
        note = try values.decodeIfPresent(String.self, forKey: .note) ?? ""
        try super.init(from: decoder)
        creationDate = endTime
    }
    
    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(name, forKey: .name)
        try container.encode(trackpoints, forKey: .trackpoints)
        try container.encode(distance, forKey: .distance)
        try container.encode(upDistance, forKey: .upDistance)
        try container.encode(downDistance, forKey: .downDistance)
        try container.encode(note, forKey: .note)
    }
    
    public func pauseTracking(){
        pauseTime = Date.localDate
    }
    
    public func resumeTracking(){
        if let pauseTime = pauseTime{
            pauseLength += pauseTime.distance(to: Date.localDate)
            self.pauseTime = nil
        }
    }
    
    public func setTrackpoints(_ trackpoints: TrackpointList){
        if !trackpoints.isEmpty{
            self.trackpoints = trackpoints
            updateFromTrackpoints()
        }
    }
    
    public func updateFromTrackpoints(){
        if !trackpoints.isEmpty{
            startTime = trackpoints.first!.timestamp
            endTime = trackpoints.last!.timestamp
            creationDate = startTime
            distance = 0
            upDistance = 0
            downDistance = 0
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
        }
    }
    
    public func addTrackpoint(from location: CLLocation){
        let tp = Trackpoint(location: location)
        if trackpoints.isEmpty{
            trackpoints.append(tp)
            Log.info("starting track at \(tp.coordinate.shortString)")
            startTime = tp.timestamp
            lastAltitude = tp.altitude
            return
        }
        let previousTrackpoint = trackpoints.last!
        let timeDiff = previousTrackpoint.timestamp.distance(to: tp.timestamp)
        //print (timeDiff)
        if timeDiff < Preferences.shared.trackpointInterval{
            return
        }
        let horizontalDiff = previousTrackpoint.coordinate.distance(to: tp.coordinate)
        if horizontalDiff < Preferences.shared.minHorizontalTrackpointDistance{
            return
        }
        Log.info("adding trackpoint at \(tp.coordinate.shortString)")
        trackpoints.append(tp)
        distance += horizontalDiff
        let verticalDiff = lastAltitude - tp.altitude
        if verticalDiff > Preferences.shared.minVerticalTrackpointDistance{
            upDistance += verticalDiff
            lastAltitude = tp.altitude
            Log.debug("new altitude: \(lastAltitude)")
            Log.debug("new up distance: \(upDistance) m")
        }
        else if verticalDiff < -Preferences.shared.minVerticalTrackpointDistance{
            downDistance += -verticalDiff
            lastAltitude = tp.altitude
            Log.debug("new altitude: \(lastAltitude)")
            Log.debug("new down distance: \(downDistance) m")
        }
        endTime = tp.timestamp
    }
    
    public func setMinimalTrackpointDistances(minDistance: CGFloat){
        if !trackpoints.isEmpty{
            var removables = Array<Trackpoint>()
            var last : Trackpoint = trackpoints.first!
            for idx in 1..<trackpoints.count - 1{
                let tp = trackpoints[idx]
                let distance = last.coordinate.distance(to: tp.coordinate)
                if distance < minDistance{
                    removables.append(tp)
                }
                else{
                    last = tp
                }
            }
            trackpoints.removeAll(where: { tp1 in
                removables.contains(where: { tp2 in
                    tp1.id == tp2.id
                })
            })
        }
        updateFromTrackpoints()
    }
    
    public func simplifyTrack(){
        Log.info("simplifying track starting with \(trackpoints.count) trackpoints")
        Log.info("using max deviation of \(Preferences.shared.maxTrackpointInLineDeviation) m")
        var i = 0
        while i + 2 < trackpoints.count{
            if canDropMiddleTrackpoint(tp0: trackpoints[i], tp1: trackpoints[i+1], tp2: trackpoints[i+2]){
                trackpoints.remove(at: i+1)
            }
            else{
                i += 1
            }
        }
        Log.info("ending with \(trackpoints.count)")
    }
    
    public func canDropMiddleTrackpoint(tp0: Trackpoint, tp1: Trackpoint, tp2: Trackpoint) -> Bool{
        //calculate expected middle coordinated between outer coordinates by triangles
        let outerLatDiff = tp2.coordinate.latitude - tp0.coordinate.latitude
        let outerLonDiff = tp2.coordinate.longitude - tp0.coordinate.longitude
        var expectedLatitude = tp1.coordinate.latitude
        if outerLatDiff == 0{
            expectedLatitude = tp0.coordinate.latitude
        }
        else if outerLonDiff == 0{
            expectedLatitude = tp1.coordinate.latitude
        }
        else{
            let innerLonDiff = tp1.coordinate.longitude - tp0.coordinate.longitude
            expectedLatitude = outerLatDiff*(innerLonDiff/outerLonDiff) + tp0.coordinate.latitude
        }
        let expectedCoordinate = CLLocationCoordinate2D(latitude: expectedLatitude, longitude: tp1.coordinate.longitude)
        //check for middle coordinate being close to expected coordinate
        return tp1.coordinate.distance(to: expectedCoordinate) <= Preferences.shared.maxTrackpointInLineDeviation
    }
    
    public func getPreviewFile() -> Data?{
        FileManager.default.readFile(url: previewURL)
    }
    
    public func trackpointsChanged(){
        if FileManager.default.fileExists(url: previewURL){
            FileManager.default.deleteFile(url: previewURL)
        }
    }
    
    override public func prepareDelete(){
        if FileManager.default.fileExists(dirPath: FileManager.previewsDirURL.path, fileName: fileName){
            if !FileManager.default.deleteFile(dirURL: FileManager.previewsDirURL, fileName: fileName){
                Log.error("TrackItem could not delete preview: \(fileName)")
            }
        }
    }
    
#if os(macOS)
    public func getPreview() -> NSImage?{
        if let data = getPreviewFile(){
            return NSImage(data: data)
        } else{
            return createPreview()
        }
    }
    public func createPreview() -> NSImage?{
        if let preview = TrackImageCreator(track: self).createImage(size: CGSize(width: Track.previewSize, height: Track.previewSize)){
            if let tiff = preview.tiffRepresentation, let tiffData = NSBitmapImageRep(data: tiff) {
                if let previewData = tiffData.representation(using: .jpeg, properties: [:]) {
                    _ = FileManager.default.assertDirectoryFor(url: previewURL)
                    FileManager.default.saveFile(data: previewData, url: previewURL)
                    return preview
                }
            }
            return preview
        }
        return nil
    }
#elseif os(iOS)
    public func getPreview() -> UIImage?{
        if let data = getPreviewFile(){
            return UIImage(data: data)
        } else{
            return createPreview()
        }
    }
    public func createPreview() -> UIImage?{
        if let preview = TrackImageCreator(track: self).createImage(size: CGSize(width: Track.previewSize, height: Track.previewSize)){
            if let data = preview.jpegData(compressionQuality: 0.85){
                _ = FileManager.default.assertDirectoryFor(url: previewURL)
                if !FileManager.default.saveFile(data: data, url: previewURL){
                    Log.error("preview could not be saved at \(previewURL)")
                }
            }
            return preview
        }
        return nil
    }
#endif
    
}

