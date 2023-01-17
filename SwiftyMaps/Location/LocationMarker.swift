/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class LocationMarker : Marker{
    
    var location : Location
    
    override var hasMedia : Bool{
        location.hasMedia
    }
    
    init(location: Location){
        self.location = location
        super.init(frame: .zero)
        updateImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateImage(){
        if hasMedia{
            asIconButton("camera", color: .systemRed)
        }
        else{
            asIconButton("mappin", color: .systemRed)
        }
    }
    
}


