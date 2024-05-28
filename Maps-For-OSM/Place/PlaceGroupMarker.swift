/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import Maps_For_OSM_Data

class PlaceGroupMarker : Marker{
    
    static var mapPinDefaultImage = UIImage(named: "mappin.group.green")!
    static var mapPinMediaImage = UIImage(named: "mappin.group.red")!
    static var mapPinTrackImage = UIImage(named: "mappin.group.blue")!
    static var mapPinMediaTrackImage = UIImage(named: "mappin.group.purple")!
    
    var placeGroup : PlaceGroup
    
    override var hasMedia : Bool{
        placeGroup.hasMedia
    }
    
    override var hasTrack : Bool{
        placeGroup.hasTrack
    }
    
    init(placeGroup: PlaceGroup){
        self.placeGroup = placeGroup
        super.init(frame: .zero)
        updateImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateImage(){
        if hasMedia{
            if hasTrack{
                setImage(PlaceGroupMarker.mapPinMediaTrackImage, for: .normal)
            }
            else{
                setImage(PlaceGroupMarker.mapPinMediaImage, for: .normal)
            }
        }
        else{
            if hasTrack{
                setImage(PlaceGroupMarker.mapPinTrackImage, for: .normal)
            }
            else{
                setImage(PlaceGroupMarker.mapPinDefaultImage, for: .normal)
            }
        }
    }
    
}


