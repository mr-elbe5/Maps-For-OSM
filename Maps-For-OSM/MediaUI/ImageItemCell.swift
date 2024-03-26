/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol ImageItemCellDelegate: PlaceItemCellDelegate{
    func viewImageItem(item: ImageItem)
}

class ImageItemCell: PlaceItemCell{
    
    static let CELL_IDENT = "imageCell"
    
    var imageItem : ImageItem? = nil {
        didSet {
            updateCell()
            setSelected(imageItem?.selected ?? false, animated: false)
        }
    }
    
    var delegate: ImageItemCellDelegate? = nil
    
    override func updateIconView(isEditing: Bool){
        iconView.removeAllSubviews()
        var lastAnchor = iconView.trailingAnchor
        if let item = imageItem{
            if isEditing{
                let selectedButton = UIButton().asIconButton(item.selected ? "checkmark.square" : "square", color: .label)
                selectedButton.addAction(UIAction(){ action in
                    item.selected = !item.selected
                    selectedButton.setImage(UIImage(systemName: item.selected ? "checkmark.square" : "square"), for: .normal)
                }, for: .touchDown)
                iconView.addSubviewWithAnchors(selectedButton, top: iconView.topAnchor, trailing: lastAnchor , bottom: iconView.bottomAnchor, insets: iconInsets)
                lastAnchor = selectedButton.leadingAnchor
            }
            
            let mapButton = UIButton().asIconButton("map", color: .label)
            mapButton.addAction(UIAction(){ action in
                self.delegate?.showPlaceOnMap(place: item.place)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(mapButton, top: iconView.topAnchor, trailing: lastAnchor, bottom: iconView.bottomAnchor, insets: iconInsets)
            
            let viewButton = UIButton().asIconButton("magnifyingglass", color: .label)
            viewButton.addAction(UIAction(){ action in
                self.delegate?.viewImageItem(item: item)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(viewButton, top: iconView.topAnchor, leading: iconView.leadingAnchor, trailing: mapButton.leadingAnchor, bottom: iconView.bottomAnchor, insets: iconInsets)
        }
    }
    
    override func updateTimeLabel(isEditing: Bool){
        timeLabel.text = imageItem?.creationDate.dateTimeString()
    }
    
    override func updateItemView(isEditing: Bool){
        itemView.removeAllSubviews()
        if let item = imageItem{
            let imageView = UIImageView()
            imageView.setDefaults()
            imageView.setRoundedBorders()
            itemView.addSubviewWithAnchors(imageView, top: itemView.topAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: UIEdgeInsets(top: 2, left: 0, bottom: defaultInset, right: 0))
            imageView.image = item.getImage()
            imageView.setAspectRatioConstraint()
            if isEditing{
                let titleField = UITextField()
                titleField.setDefaults()
                titleField.text = item.title
                titleField.delegate = self
                itemView.addSubviewWithAnchors(titleField, top: imageView.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, bottom: itemView.bottomAnchor)
            }
            else{
                if !item.title.isEmpty{
                    let titleView = UILabel(text: item.title)
                    itemView.addSubviewWithAnchors(titleView, top: imageView.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, bottom: itemView.bottomAnchor, insets: smallInsets)
                }
                else{
                    imageView.bottom(itemView.bottomAnchor)
                }
            }
        }
    }
    
}

extension ImageItemCell: UITextFieldDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let item = imageItem{
            item.title = textField.text!
        }
    }
    
}


