/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol ICloudDelegate: AppLoaderDelegate{
}

class ICloudViewController: PopupScrollViewController{
    
    var useICloudSwitch = LabeledSwitchView()
    var replaceLocalDataOnDownloadSwitch = LabeledSwitchView()
    var replaceICloudDataOnUploadSwitch = LabeledSwitchView()
    var synchronizeButton = UIButton()
    
    var delegate: ICloudDelegate? = nil
    
    override func loadView() {
        title = "iCloud".localize()
        super.loadView()
        
        useICloudSwitch.setupView(labelText: "useICloud".localize(), isOn: Preferences.shared.useICloud)
        useICloudSwitch.delegate = self
        contentView.addSubviewWithAnchors(useICloudSwitch, top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        var label = UILabel(text: "useICloudHint".localize())
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        contentView.addSubviewWithAnchors(label, top: useICloudSwitch.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        replaceLocalDataOnDownloadSwitch.setupView(labelText: "replaceLocalDataOnDownload".localize(), isOn: Preferences.shared.replaceLocalDataOnDownload)
        contentView.addSubviewWithAnchors(replaceLocalDataOnDownloadSwitch, top: label.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        label = UILabel(text: "replaceLocalDataOnDownloadHint".localize())
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        contentView.addSubviewWithAnchors(label, top: replaceLocalDataOnDownloadSwitch.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        replaceICloudDataOnUploadSwitch.setupView(labelText: "replaceICloudDataOnUpload".localize(), isOn: Preferences.shared.replaceICloudDataOnUpload)
        contentView.addSubviewWithAnchors(replaceICloudDataOnUploadSwitch, top: label.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        label = UILabel(text: "replaceICloudDataOnUploadHint".localize())
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        contentView.addSubviewWithAnchors(label, top: replaceICloudDataOnUploadSwitch.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        let saveButton = UIButton()
        saveButton.setTitle("save".localize(), for: .normal)
        saveButton.setTitleColor(.systemBlue, for: .normal)
        saveButton.addAction(UIAction(){ action in
            self.saveICloudPreferences()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(saveButton, top: label.bottomAnchor, insets: doubleInsets)
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
        label = UILabel(text: "synchronizeNowHint".localize())
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        contentView.addSubviewWithAnchors(label, top: synchronizeButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, bottom: contentView.bottomAnchor, insets: defaultInsets)
        
    }
    
    func synchronize(){
        Preferences.shared.useICloud = useICloudSwitch.isOn
        Preferences.shared.replaceLocalDataOnDownload = replaceLocalDataOnDownloadSwitch.isOn
        Preferences.shared.replaceICloudDataOnUpload = replaceICloudDataOnUploadSwitch.isOn
        AppLoader.synchronizeICloud(delegate: self)
        delegate?.appLoaded()
    }
    
    func saveICloudPreferences(){
        Preferences.shared.useICloud = useICloudSwitch.isOn
        Preferences.shared.replaceLocalDataOnDownload = replaceLocalDataOnDownloadSwitch.isOn
        Preferences.shared.replaceICloudDataOnUpload = replaceICloudDataOnUploadSwitch.isOn
        Preferences.shared.save()
        showDone(title: "ok".localize(), text: "preferencesSaved".localize())
    }
    
}

extension ICloudViewController: SwitchDelegate{
    
    func switchValueDidChange(sender: LabeledSwitchView, isOn: Bool) {
        if sender == useICloudSwitch{
            synchronizeButton.isEnabled = isOn
        }
    }
}

extension ICloudViewController: AppLoaderDelegate{
    
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

    

