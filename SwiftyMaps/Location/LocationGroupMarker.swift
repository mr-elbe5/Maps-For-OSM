/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class LocationGroupMarker : Marker{
    
    var locationGroup : LocationGroup
    
    override var hasMedia : Bool{
        locationGroup.hasMedia
    }
    
    init(placeGroup: LocationGroup){
        self.locationGroup = placeGroup
        super.init(frame: .zero)
        updateImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateImage(){
        if hasMedia{
            asIconButton("camera.circle", color: .systemRed)
        }
        else{
            asIconButton("mappin.circle", color: .systemRed)
        }
    }
    
}


