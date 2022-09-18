/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

/*
 class for handling the areas for infinit scroll
 */
class NormalizedPlanetRect{
    
    var dx: CGFloat = 0
    var rect: CGRect
    
    var minX : CGFloat{
        rect.minX
    }
    
    var minY : CGFloat{
        rect.minY
    }
    
    var width : CGFloat{
        rect.width
    }
    
    var height : CGFloat{
        rect.height
    }
    
    init(rect: CGRect, dx: CGFloat){
        self.rect = rect
        self.dx = dx
    }
    
    init(rect: CGRect){
        self.dx = World.scrollShift(x: rect.minX)
        self.rect = (dx == 0) ? rect : CGRect(x: rect.minX - dx, y: rect.minY, width: rect.width, height: rect.height)
    }
    
    convenience init(rect: CGRect, fromScale: CGFloat){
        self.init(rect: rect.scaleBy(1.0/fromScale))
    }
    
    convenience init(rect: CGRect, fromScaledPlanet: CGRect){
        let scale = World.worldSize.width/fromScaledPlanet.width
        self.init(rect: rect, fromScale: scale)
    }
    
    var originalRect : CGRect{
        (dx == 0) ? rect : CGRect(x: rect.minX + dx, y: rect.minY, width: rect.width, height: rect.height)
    }
    
    func mapTo(frame : CGRect, normalized: Bool) -> CGRect{
        let fx = frame.width/World.worldSize.width
        let fy = frame.height/World.worldSize.height
        return CGRect(x: (rect.minX + (normalized ? 0.0 : dx))*fx, y: rect.minY*fy, width: rect.width*fx, height: rect.height*fy)
    }
    
}
