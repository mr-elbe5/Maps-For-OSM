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
    
    override func updateCell(isEditing: Bool = false){
        cellBody.removeAllSubviews()
        if let imageItem = imageItem{
            let imageView = UIImageView()
            imageView.setDefaults()
            imageView.setRoundedBorders()
            cellBody.addSubviewWithAnchors(imageView, top: cellBody.topAnchor, leading: cellBody.leadingAnchor, trailing: cellBody.trailingAnchor, insets: UIEdgeInsets(top: 2, left: 0, bottom: defaultInset, right: 0))
            imageView.image = imageItem.getImage()
            imageView.setAspectRatioConstraint()
            
            if !imageItem.title.isEmpty{
                let titleView = UILabel(text: imageItem.title)
                titleView.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
                cellBody.addSubviewWithAnchors(titleView, top: cellBody.bottomAnchor, leading: cellBody.leadingAnchor, trailing: cellBody.trailingAnchor, bottom: cellBody.bottomAnchor)
            }
            else{
                imageView.bottom(cellBody.bottomAnchor)
            }
            
            let deleteButton = UIButton().asIconButton("trash", color: .systemRed)
            deleteButton.addAction(UIAction(){ action in
                self.delegate?.deleteImageItem(item: imageItem)
            }, for: .touchDown)
            cellBody.addSubviewWithAnchors(deleteButton, top: cellBody.topAnchor, trailing: cellBody.trailingAnchor, insets: defaultInsets)
            
            let viewButton = UIButton().asIconButton("magnifyingglass", color: .label)
            viewButton.addAction(UIAction(){ action in
                self.delegate?.viewImageItem(item: imageItem)
            }, for: .touchDown)
            cellBody.addSubviewWithAnchors(viewButton, top: cellBody.topAnchor, trailing: deleteButton.leadingAnchor, insets: defaultInsets)
            
        }
    }
    
}



