/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class LocationGroupMarker : Marker{
    
    static var mapPinDefaultImage = UIImage(named: "mappin.group.green")!
    static var mapPinMediaImage = UIImage(named: "mappin.group.red")!
    
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
            setImage(LocationGroupMarker.mapPinMediaImage, for: .normal)
        }
        else{
            setImage(LocationGroupMarker.mapPinDefaultImage, for: .normal)
        }
    }
    
}


