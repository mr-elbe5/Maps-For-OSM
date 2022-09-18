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
class NormalizedPlanetPoint{
    
    var dx: CGFloat = 0
    var point: CGPoint
    
    var x : CGFloat{
        point.x
    }
    
    var y : CGFloat{
        point.y
    }
    
    init(pnt: CGPoint, dx: CGFloat){
        self.point = pnt
        self.dx = dx
    }
    
    init(pnt: CGPoint){
        self.dx = World.scrollShift(x: pnt.x)
        self.point = (dx == 0) ? pnt : CGPoint(x: pnt.x - dx, y: pnt.y)
    }
    
    convenience init(pnt: CGPoint, fromScaledPlanet: CGRect){
        let scale = World.worldSize.width/fromScaledPlanet.width
        self.init(pnt: CGPoint(x: pnt.x*scale, y: pnt.y*scale))
    }
    
    var originalPoint : CGPoint{
        (dx == 0) ? point : CGPoint(x: point.x + dx, y: point.y)
    }
    
    func mapTo(frame : CGRect, fromOriginal: Bool) -> CGPoint{
        let scale = frame.width/World.worldSize.width
        return CGPoint(x: (point.x + (fromOriginal ? dx : 0))*scale, y: point.y*scale)
    }
    
    func mapTo(scaleFromPlanet : CGFloat, fromOriginal: Bool) -> CGPoint{
        return CGPoint(x: (point.x + (fromOriginal ? dx : 0))*scaleFromPlanet, y: point.y*scaleFromPlanet)
    }
    
}
