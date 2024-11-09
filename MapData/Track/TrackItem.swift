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

class TrackItem : LocatedItem{
    
    static var previewSize: CGFloat = 512
    
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
    
    static var visibleTrack : TrackItem? = nil
    
    var startTime : Date
    var pauseTime : Date? = nil
    var pauseLength : TimeInterval = 0
    var endTime : Date
    var name : String
    var trackpoints : TrackpointList
    var distance : CGFloat
    var upDistance : CGFloat
    var downDistance : CGFloat
    var note : String
    
    var lastAltitude = 0.0
    
    override var type : LocatedItemType{
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
        return startTime.distance(to: Date.localDate) - pauseLength
    }
    
    var startCoordinate: CLLocationCoordinate2D?{
        trackpoints.first?.coordinate
    }
    
    var endCoordinate: CLLocationCoordinate2D?{
        trackpoints.last?.coordinate
    }
    
    override init(){
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
    
    required init(from decoder: Decoder) throws {
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
    
    override func encode(to encoder: Encoder) throws {
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
    
    func setNameByDate(){
        name = "Tour of \(startTime.dateTimeString())"
    }
    
    func pauseTracking(){
        pauseTime = Date.localDate
    }
    
    func resumeTracking(){
        if let pauseTime = pauseTime{
            pauseLength += pauseTime.distance(to: Date.localDate)
            self.pauseTime = nil
        }
    }
    
    func setTrackpoints(_ trackpoints: TrackpointList){
        if !trackpoints.isEmpty{
            self.trackpoints = trackpoints
            updateFromTrackpoints()
        }
    }
    
    func updateFromTrackpoints(){
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
    
    func addTrackpoint(from location: CLLocation){
        let tp = Trackpoint(location: location)
        if trackpoints.isEmpty{
            trackpoints.append(tp)
            Log.info("starting track at \(tp.coordinate.debugString)")
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
        Log.info("adding trackpoint at \(tp.coordinate.debugString)")
        trackpoints.append(tp)
        distance += horizontalDiff
        let verticalDiff = tp.altitude - lastAltitude
        if abs(verticalDiff) > max(location.horizontalAccuracy, Preferences.minVerticalTrackpointDistance){
            if verticalDiff > 0{
                upDistance += verticalDiff
                lastAltitude = tp.altitude
                Log.debug("new altitude: \(lastAltitude)")
                Log.debug("new up distance: \(upDistance) m")
            }
            else {
                downDistance += -verticalDiff
                lastAltitude = tp.altitude
                Log.debug("new altitude: \(lastAltitude)")
                Log.debug("new down distance: \(downDistance) m")
            }
        }
        endTime = tp.timestamp
    }
    
    func setMinimalTrackpointDistances(minDistance: CGFloat){
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
    
    func simplifyTrack(){
        Log.info("simplifying track starting with \(trackpoints.count) trackpoints")
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
    
    func canDropMiddleTrackpoint(tp0: Trackpoint, tp1: Trackpoint, tp2: Trackpoint) -> Bool{
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
        return tp1.coordinate.distance(to: expectedCoordinate) <= Preferences.maxTrackpointInLineDeviation
    }
    
    func getPreviewFile() -> Data?{
        FileManager.default.readFile(url: previewURL)
    }
    
    func trackpointsChanged(){
        if FileManager.default.fileExists(url: previewURL){
            FileManager.default.deleteFile(url: previewURL)
        }
    }
    
    override func prepareDelete(){
        if FileManager.default.fileExists(dirPath: FileManager.previewsDirURL.path, fileName: fileName){
            if !FileManager.default.deleteFile(dirURL: FileManager.previewsDirURL, fileName: fileName){
                Log.error("TrackItem could not delete preview: \(fileName)")
            }
        }
    }
    
#if os(macOS)
    func getPreview() -> NSImage?{
        if let data = getPreviewFile(){
            return NSImage(data: data)
        } else{
            return createPreview()
        }
    }
    func createPreview() -> NSImage?{
        if let preview = TrackImageCreator(track: self).createImage(size: CGSize(width: TrackItem.previewSize, height: TrackItem.previewSize)){
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
    func getPreview() -> UIImage?{
        if let data = getPreviewFile(){
            return UIImage(data: data)
        } else{
            return createPreview()
        }
    }
    func createPreview() -> UIImage?{
        if let preview = TrackImageCreator(track: self).createImage(size: CGSize(width: TrackItem.previewSize, height: TrackItem.previewSize)){
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

