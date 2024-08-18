/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit


protocol MapMenuDelegate{
    func zoomIn()
    func zoomOut()
    func toggleCross()
    func refreshMap()
    func hideTrack()
}

class MapMenuView: NSView{
    
    var zoomInButton: NSButton!
    var zoomOutButton: NSButton!
    var toggleCrossButton: NSButton!
    var centerButton: NSButton!
    var refreshButton: NSButton!
    var hideTrackButton: NSButton!
    
    var delegate: MapMenuDelegate? = nil
    
    init(){
        super.init(frame: .zero)
        
        zoomInButton = NSButton(image: NSImage(systemSymbolName: "plus", accessibilityDescription: nil)!, target: self, action: #selector(zoomIn))
        zoomInButton.toolTip = "zoomIn".localize()
        zoomOutButton = NSButton(image: NSImage(systemSymbolName: "minus", accessibilityDescription: nil)!, target: self, action: #selector(zoomOut))
        zoomOutButton.toolTip = "zoomOut".localize()
        toggleCrossButton = NSButton(image: NSImage(systemSymbolName: "plus.circle", accessibilityDescription: nil)!, target: self, action: #selector(toggleCross))
        toggleCrossButton.toolTip = "toggleCross".localize()
        refreshButton = NSButton(image: NSImage(systemSymbolName: "arrow.triangle.2.circlepath", accessibilityDescription: nil)!, target: self, action: #selector(refreshMap))
        refreshButton.toolTip = "refresh".localize()
        hideTrackButton = NSButton(image: NSImage(systemSymbolName: "eraser", accessibilityDescription: nil)!, target: self, action: #selector(hideTrack))
        hideTrackButton.toolTip = "hideTrack".localize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView(){
        addSubview(zoomInButton)
        zoomInButton.setAnchors(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
        addSubview(zoomOutButton)
        zoomOutButton.setAnchors(top: zoomInButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
        addSubview(toggleCrossButton)
        toggleCrossButton.setAnchors(top: zoomOutButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
        addSubview(refreshButton)
        refreshButton.setAnchors(top: toggleCrossButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
        addSubview(hideTrackButton)
        hideTrackButton.setAnchors(top: refreshButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
    }
    
    @objc func zoomIn(){
        delegate?.zoomIn()
    }
    
    @objc func zoomOut(){
        delegate?.zoomOut()
    }
    
    @objc func toggleCross() {
        delegate?.toggleCross()
    }
    
    @objc func refreshMap() {
        delegate?.refreshMap()
    }
    
    @objc func hideTrack() {
        delegate?.hideTrack()
    }
    
}
    
