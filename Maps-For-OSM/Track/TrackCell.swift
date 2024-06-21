/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import E5Data
import E5IOSUI
import E5MapData

public protocol TrackDelegate{
    func editTrackItem(item: TrackItem)
    func showTrackItemOnMap(item: TrackItem)
}

class TrackCell: PlaceItemCell{

    static let CELL_IDENT = "trackCell"
    
    var track : TrackItem? = nil
    
    var placeDelegate: PlaceDelegate? = nil
    var trackDelegate: TrackDelegate? = nil
    
    override func updateIconView(isEditing: Bool){
        iconView.removeAllSubviews()
        if let track = track{
            
            let selectedButton = UIButton().asIconButton(track.selected ? "checkmark.square" : "square", color: .label)
            selectedButton.addAction(UIAction(){ action in
                track.selected = !track.selected
                selectedButton.setImage(UIImage(systemName: track.selected ? "checkmark.square" : "square"), for: .normal)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(selectedButton, top: iconView.topAnchor, trailing: iconView.trailingAnchor , bottom: iconView.bottomAnchor, insets: iconInsets)
            
            let mapButton = UIButton().asIconButton("map", color: .label)
            mapButton.addAction(UIAction(){ action in
                self.trackDelegate?.showTrackItemOnMap(item: track)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(mapButton, top: iconView.topAnchor, trailing: selectedButton.leadingAnchor, bottom: iconView.bottomAnchor, insets: iconInsets)
            
            let editButton = UIButton().asIconButton("pencil", color: .label)
            editButton.addAction(UIAction(){ action in
                self.trackDelegate?.editTrackItem(item: track)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(editButton, top: iconView.topAnchor, leading: iconView.leadingAnchor, trailing: mapButton.leadingAnchor, bottom: iconView.bottomAnchor, insets: iconInsets)
        }
    }
    
    override func updateTimeLabel(isEditing: Bool){
        timeLabel.text = track?.creationDate.dateTimeString()
    }
    
    override func updateItemView(isEditing: Bool){
        itemView.removeAllSubviews()
        if let item = track{
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

extension TrackCell: UITextFieldDelegate{
    
    func textFieldDidChange(_ textField: UITextView) {
        if let track = track{
            track.name = textField.text
        }
    }
    
}