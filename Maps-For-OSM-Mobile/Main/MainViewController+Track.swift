/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import E5Data

import UniformTypeIdentifiers

extension MainViewController{
    
    func updateFollowTrack(){
        if Preferences.shared.followTrack, TrackRecorder.isRecording{
            mapView.focusUserLocation()
        }
    }
    
    func trackChanged() {
        mapView.trackLayerView.setNeedsDisplay()
    }
    
    func showTrackOnMap(track: TrackItem) {
        if !track.trackpoints.isEmpty, let boundingRect = track.trackpoints.boundingMapRect{
            TrackItem.visibleTrack = track
            trackChanged()
            mapView.showMapRectOnMap(worldRect: boundingRect)
        }
    }
    
    func hideTrack() {
        TrackItem.visibleTrack = nil
        trackChanged()
    }
    
    func startTracking() {
        TrackRecorder.startTracking()
        cancelAlert = showCancel(title: "pleaseWait".localize(), text: "waitingForGPS".localize()){
            self.cancelAlert = nil
            TrackRecorder.instance = nil
            return
        }
    }
    
    func startTrackRecording(at location: CLLocation) {
        if let trackRecorder = TrackRecorder.instance{
            trackRecorder.track.addTrackpoint(from: location)
            trackRecorder.isRecording = true
            TrackItem.visibleTrack = trackRecorder.track
            self.trackChanged()
            self.statusView.startTrackInfo()
        }
    }
    
    func saveTrack() {
        if let track = TrackRecorder.stopTracking(), let coordinate = track.startCoordinate{
            track.name = "trackName".localize(param: track.startTime.dateString())
            Log.info("saving track \(track.name)")
            var newLocation = false
            var location = AppData.shared.getLocation(coordinate: coordinate)
            if location == nil{
                location = AppData.shared.createLocation(coordinate: coordinate)
                newLocation = true
            }
            location!.addItem(item: track)
            AppData.shared.save()
            TrackItem.visibleTrack = track
            self.trackChanged()
            self.statusView.stopTrackInfo()
            TrackRecorder.instance = nil
            DispatchQueue.main.async {
                if newLocation{
                    self.locationAdded(location: location!)
                }
                else{
                    self.locationChanged(location: location!)
                }
            }
        }
    }
    
    func cancelTrack() {
        if TrackRecorder.stopTracking() != nil{
            Log.info("track cancelled")
            TrackItem.visibleTrack = nil
            self.trackChanged()
            self.statusView.stopTrackInfo()
        }
        TrackRecorder.instance = nil
    }
    
}

extension MainViewController: TrackStatusDelegate{
    
    func togglePauseTracking() {
        if let trackRecorder = TrackRecorder.instance{
            trackRecorder.isRecording = !trackRecorder.isRecording
        }
    }
    
}



