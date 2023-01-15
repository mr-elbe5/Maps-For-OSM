/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol TrackCellDelegate{
    func showTrackOnMap(track: Track)
    func viewTrackDetails(track: Track)
    func exportTrack(track: Track)
    func deleteTrack(track: Track, approved: Bool)
}

class TrackCell: UITableViewCell{
    
    var track : Track? = nil {
        didSet {
            updateCell()
        }
    }
    
    //TrackListViewController
    var delegate: TrackCellDelegate? = nil
    
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
        if let track = track{
            
            let deleteButton = UIButton().asIconButton("trash")
            deleteButton.tintColor = UIColor.systemRed
            deleteButton.addTarget(self, action: #selector(deleteTrack), for: .touchDown)
            cellBody.addSubviewWithAnchors(deleteButton, top: cellBody.topAnchor, trailing: cellBody.trailingAnchor, insets: defaultInsets)
            
            let exportButton = UIButton().asIconButton("square.and.arrow.up", color: .systemBlue)
            exportButton.addTarget(self, action: #selector(exportTrack), for: .touchDown)
            cellBody.addSubviewWithAnchors(exportButton, top: cellBody.topAnchor, trailing: deleteButton.leadingAnchor, insets: defaultInsets)
            
            let viewButton = UIButton().asIconButton("magnifyingglass", color: .systemBlue)
            viewButton.addTarget(self, action: #selector(viewTrack), for: .touchDown)
            cellBody.addSubviewWithAnchors(viewButton, top: cellBody.topAnchor, trailing: exportButton.leadingAnchor, insets: defaultInsets)
            
            let showOnMapButton = UIButton().asIconButton("map", color: .systemBlue)
            showOnMapButton.addTarget(self, action: #selector(showTrackOnMap), for: .touchDown)
            cellBody.addSubviewWithAnchors(showOnMapButton, top: cellBody.topAnchor, trailing: viewButton.leadingAnchor, insets: defaultInsets)
            
            let header = UILabel(header: track.name)
            cellBody.addSubviewWithAnchors(header, top: showOnMapButton.bottomAnchor, leading: cellBody.leadingAnchor, insets: defaultInsets)
            
            let tp = track.trackpoints.isEmpty ? nil : track.trackpoints[0]
            let coordinateLabel = UILabel(text: tp?.coordinateString ?? "")
            cellBody.addSubviewWithAnchors(coordinateLabel, top: header.bottomAnchor, leading: cellBody.leadingAnchor, trailing: cellBody.trailingAnchor, insets: flatInsets)
            
            let timeLabel = UILabel(text: "\(track.startTime.dateTimeString()) - \(track.endTime.dateTimeString())")
            cellBody.addSubviewWithAnchors(timeLabel, top: coordinateLabel.bottomAnchor, leading: cellBody.leadingAnchor, trailing: cellBody.trailingAnchor, insets: flatInsets)
            
            let distanceLabel = UILabel(text: "\("distance".localize()): \(Int(track.distance))m")
            cellBody.addSubviewWithAnchors(distanceLabel, top: timeLabel.bottomAnchor, leading: cellBody.leadingAnchor, insets: flatInsets)
            
            let upDistanceLabel = UILabel(text: "\("upDistance".localize()): \(Int(track.upDistance))m")
            cellBody.addSubviewWithAnchors(upDistanceLabel, top: distanceLabel.bottomAnchor, leading: cellBody.leadingAnchor, insets: flatInsets)
            
            let downDistanceLabel = UILabel(text: "\("downDistance".localize()): \(Int(track.downDistance))m")
            cellBody.addSubviewWithAnchors(downDistanceLabel, top: upDistanceLabel.bottomAnchor, leading: cellBody.leadingAnchor, insets: flatInsets)
            
            let durationLabel = UILabel(text: "\("duration".localize()): \(track.duration.hmsString())")
            cellBody.addSubviewWithAnchors(durationLabel, top: downDistanceLabel.bottomAnchor, leading: cellBody.leadingAnchor, bottom: cellBody.bottomAnchor, insets: UIEdgeInsets(top: 0, left: defaultInset, bottom: defaultInset, right: defaultInset))
            
        }
    }
    
    @objc func viewTrack() {
        if let track = track{
            self.delegate?.viewTrackDetails(track: track)
        }
    }
    
    @objc func showTrackOnMap() {
        if let track = track{
            self.delegate?.showTrackOnMap(track: track)
        }
    }
    
    @objc func exportTrack() {
        if let track = track{
            self.delegate?.exportTrack(track: track)
        }
    }
    
    @objc func deleteTrack() {
        if let track = track{
            self.delegate?.deleteTrack(track: track, approved: false)
        }
    }
    
}


