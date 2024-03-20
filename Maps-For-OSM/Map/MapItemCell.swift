/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol MapItemCellDelegate{
    func deleteMapItem(item: MapItem)
    func viewMapItem(item: MapItem)
    func showItemOnMap(item: MapItem)
}

class MapItemCell: UITableViewCell{
    
    var mapItem : MapItem? = nil {
        didSet {
            updateCell()
        }
    }
    
    var delegate: MapItemCellDelegate? = nil
    
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
        cellBody.removeAllSubviews()
        if let item = mapItem{
            let deleteButton = UIButton().asIconButton("trash", color: .systemRed)
            deleteButton.addAction(UIAction(){ action in
                self.delegate?.deleteMapItem(item: item)
            }, for: .touchDown)
            cellBody.addSubviewWithAnchors(deleteButton, top: cellBody.topAnchor, trailing: cellBody.trailingAnchor, insets: defaultInsets)
            
            let viewButton = UIButton().asIconButton("magnifyingglass", color: .label)
            viewButton.addAction(UIAction(){ action in
                self.delegate?.viewMapItem(item: item)
            }, for: .touchDown)
            cellBody.addSubviewWithAnchors(viewButton, top: cellBody.topAnchor, trailing: deleteButton.leadingAnchor, insets: defaultInsets)
            
            let mapButton = UIButton().asIconButton("map", color: .label)
            mapButton.addAction(UIAction(){ action in
                self.delegate?.showItemOnMap(item: item)
            }, for: .touchDown)
            cellBody.addSubviewWithAnchors(mapButton, top: cellBody.topAnchor, trailing: viewButton.leadingAnchor, insets: defaultInsets)
            var nextAnchor = mapButton.bottomAnchor
            
            
        }
    }
    
}


