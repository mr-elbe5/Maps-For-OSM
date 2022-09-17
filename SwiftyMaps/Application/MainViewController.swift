/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import AVKit



class MainViewController: UIViewController {
    
    var mapView = MapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        mapView.frame = view.bounds
        mapView.fillView(view: view)
        MapStatics.minZoom = MapStatics.minimumZoomLevelForViewSize(viewSize: mapView.bounds.size)
        mapView.setupScrollView()
        mapView.setupTrackLayerView()
        mapView.setupUserLocationView()
        mapView.setupLocationLayerView()
        mapView.locationLayerView.delegate = self
        mapView.setupControlLayerView()
        mapView.controlLayerView.delegate = self
        mapView.setDefaultLocation()
        LocationService.shared.delegate = self
    }
    
}

extension MainViewController: LocationServiceDelegate{
    
    func locationDidChange(location: CLLocation) {
        mapView.locationDidChange(location: location)
    }
    
    func directionDidChange(direction: CLLocationDirection) {
        mapView.setDirection(direction)
    }
    
}

extension MainViewController: LocationLayerViewDelegate{
    
    func showLocationDetails(location: Location) {
        let controller = LocationDetailViewController()
        controller.location = location
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
}

extension MainViewController: ControlLayerDelegate{
    
    func preloadMap() {
        let region = mapView.currentMapRegion
        if region.size > Preferences.instance.maxPreloadTiles{
            let text = "preloadMapsAlert".localize(param1: String(region.size), param2: String(Preferences.instance.maxPreloadTiles))
            showAlert(title: "pleaseNote".localize(), text: text, onOk: nil)
        }
        else{
            let controller = MapPreloadViewController()
            controller.mapRegion = region
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true)
        }
    }
    
    func deleteTiles() {
        showDestructiveApprove(title: "confirmDeleteTiles".localize(), text: "deleteTilesHint".localize()){
            MapTiles.clear()
            self.mapView.clearTiles()
        }
    }
    
    func addLocation(){
        let coordinate = mapView.getVisibleCenterCoordinate()
        assertLocation(coordinate: coordinate){ location in
            self.updateLocationLayer()
        }
    }
    
    func openLocationList() {
        let controller = LocationListViewController()
        controller.modalPresentationStyle = .fullScreen
        controller.delegate = self
        present(controller, animated: true)
    }
    
    func showLocations(_ show: Bool) {
        Preferences.instance.showPins = show
        mapView.locationLayerView.isHidden = !Preferences.instance.showPins
    }
    
    func deleteLocations() {
        showDestructiveApprove(title: "confirmDeleteLocations".localize(), text: "deleteLocationsHint".localize()){
            if ActiveTrack.track != nil{
                self.cancelActiveTrack()
            }
            Locations.deleteAllLocations()
            self.updateLocationLayer()
            self.mapView.clearTrack()
        }
    }
    
    func startTracking(){
        if let lastLocation = LocationService.shared.lastLocation{
            assertLocation(coordinate: lastLocation.coordinate){ location in
                ActiveTrack.startTracking(startLocation: location)
                if let track = ActiveTrack.track{
                    self.mapView.trackLayerView.setTrack(track: track)
                    self.mapView.controlLayerView.startTrackControl()
                }
            }
        }
    }
    
    func openTrack(track: TrackData) {
        let controller = TrackDetailViewController()
        controller.track = track
        controller.modalPresentationStyle = .fullScreen
        controller.delegate = self
        if track == ActiveTrack.track{
            controller.activeDelegate = self
        }
        present(controller, animated: true)
    }
    
    func hideTrack() {
        mapView.trackLayerView.setTrack(track: nil)
    }
    
    func openTrackList() {
        let controller = TrackListViewController()
        controller.tracks = Locations.getAllTracks()
        controller.modalPresentationStyle = .fullScreen
        controller.delegate = self
        present(controller, animated: true)
    }
    
