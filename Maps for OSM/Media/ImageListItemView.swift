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
        
        let deleteButton = UIButton().asIconButton("xmark.circle")
        deleteButton.tintColor = UIColor.systemRed
        deleteButton.addTarget(self, action: #selector(deleteImage), for: .touchDown)
        addSubviewWithAnchors(deleteButton, top: topAnchor, trailing: trailingAnchor, insets: flatInsets)
        
        let viewButton = UIButton().asIconButton("magnifyingglass", color: .systemBlue)
        viewButton.addTarget(self, action: #selector(viewImage), for: .touchDown)
        addSubviewWithAnchors(viewButton, top: topAnchor, trailing: deleteButton.leadingAnchor, insets: flatInsets)
        
        let shareButton = UIButton().asIconButton("square.and.arrow.up", color: .systemBlue)
        shareButton.addTarget(self, action: #selector(shareImage), for: .touchDown)
        addSubviewWithAnchors(shareButton, top: topAnchor, trailing: viewButton.leadingAnchor, insets: flatInsets)
        
        let imageView = UIImageView()
        imageView.setDefaults()
        imageView.setRoundedBorders()
        addSubviewWithAnchors(imageView, top: shareButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: UIEdgeInsets(top: 2, left: 0, bottom: defaultInset, right: 0))
        imageView.image = imageData.getImage()
        imageView.setAspectRatioConstraint()
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

