/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import CoreLocation

class TrackPreferencesViewController: PopupScrollViewController{
    
    var minLocationAccuracyField = LabeledTextField()
    var maxLocationMergeDistanceField = LabeledTextField()
    var minTrackingDistanceField = LabeledTextField()
    var minTrackingIntervalField = LabeledTextField()
    var pinGroupRadiusField = LabeledTextField()
    
    override func loadView() {
        title = "tilePreferences".localize()
        super.loadView()
        
        minTrackingDistanceField.setupView(labelText: "minTrackingDistance".localize(), text: String(Int(TrackPreferences.instance.minTrackingDistance)), isHorizontal: true)
        contentView.addSubview(minTrackingDistanceField)
        minTrackingDistanceField.setAnchors(top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        minTrackingIntervalField.setupView(labelText: "minTrackingInterval".localize(), text: String(Int(TrackPreferences.instance.minTrackingInterval)), isHorizontal: true)
        contentView.addSubview(minTrackingIntervalField)
        minTrackingIntervalField.setAnchors(top: minTrackingDistanceField.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let saveButton = UIButton()
        saveButton.setTitle("save".localize(), for: .normal)
        saveButton.setTitleColor(.systemBlue, for: .normal)
        saveButton.addTarget(self, action: #selector(save), for: .touchDown)
        contentView.addSubview(saveButton)
        saveButton.setAnchors(top: minTrackingIntervalField.bottomAnchor, bottom: contentView.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
    
    }
    
    @objc func save(){
        if let val = Int(minTrackingDistanceField.text){
            TrackPreferences.instance.minTrackingDistance = CLLocationDistance(val)
        }
        if let val = Int(minTrackingIntervalField.text){
            TrackPreferences.instance.minTrackingInterval = CLLocationDistance(val)
        }
        TrackPreferences.instance.save()
        showDone(title: "ok".localize(), text: "preferencesSaved".localize())
    }
    
}
    

