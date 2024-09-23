/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit



protocol ImageCellDelegate{
    func editImage(_ image: ImageItem)
}

class ImageCellView : LocationItemCellView{
    
    var image: ImageItem
    
    var selectedButton: NSButton!
    
    var delegate: ImageCellDelegate? = nil
    
    init(image: ImageItem){
        self.image = image
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView() {
        super.setupView()
        let titleField = NSTextField(wrappingLabelWithString: "image".localize()).asHeadline()
        addSubviewWithAnchors(titleField, top: topAnchor, insets: smallInsets).centerX(centerXAnchor)
        let iconBar = IconBar()
        addSubviewWithAnchors(iconBar, top: topAnchor, trailing: trailingAnchor)
        let showButton = NSButton(icon: "magnifyingglass", target: self, action: #selector(showImage))
        iconBar.addArrangedSubview(showButton)
        let editButton = NSButton(icon: "pencil", target: self, action: #selector(editImage))
        iconBar.addArrangedSubview(editButton)
        selectedButton = NSButton(icon: image.selected ? "checkmark.square" : "square", target: self, action: #selector(selectionChanged))
        iconBar.addArrangedSubview(selectedButton)
        var lastView: NSView = iconBar
        if let image = image.getPreview(){
            let imageView = NSImageView(image: image)
            imageView.compressable()
            imageView.setAspectRatioConstraint()
            addSubviewWithAnchors(imageView, top: lastView.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor)
            lastView = imageView
        }
        if !image.comment.isEmpty{
            let label = NSTextField(wrappingLabelWithString: image.comment)
            addSubviewWithAnchors(label, top: lastView.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor)
            lastView = label
        }
        lastView.bottom(bottomAnchor)
    }
    
    override func updateIconView() {
        selectedButton.image = NSImage(systemSymbolName: image.selected ? "checkmark.square" : "square", accessibilityDescription: .none)
    }
    
    @objc func showImage(){
        MainViewController.instance.showImage(image)
    }
    
    @objc func editImage(){
        delegate?.editImage(image)
    }
    
    @objc func selectionChanged(){
        image.selected = !image.selected
        updateIconView()
    }
    
}
