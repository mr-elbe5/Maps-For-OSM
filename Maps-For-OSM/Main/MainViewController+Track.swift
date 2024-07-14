/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import E5Data
import E5MapData
import UniformTypeIdentifiers

extension MainViewController{
    
    func setupTrackStatusView(guide: UILayoutGuide){
        trackStatusView.setBackground(.transparentColor)
        trackStatusView.setup()
        trackStatusView.delegate = self
        view.addSubviewWithAnchors(trackStatusView, leading: guide.leadingAnchor, trailing: guide.trailingAnchor, bottom: licenseView.topAnchor, insets: flatInsets)
        trackStatusView.hide(true)
    }
    
    func updateFollowTrack(){
        if Preferences.shared.followTrack, TrackRecorder.isRecording{
            mapView.focusUserLocation()
        }
    }
    
    func trackChanged() {
        mapView.trackLayerView.setNeedsDisplay()
    }
    
    func showTrackOnMap(track: Track) {
        if !track.trackpoints.isEmpty, let boundingRect = track.trackpoints.boundingMapRect{
            Track.visibleTrack = track
            trackChanged()
            mapView.showMapRectOnMap(mapRect: boundingRect)
        }
    }
    
    func importTrack(){
        let filePicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType(filenameExtension: "gpx")!])
        filePicker.directoryURL = FileManager.exportGpxDirURL
        filePicker.allowsMultipleSelection = false
        filePicker.delegate = self
        filePicker.modalPresentationStyle = .fullScreen
        self.present(filePicker, animated: true)
    }
    
    func hideTrack() {
        Track.visibleTrack = nil
        trackChanged()
    }
    
    func startTracking() {
        TrackRecorder.startTracking()
        cancelAlert = showCancel(title: "pleaseWait".localize(), text: "waitingForGPS".localize()){
            self.cancelAlert = nil
            return
        }
    }
    
    func startTrackRecording(at location: CLLocation) {
        if let trackRecorder = TrackRecorder.instance{
            trackRecorder.track.addTrackpoint(from: location)
            trackRecorder.isRecording = true
            Track.visibleTrack = trackRecorder.track
            self.trackChanged()
            self.trackStatusView.hide(false)
            self.trackStatusView.startTrackInfo()
        }
    }
    
    func saveTrack() {
        if let track = TrackRecorder.stopTracking(), let coordinate = track.startCoordinate{
            track.name = "trackName".localize(param: track.startTime.dateString())
            var newLocation = false
            var location = AppData.shared.getLocation(coordinate: coordinate)
            if location == nil{
                location = AppData.shared.createLocation(coordinate: coordinate)
                newLocation = true
            }
            location!.addItem(item: track)
            AppData.shared.save()
            Track.visibleTrack = track
            self.trackChanged()
            self.trackStatusView.hide(true)
            DispatchQueue.main.async {
                if newLocation{
                    self.locationsChanged()
                }
                else{
                    self.locationChanged(location: location!)
                }
            }
        }
    }
    
    func cancelTrack() {
        if TrackRecorder.stopTracking() != nil{
            Track.visibleTrack = nil
            self.trackChanged()
            self.trackStatusView.stopTrackInfo()
            self.trackStatusView.hide(true)
        }
    }
    
}

extension MainViewController: TrackStatusDelegate{
    
    func togglePauseTracking() {
        if let trackRecorder = TrackRecorder.instance{
            trackRecorder.isRecording = !trackRecorder.isRecording
        }
    }
    
}

extension MainViewController : UIDocumentPickerDelegate{
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first{
            if url.pathExtension == "gpx"{
                importGPXFile(url: url)
            }
        }
    }
    
    private func importGPXFile(url: URL){
        if let gpxData = GPXParser.parseFile(url: url), !gpxData.isEmpty{
            let track = Track()
            track.name = gpxData.name
            for segment in gpxData.segments{
                for point in segment.points{
                    track.trackpoints.append(Trackpoint(location: point.location))
                }
            }
            track.evaluateImportedTrackpoints()
            if track.name.isEmpty{
                let ext = url.pathExtension
                var name = url.lastPathComponent
                name = String(name[name.startIndex...name.index(name.endIndex, offsetBy: -ext.count)])
                Log.debug(name)
                track.name = name
            }
            track.evaluateImportedTrackpoints()
            track.startTime = track.trackpoints.first?.timestamp ?? Date.localDate
            track.endTime = track.trackpoints.last?.timestamp ?? Date.localDate
            track.creationDate = track.startTime
            var newLocation = false
            var location = AppData.shared.getLocation(coordinate: track.startCoordinate!)
            if location == nil{
                location = AppData.shared.createLocation(coordinate: track.startCoordinate!)
                newLocation = true
            }
            location!.addItem(item: track)
            AppData.shared.save()
            DispatchQueue.main.async {
                if newLocation{
                    self.locationsChanged()
                }
                else{
                    self.locationChanged(location: location!)
                }
            }
        }
    }
    
}


