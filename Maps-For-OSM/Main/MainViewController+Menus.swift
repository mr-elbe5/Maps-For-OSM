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
import E5Data
import E5MapData
import E5IOSUI

extension MainViewController: MainMenuDelegate{
    
    func refreshMap() {
        mapView.refresh()
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
        let controller = LocationListViewController()
        controller.locationDelegate = self
        controller.trackDelegate = self
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func showLocations(_ show: Bool) {
        AppState.shared.showLocations = show
        mapView.locationLayerView.isHidden = !AppState.shared.showLocations
    }
    
    func deleteAllLocations(){
        showDestructiveApprove(title: "confirmDeleteLocations".localize(), text: "deleteLocationsHint".localize()){
            AppData.shared.deleteAllLocations()
            AppData.shared.saveLocally()
            self.locationsChanged()
        }
    }
    
    func openTrackList() {
        let controller = TrackListViewController()
        controller.tracks = AppData.shared.locations.trackItems
        controller.locationDelegate = self
        controller.trackDelegate = self
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func importTrack(){
        let filePicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType(filenameExtension: "gpx")!])
        filePicker.directoryURL = FileManager.exportGpxDirURL
        filePicker.allowsMultipleSelection = false
        filePicker.delegate = self
        filePicker.modalPresentationStyle = .fullScreen
        self.present(filePicker, animated: true)
    }
    
    func hideTrack() {
        TrackItem.visibleTrack = nil
        trackChanged()
    }
    
