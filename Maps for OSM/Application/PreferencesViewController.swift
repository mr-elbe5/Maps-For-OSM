/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import CoreLocation

class PreferencesViewController: PopupScrollViewController{
    
    var cartoUrlTemplateField = LabeledTextField()
    var topoUrlTemplateField = LabeledTextField()
    
    var minLocationAccuracyField = LabeledTextField()
    var maxLocationMergeDistanceField = LabeledTextField()
    
    var minTrackingDistanceField = LabeledTextField()
    var minTrackingIntervalField = LabeledTextField()
    var pinGroupRadiusField = LabeledTextField()
    
    override func loadView() {
        title = "preferences".localize()
        super.loadView()
        
        cartoUrlTemplateField.setupView(labelText: "cartoTemplate".localize(), text: Preferences.shared.cartoUrlTemplate, isHorizontal: false)
        contentView.addSubviewWithAnchors(cartoUrlTemplateField, top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let elbe5Button = UIButton()
        elbe5Button.setTitle("elbe5TileURL".localize(), for: .normal)
        elbe5Button.setTitleColor(.systemBlue, for: .normal)
        elbe5Button.addTarget(self, action: #selector(elbe5Template), for: .touchDown)
        contentView.addSubviewWithAnchors(elbe5Button, top: cartoUrlTemplateField.bottomAnchor, leading: contentView.leadingAnchor, insets: flatInsets)
        
        let elbe5InfoLink = UIButton()
        elbe5InfoLink.setTitleColor(.systemBlue, for: .normal)
        elbe5InfoLink.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
        contentView.addSubviewWithAnchors(elbe5InfoLink, top: elbe5Button.bottomAnchor, leading: contentView.leadingAnchor, insets: flatInsets)
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
        
        topoUrlTemplateField.setupView(labelText: "topoTemplate".localize(), text: Preferences.shared.cartoUrlTemplate, isHorizontal: false)
        contentView.addSubviewWithAnchors(topoUrlTemplateField, top: osmInfoLink.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let elbe5TopoButton = UIButton()
        elbe5TopoButton.setTitle("elbe5TopoURL".localize(), for: .normal)
        elbe5TopoButton.setTitleColor(.systemBlue, for: .normal)
        elbe5TopoButton.addTarget(self, action: #selector(elbe5TopoTemplate), for: .touchDown)
        contentView.addSubviewWithAnchors(elbe5TopoButton, top: topoUrlTemplateField.bottomAnchor, leading: contentView.leadingAnchor, insets: flatInsets)
        
        let elbe5TopoInfoLink = UIButton()
        elbe5TopoInfoLink.setTitleColor(.systemBlue, for: .normal)
        elbe5TopoInfoLink.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
        contentView.addSubviewWithAnchors(elbe5TopoInfoLink, top: elbe5TopoButton.bottomAnchor, leading: contentView.leadingAnchor, insets: flatInsets)
        elbe5TopoInfoLink.setTitle("elbe5TopoLegalInfo".localize(), for: .normal)
        elbe5TopoInfoLink.addTarget(self, action: #selector(openElbe5Info), for: .touchDown)
        
        let openTopoButton = UIButton()
        openTopoButton.setTitle("openTopoTileURL".localize(), for: .normal)
        openTopoButton.setTitleColor(.systemBlue, for: .normal)
        openTopoButton.addTarget(self, action: #selector(openTopoTemplate), for: .touchDown)
        contentView.addSubviewWithAnchors(openTopoButton, top: elbe5TopoInfoLink.bottomAnchor, leading: contentView.leadingAnchor, insets: flatInsets)
        
        let openTopoInfoLink = UIButton()
        openTopoInfoLink.setTitleColor(.systemBlue, for: .normal)
        openTopoInfoLink.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
        contentView.addSubviewWithAnchors(openTopoInfoLink, top: openTopoButton.bottomAnchor, leading: contentView.leadingAnchor, insets: flatInsets)
        openTopoInfoLink.setTitle("openTopoLegalInfo".localize(), for: .normal)
        openTopoInfoLink.addTarget(self, action: #selector(openOpenTopoInfo), for: .touchDown)
        
        minLocationAccuracyField.setupView(labelText: "minLocationAccuracy".localize(), text: String(Int(Preferences.shared.minLocationAccuracy)), isHorizontal: true)
        contentView.addSubviewWithAnchors(minLocationAccuracyField, top: openTopoInfoLink.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        maxLocationMergeDistanceField.setupView(labelText: "maxLocationMergeDistance".localize(), text: String(Int(Preferences.shared.maxLocationMergeDistance)), isHorizontal: true)
        contentView.addSubviewWithAnchors(maxLocationMergeDistanceField, top: minLocationAccuracyField.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        minTrackingDistanceField.setupView(labelText: "minTrackingDistance".localize(), text: String(Int(Preferences.shared.minTrackingDistance)), isHorizontal: true)
        contentView.addSubviewWithAnchors(minTrackingDistanceField, top: maxLocationMergeDistanceField.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        minTrackingIntervalField.setupView(labelText: "minTrackingInterval".localize(), text: String(Int(Preferences.shared.minTrackingInterval)), isHorizontal: true)
        contentView.addSubviewWithAnchors(minTrackingIntervalField, top: minTrackingDistanceField.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let saveButton = UIButton()
        saveButton.setTitle("save".localize(), for: .normal)
        saveButton.setTitleColor(.systemBlue, for: .normal)
        saveButton.addTarget(self, action: #selector(save), for: .touchDown)
        contentView.addSubviewWithAnchors(saveButton, top: minTrackingIntervalField.bottomAnchor, bottom: contentView.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
        
        
    }
    
    @objc func elbe5Template(){
        cartoUrlTemplateField.text = Preferences.elbe5Url
    }
    
    @objc func openElbe5Info() {
        UIApplication.shared.open(URL(string: "https://privacy.elbe5.de")!)
    }
    
    @objc func osmTemplate(){
        cartoUrlTemplateField.text = Preferences.osmUrl
    }
    
    @objc func openOSMInfo() {
        UIApplication.shared.open(URL(string: "https://operations.osmfoundation.org/policies/tiles/")!)
    }
    
    @objc func elbe5TopoTemplate(){
        topoUrlTemplateField.text = Preferences.elbe5TopoUrl
    }
    
    @objc func openElbe5TopoInfo() {
        UIApplication.shared.open(URL(string: "https://privacy.elbe5.de")!)
    }
    
    @objc func openTopoTemplate(){
        topoUrlTemplateField.text = Preferences.openTopoUrl
    }
    
    @objc func openOpenTopoInfo() {
        UIApplication.shared.open(URL(string: "https://opentopomap.org/about")!)
    }
    
    @objc func save(){
        let newTemplate = cartoUrlTemplateField.text
        if newTemplate != Preferences.shared.cartoUrlTemplate{
            Preferences.shared.cartoUrlTemplate = newTemplate
            TileProvider.shared.deleteAllTiles()
        }
        if let val = Int(minLocationAccuracyField.text){
            Preferences.shared.minLocationAccuracy = CLLocationDistance(val)
        }
        if let val = Int(maxLocationMergeDistanceField.text){
            Preferences.shared.maxLocationMergeDistance = CLLocationDistance(val)
        }
        if let val = Int(minTrackingDistanceField.text){
            Preferences.shared.minTrackingDistance = CLLocationDistance(val)
        }
        if let val = Int(minTrackingIntervalField.text){
            Preferences.shared.minTrackingInterval = CLLocationDistance(val)
        }
        Preferences.shared.save()
        showDone(title: "ok".localize(), text: "mapPreferencesSaved".localize())
    }
    
}
    

