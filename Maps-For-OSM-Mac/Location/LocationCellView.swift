/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

import E5MapData

protocol LocationCellDelegate{
    func showLocationDetails(_ location: Location)
}

class LocationCellView : NSView{
    
    var location: Location
    
    var selectedButton: NSButton!
    
    init(location: Location){
        self.location = location
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var delegate: LocationCellDelegate? = nil
    
    override func setupView() {
        backgroundColor = NSColor(white: 0.2, alpha: 1.0)
        let titleField = NSTextField(wrappingLabelWithString: "location".localize()).asHeadline()
        addSubviewWithAnchors(titleField, top: topAnchor, insets: smallInsets).centerX(centerXAnchor)
        let iconBar = IconBar()
        addSubviewWithAnchors(iconBar, top: topAnchor, trailing: trailingAnchor)
        let showButton = NSButton(icon: "magnifyingglass", target: self, action: #selector(showLocationDetails))
        iconBar.addArrangedSubview(showButton)
        selectedButton = NSButton(icon: location.selected ? "checkmark.square" : "square", target: self, action: #selector(selectionChanged))
        iconBar.addArrangedSubview(selectedButton)
        let addressLabel = NSTextField(labelWithString: location.address)
        addSubviewWithAnchors(addressLabel, top: iconBar.bottomAnchor, insets: defaultInsets)
            .centerX(centerXAnchor)
        let coordinateLabel = NSTextField(labelWithString: location.coordinate.asString)
        addSubviewWithAnchors(coordinateLabel, top: addressLabel.bottomAnchor, bottom: bottomAnchor, insets: defaultInsets)
            .centerX(centerXAnchor)
    }
    
    @objc func showLocationDetails(){
        delegate?.showLocationDetails(location)
    }
    
    func updateIconView(){
        selectedButton.image = NSImage(systemSymbolName: location.selected ? "checkmark.square" : "square", accessibilityDescription: .none)
    }
    
    @objc func selectionChanged(){
        location.selected = !location.selected
        updateIconView()
    }
    
}
