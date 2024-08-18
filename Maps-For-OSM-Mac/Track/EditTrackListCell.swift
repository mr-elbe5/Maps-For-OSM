/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation
import E5MapData

protocol EditTrackCellDelegate{
    func trackpointChanged(_ trackpoint: Trackpoint)
}

class EditTrackListCell: NSView{
    
    var trackpoint: Trackpoint
    
    var selectedButton: NSButton!
    
    var delegate: EditTrackCellDelegate? = nil
    
    init(trackpoint: Trackpoint){
        self.trackpoint = trackpoint
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView() {
        backgroundColor = .black
        setRoundedBorders()
        let iconBar = IconBar()
        addSubviewWithAnchors(iconBar, top: topAnchor, trailing: trailingAnchor)
        selectedButton = NSButton(icon: trackpoint.selected ? "checkmark.square" : "square", target: self, action: #selector(selectionChanged))
        iconBar.addArrangedSubview(selectedButton)
        let coordinateLabel = NSTextField(wrappingLabelWithString: trackpoint.coordinate.shortString)
        addSubviewWithAnchors(coordinateLabel, top: iconBar.bottomAnchor,leading: leadingAnchor, trailing: trailingAnchor, insets: smallInsets)
        let altitudeLabel = NSTextField(wrappingLabelWithString: "alt: \(Int(trackpoint.altitude))m")
        addSubviewWithAnchors(altitudeLabel, top: coordinateLabel.bottomAnchor,leading: leadingAnchor,trailing: trailingAnchor, insets: smallInsets)
        let timestampLabel = NSTextField(wrappingLabelWithString: "tm: \(DateFormatter.localizedString(from: trackpoint.timestamp.toUTCDate(), dateStyle: .none, timeStyle: .medium))")
        addSubviewWithAnchors(timestampLabel, top: altitudeLabel.bottomAnchor,leading: leadingAnchor,trailing: trailingAnchor, bottom: bottomAnchor, insets: smallInsets)
    }
    
    func updateIconView() {
        selectedButton.image = NSImage(systemSymbolName: trackpoint.selected ? "checkmark.square" : "square", accessibilityDescription: .none)
    }
    
    @objc func selectionChanged(){
        trackpoint.selected = !trackpoint.selected
        updateIconView()
        delegate?.trackpointChanged(trackpoint)
    }
}


