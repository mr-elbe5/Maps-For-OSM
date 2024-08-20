/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit



class LocationMarker : Marker{
    
    static var mapPinDefaultImage = NSImage(named: "mappin.green")!
    static var mapPinMediaImage = NSImage(named: "mappin.red")!
    static var mapPinTrackImage = NSImage(named: "mappin.blue")!
    static var mapPinMediaTrackImage = NSImage(named: "mappin.purple")!
    
    var location : Location
    
    override var hasMedia : Bool{
        location.hasMedia
    }
    
    override var hasTrack : Bool{
        location.hasTrack
    }
    
    init(location: Location, target: AnyObject?, action: Selector?){
        self.location = location
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
                image = LocationMarker.mapPinMediaTrackImage
            }
            else{
                image = LocationMarker.mapPinMediaImage
            }
        }
        else{
            if hasTrack{
                image = LocationMarker.mapPinTrackImage
            }
            else{
                image = LocationMarker.mapPinDefaultImage
            }
        }
    }
    
}


