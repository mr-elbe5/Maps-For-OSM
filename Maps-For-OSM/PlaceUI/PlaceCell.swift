/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit


protocol PlaceCellDelegate{
    func viewPlace(place: Place)
    func showPlaceOnMap(place: Place)
}

class PlaceCell: TableViewCell{
    
    static let CELL_IDENT = "placeCell"
    
    var place : Place? = nil
    
    var delegate: PlaceCellDelegate? = nil
    
    override func updateIconView(isEditing: Bool){
        iconView.removeAllSubviews()
        if let place = place{
            var lastAnchor = iconView.trailingAnchor
            if isEditing{
                let selectedButton = UIButton().asIconButton(place.selected ? "checkmark.square" : "square", color: .label)
                selectedButton.addAction(UIAction(){ action in
                    place.selected = !place.selected
                    selectedButton.setImage(UIImage(systemName: place.selected ? "checkmark.square" : "square"), for: .normal)
                }, for: .touchDown)
                iconView.addSubviewWithAnchors(selectedButton, top: iconView.topAnchor, trailing: lastAnchor , bottom: iconView.bottomAnchor, insets: iconInsets)
                lastAnchor = selectedButton.leadingAnchor
            }
            
            let mapButton = UIButton().asIconButton("map", color: .label)
            mapButton.addAction(UIAction(){ action in
                self.delegate?.showPlaceOnMap(place: place)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(mapButton, top: iconView.topAnchor, trailing: lastAnchor, bottom: iconView.bottomAnchor, insets: iconInsets)
            
            let viewButton = UIButton().asIconButton("magnifyingglass", color: .label)
            viewButton.addAction(UIAction(){ action in
                self.delegate?.viewPlace(place: place)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(viewButton, top: iconView.topAnchor, leading: iconView.leadingAnchor, trailing: mapButton.leadingAnchor, bottom: iconView.bottomAnchor, insets: iconInsets)
        }
    }
    
    override func updateItemView(isEditing: Bool){
        itemView.removeAllSubviews()
        
        if let place = place{
            var header = UILabel(header: place.name)
            itemView.addSubviewWithAnchors(header, top: itemView.topAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: defaultInsets)
            
            let locationLabel = UILabel(text: place.address)
            locationLabel.textAlignment = .center
            itemView.addSubviewWithAnchors(locationLabel, top: header.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: defaultInsets)
            
            let coordinateLabel = UILabel(text: place.coordinate.asString)
            coordinateLabel.textAlignment = .center
            itemView.addSubviewWithAnchors(coordinateLabel, top: locationLabel.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: flatInsets)
            
            header = UILabel(text: "mediaCount".localize() + String(place.itemCount))
            itemView.addSubviewWithAnchors(header, top: coordinateLabel.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, bottom: itemView.bottomAnchor, insets: defaultInsets)
            
        }
        
    }
    
}


