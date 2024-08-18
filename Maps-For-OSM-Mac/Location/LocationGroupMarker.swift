/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import E5MapData

class LocationGroupMarker : Marker{
    
    static var mapPinDefaultImage = NSImage(named: "mappin.group.green")!
    static var mapPinMediaImage = NSImage(named: "mappin.group.red")!
    static var mapPinTrackImage = NSImage(named: "mappin.group.blue")!
    static var mapPinMediaTrackImage = NSImage(named: "mappin.group.purple")!
    
    var locationGroup : LocationGroup
    
    override var hasMedia : Bool{
        locationGroup.hasMedia
    }
    
    override var hasTrack : Bool{
        locationGroup.hasTrack
    }
    
    init(locationGroup: LocationGroup, target: AnyObject?, action: Selector?){
        self.locationGroup = locationGroup
        super.init(frame: .zero)
        self.target = target
        self.action = action
        isBordered = false
        updateImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateImage(){
        if hasMedia{
            if hasTrack{
                image = LocationGroupMarker.mapPinMediaTrackImage
            }
            else{
                image = LocationGroupMarker.mapPinMediaImage
            }
        }
        else{
            if hasTrack{
                image = LocationGroupMarker.mapPinTrackImage
            }
            else{
                image = LocationGroupMarker.mapPinDefaultImage
            }
        }
    }
    
}


