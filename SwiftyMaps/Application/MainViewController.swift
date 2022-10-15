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
        mapView.setupScrollView()
        mapView.setupTrackLayerView()
        mapView.setupUserLocationView()
        mapView.setupPlaceLayerView()
        mapView.placeLayerView.delegate = self
        mapView.setupControlLayerView()
        mapView.controlLayerView.delegate = self
        mapView.setDefaultLocation()
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

extension MainViewController: PlaceLayerViewDelegate{
    
    func showPlaceDetails(place: Place) {
        let controller = PlaceDetailViewController()
        controller.place = place
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
}

extension MainViewController: ControlLayerDelegate{
    
    func setMapType(_ type: MapType) {
        AppState.instance.mapType = type
        AppState.instance.save()
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
    
    func addPlace(){
        let coordinate = mapView.scrollView.screenCenterCoordinate
        assertPlace(coordinate: coordinate){ place in
            self.updatePlaceLayer()
        }
    }
    
    func openPlaceList() {
        let controller = PlaceListViewController()
        controller.modalPresentationStyle = .fullScreen
        controller.delegate = self
        present(controller, animated: true)
    }
    
    func showPlaces(_ show: Bool) {
        AppState.instance.showPins = show
        mapView.placeLayerView.isHidden = !AppState.instance.showPins
    }
    
    func openPlacePreferences(){
        let controller = PlacePreferencesViewController()
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func startTracking(){
        if let lastLocation = LocationService.instance.location{
            assertPlace(coordinate: lastLocation.coordinate){ place in
                TrackRecorder.startRecording(startPoint: place)
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
        
    }
    
}

extension MainViewController: TileCacheDelegate{
    
    func deleteTiles() {
        TileCache.clear()
        self.mapView.clearTiles()
    }
    
}

extension MainViewController: PhotoCaptureDelegate{
    
    func photoCaptured(photo: PhotoData) {
        if let location = LocationService.instance.location{
            assertPlace(coordinate: location.coordinate){ place in
                let changeState = place.photos.isEmpty
                place.addPhoto(photo: photo)
                Places.save()
                if changeState{
                    DispatchQueue.main.async {
                        self.updatePlaceLayer()
                    }
                }
            }
        }
    }
    
}

extension MainViewController: PlaceViewDelegate{
    
    func updatePlaceLayer() {
        mapView.updatePlaceLayer()
    }
    
}

extension MainViewController: PlaceListDelegate{
    
    func showPlaceOnMap(place: Place) {
        mapView.scrollView.scrollToScreenCenter(coordinate: place.coordinate)
    }
    
    func deletePlace(place: Place) {
        Places.deletePlace(place)
        Places.save()
        updatePlaceLayer()
    }
    
    func deleteAllPlaces() {
        Places.deleteAllPlaces()
        self.updatePlaceLayer()
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
                Places.save()
                Tracks.visibleTrack = track
                self.mapView.trackLayerView.setNeedsDisplay()
                TrackRecorder.stopRecording()
                self.mapView.controlLayerView.stopTrackControl()
                self.mapView.updatePlaceLayer()
            })
            present(alertController, animated: true)
        }
    }
    
}


