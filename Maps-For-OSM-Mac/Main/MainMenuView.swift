/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import E5Data

protocol MainMenuDelegate{
    func setView(_ type: MainViewType)
    func openICloud()
    func openPreferences()
    func openBackup()
    func openHelp()
}

class MainMenuView: NSView{
    
    var centerMenu: NSSegmentedControl!
    var rightMenu = NSView()
    
    var openPreferencesButton: NSButton!
    var openICloudButton: NSButton!
    var openBackupButton: NSButton!
    var openHelpButton: NSButton!
    
    var delegate: MainMenuDelegate? = nil
    
    init(){
        super.init(frame: .zero)
        var centerImages = Array<NSImage>()
        centerImages.append(NSImage(systemSymbolName: "map", accessibilityDescription: "map".localize())!)
        centerImages.append(NSImage(systemSymbolName: "square.grid.3x3", accessibilityDescription: "images".localize())!)
        centerImages.append(NSImage(systemSymbolName: "photo.stack", accessibilityDescription: "slideshow".localize())!)
        centerMenu = NSSegmentedControl(images: centerImages, trackingMode: NSSegmentedControl.SwitchTracking.selectOne, target: self, action: #selector(centerMenuChanged))
        centerMenu.setLabel("map".localize(), forSegment: 0)
        centerMenu.setLabel("images".localize(), forSegment: 1)
        centerMenu.setLabel("slideshow".localize(), forSegment: 2)
        centerMenu.selectedSegment = 0
        
        openPreferencesButton = NSButton(icon: "gearshape", target: self, action: #selector(openPreferences))
        openPreferencesButton.toolTip = "openPreferences".localize()
        openICloudButton = NSButton(icon: "cloud", target: self, action: #selector(openICloud))
        openICloudButton.toolTip = "openICloud".localize()
        openBackupButton = NSButton(icon: "doc.zipper", target: self, action: #selector(openBackup))
        openBackupButton.toolTip = "openBackup".localize()
        openHelpButton = NSButton(icon: "questionmark", target: self, action: #selector(openHelp))
        openBackupButton.toolTip = "openHelp".localize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView(){
        backgroundColor = .black
        addSubview(centerMenu)
        centerMenu.setAnchors(top: topAnchor, bottom: bottomAnchor).centerX(centerXAnchor)
        addSubview(rightMenu)
        rightMenu.setAnchors(top: topAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
        
        rightMenu.addSubview(openPreferencesButton)
        openPreferencesButton.setAnchors(top: rightMenu.topAnchor, leading: rightMenu.leadingAnchor, bottom: rightMenu.bottomAnchor, insets: defaultInsets)
        rightMenu.addSubview(openICloudButton)
        openICloudButton.setAnchors(top: rightMenu.topAnchor, leading: openPreferencesButton.trailingAnchor, bottom: rightMenu.bottomAnchor, insets: defaultInsets)
        rightMenu.addSubview(openBackupButton)
        openBackupButton.setAnchors(top: rightMenu.topAnchor, leading: openICloudButton.trailingAnchor, bottom: rightMenu.bottomAnchor, insets: defaultInsets)
        rightMenu.addSubview(openHelpButton)
        openHelpButton.setAnchors(top: rightMenu.topAnchor, leading: openBackupButton.trailingAnchor, trailing: rightMenu.trailingAnchor, bottom: rightMenu.bottomAnchor, insets: defaultInsets)
    }
    
    @objc func centerMenuChanged(){
        switch centerMenu.selectedSegment{
        case 0: delegate?.setView(.map)
        case 1: delegate?.setView(.grid)
        case 2: delegate?.setView(.presenter)
        default: return
        }
    }
    
    @objc func openPreferences(){
        delegate?.openPreferences()
    }
    
    @objc func openICloud(){
        delegate?.openICloud()
    }
    
    @objc func openBackup(){
        delegate?.openBackup()
    }
    
    @objc func openHelp(){
        delegate?.openHelp()
    }
    
}
    
