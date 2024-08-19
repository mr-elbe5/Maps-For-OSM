/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation



class PreferencesViewController: NSViewController {
    
    var contentView = PreferencesView()
    
    override func loadView() {
        super.loadView()
        view.addSubviewFilling(contentView)
        contentView.setupView()
    }
    
    class PreferencesView: NSView{
        
        var maxMergeDistanceField = LabeledTextField()
        
        override func setupView() {
            
            let header = NSTextField(labelWithString: "locations".localize())
            addSubviewWithAnchors(header, top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
            
            maxMergeDistanceField.setupView(labelText: "maxMergeDistance".localize(), text: String(Preferences.shared.maxLocationMergeDistance), isHorizontal: false)
            addSubviewWithAnchors(maxMergeDistanceField, top: header.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
            let label = NSTextField(wrappingLabelWithString: "maxMergeDistanceHint".localize()).asSmallLabel()
            addSubviewWithAnchors(label, top: maxMergeDistanceField.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
            
            let saveButton = NSButton().asTextButton("save".localize(), target: self, action: #selector(saveLocationPreferences))
            addSubviewWithAnchors(saveButton, top: label.bottomAnchor, insets: doubleInsets).centerX(centerXAnchor)
                .bottom(bottomAnchor, inset: defaultInset)
        }
        
        @objc func saveLocationPreferences(){
            let val = Double(maxMergeDistanceField.text)
            if let val = val{
                if Preferences.shared.maxLocationMergeDistance != val{
                    Preferences.shared.maxLocationMergeDistance = val
                    AppData.shared.resetCoordinateRegions()
                }
            }
            Preferences.shared.save()
            MainViewController.instance.showSuccess(title: "success".localize(), text: "preferencesSaved".localize())
            NSApp.stopModal(withCode: .OK)
            window?.close()
        }
        
    }
    
}
