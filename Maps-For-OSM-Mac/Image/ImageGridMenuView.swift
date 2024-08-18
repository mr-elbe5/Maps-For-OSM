/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

protocol ImageGridMenuDelegate{
    
    func toggleSelectAll()
    func showSelected()
    func importImages()
    func exportSelected()
    func increaseImageSize()
    func decreaseImageSize()
}

class ImageGridMenuView: NSView{
    
    var selectAllButton: NSButton!
    var showPresenterButton: NSButton!
    var importButton: NSButton!
    var exportButton: NSButton!
    var increaseSizeButton: NSButton!
    var decreaseSizeButton: NSButton!
    
    var delegate: ImageGridMenuDelegate? = nil
    
    init(){
        super.init(frame: .zero)
        
        selectAllButton = NSButton(image: NSImage(systemSymbolName: "checkmark.square", accessibilityDescription: nil)!, target: self, action: #selector(toggleSelectAll))
        selectAllButton.toolTip = "selectAll".localize()
        showPresenterButton = NSButton(image: NSImage(systemSymbolName: "photo", accessibilityDescription: nil)!, target: self, action: #selector(showSelected))
        showPresenterButton.toolTip = "showSelectedImages".localize()
        importButton = NSButton(image: NSImage(systemSymbolName: "square.and.arrow.down.on.square", accessibilityDescription: nil)!, target: self, action: #selector(importImages))
        importButton.toolTip = "importImages".localize()
        exportButton = NSButton(image: NSImage(systemSymbolName: "square.and.arrow.up.on.square", accessibilityDescription: nil)!, target: self, action: #selector(exportSelected))
        exportButton.toolTip = "exportSelectedImages".localize()
        increaseSizeButton = NSButton(image: NSImage(systemSymbolName: "plus", accessibilityDescription: nil)!, target: self, action: #selector(increaseImageSize))
        increaseSizeButton.toolTip = "increaseImageSize".localize()
        decreaseSizeButton = NSButton(image: NSImage(systemSymbolName: "minus", accessibilityDescription: nil)!, target: self, action: #selector(decreaseImageSize))
        decreaseSizeButton.toolTip = "decreaseImageSize".localize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView(){
        addSubview(selectAllButton)
        selectAllButton.setAnchors(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
        addSubview(showPresenterButton)
        showPresenterButton.setAnchors(top: selectAllButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
        addSubview(importButton)
        importButton.setAnchors(top: showPresenterButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
        addSubview(exportButton)
        exportButton.setAnchors(top: importButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
        addSubview(increaseSizeButton)
        increaseSizeButton.setAnchors(top: exportButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
        addSubview(decreaseSizeButton)
        decreaseSizeButton.setAnchors(top: increaseSizeButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
    }
    
    @objc func toggleSelectAll(){
        delegate?.toggleSelectAll()
    }
    
    @objc func showSelected(){
        delegate?.showSelected()
    }
    
    @objc func importImages(){
        delegate?.importImages()
    }
    
    @objc func exportSelected() {
        delegate?.exportSelected()
    }
    
    @objc func increaseImageSize() {
        delegate?.increaseImageSize()
    }
    
    @objc func decreaseImageSize() {
        delegate?.decreaseImageSize()
    }
    
}
    
