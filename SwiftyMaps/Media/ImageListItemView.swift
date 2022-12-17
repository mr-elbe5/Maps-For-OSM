/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

protocol ImageListItemDelegate{
    func viewImage(sender: ImageListItemView)
    func shareImage(sender: ImageListItemView)
    func deleteImage(sender: ImageListItemView)
}

class ImageListItemView : UIView{
    
    var imageData : ImageFile
    
    var delegate : ImageListItemDelegate? = nil
    
    init(data: ImageFile){
        
        self.imageData = data
        super.init(frame: .zero)
        
        let buttonContainer = UIView()
        buttonContainer.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        buttonContainer.setRoundedBorders(radius: 5)
        
        let shareButton = UIButton().asIconButton("square.and.arrow.up", color: .systemBlue)
        shareButton.addTarget(self, action: #selector(shareImage), for: .touchDown)
        buttonContainer.addSubviewWithAnchors(shareButton, top: buttonContainer.topAnchor, leading: buttonContainer.leadingAnchor, bottom: buttonContainer.bottomAnchor, insets: halfFlatInsets)
        
        let viewButton = UIButton().asIconButton("magnifyingglass", color: .systemBlue)
        viewButton.addTarget(self, action: #selector(viewImage), for: .touchDown)
        buttonContainer.addSubviewWithAnchors(viewButton, top: buttonContainer.topAnchor, leading: shareButton.trailingAnchor, bottom: buttonContainer.bottomAnchor, insets: halfFlatInsets)
        
        let deleteButton = UIButton().asIconButton("xmark.circle", color: .systemRed)
        deleteButton.addTarget(self, action: #selector(deleteImage), for: .touchDown)
        buttonContainer.addSubviewWithAnchors(deleteButton, top: buttonContainer.topAnchor, leading: viewButton.trailingAnchor, trailing: buttonContainer.trailingAnchor, bottom: buttonContainer.bottomAnchor, insets: halfFlatInsets)
        
        let imageView = UIImageView()
        imageView.setDefaults()
        imageView.setRoundedBorders()
        addSubviewWithAnchors(imageView, top: shareButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: UIEdgeInsets(top: 2, left: 0, bottom: defaultInset, right: 0))
        imageView.image = imageData.getImage()
        imageView.setAspectRatioConstraint()
        
        if !imageData.title.isEmpty{
            let titleView = UILabel(text: imageData.title)
            titleView.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
            addSubviewWithAnchors(titleView, top: imageView.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
        }
        else{
            imageView.bottom(bottomAnchor)
        }
        
        addSubviewWithAnchors(buttonContainer, top: topAnchor, trailing: trailingAnchor, insets: defaultInsets)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func viewImage(){
        delegate?.viewImage(sender: self)
    }
    
    @objc func shareImage(){
        delegate?.shareImage(sender: self)
    }
    
    @objc func deleteImage(){
        delegate?.deleteImage(sender: self)
    }
    
}

