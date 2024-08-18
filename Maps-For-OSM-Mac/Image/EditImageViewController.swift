/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

import E5MapData

class EditImageViewController: ViewController {
    
    var image: Image
    
    var commentEditField = NSTextField()
    
    init(image: Image){
        self.image = image
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: 500, height: 0))
        var header = NSTextField(labelWithString: "editImage".localize()).asHeadline()
        view.addSubviewWithAnchors(header, top: view.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, insets: defaultInsets)
        let imageView = NSImageView()
        if let img = image.getPreview(){
            imageView.image = img
        }
        imageView.compressable()
        imageView.setAspectRatioConstraint()
        view.addSubviewWithAnchors(imageView, top: header.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor)
        header = NSTextField(labelWithString: "comment".localize()).asLabel()
        view.addSubviewWithAnchors(header, top: imageView.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, insets: defaultInsets)
        commentEditField.asEditableField(text: image.comment)
        view.addSubviewWithAnchors(commentEditField, top: header.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, insets: defaultInsets)
            .width(500)
        let saveButton = NSButton(title: "save".localize(), target: self, action: #selector(save))
        view.addSubviewWithAnchors(saveButton, top: commentEditField.bottomAnchor, bottom: view.bottomAnchor, insets: defaultInsets)
            .centerX(view.centerXAnchor)
    }
    
    @objc func save(){
        image.comment = commentEditField.stringValue
        AppData.shared.save()
        NSApp.stopModal(withCode: .OK)
        self.view.window?.close()
    }
    
}
