/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import CoreLocation
import Zip
import UniformTypeIdentifiers
import Photos
import PhotosUI

class BackupViewController: PopupScrollViewController{
    
    override func loadView() {
        title = "export".localize()
        super.loadView()
        
        let exportToPhotoLibraryButton = UIButton()
        exportToPhotoLibraryButton.setTitle("exportToPhotoLibrary".localize(), for: .normal)
        exportToPhotoLibraryButton.setTitleColor(.systemBlue, for: .normal)
        exportToPhotoLibraryButton.addAction(UIAction(){ action in
            self.exportToPhotoLibrary()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(exportToPhotoLibraryButton, top: contentView.topAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
        
        let importFromPhotoLibraryButton = UIButton()
        importFromPhotoLibraryButton.setTitle("importFromPhotoLibrary".localize(), for: .normal)
        importFromPhotoLibraryButton.setTitleColor(.systemBlue, for: .normal)
        importFromPhotoLibraryButton.addAction(UIAction(){ action in
            self.importFromPhotoLibrary()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(importFromPhotoLibraryButton, top: exportToPhotoLibraryButton.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
        
        let createBackupButton = UIButton()
        createBackupButton.setTitle("createBackup".localize(), for: .normal)
        createBackupButton.setTitleColor(.systemBlue, for: .normal)
        createBackupButton.addAction(UIAction(){ action in
            self.createBackup()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(createBackupButton, top: importFromPhotoLibraryButton.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
        
        let restoreBackupButton = UIButton()
        restoreBackupButton.setTitle("restoreBackup".localize(), for: .normal)
        restoreBackupButton.setTitleColor(.systemBlue, for: .normal)
        restoreBackupButton.addAction(UIAction(){ action in
            self.restoreBackup()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(restoreBackupButton, top: createBackupButton.bottomAnchor, bottom: contentView.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
    }

    
    func exportToPhotoLibrary(){
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.startAnimating()
        contentView.addSubview(spinner)
        spinner.setAnchors(centerX: contentView.centerXAnchor, centerY: contentView.centerYAnchor)
        DispatchQueue.global(qos: .userInitiated).async {
            var numCopied = 0
            for location in PlacePool.list{
                for media in location.media{
                    switch (media.type){
                    case .image:
                        if let data = media.data.getFile(){
                            if media.type == .image{
                                PhotoLibrary.savePhoto(photoData: data, fileType: .jpg, location: CLLocation(coordinate: location.coordinate, altitude: location.altitude, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: location.timestamp), resultHandler: { localIdentifier in
                                    numCopied += 1
                                })
                            }
                        }
                    case .video:
                        PhotoLibrary.saveVideo(outputFileURL: media.data.fileURL, location: CLLocation(coordinate: location.coordinate, altitude: location.altitude, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: location.timestamp), resultHandler: { localIdentifier in
                            numCopied += 1
                        })
                    default:
                        break
                    }
                }
                PlacePool.save()
            }
            DispatchQueue.main.async {
                spinner.stopAnimating()
                self.contentView.removeSubview(spinner)
                self.showDone(title: "success".localize(), text: "mediaExported".localize(i: numCopied))
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
        contentView.addSubview(spinner)
        spinner.setAnchors(centerX: contentView.centerXAnchor, centerY: contentView.centerYAnchor)
        DispatchQueue.main.async {
            if let _ = Backup.createBackupFile(name: fileName){
                self.showDone(title: "success".localize(), text: "backupSaved".localize())
            }
            spinner.stopAnimating()
            self.contentView.removeSubview(spinner)
        }
    }
    
    func restoreBackup(){
        let types = UTType.types(tag: "zip", tagClass: UTTagClass.filenameExtension, conformingTo: nil)
        let documentPickerController = UIDocumentPickerViewController(forOpeningContentTypes: types)
        documentPickerController.directoryURL = FileController.backupDirURL
        documentPickerController.delegate = self
        self.present(documentPickerController, animated: true, completion: nil)
    }
    
}

extension BackupViewController: PHPickerViewControllerDelegate{
    
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

extension BackupViewController: UIDocumentPickerDelegate{
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.startAnimating()
        contentView.addSubview(spinner)
        spinner.setAnchors(centerX: contentView.centerXAnchor, centerY: contentView.centerYAnchor)
        DispatchQueue.main.async {
            if Backup.unzipBackupFile(zipFileURL: url){
                if Backup.restoreBackupFile(){
                    self.showDone(title: "success".localize(), text: "restoreDone".localize())
                }
            }
            spinner.stopAnimating()
            self.contentView.removeSubview(spinner)
        }
    }
    
}

    

