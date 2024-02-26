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

class BackupViewController: PopupScrollViewController{
    
    override func loadView() {
        title = "export".localize()
        super.loadView()
        
        
        let exportImagesButton = UIButton()
        exportImagesButton.setTitle("exportImages".localize(), for: .normal)
        exportImagesButton.setTitleColor(.systemBlue, for: .normal)
        exportImagesButton.addTarget(self, action: #selector(exportImages), for: .touchDown)
        contentView.addSubviewWithAnchors(exportImagesButton, top: contentView.topAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
        
        let exportMediaButton = UIButton()
        exportMediaButton.setTitle("exportMedia".localize(), for: .normal)
        exportMediaButton.setTitleColor(.systemBlue, for: .normal)
        exportMediaButton.addTarget(self, action: #selector(exportMedia), for: .touchDown)
        contentView.addSubviewWithAnchors(exportMediaButton, top: exportImagesButton.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
        
        let createBackupButton = UIButton()
        createBackupButton.setTitle("createBackup".localize(), for: .normal)
        createBackupButton.setTitleColor(.systemBlue, for: .normal)
        createBackupButton.addTarget(self, action: #selector(createBackup), for: .touchDown)
        contentView.addSubviewWithAnchors(createBackupButton, top: exportMediaButton.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
        
        let restoreBackupButton = UIButton()
        restoreBackupButton.setTitle("restoreBackup".localize(), for: .normal)
        restoreBackupButton.setTitleColor(.systemBlue, for: .normal)
        restoreBackupButton.addTarget(self, action: #selector(restoreBackup), for: .touchDown)
        contentView.addSubviewWithAnchors(restoreBackupButton, top: createBackupButton.bottomAnchor, bottom: contentView.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
        
    }
    
    @objc func exportImages(){
        let alertController = UIAlertController(title: title, message: "exportImages".localize(), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "ok".localize(), style: .default) { action in
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.startAnimating()
            self.contentView.addSubview(spinner)
            spinner.setAnchors(centerX: self.contentView.centerXAnchor, centerY: self.contentView.centerYAnchor)
            DispatchQueue.main.async {
                var numCopied = 0
                for location in LocationPool.list{
                    for media in location.media{
                        if let image = media.data as? ImageFile{
                            FileController.copyImageToLibrary(name: image.fileName, fromDir: FileController.mediaDirURL){ result in
                                switch result{
                                case .success:
                                    numCopied += 1
                                case .failure:
                                    break
                                }
                            }
                        }
                    }
                }
                spinner.stopAnimating()
                self.contentView.removeSubview(spinner)
                DispatchQueue.main.async {
                    self.showAlert(title: "success".localize(), text: "imagesExported".localize(i: numCopied))
                }
            }
        })
        alertController.addAction(UIAlertAction(title: "cancel".localize(), style: .cancel))
        self.present(alertController, animated: true)
    }
    
    @objc func exportMedia(){
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.startAnimating()
        contentView.addSubview(spinner)
        spinner.setAnchors(centerX: contentView.centerXAnchor, centerY: contentView.centerYAnchor)
        DispatchQueue.main.async {
            var numCopied = 0
            for location in LocationPool.list{
                for media in location.media{
                    FileController.copyFile(fromURL: FileController.mediaDirURL.appendingPathComponent(media.data.fileName), toURL: FileController.exportMediaDirURL.appendingPathComponent(media.data.fileName), replace: true)
                    numCopied += 1
                }
            }
            spinner.stopAnimating()
            self.contentView.removeSubview(spinner)
            self.showDone(title: "success".localize(), text: "mediaExported".localize(i: numCopied))
        }
    }
    
    @objc func createBackup(){
        let fileName = "maps4osm_backup_\(Date().shortFileDate()).zip"
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.startAnimating()
        contentView.addSubview(spinner)
        spinner.setAnchors(centerX: contentView.centerXAnchor, centerY: contentView.centerYAnchor)
        DispatchQueue.main.async {
            if let url = self.createBackupFile(name: fileName){
                var urls = [URL]()
                urls.append(url)
                self.showDone(title: "success".localize(), text: "backupSaved".localize())
            }
            spinner.stopAnimating()
            self.contentView.removeSubview(spinner)
        }
    }
    
    @objc func restoreBackup(){
        let types = UTType.types(tag: "zip", tagClass: UTTagClass.filenameExtension, conformingTo: nil)
        let documentPickerController = UIDocumentPickerViewController(forOpeningContentTypes: types)
        documentPickerController.directoryURL = FileController.backupDirURL
        documentPickerController.delegate = self
        self.present(documentPickerController, animated: true, completion: nil)
    }
    
    func createBackupFile(name: String) -> URL?{
        do {
            FileController.deleteTemporaryFiles()
            var paths = Array<URL>()
            let zipFileURL = FileController.backupDirURL.appendingPathComponent(name)
            paths.append(FileController.mediaDirURL)
            for track in TrackPool.list{
                if let trackFileURL = GPXCreator.createTemporaryFile(track: track){
                    paths.append(trackFileURL)
                }
            }
            if let url = LocationPool.saveAsFile(){
                paths.append(url)
            }
            if let url = TrackPool.saveAsFile(){
                paths.append(url)
            }
            if let url = Preferences.saveAsFile(){
                paths.append(url)
            }
            if let url = AppState.saveAsFile(){
                paths.append(url)
            }
            try Zip.zipFiles(paths: paths, zipFilePath: zipFileURL, password: nil, progress: { (progress) -> () in
                print(progress)
            })
            return zipFileURL
        }
        catch let err {
            print(err)
            Log.error("could not create zip file")
        }
        return nil
    }
    
    func unzipBackupFile(zipFileURL: URL) -> Bool{
        do {
            FileController.deleteTemporaryFiles()
            try FileManager.default.createDirectory(at: FileController.temporaryURL, withIntermediateDirectories: true)
            try Zip.unzipFile(zipFileURL, destination: FileController.temporaryURL, overwrite: true, password: nil, progress: { (progress) -> () in
                print(progress)
            })
            return true
        }
        catch (let err){
            print(err.localizedDescription)
            Log.error("could not read zip file")
        }
        return false
    }
    
    func restoreBackupFile() -> Bool{
        FileController.deleteAllFiles(dirURL: FileController.mediaDirURL)
        let fileNames = FileController.listAllFiles(dirPath: FileController.temporaryURL.appendingPathComponent("media").path)
        for name in fileNames{
            FileController.copyFile(fromURL: FileController.temporaryURL.appendingPathComponent("media").appendingPathComponent(name), toURL: FileController.mediaDirURL.appendingPathComponent(name), replace: true)
        }
        var url = FileController.temporaryURL.appendingPathComponent(AppState.storeKey + ".json")
        AppState.loadFromFile(url: url)
        url = FileController.temporaryURL.appendingPathComponent(Preferences.storeKey + ".json")
        Preferences.loadFromFile(url: url)
        url = FileController.temporaryURL.appendingPathComponent(LocationPool.storeKey + ".json")
        LocationPool.loadFromFile(url: url)
        url = FileController.temporaryURL.appendingPathComponent(TrackPool.storeKey + ".json")
        TrackPool.loadFromFile(url: url)
        FileController.deleteTemporaryFiles()
        return true
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
            if self.unzipBackupFile(zipFileURL: url){
                if self.restoreBackupFile(){
                    self.showDone(title: "success".localize(), text: "restoreDone".localize())
                }
            }
            spinner.stopAnimating()
            self.contentView.removeSubview(spinner)
        }
    }
    
}

    

