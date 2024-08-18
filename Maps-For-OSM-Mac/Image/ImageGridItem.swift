/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import AppKit
import E5Data
import E5MapData

protocol ImageGridItemDelegate{
    func showImageFullSize(_ image: Image)
}

class ImageGridItem: NSCollectionViewItem, ImageGridItemViewDelegate{
    
    var image: Image
    var gridView: ImageGridView? = nil
    
    var delegate: ImageGridItemDelegate? = nil
    
    init(image: Image, gridView: ImageGridView?) {
        self.image = image
        self.gridView = gridView
        super.init(nibName: "", bundle: nil)
        setHighlightState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let itemView = ImageGridItemView()
        itemView.delegate = self
        
        view = itemView
        view.wantsLayer = true
        view.setGrayRoundedBorders()
        
        let dateView = NSTextField(labelWithString: image.creationDate.dateTimeString())
        view.addSubviewWithAnchors(dateView, top: view.topAnchor, insets: Insets.smallInsets).centerX(view.centerXAnchor)
        
        let imgView = NSImageView(image: image.getPreview() ?? NSImage(named: "gear.grey")!)
        view.addSubviewFilling(imgView, insets: NSEdgeInsets(top: 25, left: 5, bottom: 25, right: 5))
        
        let iconView = NSView()
        view.addSubviewWithAnchors(iconView, bottom: view.bottomAnchor, insets: Insets.smallInsets).centerX(view.centerXAnchor)
        
        let showFullSizeButton = NSButton(image: NSImage(systemSymbolName: "photo", accessibilityDescription: nil)!, target: itemView, action: #selector(itemView.showImageFullSize))
        showFullSizeButton.bezelStyle = .smallSquare
        iconView.addSubviewWithAnchors(showFullSizeButton, top: iconView.topAnchor, leading: iconView.leadingAnchor, bottom: iconView.bottomAnchor, insets: Insets.flatInsets)
        let showOnMapButton = NSButton(image: NSImage(systemSymbolName: "map", accessibilityDescription: nil)!, target: itemView, action: #selector(itemView.showImageOnMap))
        showOnMapButton.bezelStyle = .smallSquare
        iconView.addSubviewWithAnchors(showOnMapButton, top: iconView.topAnchor, leading: showFullSizeButton.trailingAnchor, bottom: iconView.bottomAnchor, insets: Insets.flatInsets)
        let showDetailButton = NSButton(image: NSImage(systemSymbolName: "magnifyingglass", accessibilityDescription: nil)!, target: itemView, action: #selector(itemView.showImageDetail))
        showDetailButton.bezelStyle = .smallSquare
        iconView.addSubviewWithAnchors(showDetailButton, top: iconView.topAnchor, leading: showOnMapButton.trailingAnchor, bottom: iconView.bottomAnchor, insets: Insets.flatInsets)
        let exportButton = NSButton(image: NSImage(systemSymbolName: "square.and.arrow.up", accessibilityDescription: nil)!, target: itemView, action: #selector(itemView.exportImage))
        exportButton.bezelStyle = .smallSquare
        iconView.addSubviewWithAnchors(exportButton, top: iconView.topAnchor, leading: showDetailButton.trailingAnchor, bottom: iconView.bottomAnchor, insets: Insets.flatInsets)
        let deleteButton = NSButton(image: NSImage(systemSymbolName: "trash", accessibilityDescription: nil)!, target: itemView, action: #selector(itemView.deleteImage))
        deleteButton.bezelStyle = .smallSquare
        iconView.addSubviewWithAnchors(deleteButton, top: iconView.topAnchor, leading: exportButton.trailingAnchor, trailing: iconView.trailingAnchor, bottom: iconView.bottomAnchor, insets: Insets.flatInsets)
        
        setHighlightState()
    }
    
    override func mouseDown(with event: NSEvent) {
        if event.clickCount > 1{
            gridView?.showImage(image)
        }
        else{
            super.mouseDown(with: event)
        }
    }
    
    func select(_ flag: Bool){
        isSelected = flag
        image.selected = flag
    }
    
    func showImageFullSize(){
        delegate?.showImageFullSize(image)
    }
    
    func showImageOnMap(){
        MainViewController.instance.showLocationOnMap(image.location)
    }
    
    func showImageDetail(itemView: NSView){
        let detailView = ImageGridDetailViewController(image: image)
        detailView.popover.show(relativeTo: itemView.bounds, of: itemView, preferredEdge: .minY)
    }
    
    func exportImage(){
        MainViewController.instance.exportImage(image)
    }
    
    func deleteImage(){
        MainViewController.instance.deleteImage(image)
    }
    
    func setHighlightState() {
        view.backgroundColor = isSelected ? NSColor(white: 0.7, alpha: 0.3) : .black
    }

}

fileprivate protocol ImageGridItemViewDelegate{
    func showImageDetail(itemView: NSView)
    func showImageFullSize()
    func showImageOnMap()
    func exportImage()
    func deleteImage()
}

fileprivate class ImageGridItemView: NSView{
    
    var delegate: ImageGridItemViewDelegate? = nil
    
    @objc func showImageFullSize(){
        delegate?.showImageFullSize()
    }
    
    @objc func showImageDetail(){
        delegate?.showImageDetail(itemView: self)
    }
    
    @objc func showImageOnMap(){
        delegate?.showImageOnMap()
    }
    
    @objc func exportImage(){
        delegate?.exportImage()
    }
    
    @objc func deleteImage(){
        delegate?.deleteImage()
    }
    
}



