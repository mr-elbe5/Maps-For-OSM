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
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func showLocations(_ show: Bool) {
        AppState.shared.showLocations = show
        mapView.placeLayerView.isHidden = !AppState.shared.showLocations
    }
    
    func deleteAllLocations(){
        showDestructiveApprove(title: "confirmDeletePlaces".localize(), text: "deletePlacesHint".localize()){
            PlacePool.deleteAllPlaces()
            PlacePool.save()
            self.updateMarkerLayer()
        }
    }
    
    func openPreferences(){
        let controller = PreferencesViewController()
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func openTrackList() {
        let controller = TrackListViewController()
        controller.tracks = PlacePool.tracks
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func hideTrack() {
        TrackPool.visibleTrack = nil
        trackChanged()
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
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func exportImagesToPhotoLibrary(){
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.startAnimating()
        view.addSubview(spinner)
        spinner.setAnchors(centerX: view.centerXAnchor, centerY: view.centerYAnchor)
        DispatchQueue.global(qos: .userInitiated).async {
            self.exportImagesToPhotoLibrary(){ numCopied, numErrors in
                PlacePool.save()
                DispatchQueue.main.async {
                    spinner.stopAnimating()
                    self.view.removeSubview(spinner)
                    if numErrors == 0{
                        self.showDone(title: "success".localize(), text: "imagesExported".localize(i: numCopied))
                    }
                    else{
                        self.showAlert(title: "error".localize(), text: "imagesExportedWithErrors".localize(i1: numCopied, i2: numErrors))
                    }
                }
            }
        }
    }
    
    private func exportImagesToPhotoLibrary(result: @escaping (Int, Int) -> Void){
        PHPhotoLibrary.requestAuthorization { status in
            if status == PHAuthorizationStatus.authorized {
                var photoCount = 0
                var numCopied = 0
                var numErrors = 0
                for place in PlacePool.places{
                    photoCount += place.imageCount
                }
                for place in PlacePool.places{
                    for item in place.allItems{
                        switch (item.type){
                        case .image:
                            if let item = item as? ImageItem, let data = item.getFile(){
                                if item.type == .image{
                                    PhotoLibrary.savePhoto(photoData: data, fileType: .jpg, location: CLLocation(coordinate: place.coordinate, altitude: place.altitude, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: place.timestamp), resultHandler: { localIdentifier in
                                        if !localIdentifier.isEmpty{
                                            numCopied += 1
                                        }
                                        else{
                                            numErrors += 1
                                        }
                                        if numErrors + numCopied == photoCount{
                                            result(numCopied, numErrors)
                                        }
                                    })
                                }
                            }
                            else{
                                numErrors += 1
                                if numErrors + numCopied == photoCount{
                                    result(numCopied, numErrors)
                                }
                            }
                        default:
                            break
                        }
                    }
                }
            }
        }
    }
    
    func importFromPhotoLibrary(){
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = PHPickerFilter.any(of: [.images, .videos])
        configuration.preferredAssetRepresentationMode = .automatic
        configuration.selection = .ordered
        configuration.selectionLimit = 0
        configuration.disabledCapabilities = [.search, .stagingArea]
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func createBackup(){
        let fileName = "maps4osm_backup_\(Date().shortFileDate()).zip"
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.startAnimating()
        view.addSubview(spinner)
        spinner.setAnchors(centerX: view.centerXAnchor, centerY: view.centerYAnchor)
        DispatchQueue.main.async {
            if let _ = Backup.createBackupFile(name: fileName){
                self.showDone(title: "success".localize(), text: "backupSaved".localize())
            }
            spinner.stopAnimating()
            self.view.removeSubview(spinner)
        }
    }
    
    func restoreBackup(){
        showDestructiveApprove(title: "restoreBackup".localize(), text: "restoreBackupHint".localize()){
            let types = UTType.types(tag: "zip", tagClass: UTTagClass.filenameExtension, conformingTo: nil)
            let documentPickerController = UIDocumentPickerViewController(forOpeningContentTypes: types)
            documentPickerController.directoryURL = FileController.backupDirURL
            documentPickerController.delegate = self
            self.present(documentPickerController, animated: true, completion: nil)
        }
    }
    
}

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
                        Log.debug("got image \(image.description) at location \(location?.coordinate ?? CLLocationCoordinate2D())")
                    }
                }
            }
            else{
                itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, err in
                    if let url = url {
                        Log.debug("got video url: \(url) at location \(location?.coordinate ?? CLLocationCoordinate2D())")
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

extension MainViewController: TrackStatusDelegate{
    
    func togglePauseTracking() {
        TrackRecorder.isRecording = !TrackRecorder.isRecording
    }
    
}

