/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class PlaceGroupMarker : Marker{
    
    static var mapPinDefaultImage = UIImage(named: "mappin.group.green")!
    static var mapPinItemsImage = UIImage(named: "mappin.group.red")!
    
    var placeGroup : PlaceGroup
    
    override var hasItems : Bool{
        placeGroup.hasItems
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
        if hasItems{
            setImage(PlaceGroupMarker.mapPinItemsImage, for: .normal)
        }
        else{
            setImage(PlaceGroupMarker.mapPinDefaultImage, for: .normal)
        }
    }
    
}


