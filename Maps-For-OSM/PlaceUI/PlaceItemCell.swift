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
    var dateTimeView = UIView()
    var iconView = UIView()
    var timeLabel = UILabel(text: Date().dateTimeString())
    var itemView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        isUserInteractionEnabled = true
        backgroundColor = .clear
        shouldIndentWhileEditing = true
        selectionStyle = .blue
        cellBody.setBackground(.white).setRoundedBorders()
        contentView.addSubviewFilling(cellBody, insets: defaultInsets)
        cellBody.addSubviewFilling(itemView, insets: .zero)
        dateTimeView.setBackground(UIColor(white: 1.0, alpha: 0.3)).setRoundedEdges()
        cellBody.addSubviewWithAnchors(dateTimeView, top: cellBody.topAnchor, leading: cellBody.leadingAnchor, insets: smallInsets)
        dateTimeView.addSubviewFilling(timeLabel, insets: smallInsets)
        iconView.setBackground(UIColor(white: 1.0, alpha: 0.3)).setRoundedEdges()
        cellBody.addSubviewWithAnchors(iconView, top: cellBody.topAnchor, trailing: cellBody.trailingAnchor, insets: smallInsets)
        accessoryType = .none
        updateCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(isEditing: Bool = false){
        updateItemView(isEditing: isEditing)
        updateTimeLabel(isEditing: isEditing)
        updateIconView(isEditing: isEditing)
    }
    
    func updateIconView(isEditing: Bool){
    }
    
    func updateTimeLabel(isEditing: Bool){
    }
    
    func updateItemView(isEditing: Bool){
    }
    
}


