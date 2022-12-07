/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import UniformTypeIdentifiers
import CoreLocation

protocol TrackDetailDelegate{
    func showTrackOnMap(track: Track)
}

protocol ActiveTrackDelegate{
    func cancelActiveTrack()
    func saveActiveTrack()
}

class TrackDetailViewController: PopupScrollViewController{
    
    var track: Track? = nil
    
    var isActiveTrack : Bool{
        track != nil && track == TrackRecorder.track
    }
    
    let mapButton = UIButton().asIconButton("map", color: .white)
    let deleteButton = UIButton().asIconButton("trash", color: .white)
    
    // MainViewController
    var delegate : TrackDetailDelegate? = nil
    var activeDelegate : ActiveTrackDelegate? = nil
    
    override func loadView() {
        title = "track".localize()
        super.loadView()
        scrollView.setupVertical()
        setupContent()
        setupKeyboard()
    }
    
    override func setupHeaderView(){
        super.setupHeaderView()
        
        headerView.addSubviewWithAnchors(mapButton, top: headerView.topAnchor, leading: headerView.leadingAnchor, bottom: headerView.bottomAnchor, insets: wideInsets)
        mapButton.addTarget(self, action: #selector(showTrackOnMap), for: .touchDown)
    }
    
    func setupContent() {
        if let track = track, !track.trackpoints.isEmpty {
            
            var header = UILabel(header: "startLocation".localize())
            contentView.addSubviewWithAnchors(header, top: contentView.topAnchor, leading: contentView.leadingAnchor,insets: defaultInsets)
            
            let coordinateLabel = UILabel(text: track.trackpoints[0].coordinateString)
            contentView.addSubviewWithAnchors(coordinateLabel, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor,insets: flatInsets)
            
            let timeLabel = UILabel(text: "\(track.startTime.dateTimeString()) - \(track.endTime.dateTimeString())")
            contentView.addSubviewWithAnchors(timeLabel, top: coordinateLabel.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor,insets: flatInsets)
            
            header = UILabel(header: "name".localize())
            contentView.addSubviewWithAnchors(header, top: timeLabel.bottomAnchor, leading: contentView.leadingAnchor,insets: defaultInsets)
            
            let nameLabel = UILabel(text: track.name)
            contentView.addSubviewWithAnchors(nameLabel, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor,insets: flatInsets)
            
            header = UILabel(header: "distances".localize())
            contentView.addSubviewWithAnchors(header, top: nameLabel.bottomAnchor, leading: contentView.leadingAnchor,insets: defaultInsets)
            
            let distanceLabel = UILabel(text: "\("distance".localize()): \(Int(track.distance))m")
            contentView.addSubviewWithAnchors(distanceLabel, top: header.bottomAnchor, leading: contentView.leadingAnchor,insets: flatInsets)
            
            let upDistanceLabel = UILabel(text: "\("upDistance".localize()): \(Int(track.upDistance))m")
            contentView.addSubviewWithAnchors(upDistanceLabel, top: distanceLabel.bottomAnchor, leading: contentView.leadingAnchor,insets: flatInsets)
            
            let downDistanceLabel = UILabel(text: "\("downDistance".localize()): \(Int(track.downDistance))m")
            contentView.addSubviewWithAnchors(downDistanceLabel, top: upDistanceLabel.bottomAnchor, leading: contentView.leadingAnchor,insets: flatInsets)
            
            let durationLabel = UILabel(text: "\("duration".localize()): \(track.duration.hmsString())")
            contentView.addSubviewWithAnchors(durationLabel, top: downDistanceLabel.bottomAnchor, leading: contentView.leadingAnchor,insets: flatInsets)
            
            if isActiveTrack{
                let cancelButton = UIButton()
                cancelButton.setTitle("cancel".localize(), for: .normal)
                cancelButton.setTitleColor(.systemBlue, for: .normal)
                cancelButton.setGrayRoundedBorders()
                contentView.addSubviewWithAnchors(cancelButton, top: durationLabel.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
                cancelButton.addTarget(self, action: #selector(cancel), for: .touchDown)
                
                let saveButton = UIButton()
                saveButton.setTitle("save".localize(), for: .normal)
                saveButton.setTitleColor(.systemBlue, for: .normal)
                saveButton.setGrayRoundedBorders()
                contentView.addSubviewWithAnchors(saveButton, top: cancelButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, bottom: contentView.bottomAnchor, insets: defaultInsets)
                saveButton.addTarget(self, action: #selector(save), for: .touchDown)
            }
            else{
                durationLabel.bottom(contentView.bottomAnchor)
            }
        }
        
    }
    
    @objc func showTrackOnMap(){
        if let track = track{
            delegate?.showTrackOnMap(track: track)
        }
    }
    
    @objc func cancel(){
        if isActiveTrack{
            self.dismiss(animated: true){
                self.activeDelegate?.cancelActiveTrack()
            }
        }
    }
    
    @objc func save(){
        if isActiveTrack{
            self.dismiss(animated: true){
                self.activeDelegate?.saveActiveTrack()
            }
        }
    }
    
    
}

