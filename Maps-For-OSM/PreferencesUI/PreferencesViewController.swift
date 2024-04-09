/*
 Maps For OSM
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
    
    var mergingSynchronisationSwitch = LabeledSwitchView()
    var maxMergeDistanceField = LabeledTextField()
    var followTrackSwitch = LabeledSwitchView()
    var trackpointIntervalField = LabeledTextField()
    var maxHorizontalUncertaintyField = LabeledTextField()
    var maxSpeedUncertaintyFactorField = LabeledTextField()
    var minHorizontalTrackpointDistanceField = LabeledTextField()
    var minVerticalTrackpointDistanceField = LabeledTextField()
    var maxTrackpointInLineDeviationField = LabeledTextField()
    
    var delegate: PreferencesDelegate? = nil
    
    override func loadView() {
        title = "preferences".localize()
        super.loadView()
        
        var header = UILabel(header: "iCloud".localize())
        contentView.addSubviewWithAnchors(header, top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        mergingSynchronisationSwitch.setupView(labelText: "mergeSynchronisation".localize(), isOn: Preferences.shared.mergingSynchronisation)
        contentView.addSubviewWithAnchors(mergingSynchronisationSwitch, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        header = UILabel(header: "places".localize())
        contentView.addSubviewWithAnchors(header, top: mergingSynchronisationSwitch.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        maxMergeDistanceField.setupView(labelText: "maxMergeDistance".localize(), text: String(Preferences.shared.maxPlaceMergeDistance), isHorizontal: false)
        contentView.addSubviewWithAnchors(maxMergeDistanceField, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        header = UILabel(header: "tracks".localize())
        contentView.addSubviewWithAnchors(header, top: maxMergeDistanceField.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        followTrackSwitch.setupView(labelText: "followTrack".localize(), isOn: Preferences.shared.followTrack)
        contentView.addSubviewWithAnchors(followTrackSwitch, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        trackpointIntervalField.setupView(labelText: "trackpointInterval".localize(), text: String(Preferences.shared.trackpointInterval), isHorizontal: false)
        contentView.addSubviewWithAnchors(trackpointIntervalField, top: followTrackSwitch.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        maxHorizontalUncertaintyField.setupView(labelText: "maxHorizontalUncertainty".localize(), text: String(Preferences.shared.maxHorizontalUncertainty), isHorizontal: false)
        contentView.addSubviewWithAnchors(maxHorizontalUncertaintyField, top: trackpointIntervalField.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        maxSpeedUncertaintyFactorField.setupView(labelText: "maxSpeedUncertaintyFactor".localize(), text: String(Int(Preferences.shared.maxSpeedUncertaintyFactor)), isHorizontal: false)
        contentView.addSubviewWithAnchors(maxSpeedUncertaintyFactorField, top: maxHorizontalUncertaintyField.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        minHorizontalTrackpointDistanceField.setupView(labelText: "minHorizontalTrackpointDistance".localize(), text: String(Preferences.shared.minHorizontalTrackpointDistance), isHorizontal: false)
        contentView.addSubviewWithAnchors(minHorizontalTrackpointDistanceField, top: maxSpeedUncertaintyFactorField.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
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
        
        setupKeyboard()
        
    }
    
    override func setupHeaderView(headerView: UIView){
        super.setupHeaderView(headerView: headerView)
        let infoButton = UIButton().asIconButton("info")
        headerView.addSubviewWithAnchors(infoButton, top: headerView.topAnchor, trailing: closeButton.leadingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        infoButton.addAction(UIAction(){ action in
            let controller = PreferencesInfoViewController()
            self.present(controller, animated: true)
        }, for: .touchDown)
    }
    
    func save(){
        Preferences.shared.mergingSynchronisation = mergingSynchronisationSwitch.isOn
        var val = Double(maxMergeDistanceField.text)
        if let val = val{
            Preferences.shared.maxPlaceMergeDistance = val
        }
        Preferences.shared.followTrack = followTrackSwitch.isOn
        val = Double(trackpointIntervalField.text)
        if let val = val{
            Preferences.shared.trackpointInterval = val
        }
        val = Double(maxHorizontalUncertaintyField.text)
        if let val = val{
            Preferences.shared.maxHorizontalUncertainty = val
        }
        val = Double(maxSpeedUncertaintyFactorField.text)
        if let val = val{
            Preferences.shared.maxSpeedUncertaintyFactor = val
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
        self.delegate?.updateFollowTrack()
        Preferences.shared.save()
        showDone(title: "ok".localize(), text: "preferencesSaved".localize())
    }
    
}

    

