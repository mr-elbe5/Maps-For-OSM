/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class PlacePin : Pin{
    
    static var mapPinDefaultImage = UIImage(named: "mappin.green")
    static var mapPinPhotoImage = UIImage(named: "mappin.red")
    static var mapPinTrackImage = UIImage(named: "mappin.blue")
    static var mapPinPhotoTrackImage = UIImage(named: "mappin.purple")
    
    var place : Place
    
    override var hasPhotos : Bool{
        place.hasPhotos
    }
    
    override var hasTracks: Bool{
        place.hasTracks
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
        if let image = hasPhotos ? (hasTracks ? PlacePin.mapPinPhotoTrackImage : PlacePin.mapPinPhotoImage) : (hasTracks ? PlacePin.mapPinTrackImage : PlacePin.mapPinDefaultImage){
            baseFrame = CGRect(x: -image.size.width/2, y: -image.size.height, width: image.size.width, height: image.size.height)
            setImage(image, for: .normal)
        }
    }
    
}


