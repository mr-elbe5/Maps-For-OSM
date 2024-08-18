/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation


class MapDetailView: MenuScrollView{
    
    var centerCoordinate: CLLocationCoordinate2D?{
        nil
    }
    
    override open func setupView(){
        super.setupView()
        backgroundColor = .black
    }
    
}

