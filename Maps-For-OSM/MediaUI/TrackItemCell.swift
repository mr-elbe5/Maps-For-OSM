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
    
    override func updateCell(isEditing: Bool = false){
        cellBody.removeAllSubviews()
        if let item = trackItem{
            let header = UILabel(header: item.name)
            cellBody.addSubviewWithAnchors(header, top: cellBody.topAnchor, leading: cellBody.leadingAnchor, insets: defaultInsets)
            
            let tp = item.trackpoints.isEmpty ? nil : item.trackpoints[0]
            let coordinateLabel = UILabel(text: tp?.coordinate.asString ?? "")
            cellBody.addSubviewWithAnchors(coordinateLabel, top: header.bottomAnchor, leading: cellBody.leadingAnchor, trailing: cellBody.trailingAnchor, insets: flatInsets)
            
            let timeLabel = UILabel(text: "\(item.startTime.dateTimeString()) - \(item.endTime.dateTimeString())")
            cellBody.addSubviewWithAnchors(timeLabel, top: coordinateLabel.bottomAnchor, leading: cellBody.leadingAnchor, trailing: cellBody.trailingAnchor, insets: flatInsets)
            
            let distanceLabel = UILabel(text: "\("distance".localize()): \(Int(item.distance))m")
            cellBody.addSubviewWithAnchors(distanceLabel, top: timeLabel.bottomAnchor, leading: cellBody.leadingAnchor, insets: flatInsets)
            
            let upDistanceLabel = UILabel(text: "\("upDistance".localize()): \(Int(item.upDistance))m")
            cellBody.addSubviewWithAnchors(upDistanceLabel, top: distanceLabel.bottomAnchor, leading: cellBody.leadingAnchor, insets: flatInsets)
            
            let downDistanceLabel = UILabel(text: "\("downDistance".localize()): \(Int(item.downDistance))m")
            cellBody.addSubviewWithAnchors(downDistanceLabel, top: upDistanceLabel.bottomAnchor, leading: cellBody.leadingAnchor, insets: flatInsets)
            
            let durationLabel = UILabel(text: "\("duration".localize()): \(item.duration.hmsString())")
            cellBody.addSubviewWithAnchors(durationLabel, top: downDistanceLabel.bottomAnchor, leading: cellBody.leadingAnchor, bottom: cellBody.bottomAnchor, insets: UIEdgeInsets(top: 0, left: defaultInset, bottom: defaultInset, right: defaultInset))
            
            let deleteButton = UIButton().asIconButton("trash", color: .systemRed)
            deleteButton.addAction(UIAction(){ action in
                self.delegate?.deleteTrackItem(item: item)
            }, for: .touchDown)
            cellBody.addSubviewWithAnchors(deleteButton, top: cellBody.topAnchor, trailing: cellBody.trailingAnchor, insets: defaultInsets)
            
            let mapButton = UIButton().asIconButton("map", color: .label)
            mapButton.addAction(UIAction(){ action in
                self.delegate?.showItemOnMap(item: item)
            }, for: .touchDown)
            cellBody.addSubviewWithAnchors(mapButton, top: cellBody.topAnchor, trailing: deleteButton.leadingAnchor, insets: defaultInsets)
            
        }
    }
    
}


