/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import UniformTypeIdentifiers
import CoreLocation

protocol TrackDetailDelegate{
    func showTrackItemOnMap(item: Track)
}

protocol ActiveTrackDelegate{
    func cancelActiveTrack()
    func saveActiveTrack()
}

class TrackViewController: PopupScrollViewController{
    
    var track: Track
    
    var editMode = false
    
    let editButton = UIButton().asIconButton("pencil", color: .label)
    let deleteButton = UIButton().asIconButton("trash", color: .white)
    let mapButton = UIButton().asIconButton("map", color: .white)
    
    let noteContainerView = UIView()
    var noteEditView : TextEditArea? = nil
    
    // MainViewController
    var delegate : TrackDetailDelegate? = nil
    
    init(track: Track){
        self.track = track
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "track".localize()
        super.loadView()
        scrollView.setupVertical()
        setupContent()
        setupKeyboard()
    }
    
    override func setupHeaderView(headerView: UIView){
        super.setupHeaderView(headerView: headerView)
        
        headerView.addSubviewWithAnchors(editButton, top: headerView.topAnchor, leading: headerView.leadingAnchor, bottom: headerView.bottomAnchor, insets: wideInsets)
        editButton.addAction(UIAction(){ action in
            self.toggleEditMode()
        }, for: .touchDown)
        
        headerView.addSubviewWithAnchors(mapButton, top: headerView.topAnchor, leading: editButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: wideInsets)
        mapButton.addAction(UIAction(){ action in
            self.dismiss(animated: true){
                self.delegate?.showTrackItemOnMap(item: self.track)
            }
        }, for: .touchDown)
        
        let infoButton = UIButton().asIconButton("info")
        headerView.addSubviewWithAnchors(infoButton, top: headerView.topAnchor, trailing: closeButton.leadingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        infoButton.addAction(UIAction(){ action in
            let controller = TrackInfoViewController()
            self.present(controller, animated: true)
        }, for: .touchDown)
    }
    
    func setupContent() {
        if !track.trackpoints.isEmpty {
            
            var header = UILabel(header: "startLocation".localize())
            contentView.addSubviewWithAnchors(header, top: contentView.topAnchor, leading: contentView.leadingAnchor,insets: defaultInsets)
            
            let coordinateLabel = UILabel(text: track.trackpoints[0].coordinate.asString)
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
            contentView.addSubviewWithAnchors(durationLabel, top: downDistanceLabel.bottomAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, insets: flatInsets)
                
        }
        
    }
    
    func setupNoteContainerView(){
        noteContainerView.removeAllSubviews()
        if editMode{
            let noteEditView = TextEditArea().defaultWithBorder()
            noteEditView.text = track.note
            noteContainerView.addSubviewWithAnchors(noteEditView, top: noteContainerView.topAnchor, leading: noteContainerView.leadingAnchor, trailing: noteContainerView.trailingAnchor, insets: defaultInsets)
            self.noteEditView = noteEditView
            
            let saveButton = UIButton()
            saveButton.setTitle("save".localize(), for: .normal)
            saveButton.setTitleColor(.systemBlue, for: .normal)
            saveButton.addAction(UIAction(){ action in
                self.save()
            }, for: .touchDown)
            noteContainerView.addSubviewWithAnchors(saveButton, top: noteEditView.bottomAnchor, bottom: noteContainerView.bottomAnchor, insets: defaultInsets)
                .centerX(noteContainerView.centerXAnchor)
        }
        else{
            self.noteEditView = nil
            let noteLabel = UILabel(text: track.note)
            noteContainerView.addSubviewWithAnchors(noteLabel, top: noteContainerView.topAnchor, leading: noteContainerView.leadingAnchor, trailing: noteContainerView.trailingAnchor, bottom: noteContainerView.bottomAnchor, insets: defaultInsets)
        }
    }
    
    func toggleEditMode(){
        if editMode{
            editButton.tintColor = .black
            editMode = false
        }
        else{
            editButton.tintColor = .systemBlue
            editMode = true
        }
        setupNoteContainerView()
    }
    
    func save(){
        track.note = noteEditView?.text ?? ""
        PlacePool.save()
        if editMode{
            toggleEditMode()
        }
    }
    
}

