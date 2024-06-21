/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers
import CoreLocation
import E5Data
import E5IOSUI
import E5MapData

protocol ActiveTrackDelegate{
    func cancelActiveTrack()
    func saveActiveTrack()
}

class EditTrackViewController: PopupScrollViewController{
    
    var track: TrackItem
    
    let deleteButton = UIButton().asIconButton("trash", color: .white)
    let mapButton = UIButton().asIconButton("map", color: .white)
    
    var nameEditField = UITextField()
    var noteEditView = TextEditArea()
    
    var delegate : TrackDelegate? = nil
    
    init(track: TrackItem){
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
        let buttonTopAnchor = titleLabel?.bottomAnchor ?? headerView.topAnchor
        
        headerView.addSubviewWithAnchors(mapButton, top: buttonTopAnchor, leading: headerView.leadingAnchor, bottom: headerView.bottomAnchor, insets: wideInsets)
        mapButton.addAction(UIAction(){ action in
            self.dismiss(animated: true){
                self.delegate?.showTrackItemOnMap(item: self.track)
            }
        }, for: .touchDown)
        
        let infoButton = UIButton().asIconButton("info")
        headerView.addSubviewWithAnchors(infoButton, top: buttonTopAnchor, trailing: closeButton.leadingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        infoButton.addAction(UIAction(){ action in
            let controller = TrackInfoViewController()
            self.present(controller, animated: true)
        }, for: .touchDown)
    }
    
    func setupContent() {
        contentView.removeAllSubviews()
        if !track.trackpoints.isEmpty {
            var header = UILabel(header: "startLocation".localize())
            contentView.addSubviewWithAnchors(header, top: contentView.topAnchor, leading: contentView.leadingAnchor,insets: defaultInsets)
            
            let coordinateLabel = UILabel(text: track.trackpoints[0].coordinate.asString)
            contentView.addSubviewWithAnchors(coordinateLabel, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor,insets: flatInsets)
            
            let timeLabel = UILabel(text: "\(track.startTime.dateTimeString()) - \(track.endTime.dateTimeString())")
            contentView.addSubviewWithAnchors(timeLabel, top: coordinateLabel.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor,insets: flatInsets)
            
            header = UILabel(header: "name".localize())
            contentView.addSubviewWithAnchors(header, top: timeLabel.bottomAnchor, leading: contentView.leadingAnchor,insets: defaultInsets)
            
            nameEditField.setDefaults()
            nameEditField.text = track.name
            nameEditField.setKeyboardToolbar(doneTitle: "done".localize())
            contentView.addSubviewWithAnchors(nameEditField, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
            
            header = UILabel(header: "note".localize())
            contentView.addSubviewWithAnchors(header, top: nameEditField.bottomAnchor, leading: contentView.leadingAnchor,insets: defaultInsets)
            
            noteEditView.setDefaults()
            noteEditView.text = track.note
            contentView.addSubviewWithAnchors(noteEditView, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
            
            header = UILabel(header: "distances".localize())
            contentView.addSubviewWithAnchors(header, top: noteEditView.bottomAnchor, leading: contentView.leadingAnchor,insets: defaultInsets)
            
            let distanceLabel = UILabel(text: "\("distance".localize()): \(Int(track.distance))m")
            contentView.addSubviewWithAnchors(distanceLabel, top: header.bottomAnchor, leading: contentView.leadingAnchor,insets: flatInsets)
            
            let upDistanceLabel = UILabel(text: "\("upDistance".localize()): \(Int(track.upDistance))m")
            contentView.addSubviewWithAnchors(upDistanceLabel, top: distanceLabel.bottomAnchor, leading: contentView.leadingAnchor,insets: flatInsets)
            
            let downDistanceLabel = UILabel(text: "\("downDistance".localize()): \(Int(track.downDistance))m")
            contentView.addSubviewWithAnchors(downDistanceLabel, top: upDistanceLabel.bottomAnchor, leading: contentView.leadingAnchor,insets: flatInsets)
            
            let durationLabel = UILabel(text: "\("duration".localize()): \(track.duration.hmsString())")
            contentView.addSubviewWithAnchors(durationLabel, top: downDistanceLabel.bottomAnchor, leading: contentView.leadingAnchor, insets: flatInsets)
            
            let saveButton = UIButton()
            saveButton.setTitle("save".localize(), for: .normal)
            saveButton.setTitleColor(.systemBlue, for: .normal)
            saveButton.addAction(UIAction(){ action in
                self.save()
            }, for: .touchDown)
            contentView.addSubviewWithAnchors(saveButton, top: durationLabel.bottomAnchor, bottom: contentView.bottomAnchor, insets: defaultInsets)
                .centerX(contentView.centerXAnchor)
                
        }
        
    }
    
    func save(){
        track.name = nameEditField.text ?? "Tour"
        track.note = noteEditView.text ?? ""
        AppData.shared.saveLocally()
    }
    
}
