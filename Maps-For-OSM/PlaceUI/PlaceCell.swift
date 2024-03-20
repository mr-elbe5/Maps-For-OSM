/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit


protocol PlaceCellDelegate{
    func deletePlaceFromCell(place: Place)
    func viewPlace(place: Place)
    func showPlaceOnMap(place: Place)
}

class PlaceCell: UITableViewCell{
    
    static let CELL_IDENT = "placeCell"
    
    var place : Place? = nil {
        didSet {
            updateCell()
        }
    }
    
    var delegate: PlaceCellDelegate? = nil
    
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
        if let place = place{
            let deleteButton = UIButton().asIconButton("trash", color: .systemRed)
            deleteButton.addAction(UIAction(){ action in
                self.delegate?.deletePlaceFromCell(place: place)
            }, for: .touchDown)
            cellBody.addSubviewWithAnchors(deleteButton, top: cellBody.topAnchor, trailing: cellBody.trailingAnchor, insets: defaultInsets)
            
            let viewButton = UIButton().asIconButton("magnifyingglass", color: .label)
            viewButton.addAction(UIAction(){ action in
                self.delegate?.viewPlace(place: place)
            }, for: .touchDown)
            cellBody.addSubviewWithAnchors(viewButton, top: cellBody.topAnchor, trailing: deleteButton.leadingAnchor, insets: defaultInsets)
            
            let mapButton = UIButton().asIconButton("map", color: .label)
            mapButton.addAction(UIAction(){ action in
                self.delegate?.showPlaceOnMap(place: place)
            }, for: .touchDown)
            cellBody.addSubviewWithAnchors(mapButton, top: cellBody.topAnchor, trailing: viewButton.leadingAnchor, insets: defaultInsets)
            var nextAnchor = mapButton.bottomAnchor
            
            var label = UILabel(text: place.address)
            cellBody.addSubviewWithAnchors(label, top: nextAnchor, leading: cellBody.leadingAnchor, trailing: cellBody.trailingAnchor, insets: defaultInsets)
            nextAnchor = label.bottomAnchor
            
            label = UILabel(text: place.note)
            cellBody.addSubviewWithAnchors(label, top: nextAnchor, leading: cellBody.leadingAnchor, trailing: cellBody.trailingAnchor, insets: defaultInsets)
            nextAnchor = label.bottomAnchor
            
            if !place.note.isEmpty{
                label = UILabel(text: place.note)
                cellBody.addSubviewWithAnchors(label, top: nextAnchor, leading: cellBody.leadingAnchor, trailing: cellBody.trailingAnchor, insets: defaultInsets)
                nextAnchor = label.bottomAnchor
            }
            
            label = UILabel(text: "mediaCount".localize() + String(place.items.count))
            cellBody.addSubviewWithAnchors(label, top: nextAnchor, leading: cellBody.leadingAnchor, trailing: cellBody.trailingAnchor, bottom: cellBody.bottomAnchor, insets: defaultInsets)
            
        }
    }
    
}