    func deleteTracks() {
        showDestructiveApprove(title: "confirmDeleteTracks".localize(), text: "deleteTracksHint".localize()){
            self.cancelActiveTrack()
            Locations.deleteAllTracks()
            self.updateLocationLayer()
            self.mapView.clearTrack()
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
    
    func openPreferences() {
        let controller = PreferencesViewController()
        controller.currentZoom = mapView.zoom
        controller.currentCenterCoordinate = mapView.getVisibleCenterCoordinate()
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func openCamera() {
        AVCaptureDevice.askCameraAuthorization(){ result in
            switch result{
            case .success(()):
                DispatchQueue.main.async {
                    let data = PhotoData()
                    let imageCaptureController = PhotoCaptureViewController()
                    imageCaptureController.data = data
                    imageCaptureController.delegate = self
                    imageCaptureController.modalPresentationStyle = .fullScreen
                    self.present(imageCaptureController, animated: true)
                }
                return
            case .failure:
                DispatchQueue.main.async {
                    self.showAlert(title: "error".localize(), text: "cameraNotAuthorized".localize())
                }
                return
            }
        }
    }
    
}

extension MainViewController: PhotoCaptureDelegate{
    
    func photoCaptured(photo: PhotoData) {
        if let location = LocationService.shared.lastLocation{
            assertLocation(coordinate: location.coordinate){ location in
                let changeState = location.photos.isEmpty
                location.addPhoto(photo: photo)
                Locations.save()
                if changeState{
                    DispatchQueue.main.async {
                        self.updateLocationLayer()
                    }
                }
            }
        }
    }
    
}

extension MainViewController: LocationViewDelegate{
    
    func updateLocationLayer() {
        mapView.updateLocationLayer()
    }
    
}

extension MainViewController: LocationListDelegate{
    
    func showOnMap(location: Location) {
        mapView.scrollToCenteredCoordinate(coordinate: location.coordinate)
    }
    
    func deleteLocation(location: Location) {
        if let track = ActiveTrack.track, location.tracks.contains(track){
            cancelActiveTrack()
        }
        if let track = mapView.trackLayerView.track, location.tracks.contains(track){
            mapView.clearTrack()
        }
        Locations.deleteLocation(location)
        Locations.save()
        updateLocationLayer()
    }

}

extension MainViewController: TrackDetailDelegate, TrackListDelegate, ActiveTrackDelegate{
    
    func viewTrackDetails(track: TrackData) {
        let trackController = TrackDetailViewController()
        trackController.track = track
        trackController.delegate = self
        trackController.modalPresentationStyle = .fullScreen
        self.present(trackController, animated: true)
    }
    
    func deleteTrack(track: TrackData, approved: Bool) {
        if approved{
            deleteTrack(track: track)
        }
        else{
            showDestructiveApprove(title: "confirmDeleteTrack".localize(), text: "deleteTrackHint".localize()){
                self.deleteTrack(track: track)
            }
        }
    }
    
    private func deleteTrack(track: TrackData){
        Locations.deleteTrack(track: track)
        mapView.clearTrack(track)
        updateLocationLayer()
    }
    
    func showTrackOnMap(track: TrackData) {
        if let startLocation = track.startLocation{
            mapView.trackLayerView.setTrack(track: track)
            mapView.scrollToCenteredCoordinate(coordinate: startLocation.coordinate)
        }
    }
    
    func updateTrackLayer() {
        mapView.trackLayerView.setNeedsDisplay()
    }
    
    func pauseActiveTrack() {
        ActiveTrack.pauseTracking()
        mapView.controlLayerView.pauseTrackInfo()
    }
    
    func resumeActiveTrack() {
        ActiveTrack.resumeTracking()
        mapView.controlLayerView.resumeTrackInfo()
    }
    
    func cancelActiveTrack() {
        ActiveTrack.stopTracking()
        mapView.clearTrack()
    }
    
    func saveActiveTrack() {
        if let track = ActiveTrack.track{
            let alertController = UIAlertController(title: "name".localize(), message: "nameOrDescriptionHint".localize(), preferredStyle: .alert)
            alertController.addTextField()
            alertController.addAction(UIAlertAction(title: "ok".localize(),style: .default) { action in
                track.name = alertController.textFields![0].text ?? "Route"
                track.startLocation.addTrack(track: track)
                Locations.save()
                self.mapView.trackLayerView.setTrack(track: track)
                ActiveTrack.stopTracking()
                self.mapView.controlLayerView.stopTrackControl()
                self.mapView.updateLocationLayer()
            })
            present(alertController, animated: true)
        }
    }
    
}


