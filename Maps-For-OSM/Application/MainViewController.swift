/*
 Maps For OSM
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
    
    override func loadView() {
        super.loadView()
        setupViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.setDefaultLocation()
    }
    
    func setupViews(){
        let layoutGuide = view.safeAreaLayoutGuide
        setupMapView(layoutGuide: layoutGuide)
        setupMainMenuView(layoutGuide: layoutGuide)
        mainMenuView.delegate = self
        setupLicenseView(layoutGuide: layoutGuide)
        setupStatusView(layoutGuide: layoutGuide)
        mapView.delegate = self
    }
    
    func setupMapView(layoutGuide: UILayoutGuide){
        view.addSubviewFilling(mapView)
        mapView.frame = view.bounds
        mapView.setupScrollView()
        mapView.setupTrackLayerView()
        mapView.setupLocationLayerView()
        mapView.locationLayerView.delegate = self
        mapView.setupCrossView()
        mapView.setupCurrentLocationView()
    }
    
    func setupMainMenuView(layoutGuide: UILayoutGuide){
        view.addSubviewWithAnchors(mainMenuView, top: layoutGuide.topAnchor, leading: layoutGuide.leadingAnchor, trailing: layoutGuide.trailingAnchor, insets: flatInsets)
        mainMenuView.setup()
    }
    
    func setupLicenseView(layoutGuide: UILayoutGuide){
        view.addSubviewWithAnchors(licenseView, trailing: layoutGuide.trailingAnchor, bottom: layoutGuide.bottomAnchor, insets: defaultInsets)
        
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
    
    func setupStatusView(layoutGuide: UILayoutGuide){
        statusView.setup()
        view.addSubviewWithAnchors(statusView, leading: layoutGuide.leadingAnchor, trailing: layoutGuide.trailingAnchor, bottom: licenseView.topAnchor, insets: flatInsets)
    }
    
    @objc func openOSMUrl() {
        UIApplication.shared.open(URL(string: "https://www.openstreetmap.org/copyright")!)
    }
    
    func addImage(location: Place?){
        let pickerController = ImagePickerController()
        pickerController.location = location
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        pickerController.modalPresentationStyle = .fullScreen
        self.present(pickerController, animated: true, completion: nil)
    }
    
    //LocationLayerViewDelegate
    func addImageToPlace(place: Place) {
        addImage(location: place)
    }
    
    func addPlace(at coordinate: CLLocationCoordinate2D) {
        if let coordinate = LocationService.shared.location?.coordinate{
            PlacePool.getPlace(coordinate: coordinate)
            DispatchQueue.main.async {
                self.updateMarkerLayer()
            }
        }
    }
    
    func openCamera(at coordinate: CLLocationCoordinate2D) {
        AVCaptureDevice.askCameraAuthorization(){ result in
            switch result{
            case .success(()):
                DispatchQueue.main.async {
                    let cameraCaptureController = CameraViewController()
                    cameraCaptureController.delegate = self
                    cameraCaptureController.modalPresentationStyle = .fullScreen
                    self.present(cameraCaptureController, animated: true)
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
    
    func addImage(at coordinate: CLLocationCoordinate2D) {
        addImage(location: nil)
    }
    
    func addAudio(at coordinate: CLLocationCoordinate2D){
        AVCaptureDevice.askAudioAuthorization(){ result in
            switch result{
            case .success(()):
                DispatchQueue.main.async {
                    let audioCaptureController = AudioRecorderViewController()
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
    
    func updateFollowTrack(){
        if Preferences.shared.followTrack{
            if TrackRecorder.isRecording{
                mapView.focusUserLocation()
            }
        }
    }
    
    func showSearchResult(coordinate: CLLocationCoordinate2D, mapRect: MapRect?) {
        if let mapRect = mapRect{
            mapView.scrollView.scrollToScreenCenter(coordinate: coordinate)
            mapView.scrollView.setZoomScale(World.getZoomScaleToFit(mapRect: mapRect, scaledBounds: mapView.bounds)*0.9, animated: true)
        }
        else{
            mapView.scrollView.scrollToScreenCenter(coordinate: coordinate)
        }
    }
    
    func viewTrackDetails(track: Track) {
        let trackController = TrackDetailViewController()
        trackController.track = track
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
    
    func showTrackOnMap(track: Track) {
        if !track.trackpoints.isEmpty, let boundingRect = track.trackpoints.boundingMapRect{
            TrackPool.visibleTrack = track
            mapView.trackLayerView.setNeedsDisplay()
            mapView.scrollView.scrollToScreenCenter(coordinate: boundingRect.centerCoordinate)
            mapView.scrollView.setZoomScale(World.getZoomScaleToFit(mapRect: boundingRect, scaledBounds: mapView.bounds)*0.9, animated: true)
            mainMenuView.updateTrackMenu()
        }
    }
    
    func updateTrackLayer() {
        mapView.trackLayerView.setNeedsDisplay()
    }
    
    func showDetailsOfCurrentLocation() {
        let coordinate = LocationService.shared.location?.coordinate ?? CLLocationCoordinate2D()
        let controller = LocationViewController(coordinate: coordinate, title: "currentLocation".localize())
        present(controller, animated: true)
    }
    
    func showDetailsOfCrossLocation() {
        let coordinate = mapView.scrollView.screenCenterCoordinate
        let controller = LocationViewController(coordinate: coordinate, title: "crossLocation".localize())
        controller.modalPresentationStyle = .popover
        present(controller, animated: true)
    }
    
    func showPlaceOnMap(place: Place) {
        mapView.scrollView.scrollToScreenCenter(coordinate: place.coordinate)
    }
    
    func deletePlaceFromList(place: Place) {
        PlacePool.deletePlace(place)
        PlacePool.save()
        updateMarkerLayer()
    }
    
}

extension MainViewController: LocationServiceDelegate{
    
    func locationDidChange(location: CLLocation) {
        mapView.locationDidChange(location: location)
        if TrackRecorder.isRecording{
            if TrackRecorder.updateTrack(with: location){
                mapView.trackLayerView.setNeedsDisplay()
                if Preferences.shared.followTrack{
                    mapView.focusUserLocation()
                }
            }
            statusView.updateTrackInfo()
        }
        if statusView.isDetailed{
            statusView.updateDetailInfo(location: location)
        }
    }
    
    func directionDidChange(direction: CLLocationDirection) {
        mapView.setDirection(direction)
        statusView.updateDirection(direction: direction)
    }
    
}
