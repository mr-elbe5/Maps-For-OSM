/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

extension MainViewController: MainMenuDelegate{
    
    func refreshMap() {
        mapView.refresh()
    }
    
    func updateCross() {
        mapView.crossView.isHidden = !AppState.shared.showCross
    }
    
    func openPreloadTiles() {
        let region = mapView.scrollView.tileRegion
        let controller = PreloadViewController()
        controller.mapRegion = region
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func deleteAllTiles(){
        showDestructiveApprove(title: "confirmDeleteTiles".localize(), text: "deleteTilesHint".localize()){
            TileProvider.shared.deleteAllTiles()
            self.mapView.clearTiles()
        }
    }
    
    func openLocationList() {
        let controller = LocationListViewController()
        controller.modalPresentationStyle = .fullScreen
        controller.delegate = self
        present(controller, animated: true)
    }
    
    func showLocations(_ show: Bool) {
        AppState.shared.showLocations = show
        mapView.locationLayerView.isHidden = !AppState.shared.showLocations
    }
    
    func deleteAllLocations(){
        showDestructiveApprove(title: "confirmDeleteLocations".localize(), text: "deleteLocationsHint".localize()){
            LocationPool.deleteAllLocations()
            LocationPool.save()
            self.updateMarkerLayer()
        }
    }
    
    func openPreferences(){
        let controller = PreferencesViewController()
        controller.modalPresentationStyle = .fullScreen
        controller.delegate = self
        present(controller, animated: true)
    }
    
    func startRecording(){
        if let location = LocationService.shared.location{
            TrackRecorder.startRecording(startLocation: location)
            if let track = TrackRecorder.track{
                TrackPool.visibleTrack = track
                self.mapView.trackLayerView.setNeedsDisplay()
                self.statusView.startTrackInfo()
            }
        }
    }
    
    func pauseRecording() {
        TrackRecorder.pauseRecording()
        self.statusView.pauseTrackInfo()
    }
    
    func resumeRecording() {
        TrackRecorder.resumeRecording()
        self.statusView.resumeTrackInfo()
    }
    
    func cancelRecording() {
        TrackRecorder.stopRecording()
        TrackPool.visibleTrack = nil
        mapView.trackLayerView.setNeedsDisplay()
        statusView.stopTrackInfo()
    }
    func saveRecordedTrack() {
        if let track = TrackRecorder.track{
            let alertController = UIAlertController(title: "name".localize(), message: "nameOrDescriptionHint".localize(), preferredStyle: .alert)
            alertController.addTextField()
            alertController.addAction(UIAlertAction(title: "ok".localize(),style: .default) { action in
                var name = alertController.textFields![0].text
                if name == nil || name!.isEmpty{
                    name = "Tour"
                }
                track.name = name!
                TrackPool.addTrack(track: track)
                TrackPool.save()
                TrackPool.visibleTrack = track
                self.mapView.trackLayerView.setNeedsDisplay()
                TrackRecorder.stopRecording()
                self.statusView.stopTrackInfo()
                self.mapView.updateLocationLayer()
                self.mainMenuView.updateTrackMenu()
            })
            present(alertController, animated: true)
        }
    }
    
    func hideTrack() {
        TrackPool.visibleTrack = nil
        mapView.trackLayerView.setNeedsDisplay()
    }
    
    func openTrackList() {
        let controller = TrackListViewController()
        controller.tracks = TrackPool.list
        controller.modalPresentationStyle = .fullScreen
        controller.delegate = self
        present(controller, animated: true)
    }
    
    func deleteAllTracks() {
        showDestructiveApprove(title: "confirmDeleteAllTracks".localize(), text: "deleteAllTracksHint".localize()){
            self.cancelRecording()
            TrackPool.deleteAllTracks()
            TrackPool.visibleTrack = nil
            self.mapView.trackLayerView.setNeedsDisplay()
        }
    }
    
    func focusUserLocation() {
        mapView.focusUserLocation()
    }
    
    func openInfo() {
        let controller = InfoViewController()
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func openSearch() {
        let controller = SearchViewController()
        controller.modalPresentationStyle = .fullScreen
        controller.delegate = self
        present(controller, animated: true)
    }
    
}
