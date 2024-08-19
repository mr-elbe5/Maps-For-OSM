/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit



protocol TrackCellDelegate{
    func editTrack(_ track: Track)
}

class TrackCellView : LocationItemCellView{
    
    var track: Track
    
    var selectedButton: NSButton!
    var itemView = NSView()
    
    var delegate: TrackCellDelegate? = nil
    
    init(track: Track){
        self.track = track
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView() {
        removeAllSubviews()
        let titleField = NSTextField(wrappingLabelWithString: "track".localize()).asHeadline()
        addSubviewWithAnchors(titleField, top: topAnchor, insets: smallInsets).centerX(centerXAnchor)
        let iconBar = IconBar()
        addSubviewWithAnchors(iconBar, top: topAnchor, trailing: trailingAnchor)
        let showOnMapButton = NSButton(icon: "map", target: self, action: #selector(showTrackOnMap))
        iconBar.addArrangedSubview(showOnMapButton)
        let editButton = NSButton(icon: "pencil", target: self, action: #selector(editTrack))
        iconBar.addArrangedSubview(editButton)
        selectedButton = NSButton(icon: track.selected ? "checkmark.square" : "square", target: self, action: #selector(selectionChanged))
        iconBar.addArrangedSubview(selectedButton)
        addSubviewWithAnchors(itemView, top: iconBar.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: NSEdgeInsets())
        setupItemView()
    }
    
    func setupItemView(){
        itemView.removeAllSubviews()
        let nameField = NSTextField(wrappingLabelWithString: track.name)
        itemView.addSubviewWithAnchors(nameField, top: itemView.topAnchor)
            .centerX(centerXAnchor)
        let durationField = NSTextField(labelWithString: "\("duration".localize()): \(track.duration.hmString())")
        itemView.addSubviewWithAnchors(durationField, top: nameField.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor)
        let distField = NSTextField(labelWithString: "\("distance".localize()): \(Int(track.distance))m")
        itemView.addSubviewWithAnchors(distField, top: durationField.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor)
        let upField = NSTextField(labelWithString: "\("upDistance".localize()): \(Int(track.upDistance))m")
        itemView.addSubviewWithAnchors(upField, top: distField.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor)
        let downField = NSTextField(labelWithString: "\("downDistance".localize()): \(Int(track.downDistance))m")
        itemView.addSubviewWithAnchors(downField, top: upField.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor)
        let trackpointsField = NSTextField(labelWithString: "\("numTrackpoints".localize()): \(Int(track.trackpoints.count))")
        itemView.addSubviewWithAnchors(trackpointsField, top: downField.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor)
        var lastView: NSView = trackpointsField
        if let img = track.getPreview(){
            let imgView = NSImageView(image: img)
            imgView.setAspectRatioConstraint()
            itemView.addSubviewWithAnchors(imgView, top: lastView.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: defaultInsets)
            lastView = imgView
        }
        else{
            let loadPreviewButton = NSButton(title: "loadPreview".localize(), target: self, action: #selector(loadPreview))
            itemView.addSubviewWithAnchors(loadPreviewButton, top: nameField.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: defaultInsets)
            lastView = loadPreviewButton
        }
        lastView.bottom(itemView.bottomAnchor, inset: defaultInset)
    }
    
    override func updateIconView() {
        selectedButton.image = NSImage(systemSymbolName: track.selected ? "checkmark.square" : "square", accessibilityDescription: .none)
    }
    
    @objc func showTrackOnMap(){
        MainViewController.instance.showTrackOnMap(track)
    }
    
    @objc func editTrack(){
        delegate?.editTrack(track)
    }
    
    @objc func selectionChanged(){
        track.selected = !track.selected
        updateIconView()
    }
    
    @objc func loadPreview(){
        setupItemView()
    }
    
}
