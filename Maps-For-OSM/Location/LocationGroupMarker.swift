/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import E5MapData

class LocationGroupMarker : Marker{
    
    static var mapPinDefaultImage = UIImage(named: "mappin.group.green")!
    static var mapPinMediaImage = UIImage(named: "mappin.group.red")!
    static var mapPinTrackImage = UIImage(named: "mappin.group.blue")!
    static var mapPinMediaTrackImage = UIImage(named: "mappin.group.purple")!
    
    var locationGroup : LocationGroup
    
    override var hasMedia : Bool{
        locationGroup.hasMedia
    }
    
    override var hasTrack : Bool{
        locationGroup.hasTrack
    }
    
    init(locationGroup: LocationGroup){
        self.locationGroup = locationGroup
        super.init(frame: .zero)
        updateImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateImage(){
        if hasMedia{
            if hasTrack{
                setImage(LocationGroupMarker.mapPinMediaTrackImage, for: .normal)
            }
            else{
                setImage(LocationGroupMarker.mapPinMediaImage, for: .normal)
            }
        }
        else{
            if hasTrack{
                setImage(LocationGroupMarker.mapPinTrackImage, for: .normal)
            }
            else{
                setImage(LocationGroupMarker.mapPinDefaultImage, for: .normal)
            }
        }
    }
    
}


