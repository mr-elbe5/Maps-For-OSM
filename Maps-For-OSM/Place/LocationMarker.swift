/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import E5MapData

class LocationMarker : Marker{
    
    static var mapPinDefaultImage = UIImage(named: "mappin.green")
    static var mapPinMediaImage = UIImage(named: "mappin.red")
    static var mapPinTrackImage = UIImage(named: "mappin.blue")
    static var mapPinMediaTrackImage = UIImage(named: "mappin.purple")
    
    var location : Location
    
    override var hasMedia : Bool{
        location.hasMedia
    }
    
    override var hasTrack : Bool{
        location.hasTrack
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
            if hasTrack{
                setImage(LocationMarker.mapPinMediaTrackImage, for: .normal)
            }
            else{
                setImage(LocationMarker.mapPinMediaImage, for: .normal)
            }
        }
        else{
            if hasTrack{
                setImage(LocationMarker.mapPinTrackImage, for: .normal)
            }
            else{
                setImage(LocationMarker.mapPinDefaultImage, for: .normal)
            }
        }
    }
    
}


