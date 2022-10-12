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
    
    func preloadMap() {
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
        assertPlace(coordinate: coordinate){ location in
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
    
    func deletePlaces() {
        showDestructiveApprove(title: "confirmDeleteLocations".localize(), text: "deleteLocationsHint".localize()){
            if ActiveTrack.track != nil{
                self.cancelActiveTrack()
            }
            Places.deleteAllPlaces()
            self.updatePlaceLayer()
            self.mapView.clearTrack()
        }
    }
    
    func openPlacePreferences(){
        let controller = PlacePreferencesViewController()
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func startTracking(){
        if let lastLocation = LocationService.instance.location{
            assertPlace(coordinate: lastLocation.coordinate){ location in
                ActiveTrack.startTracking(startPoint: location)
                if let track = ActiveTrack.track{
                    self.mapView.trackLayerView.setTrack(track: track)
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
        controller.tracks = Tracks.list
        controller.modalPresentationStyle = .fullScreen
        controller.delegate = self
        present(controller, animated: true)
    }
    
    func deleteTracks() {
        showDestructiveApprove(title: "confirmDeleteTracks".localize(), text: "deleteTracksHint".localize()){
            self.cancelActiveTrack()
            Tracks.deleteAllTracks()
            self.updatePlaceLayer()
            self.mapView.clearTrack()
        }
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
        showDestructiveApprove(title: "confirmDeleteTiles".localize(), text: "deleteTilesHint".localize()){
            TileCache.clear()
            self.mapView.clearTiles()
        }
    }
    
}

extension MainViewController: PhotoCaptureDelegate{
    
    func photoCaptured(photo: PhotoData) {
        if let location = LocationService.instance.location{
            assertPlace(coordinate: location.coordinate){ location in
                let changeState = location.photos.isEmpty
                location.addPhoto(photo: photo)
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
    
    func showOnMap(place: Place) {
        mapView.scrollView.scrollToScreenCenter(coordinate: place.coordinate)
    }
    
    func deletePlace(place: Place) {
        Places.deletePlace(place)
        Places.save()
        updatePlaceLayer()
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
        Tracks.deleteTrack(track)
        mapView.clearTrack(track)
        updatePlaceLayer()
    }
    
    func showTrackOnMap(track: Track) {
        if !track.trackpoints.isEmpty{
            mapView.trackLayerView.setTrack(track: track)
            mapView.scrollView.scrollToScreenCenter(coordinate: track.trackpoints[0].coordinate)
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
                Places.save()
                self.mapView.trackLayerView.setTrack(track: track)
                ActiveTrack.stopTracking()
                self.mapView.controlLayerView.stopTrackControl()
                self.mapView.updatePlaceLayer()
            })
            present(alertController, animated: true)
        }
    }
    
}


