/*
 Maps For OSM
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
    
    var imageData : ImageData
    
    var delegate : ImageListItemDelegate? = nil
    
    init(data: ImageData){
        
        self.imageData = data
        super.init(frame: .zero)
        
        let buttonContainer = UIView()
        buttonContainer.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        buttonContainer.setRoundedBorders(radius: 5)
        
        let shareButton = UIButton().asIconButton("square.and.arrow.up", color: .label)
        shareButton.addAction(UIAction(){ action in
            self.delegate?.shareImage(sender: self)
        }, for: .touchDown)
        buttonContainer.addSubviewWithAnchors(shareButton, top: buttonContainer.topAnchor, leading: buttonContainer.leadingAnchor, bottom: buttonContainer.bottomAnchor, insets: halfFlatInsets)
        
        let viewButton = UIButton().asIconButton("magnifyingglass", color: .label)
        viewButton.addAction(UIAction(){ action in
            self.delegate?.viewImage(sender: self)
        }, for: .touchDown)
        buttonContainer.addSubviewWithAnchors(viewButton, top: buttonContainer.topAnchor, leading: shareButton.trailingAnchor, bottom: buttonContainer.bottomAnchor, insets: halfFlatInsets)
        
        let deleteButton = UIButton().asIconButton("xmark.circle", color: .systemRed)
        deleteButton.addAction(UIAction(){ action in
            self.delegate?.deleteImage(sender: self)
        }, for: .touchDown)
        buttonContainer.addSubviewWithAnchors(deleteButton, top: buttonContainer.topAnchor, leading: viewButton.trailingAnchor, trailing: buttonContainer.trailingAnchor, bottom: buttonContainer.bottomAnchor, insets: halfFlatInsets)
        
        let imageView = UIImageView()
        imageView.setDefaults()
        imageView.setRoundedBorders()
        addSubviewWithAnchors(imageView, top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: UIEdgeInsets(top: 2, left: 0, bottom: defaultInset, right: 0))
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
    
}

