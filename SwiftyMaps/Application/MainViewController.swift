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
    var mainMenuView = MainMenuView()
    var statusView = StatusView()
    var licenseView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layoutGuide = view.safeAreaLayoutGuide
        view.addSubviewFilling(mapView)
        mapView.frame = view.bounds
        mapView.setupScrollView()
        mapView.setupTrackLayerView()
        mapView.setupLocationLayerView()
        mapView.locationLayerView.delegate = self
        mapView.setupCrossView()
        mapView.setupUserLocationView()
        setupMainMenuView(layoutGuide: layoutGuide)
        mainMenuView.delegate = self
        setupStatusView(layoutGuide: layoutGuide)
        setupLicenseView(layoutGuide: layoutGuide)
        mapView.delegate = self
        mapView.setDefaultLocation()
    }
    
    func setupMainMenuView(layoutGuide: UILayoutGuide){
        view.addSubviewWithAnchors(mainMenuView, top: layoutGuide.topAnchor, leading: layoutGuide.leadingAnchor, trailing: layoutGuide.trailingAnchor, insets: flatInsets)
        mainMenuView.setup()
    }
    
    func setupStatusView(layoutGuide: UILayoutGuide){
        statusView.setup()
        view.addSubviewWithAnchors(statusView, leading: layoutGuide.leadingAnchor, trailing: layoutGuide.trailingAnchor, bottom: layoutGuide.bottomAnchor, insets: flatInsets)
    }
    
    func setupLicenseView(layoutGuide: UILayoutGuide){
        view.addSubviewWithAnchors(licenseView, trailing: layoutGuide.trailingAnchor, bottom: statusView.topAnchor, insets: defaultInsets)
        
        var label = UILabel()
        label.textColor = .darkGray
        label.font = .preferredFont(forTextStyle: .footnote)
        licenseView.addSubviewWithAnchors(label, top: licenseView.topAnchor, leading: licenseView.leadingAnchor, bottom: licenseView.bottomAnchor)
        label.text = "© "
        
        let link = UIButton()
        link.setTitleColor(.systemBlue, for: .normal)
        link.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
        licenseView.addSubviewWithAnchors(link, top: licenseView.topAnchor, leading: label.trailingAnchor, bottom: licenseView.bottomAnchor)
        link.setTitle("OpenStreetMap", for: .normal)
        link.addTarget(self, action: #selector(openOSMUrl), for: .touchDown)
        
        label = UILabel()
        label.textColor = .darkGray
        label.font = .preferredFont(forTextStyle: .footnote)
        licenseView.addSubviewWithAnchors(label, top: licenseView.topAnchor, leading: link.trailingAnchor, trailing: licenseView.trailingAnchor, bottom: licenseView.bottomAnchor, insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: defaultInset))
        label.text = " contributors"
    }
    
    func addImage(location: Location?){
        let pickerController = ImagePickerController()
        pickerController.location = location
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        pickerController.modalPresentationStyle = .fullScreen
        self.present(pickerController, animated: true, completion: nil)
    }
    
    @objc func openOSMUrl() {
        UIApplication.shared.open(URL(string: "https://www.openstreetmap.org/copyright")!)
    }
    
    func startTrackInfo(){
        statusView.startInfo()
        
    }
    
    func pauseTrackInfo(){
        
    }
    
    func resumeTrackInfo(){
        
    }
    
    func updateTrackInfo(){
        statusView.updateInfo()
    }
    
    func stopTrackInfo(){
        statusView.stopInfo()
    }
    
}

extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let imageURL = info[.imageURL] as? URL, let pickerController = picker as? ImagePickerController else {return}
        let image = ImageFile()
        image.setFileNameFromURL(imageURL)
        if FileController.copyFile(fromURL: imageURL, toURL: image.fileURL){
            if let location = pickerController.location{
                let changeState = location.media.isEmpty
                location.addMedia(file: image)
                LocationPool.save()
                if changeState{
                    DispatchQueue.main.async {
                        self.updateMarkerLayer()
                    }
                }
            }
            else if let location = LocationService.shared.location{
                assertLocation(coordinate: location.coordinate){ location in
                    let changeState = location.media.isEmpty
                    location.addMedia(file: image)
                    LocationPool.save()
                    if changeState{
                        DispatchQueue.main.async {
                            self.updateMarkerLayer()
                        }
                    }
                }
            }
        }
        picker.dismiss(animated: false)
    }
    
}

