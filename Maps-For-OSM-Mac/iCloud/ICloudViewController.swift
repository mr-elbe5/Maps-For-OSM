/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation


import CloudKit

protocol ICloudDelegate{
    func mergeFromICloud()
    func copyFromICloud()
    func mergeToICloud()
    func copyToICloud()
    func synchronize()
    func assertLocalDataConsitency()
    func cleanupICloud()
}

class ICloudViewController: NSViewController, ICloudDelegate {
    
    var contentView = ICloudView()
    
    override func loadView() {
        super.loadView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: 350, height: 0))
        contentView.delegate = self
        view.addSubviewFilling(contentView)
        contentView.setupView()
    }
    
    
    func mergeFromICloud(){
        let synchronizer = CloudSynchronizer()
        synchronizer.delegate = contentView
        let spinner = startSpinner()
        Task{
            try await synchronizer.synchronizeFromICloud(deleteLocalData: false)
            AppData.shared.save()
            DispatchQueue.main.async{
                self.stopSpinner(spinner)
                self.showSuccess(title: "success".localize(), text: "mergedFromICloud".localize())
                MainViewController.instance.updateLocations()
            }
        }
    }
    
    func copyFromICloud(){
        let synchronizer = CloudSynchronizer()
        synchronizer.delegate = contentView
        let spinner = startSpinner()
        Task{
            try await synchronizer.synchronizeFromICloud(deleteLocalData: true)
            AppData.shared.save()
            DispatchQueue.main.async{
                self.stopSpinner(spinner)
                self.showSuccess(title: "success".localize(), text: "copiedFromICloud".localize())
                MainViewController.instance.updateLocations()
            }
        }
    }
    
    func mergeToICloud(){
        let synchronizer = CloudSynchronizer()
        synchronizer.delegate = contentView
        let spinner = startSpinner()
        Task{
            try await synchronizer.synchronizeToICloud(deleteICloudData: false)
            DispatchQueue.main.async{
                self.stopSpinner(spinner)
                self.showSuccess(title: "success".localize(), text: "mergedToICloud".localize())
            }
        }
    }
    
    @objc func copyToICloud(){
        let synchronizer = CloudSynchronizer()
        synchronizer.delegate = contentView
        let spinner = startSpinner()
        Task{
            try await synchronizer.synchronizeToICloud(deleteICloudData: true)
            DispatchQueue.main.async{
                self.stopSpinner(spinner)
                self.showSuccess(title: "success".localize(), text: "copiedToICloud".localize())
            }
        }
    }
    
    func synchronize(){
        let synchronizer = CloudSynchronizer()
        synchronizer.delegate = contentView
        let spinner = startSpinner()
        Task{
            try await synchronizer.synchronizeICloud(replaceLocalData: false, replaceICloudData: true)
            DispatchQueue.main.async{
                self.stopSpinner(spinner)
                self.showSuccess(title: "success".localize(), text: "synchronized".localize())
                MainViewController.instance.updateLocations()
            }
        }
        
    }
    
    func assertLocalDataConsitency(){
        AppData.shared.locations.updateCreationDates()
        AppData.shared.locations.removeDuplicates()
        AppData.shared.save()
        MainViewController.instance.updateLocations()
        self.showSuccess(title: "success".localize(), text: "assertedLocalConsistency".localize())
    }
    
    func cleanupICloud(){
        let synchronizer = CloudSynchronizer()
        synchronizer.delegate = contentView
        let spinner = startSpinner()
        Task{
            try await synchronizer.cleanupICloud()
            DispatchQueue.main.async{
                self.stopSpinner(spinner)
                self.showSuccess(title: "success".localize(), text: "cleanedUp".localize())
            }
        }
        
    }
    
}

class ICloudView: NSView {
    
    var useICloudSwitch = LabeledSwitchView()
    var mergeFromICloudButton = NSButton()
    var copyFromICloudButton = NSButton()
    var mergeToICloudButton = NSButton()
    var copyToICloudButton = NSButton()
    var synchronizeButton = NSButton()
    var assertLocalDataConsitencyButton = NSButton()
    var cleanupICloudButton = NSButton()
    
    var progressView = NSProgressIndicator()
    var currentStep: Int = 0
    var maxSteps: Int = 1
    
    var delegate: ICloudDelegate? = nil
    
