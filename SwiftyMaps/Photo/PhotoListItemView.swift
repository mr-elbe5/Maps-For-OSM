/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

protocol PhotoListItemDelegate{
    func viewPhoto(sender: PhotoListItemView)
    func sharePhoto(sender: PhotoListItemView)
    func deletePhoto(sender: PhotoListItemView)
}

class PhotoListItemView : UIView{
    
    var photoData : PhotoData
    
    var delegate : PhotoListItemDelegate? = nil
    
    init(data: PhotoData){
        self.photoData = data
        super.init(frame: .zero)
        let deleteButton = UIButton().setIcon("xmark.circle")
        deleteButton.tintColor = UIColor.systemRed
        deleteButton.addTarget(self, action: #selector(deletePhoto), for: .touchDown)
        addSubviewWithAnchors(deleteButton, top: topAnchor, trailing: trailingAnchor, insets: flatInsets)
        let viewButton = UIButton().setIcon("magnifyingglass", color: .systemBlue)
        viewButton.addTarget(self, action: #selector(viewPhoto), for: .touchDown)
        addSubviewWithAnchors(viewButton, top: topAnchor, trailing: deleteButton.leadingAnchor, insets: flatInsets)
        let shareButton = UIButton().setIcon("square.and.arrow.up", color: .systemBlue)
        shareButton.addTarget(self, action: #selector(sharePhoto), for: .touchDown)
        addSubviewWithAnchors(shareButton, top: topAnchor, trailing: viewButton.leadingAnchor, insets: flatInsets)
        let imageView = UIImageView()
        imageView.setDefaults()
        imageView.setRoundedBorders()
        addSubviewWithAnchors(imageView, top: shareButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: UIEdgeInsets(top: 2, left: 0, bottom: defaultInset, right: 0))
        imageView.image = photoData.getImage()
        imageView.setAspectRatioConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func viewPhoto(){
        delegate?.viewPhoto(sender: self)
    }
    
    @objc func sharePhoto(){
        delegate?.sharePhoto(sender: self)
    }
    
    @objc func deletePhoto(){
        delegate?.deletePhoto(sender: self)
    }
    
}

