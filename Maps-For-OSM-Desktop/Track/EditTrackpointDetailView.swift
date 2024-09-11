/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation


class EditTrackpointDetailView: NSView{
    
    var trackpointLabel = NSTextField(labelWithString: "")
    
    override func setupView() {
        backgroundColor = .black
        let label = NSTextField(labelWithString: "selectedTrackpoint".localizeWithColon())
        addSubviewWithAnchors(label, top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, insets: defaultInsets)
        addSubviewWithAnchors(trackpointLabel, top: topAnchor, leading: label.trailingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: defaultInsets)
    }
    
    func setTrackPoint(_ trackpoint: Trackpoint?){
        if let trackpoint = trackpoint{
            trackpointLabel.stringValue = "\(trackpoint.coordinate.asShortString), \(Int(trackpoint.altitude)) m, \(DateFormatter.localizedString(from: trackpoint.timestamp.toUTCDate(), dateStyle: .none, timeStyle: .medium))"
        }
        else{
            trackpointLabel.stringValue = ""
        }
    }
}
