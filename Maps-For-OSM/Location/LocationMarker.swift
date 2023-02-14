/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class LocationMarker : Marker{
    
    static var mapPinDefaultImage = UIImage(named: "mappin.green")
    static var mapPinMediaImage = UIImage(named: "mappin.red")
    
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
            setImage(LocationMarker.mapPinMediaImage, for: .normal)
        }
        else{
            setImage(LocationMarker.mapPinDefaultImage, for: .normal)
        }
    }
    
}


