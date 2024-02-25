/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import CoreLocation

protocol PreferencesDelegate{
    func updateFollowTrack()
}

class PreferencesViewController: PopupScrollViewController{
    
    var tileUrlTemplateField = LabeledTextField()
    var followTrackSwitch = LabeledSwitchView()
    var showTrackpointsSwitch = LabeledSwitchView()
    var trackpointIntervalField = LabeledTextField()
    var maxHorizontalUncertaintyField = LabeledTextField()
    var maxSpeedUncertaintyFactorField = LabeledTextField()
    var minHorizontalTrackpointDistanceField = LabeledTextField()
    var minVerticalTrackpointDistanceField = LabeledTextField()
    var maxTrackpointInLineDeviationField = LabeledTextField()
    
    var delegate: PreferencesDelegate? = nil
    
    override func loadView() {
        title = "preferences".localize()
        super.loadView()
        
        tileUrlTemplateField.setupView(labelText: "urlTemplate".localize(), text: Preferences.shared.urlTemplate, isHorizontal: false)
        contentView.addSubviewWithAnchors(tileUrlTemplateField, top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let elbe5Button = UIButton()
        elbe5Button.setTitle("elbe5TileURL".localize(), for: .normal)
        elbe5Button.setTitleColor(.systemBlue, for: .normal)
        elbe5Button.addTarget(self, action: #selector(elbe5Template), for: .touchDown)
        contentView.addSubviewWithAnchors(elbe5Button, top: tileUrlTemplateField.bottomAnchor, leading: contentView.leadingAnchor, insets: flatInsets)
        
        let elbe5TopoButton = UIButton()
        elbe5TopoButton.setTitle("elbe5TopoTileURL".localize(), for: .normal)
        elbe5TopoButton.setTitleColor(.systemBlue, for: .normal)
        elbe5TopoButton.addTarget(self, action: #selector(elbe5TopoTemplate), for: .touchDown)
        contentView.addSubviewWithAnchors(elbe5TopoButton, top: elbe5Button.bottomAnchor, leading: contentView.leadingAnchor, insets: flatInsets)
        
        let elbe5InfoLink = UIButton()
        elbe5InfoLink.setTitleColor(.systemBlue, for: .normal)
        elbe5InfoLink.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
        contentView.addSubviewWithAnchors(elbe5InfoLink, top: elbe5TopoButton.bottomAnchor, leading: contentView.leadingAnchor, insets: flatInsets)
        elbe5InfoLink.setTitle("elbe5LegalInfo".localize(), for: .normal)
        elbe5InfoLink.addTarget(self, action: #selector(openElbe5Info), for: .touchDown)
        
        let osmButton = UIButton()
        osmButton.setTitle("osmTileURL".localize(), for: .normal)
        osmButton.setTitleColor(.systemBlue, for: .normal)
        osmButton.addTarget(self, action: #selector(osmTemplate), for: .touchDown)
        contentView.addSubviewWithAnchors(osmButton, top: elbe5InfoLink.bottomAnchor, leading: contentView.leadingAnchor, insets: flatInsets)
        
        let osmInfoLink = UIButton()
        osmInfoLink.setTitleColor(.systemBlue, for: .normal)
        osmInfoLink.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
        contentView.addSubviewWithAnchors(osmInfoLink, top: osmButton.bottomAnchor, leading: contentView.leadingAnchor, insets: flatInsets)
        osmInfoLink.setTitle("osmLegalInfo".localize(), for: .normal)
        osmInfoLink.addTarget(self, action: #selector(openOSMInfo), for: .touchDown)
        
        followTrackSwitch.setupView(labelText: "followTrack".localize(), isOn: Preferences.shared.followTrack)
        contentView.addSubviewWithAnchors(followTrackSwitch, top: osmInfoLink.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        showTrackpointsSwitch.setupView(labelText: "showTrackpoints".localize(), isOn: Preferences.shared.showTrackpoints)
        contentView.addSubviewWithAnchors(showTrackpointsSwitch, top: followTrackSwitch.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        trackpointIntervalField.setupView(labelText: "trackpointInterval".localize(), text: String(Preferences.shared.trackpointInterval), isHorizontal: false)
        contentView.addSubviewWithAnchors(trackpointIntervalField, top: showTrackpointsSwitch.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        maxHorizontalUncertaintyField.setupView(labelText: "maxHorizontalUncertainty".localize(), text: String(Preferences.shared.maxHorizontalUncertainty), isHorizontal: false)
        contentView.addSubviewWithAnchors(maxHorizontalUncertaintyField, top: trackpointIntervalField.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        maxSpeedUncertaintyFactorField.setupView(labelText: "maxSpeedUncertaintyFactor".localize(), text: String(Int(Preferences.shared.maxSpeedUncertaintyFactor)), isHorizontal: false)
        contentView.addSubviewWithAnchors(maxSpeedUncertaintyFactorField, top: maxHorizontalUncertaintyField.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        minHorizontalTrackpointDistanceField.setupView(labelText: "minHorizontalTrackpointDistance".localize(), text: String(Preferences.shared.minHorizontalTrackpointDistance), isHorizontal: false)
        contentView.addSubviewWithAnchors(minHorizontalTrackpointDistanceField, top: maxSpeedUncertaintyFactorField.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        minVerticalTrackpointDistanceField.setupView(labelText: "minVerticalTrackpointDistance".localize(), text: String(Preferences.shared.minVerticalTrackpointDistance), isHorizontal: false)
        contentView.addSubviewWithAnchors(minVerticalTrackpointDistanceField, top: minHorizontalTrackpointDistanceField.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        maxTrackpointInLineDeviationField.setupView(labelText: "maxTrackpointInLineDeviation".localize(), text: String(Preferences.shared.maxTrackpointInLineDeviation), isHorizontal: false)
        contentView.addSubviewWithAnchors(maxTrackpointInLineDeviationField, top: minVerticalTrackpointDistanceField.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let saveButton = UIButton()
        saveButton.setTitle("save".localize(), for: .normal)
        saveButton.setTitleColor(.systemBlue, for: .normal)
        saveButton.addTarget(self, action: #selector(save), for: .touchDown)
        contentView.addSubviewWithAnchors(saveButton, top: maxTrackpointInLineDeviationField.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
        
        let saveLogButton = UIButton()
        saveLogButton.setTitle("saveLog".localize(), for: .normal)
        saveLogButton.setTitleColor(.systemBlue, for: .normal)
        saveLogButton.addTarget(self, action: #selector(saveLog), for: .touchDown)
        contentView.addSubviewWithAnchors(saveLogButton, top: saveButton.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
        
        let exportButton = UIButton()
        exportButton.setTitle("exportImages".localize(), for: .normal)
        exportButton.setTitleColor(.systemBlue, for: .normal)
        exportButton.addTarget(self, action: #selector(export), for: .touchDown)
        contentView.addSubviewWithAnchors(exportButton, top: saveLogButton.bottomAnchor, bottom: contentView.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
        
        setupKeyboard()
        
    }
    
    @objc func elbe5Template(){
        tileUrlTemplateField.text = Preferences.elbe5Url
    }
    
    @objc func elbe5TopoTemplate(){
        tileUrlTemplateField.text = Preferences.elbe5TopoUrl
    }
    
    @objc func openElbe5Info() {
        UIApplication.shared.open(URL(string: "https://privacy.elbe5.de")!)
    }
    
    @objc func osmTemplate(){
        tileUrlTemplateField.text = Preferences.osmUrl
    }
    
    @objc func openOSMInfo() {
        UIApplication.shared.open(URL(string: "https://operations.osmfoundation.org/policies/tiles/")!)
    }
    
    @objc func save(){
        let newTemplate = tileUrlTemplateField.text
        if newTemplate != Preferences.shared.urlTemplate{
            Preferences.shared.urlTemplate = newTemplate
        }
        Preferences.shared.followTrack = followTrackSwitch.isOn
        Preferences.shared.showTrackpoints = showTrackpointsSwitch.isOn
        var val = Double(trackpointIntervalField.text)
        if let val = val{
            Preferences.shared.trackpointInterval = val
        }
        val = Double(maxHorizontalUncertaintyField.text)
        if let val = val{
            Preferences.shared.maxHorizontalUncertainty = val
        }
        val = Double(maxSpeedUncertaintyFactorField.text)
        if let val = val{
            Preferences.shared.maxSpeedUncertaintyFactor = val
        }
        val = Double(minHorizontalTrackpointDistanceField.text)
        if let val = val{
            Preferences.shared.minHorizontalTrackpointDistance = val
        }
        val = Double(minVerticalTrackpointDistanceField.text)
        if let val = val{
            Preferences.shared.minVerticalTrackpointDistance = val
        }
        val = Double(maxTrackpointInLineDeviationField.text)
        if let val = val{
            Preferences.shared.maxTrackpointInLineDeviation = val
        }
        delegate?.updateFollowTrack()
        Preferences.shared.save()
        showDone(title: "ok".localize(), text: "preferencesSaved".localize())
    }
    
    @objc func saveLog(){
        Log.save()
    }
    
    @objc func export(){
        let alertController = UIAlertController(title: title, message: "exportImages".localize(), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "imageLibrary".localize(), style: .default) { action in
            let (numCopied,numErrors) = Backup.export()
            DispatchQueue.main.async {
                self.showAlert(title: "success".localize(), text: "\(numCopied) imagesExported, \(numErrors) errors")
            }
        })
        alertController.addAction(UIAlertAction(title: "cancel".localize(), style: .cancel))
        self.present(alertController, animated: true)
    }
    
}

    

