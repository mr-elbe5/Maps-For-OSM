/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import E5Data
import E5IOSUI
import E5MapData
import UniformTypeIdentifiers

protocol SettingsViewDelegate: TileSourceDelegate{
    func getRegion() -> TileRegion
    func backupRestored()
}

class SettingsViewController: NavScrollViewController{
    
    var maxMergeDistanceField = LabeledTextField()
    
    var delegate: SettingsViewDelegate? = nil
    
    override func loadView() {
        title = "preferences".localize()
        super.loadView()
        scrollView.backgroundColor = .white
        setupKeyboard()
    }
    
    override func loadScrollableSubviews() {
        
        var header = UILabel(header: "tracks".localize())
        contentView.addSubviewWithAnchors(header, top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let trackSettingsButton = UIButton(name: "trackSettings".localize(), action: UIAction(){ action in
            let controller = TrackSettingsViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        })
        contentView.addSubviewWithAnchors(trackSettingsButton, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        header = UILabel(header: "map".localize())
        contentView.addSubviewWithAnchors(header, top: trackSettingsButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let tileSourceButton = UIButton(name: "tileSource".localize(), action: UIAction(){ action in
            let controller = TileSourceViewController()
            controller.delegate = self.delegate
            self.navigationController?.pushViewController(controller, animated: true)
        })
        contentView.addSubviewWithAnchors(tileSourceButton, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let tilePreloadButton = UIButton(name: "preloadTiles".localize(), action: UIAction(){ action in
            if let region = self.delegate?.getRegion(){
                let controller = TilePreloadViewController()
                controller.mapRegion = region
                self.navigationController?.pushViewController(controller, animated: true)
            }
        })
        contentView.addSubviewWithAnchors(tilePreloadButton, top: tileSourceButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        header = UILabel(header: "backup".localize())
        contentView.addSubviewWithAnchors(header, top: tilePreloadButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let createBackupButton = UIButton()
        createBackupButton.setTitle("createBackup".localize(), for: .normal)
        createBackupButton.setTitleColor(.systemBlue, for: .normal)
        createBackupButton.addAction(UIAction(){ action in
            self.createBackup()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(createBackupButton, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let restoreBackupButton = UIButton()
        restoreBackupButton.setTitle("restoreBackup".localize(), for: .normal)
        restoreBackupButton.setTitleColor(.systemBlue, for: .normal)
        restoreBackupButton.addAction(UIAction(){ action in
            self.restoreBackup()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(restoreBackupButton, top: createBackupButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        header = UILabel(header: "log".localize())
        contentView.addSubviewWithAnchors(header, top: restoreBackupButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let openLogButton = UIButton()
        openLogButton.setTitle("openLog".localize(), for: .normal)
        openLogButton.setTitleColor(.systemBlue, for: .normal)
        openLogButton.addAction(UIAction(){ action in
            let controller = LogViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(openLogButton, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        header = UILabel(header: "locations".localize())
        contentView.addSubviewWithAnchors(header, top: openLogButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        maxMergeDistanceField.setupView(labelText: "maxMergeDistance".localize(), text: String(Preferences.shared.maxLocationMergeDistance), isHorizontal: false)
        contentView.addSubviewWithAnchors(maxMergeDistanceField, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        let label = UILabel(text: "maxMergeDistanceHint".localize())
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        contentView.addSubviewWithAnchors(label, top: maxMergeDistanceField.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        let saveButton = UIButton()
        saveButton.setTitle("save".localize(), for: .normal)
        saveButton.setTitleColor(.systemBlue, for: .normal)
        saveButton.addAction(UIAction(){ action in
            self.saveLocationPreferences()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(saveButton, top: label.bottomAnchor, bottom: contentView.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
        
    }
    
    func saveLocationPreferences(){
        let val = Double(maxMergeDistanceField.text)
        if let val = val{
            if Preferences.shared.maxLocationMergeDistance != val{
                Preferences.shared.maxLocationMergeDistance = val
                AppData.shared.resetCoordinateRegions()
            }
        }
        Preferences.shared.save()
        showDone(title: "ok".localize(), text: "preferencesSaved".localize())
    }
    
    func createBackup(){
        let url = FileManager.backupDirURL.appendingPathComponent("maps4osm_backup_\(Date.localDate.shortFileDate()).zip")
        let spinner = startSpinner()
        DispatchQueue.main.async {
            if Backup.createBackupFile(at: url){
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

extension SettingsViewController : UIDocumentPickerDelegate{
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first{
            if url.pathExtension == "zip"{
                importBackupFile(url: url)
            }
        }
    }
    
    private func importBackupFile(url: URL){
        let spinner = startSpinner()
        DispatchQueue.main.async {
            if Backup.unzipBackupFile(zipFileURL: url){
                if Backup.restoreBackupFile(){
                    self.showDone(title: "success".localize(), text: "restoreDone".localize())
                    self.delegate?.backupRestored()
                }
            }
            self.stopSpinner(spinner)
        }
    }
    
}
    

