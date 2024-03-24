/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol TrackItemCellDelegate{
    func viewTrackItem(item: TrackItem)
    func showTrackItemOnMap(item: TrackItem)
}

class TrackItemCell: PlaceItemCell{

    static let CELL_IDENT = "trackCell"
    
    var trackItem : TrackItem? = nil
    
    var delegate: TrackItemCellDelegate? = nil
    
    override func updateIconView(isEditing: Bool){
        iconView.removeAllSubviews()
        if let item = trackItem{
            var lastAnchor = iconView.trailingAnchor
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
                self.delegate?.showTrackItemOnMap(item: item)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(mapButton, top: iconView.topAnchor, trailing: lastAnchor, bottom: iconView.bottomAnchor, insets: iconInsets)
            
            let viewButton = UIButton().asIconButton("magnifyingglass", color: .label)
            viewButton.addAction(UIAction(){ action in
                self.delegate?.viewTrackItem(item: item)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(viewButton, top: iconView.topAnchor, leading: iconView.leadingAnchor, trailing: mapButton.leadingAnchor, bottom: iconView.bottomAnchor, insets: iconInsets)
        }
    }
    
    override func updateTimeLabel(isEditing: Bool){
        timeLabel.text = trackItem?.creationDate.dateTimeString()
    }
    
    override func updateItemView(isEditing: Bool){
        itemView.removeAllSubviews()
        if let item = trackItem{
            let header = UILabel(header: "track".localize())
            itemView.addSubviewWithAnchors(header, top: itemView.topAnchor, insets: UIEdgeInsets(top: 40, left: defaultInset, bottom: defaultInset, right: defaultInset))
                .centerX(itemView.centerXAnchor)
            
            let nameLabel = UILabel(text: item.name)
            nameLabel.textAlignment = .center
            itemView.addSubviewWithAnchors(nameLabel, top: header.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: defaultInsets)
            
            let tp = item.trackpoints.isEmpty ? nil : item.trackpoints[0]
            let startLabel = UILabel(text: "\("start".localize()): \(tp?.coordinate.asString ?? ""), \(item.startTime.dateTimeString())")
            itemView.addSubviewWithAnchors(startLabel, top: nameLabel.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: defaultInsets)
            
            let endLabel = UILabel(text: "\("end".localize()): \(item.endTime.dateTimeString())")
            itemView.addSubviewWithAnchors(endLabel, top: startLabel.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: flatInsets)
            
            let distanceLabel = UILabel(text: "\("distance".localize()): \(Int(item.distance))m")
            itemView.addSubviewWithAnchors(distanceLabel, top: endLabel.bottomAnchor, leading: itemView.leadingAnchor, insets: flatInsets)
            
            let upDistanceLabel = UILabel(text: "\("upDistance".localize()): \(Int(item.upDistance))m")
            itemView.addSubviewWithAnchors(upDistanceLabel, top: distanceLabel.bottomAnchor, leading: itemView.leadingAnchor, insets: flatInsets)
            
            let downDistanceLabel = UILabel(text: "\("downDistance".localize()): \(Int(item.downDistance))m")
            itemView.addSubviewWithAnchors(downDistanceLabel, top: upDistanceLabel.bottomAnchor, leading: itemView.leadingAnchor, insets: flatInsets)
            
            let durationLabel = UILabel(text: "\("duration".localize()): \(item.duration.hmsString())")
            itemView.addSubviewWithAnchors(durationLabel, top: downDistanceLabel.bottomAnchor, leading: itemView.leadingAnchor, bottom: itemView.bottomAnchor, insets: UIEdgeInsets(top: 0, left: defaultInset, bottom: defaultInset, right: defaultInset))
        }
    }
    
}


