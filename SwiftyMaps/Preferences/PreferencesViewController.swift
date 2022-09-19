/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import CoreLocation

class PreferencesViewController: PopupScrollViewController{
    
    var urlTemplateField = LabeledTextField()
    var minLocationAccuracyField = LabeledTextField()
    var maxLocationMergeDistanceField = LabeledTextField()
    var minTrackingDistanceField = LabeledTextField()
    var minTrackingIntervalField = LabeledTextField()
    var pinGroupRadiusField = LabeledTextField()
    var startWithLastPositionSwitch = LabeledSwitchView()
    
    var currentZoom : Int = World.minZoom
    var currentCenterCoordinate : CLLocationCoordinate2D? = nil
    
    override func loadView() {
        title = "mapPreferences".localize()
        super.loadView()
        
        urlTemplateField.setupView(labelText: "urlTemplate".localize(), text: Preferences.instance.urlTemplate, isHorizontal: false)
        contentView.addSubview(urlTemplateField)
        urlTemplateField.setAnchors(top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let elbe5Button = UIButton()
        elbe5Button.setTitle("elbe5TileURL".localize(), for: .normal)
        elbe5Button.setTitleColor(.systemBlue, for: .normal)
        elbe5Button.addTarget(self, action: #selector(elbe5Template), for: .touchDown)
        contentView.addSubview(elbe5Button)
        elbe5Button.setAnchors(top: urlTemplateField.bottomAnchor, leading: contentView.leadingAnchor, insets: flatInsets)
        
        let elbe5InfoLink = UIButton()
        elbe5InfoLink.setTitleColor(.systemBlue, for: .normal)
        elbe5InfoLink.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
        contentView.addSubview(elbe5InfoLink)
        elbe5InfoLink.setAnchors(top: elbe5Button.bottomAnchor, leading: contentView.leadingAnchor, insets: flatInsets)
        elbe5InfoLink.setTitle("elbe5LegalInfo".localize(), for: .normal)
        elbe5InfoLink.addTarget(self, action: #selector(openElbe5Info), for: .touchDown)
        
        let osmButton = UIButton()
        osmButton.setTitle("osmTileURL".localize(), for: .normal)
        osmButton.setTitleColor(.systemBlue, for: .normal)
        osmButton.addTarget(self, action: #selector(osmTemplate), for: .touchDown)
        contentView.addSubview(osmButton)
        osmButton.setAnchors(top: elbe5InfoLink.bottomAnchor, leading: contentView.leadingAnchor, insets: flatInsets)
        
        let osmInfoLink = UIButton()
        osmInfoLink.setTitleColor(.systemBlue, for: .normal)
        osmInfoLink.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
        contentView.addSubview(osmInfoLink)
        osmInfoLink.setAnchors(top: osmButton.bottomAnchor, leading: contentView.leadingAnchor, insets: flatInsets)
        osmInfoLink.setTitle("osmLegalInfo".localize(), for: .normal)
        osmInfoLink.addTarget(self, action: #selector(openOSMInfo), for: .touchDown)
        
        maxLocationMergeDistanceField.setupView(labelText: "maxLocationMergeDistance".localize(), text: String(Int(Preferences.instance.maxLocationMergeDistance)), isHorizontal: true)
        contentView.addSubview(maxLocationMergeDistanceField)
        maxLocationMergeDistanceField.setAnchors(top: osmInfoLink.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        minTrackingDistanceField.setupView(labelText: "minTrackingDistance".localize(), text: String(Int(Preferences.instance.minTrackingDistance)), isHorizontal: true)
        contentView.addSubview(minTrackingDistanceField)
        minTrackingDistanceField.setAnchors(top: maxLocationMergeDistanceField.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        minTrackingIntervalField.setupView(labelText: "minTrackingInterval".localize(), text: String(Int(Preferences.instance.minTrackingInterval)), isHorizontal: true)
        contentView.addSubview(minTrackingIntervalField)
        minTrackingIntervalField.setAnchors(top: minTrackingDistanceField.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        startWithLastPositionSwitch.setupView(labelText: "startWithLastPosition".localize(), isOn: Preferences.instance.startWithLastPosition)
        contentView.addSubview(startWithLastPositionSwitch)
        startWithLastPositionSwitch.setAnchors(top: minTrackingIntervalField.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let saveButton = UIButton()
        saveButton.setTitle("save".localize(), for: .normal)
        saveButton.setTitleColor(.systemBlue, for: .normal)
        saveButton.addTarget(self, action: #selector(save), for: .touchDown)
        contentView.addSubview(saveButton)
        saveButton.setAnchors(top: startWithLastPositionSwitch.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
    
        let backupButton = UIButton()
        backupButton.setTitle("backup".localize(), for: .normal)
        backupButton.setTitleColor(.systemBlue, for: .normal)
        backupButton.addTarget(self, action: #selector(backup), for: .touchDown)
        contentView.addSubview(backupButton)
        backupButton.setAnchors(top: saveButton.bottomAnchor, bottom: contentView.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
    }
    
    @objc func elbe5Template(){
        urlTemplateField.text = Preferences.elbe5Url
    }
    
    @objc func openElbe5Info() {
        UIApplication.shared.open(URL(string: "https://privacy.elbe5.de")!)
    }
    
    @objc func osmTemplate(){
        urlTemplateField.text = Preferences.osmUrl
    }
    
    @objc func openOSMInfo() {
        UIApplication.shared.open(URL(string: "https://operations.osmfoundation.org/policies/tiles/")!)
    }
    
    @objc func save(){
        let newTemplate = urlTemplateField.text
        if newTemplate != Preferences.instance.urlTemplate{
            Preferences.instance.urlTemplate = newTemplate
            _ = MapTiles.clear()
        }
        if let val = Int(maxLocationMergeDistanceField.text){
            Preferences.instance.maxLocationMergeDistance = CLLocationDistance(val)
        }
        if let val = Int(minTrackingDistanceField.text){
            Preferences.instance.minTrackingDistance = CLLocationDistance(val)
        }
        if let val = Int(minTrackingIntervalField.text){
            Preferences.instance.minTrackingInterval = CLLocationDistance(val)
        }
        Preferences.instance.startWithLastPosition = startWithLastPositionSwitch.isOn
        Preferences.instance.save()
        showDone(title: "ok".localize(), text: "preferencesSaved".localize())
    }
    
    @objc func backup(){
        let locationsURL = FileController.backupDirURL.appendingPathComponent("places.json")
        let tracksURL = FileController.backupDirURL.appendingPathComponent("tracks.json")
        FileController.deleteFile(url: locationsURL)
        FileController.deleteFile(url: tracksURL)
        for location in Places.list{
            if location.name.isEmpty{
                location.name = location.description
            }
        }
        let json = Places.list.toJSON().replacingOccurrences(of: "\"photos\" :", with: "\"images\" :")
        FileController.saveFile(text: json, url: locationsURL)
        var tracks = TrackList()
        for location in Places.list{
            for track in location.getTracks(){
                tracks.append(track)
            }
        }
        FileController.saveFile(text: tracks.toJSON(), url: tracksURL)
        
        FileController.deleteAllFiles(dirURL: FileController.backupImagesDirURL)
        FileController.deleteAllFiles(dirURL: FileController.backupTilesDirURL)
        var targetURL: URL
        var sourceURL: URL
        let files = FileController.listAllURLs(dirURL: FileController.imageDirURL)
        for file in files {
            if !FileController.isDirectory(url: file){
                targetURL = FileController.backupImagesDirURL.appendingPathComponent(file.lastPathComponent)
                FileController.copyFile(fromURL: file.absoluteURL, toURL: targetURL)
            }
        }
        if let paths = try? FileManager.default.subpathsOfDirectory(atPath: FileController.tilesDirURL.path){
            for path in paths {
                if path.hasSuffix(".png"){
                    sourceURL = FileController.tilesDirURL.appendingPathComponent(path)
                    targetURL = FileController.backupTilesDirURL.appendingPathComponent(path)
                    if !FileController.assertDirectoryFor(url: targetURL){
                        continue
                    }
                    FileController.copyFile(fromURL: sourceURL, toURL: targetURL)
                }
            }
        }
        showDone(title: "ok".localize(), text: "backupSaved".localize())
    }
    
    @objc func deleteAllLogs(){
        showDestructiveApprove(title: "confirmDeleteLogs".localize(), text: "deleteLogsHint".localize()){
            FileController.deleteAllFiles(dirURL: FileController.logDirURL)
            self.showDone(title: "ok".localize(), text: "logsDeleted".localize())
        }
    }
    
}
    

