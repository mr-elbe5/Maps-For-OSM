/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class Marker : UIButton{
    
    var baseFrame : CGRect = .zero
    
    var hasMedia : Bool{
        false
    }
    
    func updatePosition(to pos: CGPoint){
        frame = baseFrame.offsetBy(dx: pos.x, dy: pos.y)
        setNeedsDisplay()
    }
    
    func updateImage(){
    }
    
}