    override func setupView() {
        
        mergeFromICloudButton.asTextButton("mergeFromICloud".localize(), target: self, action: #selector(mergeFromICloud))
        addSubviewWithAnchors(mergeFromICloudButton, top: topAnchor, insets: doubleInsets).centerX(centerXAnchor)
        var label = NSTextField(wrappingLabelWithString: "mergeFromICloudHint".localize()).asSmallLabel()
        addSubviewWithAnchors(label, top: mergeFromICloudButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
        
        copyFromICloudButton.asTextButton("copyFromICloud".localize(), target: self, action: #selector(copyFromICloud))
        addSubviewWithAnchors(copyFromICloudButton, top: label.bottomAnchor, insets: defaultInsets).centerX(centerXAnchor)
        label = NSTextField(wrappingLabelWithString: "copyFromICloudHint".localize()).asSmallLabel()
        addSubviewWithAnchors(label, top: copyFromICloudButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
        
        mergeToICloudButton.asTextButton("mergeToICloud".localize(), target: self, action: #selector(mergeToICloud))
        addSubviewWithAnchors(mergeToICloudButton, top: label.bottomAnchor, insets: defaultInsets).centerX(centerXAnchor)
        label = NSTextField(wrappingLabelWithString: "mergeToICloudHint".localize()).asSmallLabel()
        addSubviewWithAnchors(label, top: mergeToICloudButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
        
        copyToICloudButton.asTextButton("copyToICloud".localize(), target: self, action: #selector(copyToICloud))
        addSubviewWithAnchors(copyToICloudButton, top: label.bottomAnchor, insets: defaultInsets).centerX(centerXAnchor)
        label = NSTextField(wrappingLabelWithString: "copyToICloudHint".localize()).asSmallLabel()
        addSubviewWithAnchors(label, top: copyToICloudButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
        
        synchronizeButton.asTextButton("synchronizeNow".localize(), target: self, action: #selector(synchronize))
        addSubviewWithAnchors(synchronizeButton, top: label.bottomAnchor, insets: defaultInsets).centerX(centerXAnchor)
        label = NSTextField(wrappingLabelWithString: "synchronizeNowHint".localize()).asSmallLabel()
        addSubviewWithAnchors(label, top: synchronizeButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
        
        assertLocalDataConsitencyButton.asTextButton("assertLocalDataConsistency".localize(), target: self, action: #selector(assertLocalDataConsitency))
        addSubviewWithAnchors(assertLocalDataConsitencyButton, top: label.bottomAnchor, insets: defaultInsets).centerX(centerXAnchor)
        label = NSTextField(wrappingLabelWithString: "assertLocalDataConsistencyHint".localize())
        addSubviewWithAnchors(label, top: assertLocalDataConsitencyButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
        
        cleanupICloudButton.asTextButton("cleanupICloud".localize(), target: self, action: #selector(cleanupICloud))
        addSubviewWithAnchors(cleanupICloudButton, top: label.bottomAnchor, insets: defaultInsets).centerX(centerXAnchor)
        label = NSTextField(wrappingLabelWithString: "cleanupICloudHint".localize()).asSmallLabel()
        addSubviewWithAnchors(label, top: cleanupICloudButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
        
        progressView.isIndeterminate = false
        addSubviewWithAnchors(progressView, top: label.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
            .bottom(bottomAnchor, inset: defaultInset)
        
        updateButtonStates()
    }
    
    func setupProgressView(max: Int){
        maxSteps = max
        currentStep = 0
        progressView.minValue = 0
        progressView.maxValue = 1
        progressView.doubleValue = 0
    }
    
    func increaseProgressView(){
        currentStep += 1
        progressView.doubleValue = Double(currentStep) / Double(maxSteps)
    }
        
    @objc func mergeFromICloud(){
        delegate?.mergeFromICloud()
    }
    
    @objc func copyFromICloud(){
        delegate?.copyFromICloud()
    }
    
    @objc func mergeToICloud(){
        delegate?.mergeToICloud()
    }
    
    @objc func copyToICloud(){
        delegate?.copyToICloud()
    }
    
    @objc func synchronize(){
        delegate?.synchronize()
    }
    
    @objc func assertLocalDataConsitency(){
        delegate?.assertLocalDataConsitency()
    }
    
    @objc func cleanupICloud(){
        delegate?.cleanupICloud()
        
    }
    
    func updateButtonStates(){
        Task{
            let isOn = try await CKContainer.isConnected()
            mergeFromICloudButton.isEnabled = isOn
            copyFromICloudButton.isEnabled = isOn
            mergeToICloudButton.isEnabled = isOn
            copyToICloudButton.isEnabled = isOn
            synchronizeButton.isEnabled = isOn
        }
    }
    
    
}

extension ICloudView: CloudSynchronizerDelegate{
    
    func setMaxSteps(_ value: Int) {
        setupProgressView(max: value)
    }
    
    func nextStep() {
        increaseProgressView()
    }
    
}
