/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol ImageItemCellDelegate{
    func deleteImageItem(item: ImageItem)
    func viewImageItem(item: ImageItem)
}

class ImageItemCell: PlaceItemCell{
    
    static let CELL_IDENT = "imageCell"
    
    var imageItem : ImageItem? = nil {
        didSet {
            updateCell()
        }
    }
    
    var delegate: ImageItemCellDelegate? = nil
    
    override func updateIconView(isEditing: Bool){
        iconView.removeAllSubviews()
        if let imageItem = imageItem{
            let deleteButton = UIButton().asIconButton("trash", color: .systemRed)
            deleteButton.addAction(UIAction(){ action in
                self.delegate?.deleteImageItem(item: imageItem)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(deleteButton, top: iconView.topAnchor, trailing: iconView.trailingAnchor, bottom: iconView.bottomAnchor, insets: defaultInsets)
            
            let viewButton = UIButton().asIconButton("magnifyingglass", color: .label)
            viewButton.addAction(UIAction(){ action in
                self.delegate?.viewImageItem(item: imageItem)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(viewButton, top: iconView.topAnchor, leading: iconView.leadingAnchor, trailing: deleteButton.leadingAnchor, bottom: iconView.bottomAnchor, insets: defaultInsets)
        }
    }
    
    override func updateTimeLabel(isEditing: Bool){
        timeLabel.text = imageItem?.creationDate.dateTimeString()
    }
    
    override func updateItemView(isEditing: Bool){
        itemView.removeAllSubviews()
        if let imageItem = imageItem{
            let imageView = UIImageView()
            imageView.setDefaults()
            imageView.setRoundedBorders()
            itemView.addSubviewWithAnchors(imageView, top: itemView.topAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: UIEdgeInsets(top: 2, left: 0, bottom: defaultInset, right: 0))
            imageView.image = imageItem.getImage()
            imageView.setAspectRatioConstraint()
            
            if !imageItem.title.isEmpty{
                let titleView = UILabel(text: imageItem.title)
                titleView.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
                itemView.addSubviewWithAnchors(titleView, top: itemView.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, bottom: itemView.bottomAnchor)
            }
            else{
                imageView.bottom(itemView.bottomAnchor)
            }
        }
    }
    
}



