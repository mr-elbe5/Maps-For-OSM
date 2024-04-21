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
    var deleteLocalDataOnDownloadSwitch = LabeledSwitchView()
    var deleteICloudDataOnUploadSwitch = LabeledSwitchView()
    var mergeFromICloudButton = UIButton()
    var copyFromICloudButton = UIButton()
    var mergeToICloudButton = UIButton()
    var copyToICloudButton = UIButton()
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
        
        deleteLocalDataOnDownloadSwitch.setupView(labelText: "deleteLocalDataOnDownload".localize(), isOn: Preferences.shared.deleteLocalDataOnDownload)
        contentView.addSubviewWithAnchors(deleteLocalDataOnDownloadSwitch, top: label.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        label = UILabel(text: "deleteLocalDataOnDownloadHint".localize())
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        contentView.addSubviewWithAnchors(label, top: deleteLocalDataOnDownloadSwitch.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        deleteICloudDataOnUploadSwitch.setupView(labelText: "deleteICloudDataOnUpload".localize(), isOn: Preferences.shared.deleteICloudDataOnUpload)
        contentView.addSubviewWithAnchors(deleteICloudDataOnUploadSwitch, top: label.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        label = UILabel(text: "deleteICloudDataOnUploadHint".localize())
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        contentView.addSubviewWithAnchors(label, top: deleteICloudDataOnUploadSwitch.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        let saveButton = UIButton()
        saveButton.setTitle("save".localize(), for: .normal)
        saveButton.setTitleColor(.systemBlue, for: .normal)
        saveButton.addAction(UIAction(){ action in
            self.saveICloudPreferences()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(saveButton, top: label.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
        
        mergeFromICloudButton.setTitle("mergeFromICloud".localize(), for: .normal)
        mergeFromICloudButton.setTitleColor(.systemBlue, for: .normal)
        mergeFromICloudButton.setTitleColor(.systemGray, for: .disabled)
        mergeFromICloudButton.addAction(UIAction(){ action in
            self.mergeFromICloud()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(mergeFromICloudButton, top: saveButton.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
        mergeFromICloudButton.isEnabled = Preferences.shared.useICloud
        label = UILabel(text: "mergeFromICloudHint".localize())
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        contentView.addSubviewWithAnchors(label, top: mergeFromICloudButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        copyFromICloudButton.setTitle("copyFromICloud".localize(), for: .normal)
        copyFromICloudButton.setTitleColor(.systemBlue, for: .normal)
        copyFromICloudButton.setTitleColor(.systemGray, for: .disabled)
        copyFromICloudButton.addAction(UIAction(){ action in
            self.copyFromICloud()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(copyFromICloudButton, top: label.bottomAnchor, insets: defaultInsets)
        .centerX(contentView.centerXAnchor)
        copyFromICloudButton.isEnabled = Preferences.shared.useICloud
        label = UILabel(text: "copyFromICloudHint".localize())
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        contentView.addSubviewWithAnchors(label, top: copyFromICloudButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        mergeToICloudButton.setTitle("mergeToICloud".localize(), for: .normal)
        mergeToICloudButton.setTitleColor(.systemBlue, for: .normal)
        mergeToICloudButton.setTitleColor(.systemGray, for: .disabled)
        mergeToICloudButton.addAction(UIAction(){ action in
            self.mergeToICloud()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(mergeToICloudButton, top: label.bottomAnchor, insets: defaultInsets)
        .centerX(contentView.centerXAnchor)
        mergeToICloudButton.isEnabled = Preferences.shared.useICloud
        label = UILabel(text: "mergeToICloudHint".localize())
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        contentView.addSubviewWithAnchors(label, top: mergeToICloudButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        copyToICloudButton.setTitle("copyToICloud".localize(), for: .normal)
        copyToICloudButton.setTitleColor(.systemBlue, for: .normal)
        copyToICloudButton.setTitleColor(.systemGray, for: .disabled)
        copyToICloudButton.addAction(UIAction(){ action in
            self.copyToICloud()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(copyToICloudButton, top: label.bottomAnchor, insets: defaultInsets)
        .centerX(contentView.centerXAnchor)
        copyToICloudButton.isEnabled = Preferences.shared.useICloud
        label = UILabel(text: "copyToICloudHint".localize())
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        contentView.addSubviewWithAnchors(label, top: copyToICloudButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        synchronizeButton.setTitle("synchronizeNow".localize(), for: .normal)
        synchronizeButton.setTitleColor(.systemBlue, for: .normal)
        synchronizeButton.setTitleColor(.systemGray, for: .disabled)
        synchronizeButton.addAction(UIAction(){ action in
            self.synchronize()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(synchronizeButton, top: label.bottomAnchor, insets: defaultInsets)
        .centerX(contentView.centerXAnchor)
        synchronizeButton.isEnabled = Preferences.shared.useICloud
        label = UILabel(text: "synchronizeNowHint".localize())
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        contentView.addSubviewWithAnchors(label, top: synchronizeButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, bottom: contentView.bottomAnchor, insets: flatInsets)
        
    }
    
    func mergeFromICloud(){
        let synchronizer = CloudSynchronizer()
        Task{
            try await synchronizer.synchronizeFromICloud(deleteLocalData: false)
            delegate?.appLoaded()
        }
    }
    
    func copyFromICloud(){
        let synchronizer = CloudSynchronizer()
        Task{
            try await synchronizer.synchronizeFromICloud(deleteLocalData: true)
            delegate?.appLoaded()
        }
    }
    
    func mergeToICloud(){
        let synchronizer = CloudSynchronizer()
        Task{
            try await synchronizer.synchronizeToICloud(deleteICloudData: false)
            delegate?.appSaved()
        }
    }
    
    func copyToICloud(){
        let synchronizer = CloudSynchronizer()
        Task{
            try await synchronizer.synchronizeToICloud(deleteICloudData: true)
            delegate?.appSaved()
        }
    }
    
    func synchronize(){
        let synchronizer = CloudSynchronizer()
        delegate?.startSynchronization()
        Task{
            try await synchronizer.synchronizeICloud(replaceLocalData: deleteLocalDataOnDownloadSwitch.isOn, replaceICloudData: deleteICloudDataOnUploadSwitch.isOn)
            delegate?.appSynchronized()
        }
        
    }
    
    func saveICloudPreferences(){
        Preferences.shared.useICloud = useICloudSwitch.isOn
        Preferences.shared.deleteLocalDataOnDownload = deleteLocalDataOnDownloadSwitch.isOn
        Preferences.shared.deleteICloudDataOnUpload = deleteICloudDataOnUploadSwitch.isOn
        Preferences.shared.save()
        showDone(title: "ok".localize(), text: "preferencesSaved".localize())
    }
    
}

extension ICloudViewController: SwitchDelegate{
    
    func switchValueDidChange(sender: LabeledSwitchView, isOn: Bool) {
        if sender == useICloudSwitch{
            mergeFromICloudButton.isEnabled = isOn
            copyFromICloudButton.isEnabled = isOn
            mergeToICloudButton.isEnabled = isOn
            copyToICloudButton.isEnabled = isOn
            synchronizeButton.isEnabled = isOn
        }
    }
}

extension ICloudViewController: AppLoaderDelegate{
    
    func startSynchronization() {
        
    }
    
    func appSynchronized() {
        delegate?.appLoaded()
    }
    
    
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

    

