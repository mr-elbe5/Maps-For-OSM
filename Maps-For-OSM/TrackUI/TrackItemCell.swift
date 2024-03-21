/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol TrackItemCellDelegate{
    func deleteTrackItem(item: TrackItem)
    func viewTrackItem(item: TrackItem)
    func showItemOnMap(item: TrackItem)
}

class TrackItemCell: PlaceItemCell{

    static let CELL_IDENT = "trackCell"
    
    var trackItem : TrackItem? = nil {
        didSet {
            updateCell()
        }
    }
    
    var delegate: TrackItemCellDelegate? = nil
    
    override func updateIconView(isEditing: Bool){
        iconView.removeAllSubviews()
        if let item = trackItem{
            let deleteButton = UIButton().asIconButton("trash", color: .systemRed)
            deleteButton.addAction(UIAction(){ action in
                self.delegate?.deleteTrackItem(item: item)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(deleteButton, top: iconView.topAnchor, trailing: iconView.trailingAnchor, bottom: iconView.bottomAnchor, insets: defaultInsets)
            
            let mapButton = UIButton().asIconButton("map", color: .label)
            mapButton.addAction(UIAction(){ action in
                self.delegate?.showItemOnMap(item: item)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(mapButton, top: iconView.topAnchor, leading: iconView.leadingAnchor, trailing: deleteButton.leadingAnchor, bottom: iconView.bottomAnchor, insets: defaultInsets)
        }
    }
    
    override func updateTimeLabel(isEditing: Bool){
        timeLabel.text = trackItem?.creationDate.dateTimeString()
    }
    
    override func updateItemView(isEditing: Bool){
        itemView.removeAllSubviews()
        if let item = trackItem{
            let header = UILabel(header: "track".localize())
            itemView.addSubviewWithAnchors(header, top: itemView.topAnchor, insets: defaultInsets)
                .centerX(itemView.centerXAnchor)
            
            let nameLabel = UILabel(text: item.name)
            itemView.addSubviewWithAnchors(nameLabel, top: header.bottomAnchor, leading: itemView.leadingAnchor, insets: defaultInsets)
            
            let tp = item.trackpoints.isEmpty ? nil : item.trackpoints[0]
            let coordinateLabel = UILabel(text: tp?.coordinate.asString ?? "")
            itemView.addSubviewWithAnchors(coordinateLabel, top: nameLabel.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: flatInsets)
            
            let timeLabel = UILabel(text: "\(item.startTime.dateTimeString()) - \(item.endTime.dateTimeString())")
            itemView.addSubviewWithAnchors(timeLabel, top: coordinateLabel.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: flatInsets)
            
            let distanceLabel = UILabel(text: "\("distance".localize()): \(Int(item.distance))m")
            itemView.addSubviewWithAnchors(distanceLabel, top: timeLabel.bottomAnchor, leading: itemView.leadingAnchor, insets: flatInsets)
            
            let upDistanceLabel = UILabel(text: "\("upDistance".localize()): \(Int(item.upDistance))m")
            itemView.addSubviewWithAnchors(upDistanceLabel, top: distanceLabel.bottomAnchor, leading: itemView.leadingAnchor, insets: flatInsets)
            
            let downDistanceLabel = UILabel(text: "\("downDistance".localize()): \(Int(item.downDistance))m")
            itemView.addSubviewWithAnchors(downDistanceLabel, top: upDistanceLabel.bottomAnchor, leading: itemView.leadingAnchor, insets: flatInsets)
            
            let durationLabel = UILabel(text: "\("duration".localize()): \(item.duration.hmsString())")
            itemView.addSubviewWithAnchors(durationLabel, top: downDistanceLabel.bottomAnchor, leading: itemView.leadingAnchor, bottom: itemView.bottomAnchor, insets: UIEdgeInsets(top: 0, left: defaultInset, bottom: defaultInset, right: defaultInset))
        }
    }
    
}


