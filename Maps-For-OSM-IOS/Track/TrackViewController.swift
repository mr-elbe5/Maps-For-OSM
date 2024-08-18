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

class TrackViewController: NavScrollViewController{
    
    var track: Track
    
    var nameEditField = UITextField()
    var noteEditView = TextEditArea()
    
    var mainViewController: MainViewController?{
        navigationController?.rootViewController as? MainViewController
    }
    
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
        setupKeyboard()
    }
    
    override func updateNavigationItems() {
        super.updateNavigationItems()
        var groups = Array<UIBarButtonItemGroup>()
        var items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "showOnMap", image: UIImage(systemName: "map"), primaryAction: UIAction(){ action in
            self.navigationController?.popToRootViewController(animated: true)
            self.mainViewController?.showTrackOnMap(track: self.track)
        }))
        items.append(UIBarButtonItem(title: "export", image: UIImage(systemName: "square.and.arrow.up"), primaryAction: UIAction(){ action in
            self.exportTrack(item: self.track)
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(items: items))
        navigationItem.trailingItemGroups = groups
    }
    
    override func loadScrollableSubviews() {
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
            contentView.addSubviewWithAnchors(saveButton, top: durationLabel.bottomAnchor, insets: defaultInsets)
                .centerX(contentView.centerXAnchor)
            
            var lastView: UIView = saveButton
            
            if let img = TrackImageCreator(track: track).createImage(size: CGSize(width: 500, height: 500)){
                let imgView = UIImageView(image: img)
                imgView.setAspectRatioConstraint()
                contentView.addSubviewWithAnchors(imgView, top: saveButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
                lastView = imgView
            }
            else{
                let loadButton = UIButton()
                loadButton.setTitle("loadImage".localize(), for: .normal)
                loadButton.setTitleColor(.systemBlue, for: .normal)
                loadButton.addAction(UIAction(){ action in
                    self.loadScrollableSubviews()
                }, for: .touchDown)
                contentView.addSubviewWithAnchors(loadButton, top: saveButton.bottomAnchor, insets: defaultInsets)
                    .centerX(contentView.centerXAnchor)
                lastView = loadButton
            }
            
            lastView.bottom(contentView.bottomAnchor)
                
        }
        
    }
    
    func exportTrack(item: Track) {
        if let url = GPXCreator.createTemporaryFile(track: item){
            let controller = UIDocumentPickerViewController(forExporting: [url], asCopy: false)
            controller.directoryURL = FileManager.exportGpxDirURL
            present(controller, animated: true)
        }
    }
    
    func save(){
        track.name = nameEditField.text ?? "Tour"
        track.note = noteEditView.text ?? ""
        AppData.shared.save()
    }
    
}

