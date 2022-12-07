/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import CoreLocation

class LocationPreferencesViewController: PopupScrollViewController{
    
    var minLocationAccuracyField = LabeledTextField()
    var maxLocationMergeDistanceField = LabeledTextField()
    var pinGroupRadiusField = LabeledTextField()
    
    override func loadView() {
        title = "locationPreferences".localize()
        super.loadView()
        
        minLocationAccuracyField.setupView(labelText: "minLocationAccuracy".localize(), text: String(Int(LocationPreferences.instance.minLocationAcciuracy)), isHorizontal: true)
        contentView.addSubviewWithAnchors(minLocationAccuracyField, top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        maxLocationMergeDistanceField.setupView(labelText: "maxLocationMergeDistance".localize(), text: String(Int(LocationPreferences.instance.maxLocationMergeDistance)), isHorizontal: true)
        contentView.addSubviewWithAnchors(maxLocationMergeDistanceField, top: minLocationAccuracyField.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let saveButton = UIButton()
        saveButton.setTitle("save".localize(), for: .normal)
        saveButton.setTitleColor(.systemBlue, for: .normal)
        saveButton.addTarget(self, action: #selector(save), for: .touchDown)
        contentView.addSubviewWithAnchors(saveButton, top: maxLocationMergeDistanceField.bottomAnchor, bottom: contentView.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
    
    }
    
    @objc func save(){
        if let val = Int(minLocationAccuracyField.text){
            LocationPreferences.instance.minLocationAcciuracy = CLLocationDistance(val)
        }
        if let val = Int(maxLocationMergeDistanceField.text){
            LocationPreferences.instance.maxLocationMergeDistance = CLLocationDistance(val)
        }
        LocationPreferences.instance.save()
        showDone(title: "ok".localize(), text: "preferencesSaved".localize())
    }
    
}
    

