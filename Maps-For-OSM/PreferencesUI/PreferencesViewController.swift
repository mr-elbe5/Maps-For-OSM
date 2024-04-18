/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol PreferencesDelegate: AppLoaderDelegate{
}

class PreferencesViewController: PopupScrollViewController{
    
    var useICloudSwitch = LabeledSwitchView()
    var replaceLocalDataOnDownloadSwitch = LabeledSwitchView()
    var replaceICloudDataOnUploadSwitch = LabeledSwitchView()
    var synchronizeButton = UIButton()
    
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
        
        useICloudSwitch.setupView(labelText: "useICloud".localize(), isOn: Preferences.shared.useICloud)
        useICloudSwitch.delegate = self
        contentView.addSubviewWithAnchors(useICloudSwitch, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        replaceLocalDataOnDownloadSwitch.setupView(labelText: "replaceLocalDataOnDownload".localize(), isOn: Preferences.shared.replaceLocalDataOnDownload)
        contentView.addSubviewWithAnchors(replaceLocalDataOnDownloadSwitch, top: useICloudSwitch.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        replaceICloudDataOnUploadSwitch.setupView(labelText: "replaceICloudDataOnUpload".localize(), isOn: Preferences.shared.replaceICloudDataOnUpload)
        contentView.addSubviewWithAnchors(replaceICloudDataOnUploadSwitch, top: replaceLocalDataOnDownloadSwitch.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        var saveButton = UIButton()
        saveButton.setTitle("save".localize(), for: .normal)
        saveButton.setTitleColor(.systemBlue, for: .normal)
        saveButton.addAction(UIAction(){ action in
            self.saveICloudPreferences()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(saveButton, top: replaceICloudDataOnUploadSwitch.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
        
        synchronizeButton.setTitle("synchronizeNow".localize(), for: .normal)
        synchronizeButton.setTitleColor(.systemBlue, for: .normal)
        synchronizeButton.setTitleColor(.systemGray, for: .disabled)
        synchronizeButton.addAction(UIAction(){ action in
            self.synchronize()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(synchronizeButton, top: saveButton.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
        synchronizeButton.isEnabled = Preferences.shared.useICloud
        
        header = UILabel(header: "places".localize())
        contentView.addSubviewWithAnchors(header, top: synchronizeButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        maxMergeDistanceField.setupView(labelText: "maxMergeDistance".localize(), text: String(Preferences.shared.maxPlaceMergeDistance), isHorizontal: false)
        contentView.addSubviewWithAnchors(maxMergeDistanceField, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        saveButton = UIButton()
        saveButton.setTitle("save".localize(), for: .normal)
        saveButton.setTitleColor(.systemBlue, for: .normal)
        saveButton.addAction(UIAction(){ action in
            self.savePlacePreferences()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(saveButton, top: maxMergeDistanceField.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
        
        header = UILabel(header: "tracks".localize())
        contentView.addSubviewWithAnchors(header, top: saveButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
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
        
        saveButton = UIButton()
        saveButton.setTitle("save".localize(), for: .normal)
        saveButton.setTitleColor(.systemBlue, for: .normal)
        saveButton.addAction(UIAction(){ action in
            self.saveTrackPreferences()
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
    
    func synchronize(){
        Preferences.shared.useICloud = useICloudSwitch.isOn
        Preferences.shared.replaceLocalDataOnDownload = replaceLocalDataOnDownloadSwitch.isOn
        Preferences.shared.replaceICloudDataOnUpload = replaceICloudDataOnUploadSwitch.isOn
        AppLoader.synchronizeICloud(delegate: self)
    }
    
    func saveICloudPreferences(){
        Preferences.shared.useICloud = useICloudSwitch.isOn
        Preferences.shared.replaceLocalDataOnDownload = replaceLocalDataOnDownloadSwitch.isOn
        Preferences.shared.replaceICloudDataOnUpload = replaceICloudDataOnUploadSwitch.isOn
        Preferences.shared.save()
        showDone(title: "ok".localize(), text: "preferencesSaved".localize())
    }
    
    func savePlacePreferences(){
        var val = Double(maxMergeDistanceField.text)
        if let val = val{
            if Preferences.shared.maxPlaceMergeDistance != val{
                Preferences.shared.maxPlaceMergeDistance = val
                AppData.shared.resetCoordinateRegions()
            }
        }
        Preferences.shared.save()
        showDone(title: "ok".localize(), text: "preferencesSaved".localize())
    }
    
    func saveTrackPreferences(){
        Preferences.shared.followTrack = followTrackSwitch.isOn
        var val = Double(trackpointIntervalField.text)
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
        Preferences.shared.save()
        showDone(title: "ok".localize(), text: "preferencesSaved".localize())
    }
    
}

extension PreferencesViewController: SwitchDelegate{
    
    func switchValueDidChange(sender: LabeledSwitchView, isOn: Bool) {
        if sender == useICloudSwitch{
            synchronizeButton.isEnabled = isOn
        }
    }
}

extension PreferencesViewController: AppLoaderDelegate{
    
    func startLoading() {
        //todo
    }
    
    func appLoaded() {
        delegate?.appLoaded()
    }
    
    func startSaving() {
        
    }
    
    func appSaved() {
    }
    
}

    

