/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation

protocol PreferencesDelegate{
    func clearTiles()
    func tileSourceChanged()
}

class PreferencesViewController: ModalViewController, PreferencesDelegate {
    
    var contentView = PreferencesView()
    
    override func loadView() {
        super.loadView()
        view.addSubviewFilling(contentView)
        contentView.setupView()
        contentView.delegate = self
    }
    
    func tileSourceChanged(){
        showSuccess(title: "ok".localize(), text: "preferencesSaved".localize())
        deleteTiles()
    }
    
    func clearTiles(){
        showDestructiveApprove(title: "confirmDeleteTiles".localize(), text: "deleteTilesHint".localize()){
            self.deleteTiles()
        }
    }
    
    private func deleteTiles(){
        TileProvider.shared.deleteAllTiles()
        MainViewController.instance.updateMap()
    }
    
    class PreferencesView: NSView{
        
        var maxMergeDistanceField = LabeledTextField()
        
        var tileUrlTemplateField = LabeledTextField()
        
        var delegate: PreferencesDelegate? = nil
        
        override func setupView() {
            
            let header = NSTextField(labelWithString: "locations".localize())
            addSubviewWithAnchors(header, top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
            
            maxMergeDistanceField.setupView(labelText: "maxMergeDistance".localize(), text: String(Preferences.shared.maxLocationMergeDistance), isHorizontal: false)
            addSubviewWithAnchors(maxMergeDistanceField, top: header.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
            var label = NSTextField(wrappingLabelWithString: "maxMergeDistanceHint".localize()).asSmallLabel()
            addSubviewWithAnchors(label, top: maxMergeDistanceField.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
            
            tileUrlTemplateField.setupView(labelText: "urlTemplate".localize(), text: String(Preferences.shared.urlTemplate), isHorizontal: false)
            addSubviewWithAnchors(tileUrlTemplateField, top: label.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
            label = NSTextField(wrappingLabelWithString: "urlTemplateHint".localize()).asSmallLabel()
            addSubviewWithAnchors(label, top: tileUrlTemplateField.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
            
            let elbe5Button = NSButton().asTextButton("elbe5TileURL".localize(), target: self, action: #selector(setElbe5Template))
            addSubviewWithAnchors(elbe5Button, top: label.bottomAnchor, insets: doubleInsets).centerX(centerXAnchor)
            label = NSTextField(wrappingLabelWithString: "elbe5TileURLHint".localize()).asSmallLabel()
            addSubviewWithAnchors(label, top: elbe5Button.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
            
            let elbe5TopoButton = NSButton().asTextButton("elbe5TopoTileURL".localize(), target: self, action: #selector(setElbe5TopoTemplate))
            addSubviewWithAnchors(elbe5TopoButton, top: label.bottomAnchor, insets: doubleInsets).centerX(centerXAnchor)
            label = NSTextField(wrappingLabelWithString: "elbe5TopoTileURLHint".localize()).asSmallLabel()
            addSubviewWithAnchors(label, top: elbe5TopoButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
            
            let elbe5LegalInfoButton = NSButton().asTextButton("elbe5LegalInfo".localize(), target: self, action: #selector(showElbe5LegalInfo))
            addSubviewWithAnchors(elbe5LegalInfoButton, top: label.bottomAnchor, insets: doubleInsets).centerX(centerXAnchor)
            
            let osmButton = NSButton().asTextButton("osmTileURL".localize(), target: self, action: #selector(setOsmTemplate))
            addSubviewWithAnchors(osmButton, top: elbe5LegalInfoButton.bottomAnchor, insets: doubleInsets).centerX(centerXAnchor)
            label = NSTextField(wrappingLabelWithString: "osmTileURLHint".localize()).asSmallLabel()
            addSubviewWithAnchors(label, top: osmButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
            
            let osmLegalInfoButton = NSButton().asTextButton("osmLegalInfo".localize(), target: self, action: #selector(showOsmLegalInfo))
            addSubviewWithAnchors(osmLegalInfoButton, top: label.bottomAnchor, insets: doubleInsets).centerX(centerXAnchor)
            
            let saveButton = NSButton().asTextButton("save".localize(), target: self, action: #selector(save))
            addSubviewWithAnchors(saveButton, top: osmLegalInfoButton.bottomAnchor, insets: doubleInsets).centerX(centerXAnchor)
            
            let clearTilesButton = NSButton().asTextButton("deleteAllTiles".localize(), target: self, action: #selector(clearTiles))
            addSubviewWithAnchors(clearTilesButton, top: saveButton.bottomAnchor, insets: doubleInsets).centerX(centerXAnchor)
                .bottom(bottomAnchor, inset: defaultInset)
        }
        
        @objc func setElbe5Template(){
            tileUrlTemplateField.text = Preferences.elbe5Url
        }
        
        @objc func setElbe5TopoTemplate(){
            tileUrlTemplateField.text = Preferences.elbe5TopoUrl
        }
        
        @objc func showElbe5LegalInfo(){
            NSWorkspace.shared.open(URL(string: "https://privacy.elbe5.de")!)
        }
        
        @objc func setOsmTemplate(){
            tileUrlTemplateField.text = Preferences.osmUrl
        }
        
        @objc func showOsmLegalInfo(){
            NSWorkspace.shared.open(URL(string: "https://operations.osmfoundation.org/policies/tiles/")!)
        }
        
        @objc func save(){
            let val = Double(maxMergeDistanceField.text)
            if let val = val{
                if Preferences.shared.maxLocationMergeDistance != val{
                    Preferences.shared.maxLocationMergeDistance = val
                    AppData.shared.resetCoordinateRegions()
                }
            }
            
            let newTemplate = tileUrlTemplateField.text
            if newTemplate != Preferences.shared.urlTemplate{
                Preferences.shared.urlTemplate = newTemplate
            }
            Preferences.shared.save()
            delegate?.tileSourceChanged()
        }
        
        @objc func clearTiles(){
            delegate?.clearTiles()
        }
        
    }
    
}
