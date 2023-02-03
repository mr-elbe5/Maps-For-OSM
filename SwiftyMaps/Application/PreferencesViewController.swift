/*
 SwiftyMaps
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
        
        let saveButton = UIButton()
        saveButton.setTitle("save".localize(), for: .normal)
        saveButton.setTitleColor(.systemBlue, for: .normal)
        saveButton.addTarget(self, action: #selector(save), for: .touchDown)
        contentView.addSubviewWithAnchors(saveButton, top: followTrackSwitch.bottomAnchor, bottom: contentView.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
        
        
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
        delegate?.updateFollowTrack()
        Preferences.shared.save()
        showDone(title: "ok".localize(), text: "preferencesSaved".localize())
    }
    
}
    