extension MainViewController: LocationServiceDelegate{
    
    func locationDidChange(location: CLLocation) {
        mapView.locationDidChange(location: location)
        if TrackRecorder.isRecording{
            TrackRecorder.updateTrack(with: location)
            mapView.trackLayerView.setNeedsDisplay()
            updateTrackInfo()
        }
    }
    
    func directionDidChange(direction: CLLocationDirection) {
        mapView.setDirection(direction)
    }
    
}

extension MainViewController: LocationLayerViewDelegate{
    
    func showLocationDetails(location: Location) {
        let controller = LocationDetailViewController(location: location)
        controller.location = location
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func addImageToLocation(location: Location) {
        addImage(location: location)
    }
    
    func showGroupDetails(group: LocationGroup) {
        //todo
    }
    
    func mergeGroup(group: LocationGroup) {
        //todo
    }
    
}

extension MainViewController: MapPositionDelegate{
    
    func showDetailsOfCurrentPosition() {
        if let location = LocationService.shared.location{
            LocationService.shared.getPlacemark(for: location){ placemark in
                var str : String
                if let placemark = placemark{
                    str = placemark.locationString + "\n" + location.coordinate.coordinateString
                } else{
                    str = location.coordinate.coordinateString
                }
                self.showAlert(title: "currentPosition".localize(), text: str)
            }
        }
    }
    
    func addLocationAtCurrentPosition() {
        if let location = LocationService.shared.location{
            assertLocation(coordinate: location.coordinate){ location in
                LocationPool.save()
                DispatchQueue.main.async {
                    self.updateMarkerLayer()
                }
            }
        }
    }
    
