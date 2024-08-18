/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

class Marker : NSButton{
    
    static var baseFrame = CGRect(x: -16,y: -32, width: 32, height: 32)
    
    var hasMedia : Bool{
        false
    }
    
    var hasTrack : Bool{
        false
    }
    
    func updatePosition(to pos: CGPoint){
        frame = Marker.baseFrame.offsetBy(dx: pos.x, dy: pos.y)
        needsDisplay = true
    }
    
    func updateImage(){
    }
    
}


