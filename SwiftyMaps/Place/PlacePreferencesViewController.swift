/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import CoreLocation

class PlacePreferencesViewController: PopupScrollViewController{
    
    var minLocationAccuracyField = LabeledTextField()
    var maxLocationMergeDistanceField = LabeledTextField()
    var pinGroupRadiusField = LabeledTextField()
    
    override func loadView() {
        title = "placePreferences".localize()
        super.loadView()
        
        minLocationAccuracyField.setupView(labelText: "minLocationAccuracy".localize(), text: String(Int(PlacePreferences.instance.minLocationAcciuracy)), isHorizontal: true)
        contentView.addSubview(minLocationAccuracyField)
        minLocationAccuracyField.setAnchors(top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        maxLocationMergeDistanceField.setupView(labelText: "maxLocationMergeDistance".localize(), text: String(Int(PlacePreferences.instance.maxLocationMergeDistance)), isHorizontal: true)
        contentView.addSubview(maxLocationMergeDistanceField)
        maxLocationMergeDistanceField.setAnchors(top: minLocationAccuracyField.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        
        let saveButton = UIButton()
        saveButton.setTitle("save".localize(), for: .normal)
        saveButton.setTitleColor(.systemBlue, for: .normal)
        saveButton.addTarget(self, action: #selector(save), for: .touchDown)
        contentView.addSubview(saveButton)
        saveButton.setAnchors(top: maxLocationMergeDistanceField.bottomAnchor, bottom: contentView.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
    
    }
    
    @objc func save(){
        if let val = Int(minLocationAccuracyField.text){
            PlacePreferences.instance.minLocationAcciuracy = CLLocationDistance(val)
        }
        if let val = Int(maxLocationMergeDistanceField.text){
            PlacePreferences.instance.maxLocationMergeDistance = CLLocationDistance(val)
        }
        PlacePreferences.instance.save()
        showDone(title: "ok".localize(), text: "preferencesSaved".localize())
    }
    
}
    

