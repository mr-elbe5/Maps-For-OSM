/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import CoreLocation

class ExportViewController: PopupScrollViewController{
    
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
        contentView.addSubviewWithAnchors(createBackupButton, top: exportMediaButton.bottomAnchor, bottom: contentView.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
        
    }
    
    @objc func exportImages(){
        let alertController = UIAlertController(title: title, message: "exportImages".localize(), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "imageLibrary".localize(), style: .default) { action in
            let (numCopied,numErrors) = Backup.exportImages()
            DispatchQueue.main.async {
                self.showAlert(title: "success".localize(), text: "\(numCopied) imagesExported, \(numErrors) errors")
            }
        })
        alertController.addAction(UIAlertAction(title: "cancel".localize(), style: .cancel))
        self.present(alertController, animated: true)
    }
    
    @objc func exportMedia(){
        let urls = Backup.getMediaUrls()
        let documentPickerController = UIDocumentPickerViewController(forExporting: urls, asCopy: true)
        self.present(documentPickerController, animated: true, completion: {
            //self.navigationController?.popViewController(animated: true)
        })
    }
    
    @objc func createBackup(){
        let fileName = "maps4osm_backup_\(Date().shortFileDate()).zip"
        Indicator.shared.show()
        if let url = Backup.createBackupFile(name: fileName){
            var urls = [URL]()
            urls.append(url)
            let documentPickerController = UIDocumentPickerViewController(
                forExporting: urls)
            self.present(documentPickerController, animated: true, completion: {
                //self.navigationController?.popViewController(animated: true)
            })
        }
        Indicator.shared.hide()
    }
    
}

    

