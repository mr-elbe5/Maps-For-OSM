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
                for location in PlacePool.places{
                    for item in location.items{
                        if item.type == .image{
                            photoCount += 1
                        }
                    }
                }
                for place in PlacePool.places{
                    for listItem in place.items{
                        switch (listItem.type){
                        case .image:
                            if let item = listItem as? ImageItem, let data = item.getFile(){
                                if listItem.type == .image{
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

