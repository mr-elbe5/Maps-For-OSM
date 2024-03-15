/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import AVFoundation

extension MainViewController: MainMenuDelegate{
    
    func refreshMap() {
        mapView.refresh()
    }
    
    func updateCross() {
        mapView.crossLocationView.isHidden = !AppState.shared.showCross
    }
    
    func openPreloadTiles() {
        let region = mapView.scrollView.tileRegion
        let controller = PreloadViewController()
        controller.mapRegion = region
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func changeTileSource() {
        let controller = TileSourceViewController()
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
        let controller = PlaceListViewController()
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func showLocations(_ show: Bool) {
        AppState.shared.showLocations = show
        mapView.locationLayerView.isHidden = !AppState.shared.showLocations
    }
    
    func deleteAllLocations(){
        showDestructiveApprove(title: "confirmDeletePlaces".localize(), text: "deletePlacesHint".localize()){
            PlacePool.deleteAllPlaces()
            PlacePool.save()
            self.updateMarkerLayer()
        }
    }
    
    func openExport(){
        let controller = BackupViewController()
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func openPreferences(){
        let controller = PreferencesViewController()
        controller.modalPresentationStyle = .fullScreen
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
        present(controller, animated: true)
    }
    
}

extension MainViewController: PlaceLayerViewDelegate{
    
    func showPlaceDetails(place: Place) {
        let controller = PlaceDetailViewController(location: place)
        controller.place = place
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func movePlaceToScreenCenter(place: Place) {
        let centerCoordinate = mapView.scrollView.screenCenterCoordinate
        showDestructiveApprove(title: "confirmMovePlace".localize(), text: "\("newLocationHint".localize())\n\(centerCoordinate.asString)"){
            place.coordinate = centerCoordinate
            place.evaluatePlacemark()
            PlacePool.save()
            self.updateMarkerLayer()
        }
    }
    
    func deletePlace(place: Place) {
        showDestructiveApprove(title: "confirmDeletePlace".localize(), text: "deletePlaceHint".localize()){
            PlacePool.deletePlace(place)
            PlacePool.save()
            self.updateMarkerLayer()
        }
    }
    
    func showGroupDetails(group: PlaceGroup) {
        let controller = PlaceGroupViewController(group: group)
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func mergeGroup(group: PlaceGroup) {
        if let mergedLocation = group.centralPlace{
            showDestructiveApprove(title: "confirmMergeGroup".localize(), text: "\("newLocationHint".localize())\n\(mergedLocation.coordinate.asString)"){
                PlacePool.list.append(mergedLocation)
                PlacePool.list.removeAllOf(group.places)
                PlacePool.save()
                self.updateMarkerLayer()
            }
        }
    }
    
}

extension MainViewController: PlaceViewDelegate{
    
    func updateMarkerLayer() {
        mapView.updateLocationLayer()
    }
    
}

/// media delegates

extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let imageURL = info[.imageURL] as? URL, let pickerController = picker as? ImagePickerController else {return}
        let image = ImageFile()
        image.setFileNameFromURL(imageURL)
        if FileController.copyFile(fromURL: imageURL, toURL: image.fileURL){
            if let location = pickerController.location{
                let changeState = location.media.isEmpty
                location.addMedia(file: image)
                PlacePool.save()
                if changeState{
                    DispatchQueue.main.async {
                        self.updateMarkerLayer()
                    }
                }
            }
            else if let coordinate = LocationService.shared.location?.coordinate{
                let location = PlacePool.getPlace(coordinate: coordinate)
                let changeState = location.media.isEmpty
                location.addMedia(file: image)
                PlacePool.save()
                if changeState{
                    DispatchQueue.main.async {
                        self.updateMarkerLayer()
                    }
                }
            }
        }
        picker.dismiss(animated: false)
    }
    
}

extension MainViewController: CameraDelegate{
    
    func photoCaptured(data: Data, cllocation: CLLocation?) {
        if let cllocation = cllocation{
            let imageFile = ImageFile()
            imageFile.saveFile(data: data)
            print("photo saved locally")
            let location = PlacePool.getPlace(coordinate: cllocation.coordinate)
            let changeState = location.media.isEmpty
            location.addMedia(file: imageFile)
            PlacePool.save()
            if changeState{
                self.markersChanged()
            }
        }
    }
    
    func getImageWithImageData(data: Data, properties: NSDictionary) -> Data{

        let imageRef: CGImageSource = CGImageSourceCreateWithData((data as CFData), nil)!
        let uti: CFString = CGImageSourceGetType(imageRef)!
        let dataWithEXIF: NSMutableData = NSMutableData(data: data)
        let destination: CGImageDestination = CGImageDestinationCreateWithData((dataWithEXIF as CFMutableData), uti, 1, nil)!
        CGImageDestinationAddImageFromSource(destination, imageRef, 0, (properties as CFDictionary))
        CGImageDestinationFinalize(destination)
        return dataWithEXIF as Data
    }
    
    func videoCaptured(data: Data, cllocation: CLLocation?) {
        if let cllocation = cllocation{
            let videoFile = VideoFile()
            videoFile.saveFile(data: data)
            print("video saved locally")
            let location = PlacePool.getPlace(coordinate: cllocation.coordinate)
            let changeState = location.media.isEmpty
            location.addMedia(file: videoFile)
            PlacePool.save()
            if changeState{
                self.markersChanged()
            }
        }
    }
    
    func markersChanged() {
        DispatchQueue.main.async {
            self.updateMarkerLayer()
        }
    }
    
}

extension MainViewController: AudioCaptureDelegate{
    
    func audioCaptured(data: AudioFile){
        if let coordinate = LocationService.shared.location?.coordinate{
            let location = PlacePool.getPlace(coordinate: coordinate)
            let changeState = location.media.isEmpty
            location.addMedia(file: data)
            PlacePool.save()
            if changeState{
                DispatchQueue.main.async {
                    self.updateMarkerLayer()
                }
            }
        }
    }
    
}


