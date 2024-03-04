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
        Backup.exportToPhotoLibrary(){ result in
            spinner.stopAnimating()
            self.contentView.removeSubview(spinner)
            self.showDone(title: "success".localize(), text: "mediaExported".localize(i: result))
        }
    }
    
    @objc func createBackup(){
        let fileName = "maps4osm_backup_\(Date().shortFileDate()).zip"
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.startAnimating()
        contentView.addSubview(spinner)
        spinner.setAnchors(centerX: contentView.centerXAnchor, centerY: contentView.centerYAnchor)
        DispatchQueue.main.async {
            if let url = Backup.createBackupFile(name: fileName){
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

    

