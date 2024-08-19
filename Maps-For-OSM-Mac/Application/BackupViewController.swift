/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation
import UniformTypeIdentifiers
import E5Data



protocol BackupDelegate{
    func createBackup()
    func restoreBackup()
}

class BackupViewController: NSViewController, BackupDelegate {
    
    var contentView = BackupView()
    
    override func loadView() {
        super.loadView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: 350, height: 0))
        contentView.delegate = self
        view.addSubviewFilling(contentView)
        contentView.setupView()
    }
    
    func createBackup(){
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = UTType.types(tag: "zip", tagClass: UTTagClass.filenameExtension, conformingTo: nil)
        savePanel.nameFieldStringValue = "maps4osm_backup_\(Date.localDate.shortFileDate()).zip"
        savePanel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
        if savePanel.runModal() == .OK{
            let spinner = startSpinner()
            DispatchQueue.main.async {
                if let targetUrl = savePanel.url, Backup.createBackupFile(at: targetUrl){
                    self.showSuccess(title: "success".localize(), text: "backupSaved".localize())
                }
                self.stopSpinner(spinner)
            }
        }
    }
    
    func restoreBackup(){
        showDestructiveApprove(title: "restoreBackup".localize(), text: "restoreBackupHint".localize()){
            let openPanel = NSOpenPanel()
            openPanel.allowedContentTypes = UTType.types(tag: "zip", tagClass: UTTagClass.filenameExtension, conformingTo: nil)
            openPanel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
            openPanel.canChooseFiles = true
            openPanel.canChooseDirectories = false
            openPanel.allowsMultipleSelection = false
            if openPanel.runModal() == .OK{
                if let url = openPanel.url{
                    DispatchQueue.main.async {
                        let spinner = self.startSpinner()
                        if Backup.unzipBackupFile(zipFileURL: url){
                            if Backup.restoreBackupFile(){
                                self.showSuccess(title: "success".localize(), text: "restoreDone".localize())
                                MainViewController.instance.updateLocations()
                            }
                        }
                        self.stopSpinner(spinner)
                    }
                }
            }
        }
    }
    
    class BackupView: NSView{
        
        var delegate: BackupDelegate? = nil
        
        override func setupView() {
            
            let createBackupButton = NSButton().asTextButton("createBackup".localize(), target: self, action: #selector(createBackup))
            addSubviewWithAnchors(createBackupButton, top: topAnchor, insets: doubleInsets).centerX(centerXAnchor)
            
            let restoreBackupButton = NSButton().asTextButton("restoreBackup".localize(), target: self, action: #selector(restoreBackup))
            addSubviewWithAnchors(restoreBackupButton, top: createBackupButton.bottomAnchor, insets: doubleInsets).centerX(centerXAnchor)
                .bottom(bottomAnchor, inset: defaultInset)
        }
        
        @objc func createBackup(){
            delegate?.createBackup()
        }
        
        @objc func restoreBackup(){
            delegate?.restoreBackup()
        }
        
    }
    
}
