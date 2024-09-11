/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation


class MapStatusView: NSView{
    
    var zoomLabel = NSTextField(labelWithString: "")
    
    override func setupView() {
        backgroundColor = .black
        var label = NSTextField(labelWithString: "zoomLevel".localizeWithColon())
        addSubviewWithAnchors(label, top: topAnchor, leading: leadingAnchor, insets: narrowInsets)
        addSubviewWithAnchors(zoomLabel, top: topAnchor, leading: label.trailingAnchor, trailing: trailingAnchor, insets: defaultInsets)
        label = NSTextField(wrappingLabelWithString: "mapHint".localize())
        addSubviewWithAnchors(label, top: zoomLabel.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: narrowInsets)
    }
    
    func setZoom(_ zoom: Int){
        zoomLabel.stringValue = String(zoom)
    }
    
}
