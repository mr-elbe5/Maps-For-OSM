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
        view.addSubviewFilling(mapView)
        mapView.frame = view.bounds
        mapView.setupScrollView()
        mapView.setupTrackLayerView()
        mapView.setupLocationLayerView()
        mapView.locationLayerView.delegate = self
        mapView.setupCrossView()
        mapView.setupUserLocationView()
        mapView.setupControlLayerView()
        mapView.controlLayerView.delegate = self
        mapView.setDefaultLocation()
        mapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //TestCenter.testMapView(mapView: mapView)
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
    
    func addImageToLocation(location: Location) {
        
    }
    
}

extension MainViewController: MapViewDelegate{
    
    func showDetailsOfCurrentPosition() {
    
    }
    
    func addLocationAtCurrentPosition() {
        
    }
    
    func addPhotoAtCurrentPosition() {
        
    }
    
    func addImageAtCurrentPosition() {
        
    }
    
    func showDetailsOfCrossPosition() {
        
    }
    
    func addLocationAtCrossPosition() {
        
    }
    
    func addImageAtCrossPosition() {
        
    }
    
}

extension MainViewController: MainMenuDelegate{
    func updateCross() {
        mapView.crossView.isHidden = !AppState.shared.showCross
    }
    
    func setMapType(_ type: MapType) {
        AppState.shared.mapType = type
        AppState.shared.save()
        //todo
    }
    
