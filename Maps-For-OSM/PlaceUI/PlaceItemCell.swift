/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol PlaceItemCellDelegate{
    func deletePlaceItem(item: PlaceItem)
    func viewPlaceItem(item: PlaceItem)
    func showItemOnMap(item: PlaceItem)
}

class PlaceItemCell: UITableViewCell{
    
    var cellBody = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        isUserInteractionEnabled = true
        backgroundColor = .clear
        shouldIndentWhileEditing = false
        cellBody.setBackground(.white).setRoundedBorders()
        contentView.addSubviewFilling(cellBody, insets: defaultInsets)
        accessoryType = .none
        updateCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(isEditing: Bool = false){
    }
    
}


