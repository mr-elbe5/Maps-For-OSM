/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import E5Data
import E5IOSUI
import E5MapData

class TileSourceViewController: PopupScrollViewController{
    
    var tileUrlTemplateField = LabeledTextField()
    
    override func loadView() {
        title = "tileSource".localize()
        super.loadView()
        
        tileUrlTemplateField.setupView(labelText: "urlTemplate".localize(), text: Preferences.shared.urlTemplate, isHorizontal: false)
        contentView.addSubviewWithAnchors(tileUrlTemplateField, top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let elbe5Button = UIButton()
        elbe5Button.setTitle("elbe5TileURL".localize(), for: .normal)
        elbe5Button.setTitleColor(.systemBlue, for: .normal)
        elbe5Button.addAction(UIAction(){ action in
            self.tileUrlTemplateField.text = Preferences.elbe5Url
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(elbe5Button, top: tileUrlTemplateField.bottomAnchor, leading: contentView.leadingAnchor, insets: flatInsets)
        
        let elbe5TopoButton = UIButton()
        elbe5TopoButton.setTitle("elbe5TopoTileURL".localize(), for: .normal)
        elbe5TopoButton.setTitleColor(.systemBlue, for: .normal)
        elbe5TopoButton.addAction(UIAction(){ action in
            self.tileUrlTemplateField.text = Preferences.elbe5TopoUrl
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(elbe5TopoButton, top: elbe5Button.bottomAnchor, leading: contentView.leadingAnchor, insets: flatInsets)
        
        let elbe5InfoLink = UIButton()
        elbe5InfoLink.setTitleColor(.systemBlue, for: .normal)
        elbe5InfoLink.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
        contentView.addSubviewWithAnchors(elbe5InfoLink, top: elbe5TopoButton.bottomAnchor, leading: contentView.leadingAnchor, insets: flatInsets)
        elbe5InfoLink.setTitle("elbe5LegalInfo".localize(), for: .normal)
        elbe5InfoLink.addAction(UIAction(){ action in
            UIApplication.shared.open(URL(string: "https://privacy.elbe5.de")!)
        }, for: .touchDown)
        
        let osmButton = UIButton()
        osmButton.setTitle("osmTileURL".localize(), for: .normal)
        osmButton.setTitleColor(.systemBlue, for: .normal)
        osmButton.addAction(UIAction(){ action in
            self.tileUrlTemplateField.text = Preferences.osmUrl
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(osmButton, top: elbe5InfoLink.bottomAnchor, leading: contentView.leadingAnchor, insets: flatInsets)
        
        let osmInfoLink = UIButton()
        osmInfoLink.setTitleColor(.systemBlue, for: .normal)
        osmInfoLink.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
        contentView.addSubviewWithAnchors(osmInfoLink, top: osmButton.bottomAnchor, leading: contentView.leadingAnchor, insets: flatInsets)
        osmInfoLink.setTitle("osmLegalInfo".localize(), for: .normal)
        osmInfoLink.addAction(UIAction(){ action in
            UIApplication.shared.open(URL(string: "https://operations.osmfoundation.org/policies/tiles/")!)
        }, for: .touchDown)
        
        let saveButton = UIButton()
        saveButton.setTitle("save".localize(), for: .normal)
        saveButton.setTitleColor(.systemBlue, for: .normal)
        saveButton.addAction(UIAction(){ action in
            self.save()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(saveButton, top: osmInfoLink.bottomAnchor, bottom: contentView.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
        
        setupKeyboard()
        
    }
    
    func save(){
        let newTemplate = tileUrlTemplateField.text
        if newTemplate != Preferences.shared.urlTemplate{
            Preferences.shared.urlTemplate = newTemplate
        }
        Preferences.shared.save()
        showDone(title: "ok".localize(), text: "tileSourceSaved".localize())
    }
    
}

    