    func openPreloadMap() {
        let region = mapView.scrollView.tileRegion
        let controller = TileCacheViewController()
        controller.mapRegion = region
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func openMapPreferences(){
        let controller = TileSourcesViewController()
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func addLocation(){
        let coordinate = mapView.scrollView.screenCenterCoordinate
        assertLocation(coordinate: coordinate){ location in
            self.updateMarkerLayer()
        }
    }
    
    func openLocationList() {
        let controller = LocationListViewController()
        controller.modalPresentationStyle = .fullScreen
        controller.delegate = self
        present(controller, animated: true)
    }
    
    func showLocations(_ show: Bool) {
        AppState.shared.showPins = show
        mapView.locationLayerView.isHidden = !AppState.shared.showPins
    }
    
    func openLocationPreferences(){
        let controller = LocationPreferencesViewController()
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func startTracking(){
        if let lastLocation = LocationService.instance.location{
            assertLocation(coordinate: lastLocation.coordinate){ location in
                TrackRecorder.startRecording(startPoint: location)
                if let track = TrackRecorder.track{
                    Tracks.visibleTrack = track
                    self.mapView.trackLayerView.setNeedsDisplay()
                    self.mapView.controlLayerView.startTrackControl()
                }
            }
        }
    }
    
    func openTrack(track: Track) {
        let controller = TrackDetailViewController()
        controller.track = track
        controller.modalPresentationStyle = .fullScreen
        controller.delegate = self
        if track == TrackRecorder.track{
            controller.activeDelegate = self
        }
        present(controller, animated: true)
    }
    
    func hideTrack() {
        Tracks.visibleTrack = nil
        mapView.trackLayerView.setNeedsDisplay()
    }
    
    func openTrackList() {
        let controller = TrackListViewController()
        controller.tracks = Tracks.list
        controller.modalPresentationStyle = .fullScreen
        controller.delegate = self
        present(controller, animated: true)
    }
    
    func openTrackPreferences(){
        let controller = TrackPreferencesViewController()
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func focusUserLocation() {
        mapView.focusUserLocation()
    }
    
    func openInfo() {
        let controller = InfoViewController()
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
    
    func openSearch() {
        let controller = SearchViewController()
        controller.modalPresentationStyle = .fullScreen
        controller.delegate = self
        present(controller, animated: true)
    }
    
}

extension MainViewController: TileCacheDelegate{
    
    func deleteTiles() {
        TileCache.clear()
        self.mapView.clearTiles()
    }
    
}

extension MainViewController: SearchDelegate{
    
    func showSearchResult(coordinate: CLLocationCoordinate2D, region: CoordinateRegion?) {
        if let region = region{
            mapView.setRegion(region: region)
        }
        else{
            mapView.scrollView.scrollToScreenCenter(coordinate: coordinate)
        }
    }
    

}

extension MainViewController: PhotoCaptureDelegate{
    
    func photoCaptured(photo: PhotoData) {
        if let location = LocationService.instance.location{
            assertLocation(coordinate: location.coordinate){ location in
                let changeState = location.photos.isEmpty
                location.addPhoto(photo: photo)
                Locations.save()
                if changeState{
                    DispatchQueue.main.async {
                        self.updateMarkerLayer()
                    }
                }
            }
        }
    }
    
}

extension MainViewController: LocationViewDelegate{
    
    func updateMarkerLayer() {
        mapView.updateLocationLayer()
    }
    
}

extension MainViewController: LocationListDelegate{
    
    func showLocationOnMap(location: Location) {
        mapView.scrollView.scrollToScreenCenter(coordinate: location.coordinate)
    }
    
    func deleteLocation(location: Location) {
        Locations.deleteLocation(location)
        Locations.save()
        updateMarkerLayer()
    }
    
    func deleteAllLocations() {
        Locations.deleteAllLocations()
        self.updateMarkerLayer()
    }

}

extension MainViewController: TrackDetailDelegate, TrackListDelegate, ActiveTrackDelegate{
    
    func viewTrackDetails(track: Track) {
        let trackController = TrackDetailViewController()
        trackController.track = track
        trackController.delegate = self
        trackController.modalPresentationStyle = .fullScreen
        self.present(trackController, animated: true)
    }
    
    func deleteTrack(track: Track, approved: Bool) {
        if approved{
            deleteTrack(track: track)
        }
        else{
            showDestructiveApprove(title: "confirmDeleteTrack".localize(), text: "deleteTrackHint".localize()){
                self.deleteTrack(track: track)
            }
        }
    }
    
    private func deleteTrack(track: Track){
        let isVisibleTrack = track == Tracks.visibleTrack
        Tracks.deleteTrack(track)
        if isVisibleTrack{
            Tracks.visibleTrack = nil
            mapView.trackLayerView.setNeedsDisplay()
        }
    }
    
    func deleteAllTracks() {
        cancelActiveTrack()
        Tracks.deleteAllTracks()
        Tracks.visibleTrack = nil
        mapView.trackLayerView.setNeedsDisplay()
    }
    
    func showTrackOnMap(track: Track) {
        if !track.trackpoints.isEmpty, let boundingRect = track.trackpoints.boundingMapRect{
            Tracks.visibleTrack = track
            mapView.trackLayerView.setNeedsDisplay()
            mapView.scrollView.scrollToScreenCenter(coordinate: boundingRect.centerCoordinate)
            mapView.scrollView.setZoomScale(World.getZoomScaleToFit(mapRect: boundingRect, scaledBounds: mapView.bounds)*0.9, animated: true)
        }
    }
    
    func updateTrackLayer() {
        mapView.trackLayerView.setNeedsDisplay()
    }
    
    func pauseActiveTrack() {
        TrackRecorder.pauseRecording()
        mapView.controlLayerView.pauseTrackInfo()
    }
    
    func resumeActiveTrack() {
        TrackRecorder.resumeRecording()
        mapView.controlLayerView.resumeTrackInfo()
    }
    
    func cancelActiveTrack() {
        TrackRecorder.stopRecording()
        Tracks.visibleTrack = nil
        mapView.trackLayerView.setNeedsDisplay()
        mapView.controlLayerView.stopTrackControl()
    }
    
    func saveActiveTrack() {
        if let track = TrackRecorder.track{
            let alertController = UIAlertController(title: "name".localize(), message: "nameOrDescriptionHint".localize(), preferredStyle: .alert)
            alertController.addTextField()
            alertController.addAction(UIAlertAction(title: "ok".localize(),style: .default) { action in
                track.name = alertController.textFields![0].text ?? "Route"
                Locations.save()
                Tracks.visibleTrack = track
                self.mapView.trackLayerView.setNeedsDisplay()
                TrackRecorder.stopRecording()
                self.mapView.controlLayerView.stopTrackControl()
                self.mapView.updateLocationLayer()
            })
            present(alertController, animated: true)
        }
    }
    
}


