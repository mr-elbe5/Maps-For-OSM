/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import Maps_For_OSM_Data

class PlaceMarker : Marker{
    
    static var mapPinDefaultImage = UIImage(named: "mappin.green")
    static var mapPinMediaImage = UIImage(named: "mappin.red")
    static var mapPinTrackImage = UIImage(named: "mappin.blue")
    static var mapPinMediaTrackImage = UIImage(named: "mappin.purple")
    
    var place : Place
    
    override var hasMedia : Bool{
        place.hasMedia
    }
    
    override var hasTrack : Bool{
        place.hasTrack
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
            if hasTrack{
                setImage(PlaceMarker.mapPinMediaTrackImage, for: .normal)
            }
            else{
                setImage(PlaceMarker.mapPinMediaImage, for: .normal)
            }
        }
        else{
            if hasTrack{
                setImage(PlaceMarker.mapPinTrackImage, for: .normal)
            }
            else{
                setImage(PlaceMarker.mapPinDefaultImage, for: .normal)
            }
        }
    }
    
}


