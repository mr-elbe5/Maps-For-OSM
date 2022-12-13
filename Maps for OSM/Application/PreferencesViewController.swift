/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import CoreLocation

class PreferencesViewController: PopupScrollViewController{
    
    var tileUrlTemplateField = LabeledTextField()
    
    var minLocationAccuracyField = LabeledTextField()
    var maxLocationMergeDistanceField = LabeledTextField()
    
    var minTrackingDistanceField = LabeledTextField()
    var minTrackingIntervalField = LabeledTextField()
    var pinGroupRadiusField = LabeledTextField()
    
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
        
        minLocationAccuracyField.setupView(labelText: "minLocationAccuracy".localize(), text: String(Int(Preferences.shared.minLocationAccuracy)), isHorizontal: true)
        contentView.addSubviewWithAnchors(minLocationAccuracyField, top: osmInfoLink.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
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
        tileUrlTemplateField.text = Preferences.elbe5Url
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
        showDone(title: "ok".localize(), text: "preferencesSaved".localize())
    }
    
}
    