    func addPhotoAtCurrentPosition() {
        AVCaptureDevice.askCameraAuthorization(){ result in
            switch result{
            case .success(()):
                DispatchQueue.main.async {
                    let imageCaptureController = PhotoCaptureViewController()
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
    
    func addImageAtCurrentPosition() {
        addImage(location: nil)
    }
    
    func addAudioAtCurrentPosition(){
        AVCaptureDevice.askAudioAuthorization(){ result in
            switch result{
            case .success(()):
                DispatchQueue.main.async {
                    let audioCaptureController = AudioRecorderViewController()
                    audioCaptureController.delegate = self
                    audioCaptureController.modalPresentationStyle = .fullScreen
                    self.present(audioCaptureController, animated: true)
                }
                return
            case .failure:
                DispatchQueue.main.async {
                    self.showError("MainViewController audioNotAuthorized")
                }
                return
            }
        }
    }
    
    func addVideoAtCurrentPosition(){
        AVCaptureDevice.askVideoAuthorization(){ result in
            switch result{
            case .success(()):
                DispatchQueue.main.async {
                    let videoCaptureController = VideoCaptureViewController()
                    videoCaptureController.delegate = self
                    videoCaptureController.modalPresentationStyle = .fullScreen
                    self.present(videoCaptureController, animated: true)
                }
                return
            case .failure:
                DispatchQueue.main.async {
                    self.showError("MainViewController videoNotAuthorized")
                }
                return
            }
        }
    }
    
    func showDetailsOfCrossPosition() {
        let coordinate = mapView.scrollView.screenCenterCoordinate
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        LocationService.shared.getPlacemark(for: location){ placemark in
            var str : String
            if let placemark = placemark{
                str = placemark.locationString + "\n" + location.coordinate.coordinateString
            } else{
                str = location.coordinate.coordinateString
            }
            self.showAlert(title: "crossPosition".localize(), text: str)
        }
    }
    
    func addLocationAtCrossPosition() {
        assertLocation(coordinate: mapView.scrollView.screenCenterCoordinate){ location in
            LocationPool.save()
            DispatchQueue.main.async {
                self.updateMarkerLayer()
            }
        }
    }
    
    func addImageAtCrossPosition() {
        assertLocation(coordinate: mapView.scrollView.screenCenterCoordinate){ location in
            LocationPool.save()
            self.addImage(location: location)
        }
    }
    
}

extension MainViewController: PhotoCaptureDelegate{
    
    func photoCaptured(photo: ImageFile) {
        if let location = LocationService.shared.location{
            assertLocation(coordinate: location.coordinate){ location in
                let changeState = location.media.isEmpty
                debug("MainViewController adding photo to location, current media count = \(location.media.count)")
                location.addMedia(file: photo)
                debug("new media count = \(location.media.count)")
                LocationPool.save()
                if changeState{
                    DispatchQueue.main.async {
                        self.updateMarkerLayer()
                    }
                }
            }
        }
    }
    
}

extension MainViewController: VideoCaptureDelegate{
    
    func videoCaptured(data: VideoFile){
        if let location = LocationService.shared.location{
            assertLocation(coordinate: location.coordinate){ location in
                let changeState = location.media.isEmpty
                location.addMedia(file: data)
                LocationPool.save()
                if changeState{
                    DispatchQueue.main.async {
                        self.updateMarkerLayer()
                    }
                }
            }
        }
    }
    
}

extension MainViewController: AudioCaptureDelegate{
    
    func audioCaptured(data: AudioFile){
        if let location = LocationService.shared.location{
            assertLocation(coordinate: location.coordinate){ location in
                let changeState = location.media.isEmpty
                location.addMedia(file: data)
                LocationPool.save()
                if changeState{
                    DispatchQueue.main.async {
                        self.updateMarkerLayer()
                    }
                }
            }
        }
    }
    
}


extension MainViewController: MainMenuDelegate{
    
    func refreshMap() {
        mapView.refresh()
    }
    
    func updateCross() {
        mapView.crossView.isHidden = !AppState.shared.showCross
    }
    
    func openPreloadMap() {
        let region = mapView.scrollView.tileRegion
        if region.size > Preferences.maxRegionSize{
            showAlert(title: "regionTooLarge".localize(), text: "selectSmallerRegion".localize())
            return
        }
        let controller = TileCacheViewController()
        controller.mapRegion = region
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
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
    
    func openPreferences(){
        let controller = PreferencesViewController()
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func startTracking(){
        if let lastLocation = LocationService.shared.location{
            assertLocation(coordinate: lastLocation.coordinate){ location in
                TrackRecorder.startRecording(startPoint: location)
                if let track = TrackRecorder.track{
                    TrackPool.visibleTrack = track
                    self.mapView.trackLayerView.setNeedsDisplay()
                    self.startTrackInfo()
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

extension MainViewController: TileCacheDelegate{
    
    func deleteTiles() {
        TileProvider.shared.deleteAllTiles()
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
        LocationPool.deleteLocation(location)
        LocationPool.save()
        updateMarkerLayer()
    }
    
    func deleteAllLocations() {
        LocationPool.deleteAllLocations()
        LocationPool.save()
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
        let isVisibleTrack = track == TrackPool.visibleTrack
        TrackPool.deleteTrack(track)
        if isVisibleTrack{
            TrackPool.visibleTrack = nil
            mapView.trackLayerView.setNeedsDisplay()
        }
    }
    
    func deleteAllTracks() {
        cancelActiveTrack()
        TrackPool.deleteAllTracks()
        TrackPool.visibleTrack = nil
        mapView.trackLayerView.setNeedsDisplay()
    }
    
    func showTrackOnMap(track: Track) {
        if !track.trackpoints.isEmpty, let boundingRect = track.trackpoints.boundingMapRect{
            TrackPool.visibleTrack = track
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
        pauseTrackInfo()
    }
    
    func resumeActiveTrack() {
        TrackRecorder.resumeRecording()
        resumeTrackInfo()
    }
    
    func cancelActiveTrack() {
        TrackRecorder.stopRecording()
        TrackPool.visibleTrack = nil
        mapView.trackLayerView.setNeedsDisplay()
        stopTrackInfo()
    }
    
    func saveActiveTrack() {
        if let track = TrackRecorder.track{
            let alertController = UIAlertController(title: "name".localize(), message: "nameOrDescriptionHint".localize(), preferredStyle: .alert)
            alertController.addTextField()
            alertController.addAction(UIAlertAction(title: "ok".localize(),style: .default) { action in
                track.name = alertController.textFields![0].text ?? "Tour"
                TrackPool.addTrack(track: track)
                TrackPool.save()
                TrackPool.visibleTrack = track
                self.mapView.trackLayerView.setNeedsDisplay()
                TrackRecorder.stopRecording()
                self.stopTrackInfo()
                self.mapView.updateLocationLayer()
            })
            present(alertController, animated: true)
        }
    }
    
}


