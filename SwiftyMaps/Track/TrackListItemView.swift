/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

protocol TrackListItemDelegate{
    func viewTrack(sender: TrackListItemView)
    func showTrackOnMap(sender: TrackListItemView)
    func exportTrack(sender: TrackListItemView)
    func deleteTrack(sender: TrackListItemView)
}

class TrackListItemView : UIView{
    
    var trackData : Track
    
    var delegate : TrackListItemDelegate? = nil
    
    init(data: Track){
        self.trackData = data
        super.init(frame: .zero)
        let deleteButton = IconButton(icon: "xmark.circle")
        deleteButton.tintColor = UIColor.systemRed
        deleteButton.addTarget(self, action: #selector(deleteTrack), for: .touchDown)
        addSubview(deleteButton)
        deleteButton.setAnchors(top: topAnchor, trailing: trailingAnchor, insets: defaultInsets)
        let exportButton = IconButton(icon: "square.and.arrow.up", tintColor: .systemBlue)
        exportButton.addTarget(self, action: #selector(exportTrack), for: .touchDown)
        addSubview(exportButton)
        exportButton.setAnchors(top: topAnchor, trailing: deleteButton.leadingAnchor, insets: defaultInsets)
        let viewButton = IconButton(icon: "magnifyingglass", tintColor: .systemBlue)
        viewButton.addTarget(self, action: #selector(viewTrack), for: .touchDown)
        addSubview(viewButton)
        viewButton.setAnchors(top: topAnchor, trailing: exportButton.leadingAnchor, insets: defaultInsets)
        let showOnMapButton = IconButton(icon: "map", tintColor: .systemBlue)
        showOnMapButton.addTarget(self, action: #selector(showTrackOnMap), for: .touchDown)
        addSubview(showOnMapButton)
        showOnMapButton.setAnchors(top: topAnchor, trailing: viewButton.leadingAnchor, insets: defaultInsets)
        let trackView = UIView()
        trackView.setGrayRoundedBorders()
        addSubview(trackView)
        trackView.setAnchors(top: showOnMapButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: UIEdgeInsets(top: 2, left: defaultInset, bottom: defaultInset, right: defaultInset))
        let header = UILabel(header: trackData.name)
        trackView.addSubview(header)
        header.setAnchors(top: trackView.topAnchor, leading: trackView.leadingAnchor, insets: defaultInsets)
        let tp = trackData.trackpoints.isEmpty ? nil : trackData.trackpoints[0]
        let coordinateLabel = UILabel(text: tp?.coordinateString ?? "")
        trackView.addSubview(coordinateLabel)
        coordinateLabel.setAnchors(top: header.bottomAnchor, leading: trackView.leadingAnchor, trailing: trackView.trailingAnchor, insets: flatInsets)
        let timeLabel = UILabel(text: "\(trackData.startTime.dateTimeString()) - \(trackData.endTime.dateTimeString())")
        trackView.addSubview(timeLabel)
        timeLabel.setAnchors(top: coordinateLabel.bottomAnchor, leading: trackView.leadingAnchor, trailing: trackView.trailingAnchor, insets: flatInsets)
        let distanceLabel = UILabel(text: "\("distance".localize()): \(Int(trackData.distance))m")
        trackView.addSubview(distanceLabel)
        distanceLabel.setAnchors(top: timeLabel.bottomAnchor, leading: trackView.leadingAnchor, insets: flatInsets)
        let upDistanceLabel = UILabel(text: "\("upDistance".localize()): \(Int(trackData.upDistance))m")
        trackView.addSubview(upDistanceLabel)
        upDistanceLabel.setAnchors(top: distanceLabel.bottomAnchor, leading: trackView.leadingAnchor, insets: flatInsets)
        let downDistanceLabel = UILabel(text: "\("downDistance".localize()): \(Int(trackData.downDistance))m")
        trackView.addSubview(downDistanceLabel)
        downDistanceLabel.setAnchors(top: upDistanceLabel.bottomAnchor, leading: trackView.leadingAnchor, insets: flatInsets)
        let durationLabel = UILabel(text: "\("duration".localize()): \(trackData.duration.hmsString())")
        trackView.addSubview(durationLabel)
        durationLabel.setAnchors(top: downDistanceLabel.bottomAnchor, leading: trackView.leadingAnchor, bottom: trackView.bottomAnchor, insets: UIEdgeInsets(top: 0, left: defaultInset, bottom: defaultInset, right: defaultInset))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func viewTrack(){
        delegate?.viewTrack(sender: self)
    }
    
    @objc func showTrackOnMap(){
        delegate?.showTrackOnMap(sender: self)
    }
    
    @objc func exportTrack(){
        delegate?.exportTrack(sender: self)
    }
    
    @objc func deleteTrack(){
        delegate?.deleteTrack(sender: self)
    }
    
}
