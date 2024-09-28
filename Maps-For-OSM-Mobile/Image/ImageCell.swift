/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import E5Data
import E5IOSUI

import CoreLocation

public protocol ImageCellDelegate {
    func viewImage(image: ImageItem)
    func showLocationOnMap(coordinate: CLLocationCoordinate2D)
}

class ImageCell: LocationItemCell{
    
    static let CELL_IDENT = "imageCell"
    
    var image : ImageItem? = nil {
        didSet {
            updateCell()
            setSelected(image?.selected ?? false, animated: false)
        }
    }
    
    var delegate: ImageCellDelegate? = nil
    
    var useShortDate = false
    
    override func updateIconView(){
        iconView.removeAllSubviews()
        if let image = image{
            
            let selectedButton = UIButton().asIconButton(image.selected ? "checkmark.square" : "square", color: .label)
            selectedButton.addAction(UIAction(){ action in
                image.selected = !image.selected
                selectedButton.setImage(UIImage(systemName: image.selected ? "checkmark.square" : "square"), for: .normal)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(selectedButton, top: iconView.topAnchor, trailing: iconView.trailingAnchor , bottom: iconView.bottomAnchor, insets: iconInsets)
            
            let viewButton = UIButton().asIconButton("magnifyingglass", color: .label)
            viewButton.addAction(UIAction(){ action in
                self.delegate?.viewImage(image: image)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(viewButton, top: iconView.topAnchor, leading: iconView.leadingAnchor, trailing: selectedButton.leadingAnchor, bottom: iconView.bottomAnchor, insets: iconInsets)
        }
    }
    
    override func updateTimeLabel(){
        timeLabel.text = useShortDate ? image?.creationDate.timeString() : image?.creationDate.dateTimeString()
    }
    
    override func updateItemView(){
        itemView.removeAllSubviews()
        if let image = image{
            let imageView = UIImageView()
            imageView.withDefaults()
            imageView.setRoundedBorders()
            itemView.addSubviewWithAnchors(imageView, top: iconView.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: UIEdgeInsets(top: 2, left: 0, bottom: defaultInset, right: 0))
            imageView.image = image.getImage()
            imageView.setAspectRatioConstraint()
            if !image.comment.isEmpty{
                let commentView = UILabel(text: image.comment)
                itemView.addSubviewWithAnchors(commentView, top: imageView.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, bottom: itemView.bottomAnchor, insets: smallInsets)
            }
            else{
                imageView.bottom(itemView.bottomAnchor)
            }
        }
    }
    
}

extension ImageCell: UITextFieldDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let item = image{
            item.comment = textField.text!
        }
    }
    
}



