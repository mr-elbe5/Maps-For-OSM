/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation
import UniformTypeIdentifiers



protocol TilesSourceDelegate{
    func clearTiles()
    func tileSourceChanged()
}

class TilesViewController: ModalViewController, TilesSourceDelegate {
    
    var contentView = TilesView()
    
    override func loadView() {
        super.loadView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: 350, height: 0))
        contentView.delegate = self
        view.addSubviewFilling(contentView)
        contentView.setupView()
    }
    
    func tileSourceChanged(){
        showSuccess(title: "ok".localize(), text: "tileSourceSaved".localize())
    }
    
    func clearTiles(){
        showDestructiveApprove(title: "confirmDeleteTiles".localize(), text: "deleteTilesHint".localize()){
            TileProvider.shared.deleteAllTiles()
            MainViewController.instance.updateLocations()
        }
    }
    
    class TilesView: NSView{
        
        var tileUrlTemplateField = LabeledTextField()
        
        var delegate: TilesSourceDelegate? = nil
        
        override func setupView() {
            
            tileUrlTemplateField.setupView(labelText: "urlTemplate".localize(), text: String(Preferences.shared.urlTemplate), isHorizontal: false)
            addSubviewWithAnchors(tileUrlTemplateField, top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
            var label = NSTextField(wrappingLabelWithString: "urlTemplateHint".localize()).asSmallLabel()
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
