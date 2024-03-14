/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class PlaceMarker : Marker{
    
    static var mapPinDefaultImage = UIImage(named: "mappin.green")
    static var mapPinMediaImage = UIImage(named: "mappin.red")
    
    var place : Place
    
    override var hasMedia : Bool{
        place.hasMedia
    }
    
    init(place: Place){
        self.place = place
        super.init(frame: .zero)
        updateImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateImage(){
        if hasMedia{
            setImage(PlaceMarker.mapPinMediaImage, for: .normal)
        }
        else{
            setImage(PlaceMarker.mapPinDefaultImage, for: .normal)
        }
    }
    
}


