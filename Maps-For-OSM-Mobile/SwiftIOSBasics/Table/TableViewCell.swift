/*
 E5IOSUI
 Basic classes and extensions for reuse
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class TableViewCell: UITableViewCell{
    
    var iconView = UIView()
    var itemView = UIView()
    
    var cellBody = UIView()
    
    var iconInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        isUserInteractionEnabled = true
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        cellBody.backgroundColor = .tertiarySystemBackground
        contentView.addSubviewFilling(cellBody, insets: defaultInsets)
        setupCellBody()
        accessoryType = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCellBody(){
        cellBody.setRoundedBorders()
        cellBody.addSubviewWithAnchors(iconView, top: cellBody.topAnchor, trailing: cellBody.trailingAnchor, insets: smallInsets)
        cellBody.addSubviewWithAnchors(itemView, top: iconView.bottomAnchor, leading: cellBody.leadingAnchor, trailing: cellBody.trailingAnchor, bottom: cellBody.bottomAnchor, insets: .zero)
    }
    
    func updateCell(){
        updateItemView()
        updateIconView()
    }
    
    func updateIconView(){
    }
    
    func updateItemView(){
    }
    
}


