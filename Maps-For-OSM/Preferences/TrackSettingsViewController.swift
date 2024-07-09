/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import E5Data
import E5IOSUI
import E5MapData

class TrackSettingsViewController: NavScrollViewController{
    
    var followTrackSwitch = LabeledSwitchView()
    var trackpointIntervalField = LabeledTextField()
    var maxHorizontalUncertaintyField = LabeledTextField()
    var minHorizontalTrackpointDistanceField = LabeledTextField()
    var minVerticalTrackpointDistanceField = LabeledTextField()
    var maxTrackpointInLineDeviationField = LabeledTextField()
    
    override func loadView() {
        title = "trackSettings".localize()
        super.loadView()
        setupKeyboard()
    }
    
    override func loadScrollableSubviews() {
        let label = UILabel(text: "trackSettingsHint".localize())
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        contentView.addSubviewWithAnchors(label, top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        followTrackSwitch.setupView(labelText: "followTrack".localize(), isOn: Preferences.shared.followTrack)
        contentView.addSubviewWithAnchors(followTrackSwitch, top: label.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        trackpointIntervalField.setupView(labelText: "trackpointInterval".localize(), text: String(Preferences.shared.trackpointInterval), isHorizontal: false)
        contentView.addSubviewWithAnchors(trackpointIntervalField, top: followTrackSwitch.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        maxHorizontalUncertaintyField.setupView(labelText: "maxHorizontalUncertainty".localize(), text: String(Preferences.shared.maxHorizontalUncertainty), isHorizontal: false)
        contentView.addSubviewWithAnchors(maxHorizontalUncertaintyField, top: trackpointIntervalField.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        minHorizontalTrackpointDistanceField.setupView(labelText: "minHorizontalTrackpointDistance".localize(), text: String(Preferences.shared.minHorizontalTrackpointDistance), isHorizontal: false)
        contentView.addSubviewWithAnchors(minHorizontalTrackpointDistanceField, top: maxHorizontalUncertaintyField.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        minVerticalTrackpointDistanceField.setupView(labelText: "minVerticalTrackpointDistance".localize(), text: String(Preferences.shared.minVerticalTrackpointDistance), isHorizontal: false)
        contentView.addSubviewWithAnchors(minVerticalTrackpointDistanceField, top: minHorizontalTrackpointDistanceField.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        maxTrackpointInLineDeviationField.setupView(labelText: "maxTrackpointInLineDeviation".localize(), text: String(Preferences.shared.maxTrackpointInLineDeviation), isHorizontal: false)
        contentView.addSubviewWithAnchors(maxTrackpointInLineDeviationField, top: minVerticalTrackpointDistanceField.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        let saveButton = UIButton()
        saveButton.setTitle("save".localize(), for: .normal)
        saveButton.setTitleColor(.systemBlue, for: .normal)
        saveButton.addAction(UIAction(){ action in
            self.save()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(saveButton, top: maxTrackpointInLineDeviationField.bottomAnchor, bottom: contentView.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
    }
    
    func save(){
        Preferences.shared.followTrack = followTrackSwitch.isOn
        var val = Double(trackpointIntervalField.text)
        if let val = val{
            Preferences.shared.trackpointInterval = val
        }
        val = Double(maxHorizontalUncertaintyField.text)
        if let val = val{
            Preferences.shared.maxHorizontalUncertainty = val
        }
        val = Double(minHorizontalTrackpointDistanceField.text)
        if let val = val{
            Preferences.shared.minHorizontalTrackpointDistance = val
        }
        val = Double(minVerticalTrackpointDistanceField.text)
        if let val = val{
            Preferences.shared.minVerticalTrackpointDistance = val
        }
        val = Double(maxTrackpointInLineDeviationField.text)
        if let val = val{
            Preferences.shared.maxTrackpointInLineDeviation = val
        }
        Preferences.shared.save()
        showDone(title: "ok".localize(), text: "preferencesSaved".localize())
    }
    
}

    

