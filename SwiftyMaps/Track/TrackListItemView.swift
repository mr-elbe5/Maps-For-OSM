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
        let deleteButton = UIButton().setIcon("trash")
        deleteButton.tintColor = UIColor.systemRed
        deleteButton.addTarget(self, action: #selector(deleteTrack), for: .touchDown)
        addSubviewWithAnchors(deleteButton, top: topAnchor, trailing: trailingAnchor, insets: defaultInsets)
        let exportButton = UIButton().setIcon("square.and.arrow.up", color: .systemBlue)
        exportButton.addTarget(self, action: #selector(exportTrack), for: .touchDown)
        addSubviewWithAnchors(exportButton, top: topAnchor, trailing: deleteButton.leadingAnchor, insets: defaultInsets)
        let viewButton = UIButton().setIcon("magnifyingglass", color: .systemBlue)
        viewButton.addTarget(self, action: #selector(viewTrack), for: .touchDown)
        addSubviewWithAnchors(viewButton, top: topAnchor, trailing: exportButton.leadingAnchor, insets: defaultInsets)
        let showOnMapButton = UIButton().setIcon("map", color: .systemBlue)
        showOnMapButton.addTarget(self, action: #selector(showTrackOnMap), for: .touchDown)
        addSubviewWithAnchors(showOnMapButton, top: topAnchor, trailing: viewButton.leadingAnchor, insets: defaultInsets)
        let trackView = UIView()
        trackView.setGrayRoundedBorders()
        addSubviewWithAnchors(trackView, top: showOnMapButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: UIEdgeInsets(top: 2, left: defaultInset, bottom: defaultInset, right: defaultInset))
        let header = UILabel(header: trackData.name)
        trackView.addSubviewWithAnchors(header, top: trackView.topAnchor, leading: trackView.leadingAnchor, insets: defaultInsets)
        let tp = trackData.trackpoints.isEmpty ? nil : trackData.trackpoints[0]
        let coordinateLabel = UILabel(text: tp?.coordinateString ?? "")
        trackView.addSubviewWithAnchors(coordinateLabel, top: header.bottomAnchor, leading: trackView.leadingAnchor, trailing: trackView.trailingAnchor, insets: flatInsets)
        let timeLabel = UILabel(text: "\(trackData.startTime.dateTimeString()) - \(trackData.endTime.dateTimeString())")
        trackView.addSubviewWithAnchors(timeLabel, top: coordinateLabel.bottomAnchor, leading: trackView.leadingAnchor, trailing: trackView.trailingAnchor, insets: flatInsets)
        let distanceLabel = UILabel(text: "\("distance".localize()): \(Int(trackData.distance))m")
        trackView.addSubviewWithAnchors(distanceLabel, top: timeLabel.bottomAnchor, leading: trackView.leadingAnchor, insets: flatInsets)
        let upDistanceLabel = UILabel(text: "\("upDistance".localize()): \(Int(trackData.upDistance))m")
        trackView.addSubviewWithAnchors(upDistanceLabel, top: distanceLabel.bottomAnchor, leading: trackView.leadingAnchor, insets: flatInsets)
        let downDistanceLabel = UILabel(text: "\("downDistance".localize()): \(Int(trackData.downDistance))m")
        trackView.addSubviewWithAnchors(downDistanceLabel, top: upDistanceLabel.bottomAnchor, leading: trackView.leadingAnchor, insets: flatInsets)
        let durationLabel = UILabel(text: "\("duration".localize()): \(trackData.duration.hmsString())")
        trackView.addSubviewWithAnchors(durationLabel)
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
