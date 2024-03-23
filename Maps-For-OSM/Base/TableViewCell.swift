/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class TableViewCell: UITableViewCell{
    
    var iconView = UIView()
    var itemView = UIView()
    
    var cellBody = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        isUserInteractionEnabled = true
        backgroundColor = .clear
        shouldIndentWhileEditing = true
        selectionStyle = .blue
        cellBody.setBackground(.white).setRoundedBorders()
        contentView.addSubviewFilling(cellBody, insets: defaultInsets)
        setupCellBody()
        accessoryType = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCellBody(){
        cellBody.addSubviewFilling(itemView, insets: .zero)
        iconView.setBackground(UIColor(white: 1.0, alpha: 0.3)).setRoundedEdges()
        cellBody.addSubviewWithAnchors(iconView, top: cellBody.topAnchor, trailing: cellBody.trailingAnchor, insets: smallInsets)
    }
    
    func updateCell(isEditing: Bool = false){
        updateItemView(isEditing: isEditing)
        updateIconView(isEditing: isEditing)
    }
    
    func updateIconView(isEditing: Bool){
    }
    
    func updateItemView(isEditing: Bool){
    }
    
}