    func openImageList() {
        let controller = ImageListViewController()
        controller.images = AppData.shared.locations.imageItems
        controller.locationDelegate = self
        controller.imageDelegate = self
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func importImages() {
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
    
    func applyFilter() {
        mapView.updateLocations()
    }
    
    func focusUserLocation() {
        mapView.focusUserLocation()
    }
    
    func openICloud(){
        let controller = ICloudViewController()
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func openPreferences(){
        let controller = PreferencesViewController()
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func openSearch() {
        let controller = SearchViewController()
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func createBackup(){
        let fileName = "maps4osm_backup_\(Date.localDate.shortFileDate()).zip"
        let spinner = startSpinner()
        DispatchQueue.main.async {
            if let _ = Backup.createBackupFile(name: fileName){
                self.showDone(title: "success".localize(), text: "backupSaved".localize())
            }
            self.stopSpinner(spinner)
        }
    }
    
    func restoreBackup(){
        showDestructiveApprove(title: "restoreBackup".localize(), text: "restoreBackupHint".localize()){
            let types = UTType.types(tag: "zip", tagClass: UTTagClass.filenameExtension, conformingTo: nil)
            let documentPickerController = UIDocumentPickerViewController(forOpeningContentTypes: types)
            documentPickerController.directoryURL = FileManager.backupDirURL
            documentPickerController.delegate = self
            self.present(documentPickerController, animated: true, completion: nil)
        }
    }
    
}

extension MainViewController: PHPickerViewControllerDelegate{
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        for result in results{
            var location: CLLocation? = nil
            var creationDate : Date? = nil
            if let ident = result.assetIdentifier{
                if let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [ident], options: nil).firstObject{
                    location = fetchResult.location
                    creationDate = fetchResult.creationDate
                }
            }
            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) {  uiimage, error in
                    if let uiimage = uiimage as? UIImage {
                        //Log.debug("got image \(uiimage.description) at location \(location?.coordinate ?? CLLocationCoordinate2D())")
                        if let coordinate = location?.coordinate{
                            var newLocation = false
                            var location = AppData.shared.getLocation(coordinate: coordinate)
                            if location == nil{
                                location = AppData.shared.createLocation(coordinate: coordinate)
                                newLocation = true
                            }
                            let image = ImageItem()
                            image.creationDate = creationDate ?? Date.localDate
                            image.saveImage(uiImage: uiimage)
                            location!.addItem(item: image)
                            DispatchQueue.main.async {
                                if newLocation{
                                    self.locationsChanged()
                                }
                                else{
                                    self.locationChanged(location: location!)
                                }
                            }
                        }
                    }
                }
            }
            else{
                itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, err in
                    if let url = url {
                        //Log.debug("got video url: \(url) at location \(location?.coordinate ?? CLLocationCoordinate2D())")
                        if let coordinate = location?.coordinate{
                            var newLocation = false
                            var location = AppData.shared.getLocation(coordinate: coordinate)
                            if location == nil{
                                location = AppData.shared.createLocation(coordinate: coordinate)
                                newLocation = true
                            }
                            let video = VideoItem()
                            video.creationDate = creationDate ?? Date.localDate
                            video.setFileNameFromURL(url)
                            if let data = FileManager.default.readFile(url: url){
                                video.saveFile(data: data)
                                location!.addItem(item: video)
                                DispatchQueue.main.async {
                                    if newLocation{
                                        self.locationsChanged()
                                    }
                                    else{
                                        self.locationChanged(location: location!)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        picker.dismiss(animated: false)
    }
    
}

extension MainViewController : UIDocumentPickerDelegate{
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first{
            if url.pathExtension == "gpx"{
                importGPXFile(url: url)
            }
            if url.pathExtension == "zip"{
                importBackupFile(url: url)
            }
        }
    }
    
    private func importGPXFile(url: URL){
        if let gpxData = GPXParser.parseFile(url: url), !gpxData.isEmpty{
            let track = TrackItem()
            track.name = gpxData.name
            for segment in gpxData.segments{
                for point in segment.points{
                    track.trackpoints.append(Trackpoint(location: point.location))
                }
            }
            track.evaluateImportedTrackpoints()
            if track.name.isEmpty{
                let ext = url.pathExtension
                var name = url.lastPathComponent
                name = String(name[name.startIndex...name.index(name.endIndex, offsetBy: -ext.count)])
                Log.debug(name)
                track.name = name
            }
            track.evaluateImportedTrackpoints()
            track.startTime = track.trackpoints.first?.timestamp ?? Date.localDate
            track.endTime = track.trackpoints.last?.timestamp ?? Date.localDate
            track.creationDate = track.startTime
            var newLocation = false
            var location = AppData.shared.getLocation(coordinate: track.startCoordinate!)
            if location == nil{
                location = AppData.shared.createLocation(coordinate: track.startCoordinate!)
                newLocation = true
            }
            location!.addItem(item: track)
            AppData.shared.saveLocally()
            DispatchQueue.main.async {
                if newLocation{
                    self.locationsChanged()
                }
                else{
                    self.locationChanged(location: location!)
                }
            }
        }
    }
    
    private func importBackupFile(url: URL){
        let spinner = startSpinner()
        DispatchQueue.main.async {
            if Backup.unzipBackupFile(zipFileURL: url){
                if Backup.restoreBackupFile(){
                    self.showDone(title: "success".localize(), text: "restoreDone".localize())
                    self.mapView.updateLocations()
                }
            }
            self.stopSpinner(spinner)
        }
    }
    
}

extension MainViewController: MapMenuDelegate{
    
    func updateCross() {
        mapView.crossLocationView.isHidden = !AppState.shared.showCross
    }
    
    func zoomIn() {
        if AppState.shared.zoom < World.maxZoom{
            mapView.zoomTo(zoom: AppState.shared.zoom + 1, animated: true)
        }
    }
    
    func zoomOut() {
        if AppState.shared.zoom > World.minZoom{
            mapView.zoomTo(zoom: AppState.shared.zoom - 1, animated: true)
        }
    }
    
}

extension MainViewController: TrackStatusDelegate{
    
    func togglePauseTracking() {
        if let trackRecorder = TrackRecorder.instance{
            trackRecorder.isRecording = !trackRecorder.isRecording
        }
    }
    
}

extension MainViewController: AppLoaderDelegate{
    
    func dataChanged() {
        mapView.updateLocations()
    }
    
}

