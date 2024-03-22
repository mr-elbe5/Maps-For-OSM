/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import AVFoundation
import Photos
import PhotosUI

extension MainViewController: PHPickerViewControllerDelegate{
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        for result in results{
            var location: CLLocation? = nil
            if let ident = result.assetIdentifier{
                if let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [ident], options: nil).firstObject{
                    location = fetchResult.location
                }
            }
            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) {  image, error in
                    if let image = image {
                        print("got image \(image.description) at location \(location?.coordinate ?? CLLocationCoordinate2D())")
                    }
                }
            }
            else{
                itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, err in
                    if let url = url {
                        print("got video url: \(url) at location \(location?.coordinate ?? CLLocationCoordinate2D())")
                    }
                }
            }
        }
        picker.dismiss(animated: false)
    }
    
}

extension MainViewController: UIDocumentPickerDelegate{
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.startAnimating()
        view.addSubview(spinner)
        spinner.setAnchors(centerX: view.centerXAnchor, centerY: view.centerYAnchor)
        DispatchQueue.main.async {
            if Backup.unzipBackupFile(zipFileURL: url){
                if Backup.restoreBackupFile(){
                    self.showDone(title: "success".localize(), text: "restoreDone".localize())
                    self.mapView.updatePlaceLayer()
                }
            }
            spinner.stopAnimating()
            self.view.removeSubview(spinner)
        }
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
            trackStatusView.updateTrackInfo()
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

extension MainViewController: MapPositionDelegate{
    
    func showDetailsOfCurrentLocation() {
        let coordinate = LocationService.shared.location?.coordinate ?? CLLocationCoordinate2D()
        let controller = LocationViewController(coordinate: coordinate, title: "currentLocation".localize())
        controller.delegate = self
        controller.modalPresentationStyle = .automatic
        present(controller, animated: true)
    }
    
    func showDetailsOfCrossLocation() {
        let coordinate = mapView.scrollView.screenCenterCoordinate
        let controller = LocationViewController(coordinate: coordinate, title: "crossLocation".localize())
        controller.delegate = self
        controller.modalPresentationStyle = .automatic
        present(controller, animated: true)
    }
    
}

extension MainViewController: TrackStatusDelegate{
    
    func togglePauseTracking() {
        TrackRecorder.isRecording = !TrackRecorder.isRecording
    }
    
}

extension MainViewController: PlaceListDelegate, PlaceViewDelegate, PlaceLayerDelegate, LocationViewDelegate {
    
    func showPlaceOnMap(place: Place) {
        mapView.scrollView.scrollToScreenCenter(coordinate: place.coordinate)
    }
    
    func deletePlaceFromList(place: Place) {
        PlacePool.deletePlace(place)
        PlacePool.save()
        updateMarkerLayer()
    }
    
    func showPlaceDetails(place: Place) {
        let controller = PlaceViewController(location: place)
        controller.place = place
        controller.modalPresentationStyle = .fullScreen
        controller.delegate = self
        present(controller, animated: true)
    }
    
    func deletePlace(place: Place) {
        showDestructiveApprove(title: "confirmDeletePlace".localize(), text: "deletePlaceHint".localize()){
            PlacePool.deletePlace(place)
            PlacePool.save()
            self.updateMarkerLayer()
        }
    }
    
    func addPlace(at coordinate: CLLocationCoordinate2D) {
        if let coordinate = LocationService.shared.location?.coordinate{
            PlacePool.assertPlace(coordinate: coordinate)
            DispatchQueue.main.async {
                self.updateMarkerLayer()
            }
        }
    }
    
    func showItemOnMap(place: Place, item: PlaceItem) {
        
    }
    
    func showGroupDetails(group: PlaceGroup) {
        let controller = PlaceGroupViewController(group: group)
        controller.modalPresentationStyle = .popover
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func mergeGroup(group: PlaceGroup) {
        if let mergedLocation = group.centralPlace{
            showDestructiveApprove(title: "confirmMergeGroup".localize(), text: "\("newLocationHint".localize())\n\(mergedLocation.coordinate.asString)"){
                PlacePool.places.append(mergedLocation)
                PlacePool.places.removeAllOf(group.places)
                PlacePool.save()
                self.updateMarkerLayer()
            }
        }
    }
}

extension MainViewController: TrackDetailDelegate, TrackListDelegate{
    
    func viewTrackDetails(track: TrackItem) {
        let controller = TrackViewController(track: track)
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
    }
    
    func deleteTrack(track: TrackItem, approved: Bool) {
        if approved{
            deleteTrack(track: track)
        }
        else{
            showDestructiveApprove(title: "confirmDeleteTrack".localize(), text: "deleteTrackHint".localize()){
                self.deleteTrack(track: track)
            }
        }
    }
    
    private func deleteTrack(track: TrackItem){
        let isVisibleTrack = track == TrackPool.visibleTrack
        TrackPool.deleteTrack(track)
        if isVisibleTrack{
            TrackPool.visibleTrack = nil
            mapView.trackLayerView.setNeedsDisplay()
        }
    }
    
    func showTrackOnMap(track: TrackItem) {
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
    
}

extension MainViewController: SearchDelegate{
    
    func showSearchResult(coordinate: CLLocationCoordinate2D, mapRect: MapRect?) {
        if let mapRect = mapRect{
            mapView.scrollView.scrollToScreenCenter(coordinate: coordinate)
            mapView.scrollView.setZoomScale(World.getZoomScaleToFit(mapRect: mapRect, scaledBounds: mapView.bounds)*0.9, animated: true)
        }
        else{
            mapView.scrollView.scrollToScreenCenter(coordinate: coordinate)
        }
    }
    
}

