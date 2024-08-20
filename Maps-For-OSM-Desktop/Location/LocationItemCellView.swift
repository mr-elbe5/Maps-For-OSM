/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

protocol LocationItemDelegate{
    func itemsChanged()
}

class LocationItemCellView : NSView{
    
    init(){
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView() {
        super.setupView()
        backgroundColor = .black
    }
    
    func updateIconView(){
    }
    
}

