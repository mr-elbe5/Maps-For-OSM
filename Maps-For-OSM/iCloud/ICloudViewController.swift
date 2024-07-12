/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import E5Data
import E5IOSUI
import E5MapData

protocol ICloudDelegate{
    func dataChanged()
}

class ICloudViewController: NavScrollViewController{
    
    var useICloudSwitch = LabeledSwitchView()
    var mergeFromICloudButton = UIButton()
    var copyFromICloudButton = UIButton()
    var mergeToICloudButton = UIButton()
    var copyToICloudButton = UIButton()
    var synchronizeButton = UIButton()
    var assertLocalDataConsitencyButton = UIButton()
    var cleanupICloudButton = UIButton()
    
    var delegate: ICloudDelegate? = nil
    
    override func loadView() {
        title = "iCloud".localize()
        super.loadView()
        scrollView.backgroundColor = .white
    }
    
    override func loadScrollableSubviews() {
        mergeFromICloudButton.setTitle("mergeFromICloud".localize(), for: .normal)
        mergeFromICloudButton.setTitleColor(.systemBlue, for: .normal)
        mergeFromICloudButton.setTitleColor(.systemGray, for: .disabled)
        mergeFromICloudButton.addAction(UIAction(){ action in
            self.mergeFromICloud()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(mergeFromICloudButton, top: contentView.topAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
        var label = UILabel(text: "mergeFromICloudHint".localize())
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
        label = UILabel(text: "synchronizeNowHint".localize())
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        contentView.addSubviewWithAnchors(label, top: synchronizeButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        assertLocalDataConsitencyButton.setTitle("assertLocalDataConsitency".localize(), for: .normal)
        assertLocalDataConsitencyButton.setTitleColor(.systemBlue, for: .normal)
        assertLocalDataConsitencyButton.setTitleColor(.systemGray, for: .disabled)
        assertLocalDataConsitencyButton.addAction(UIAction(){ action in
            self.assertLocalDataConsitency()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(assertLocalDataConsitencyButton, top: label.bottomAnchor, insets: defaultInsets)
        .centerX(contentView.centerXAnchor)
        label = UILabel(text: "assertLocalDataConsitencyHint".localize())
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        contentView.addSubviewWithAnchors(label, top: assertLocalDataConsitencyButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        cleanupICloudButton.setTitle("cleanupICloud".localize(), for: .normal)
        cleanupICloudButton.setTitleColor(.systemBlue, for: .normal)
        cleanupICloudButton.setTitleColor(.systemGray, for: .disabled)
        cleanupICloudButton.addAction(UIAction(){ action in
            self.cleanupICloud()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(cleanupICloudButton, top: label.bottomAnchor, insets: defaultInsets)
        .centerX(contentView.centerXAnchor)
        label = UILabel(text: "cleanupICloudHint".localize())
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        contentView.addSubviewWithAnchors(label, top: cleanupICloudButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, bottom: contentView.bottomAnchor, insets: flatInsets)
    }
    
    func mergeFromICloud(){
        let synchronizer = CloudSynchronizer()
        let spinner = startSpinner()
        spinner.startAnimating()
        Task{
            try await synchronizer.synchronizeFromICloud(deleteLocalData: false)
            AppData.shared.save()
            DispatchQueue.main.async{
                self.stopSpinner(spinner)
                self.showDone(title: "success".localize(), text: "mergedFromICloud".localize())
                self.delegate?.dataChanged()
            }
        }
    }
    
    func copyFromICloud(){
        let synchronizer = CloudSynchronizer()
        let spinner = startSpinner()
        Task{
            try await synchronizer.synchronizeFromICloud(deleteLocalData: true)
            AppData.shared.save()
            DispatchQueue.main.async{
                self.stopSpinner(spinner)
                self.showDone(title: "success".localize(), text: "copiedFromICloud".localize())
                self.delegate?.dataChanged()
            }
        }
    }
    
    func mergeToICloud(){
        let synchronizer = CloudSynchronizer()
        let spinner = startSpinner()
        spinner.startAnimating()
        Task{
            try await synchronizer.synchronizeToICloud(deleteICloudData: false)
            DispatchQueue.main.async{
                self.stopSpinner(spinner)
                self.showDone(title: "success".localize(), text: "mergedToICloud".localize())
            }
        }
    }
    
    func copyToICloud(){
        let synchronizer = CloudSynchronizer()
        let spinner = startSpinner()
        Task{
            try await synchronizer.synchronizeToICloud(deleteICloudData: true)
            DispatchQueue.main.async{
                self.stopSpinner(spinner)
                self.showDone(title: "success".localize(), text: "copiedToICloud".localize())
            }
        }
    }
    
    func synchronize(){
        let synchronizer = CloudSynchronizer()
        let spinner = startSpinner()
        Task{
            try await synchronizer.synchronizeICloud(replaceLocalData: false, replaceICloudData: true)
            DispatchQueue.main.async{
                self.stopSpinner(spinner)
                self.showDone(title: "success".localize(), text: "synchronized".localize())
                self.delegate?.dataChanged()
            }
        }
        
    }
    
    func assertLocalDataConsitency(){
        AppData.shared.locations.updateCreationDates()
        AppData.shared.locations.removeDuplicates()
        AppData.shared.save()
        self.delegate?.dataChanged()
        self.showDone(title: "success".localize(), text: "assertedLocalConsistency".localize())
    }
    
    func cleanupICloud(){
        let synchronizer = CloudSynchronizer()
        let spinner = startSpinner()
        Task{
            try await synchronizer.cleanupICloud()
            DispatchQueue.main.async{
                self.stopSpinner(spinner)
                self.showDone(title: "success".localize(), text: "cleanedUp".localize())
            }
        }
        
    }
    
}

