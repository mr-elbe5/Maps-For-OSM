/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation

extension CGRect{
    
    func scaleBy(_ scale: CGFloat) -> CGRect{
        CGRect(x: minX*scale, y: minY*scale, width: width*scale, height: height*scale)
    }
    
    func scaleCenteredBy(_ scale: CGFloat) -> CGRect{
        CGRect(x: midX - width*scale/2, y: midY - height*scale/2, width: width*scale, height: height*scale)
    }
    
    func expandBy(size: CGSize) -> CGRect{
        CGRect(x: minX - size.width, y: minY - size.height, width: width + 2*size.width, height: height + 2*size.height)
    }
    
    var topLeft: CGPoint{
        CGPoint(x: minX, y: maxY)
    }
    
    var bottomRight: CGPoint{
        CGPoint(x: maxX, y: minY)
    }
    
    var center: CGPoint{
        var cx = minX + width/2
        if cx > World.worldSize.width{
            cx -= World.worldSize.width
        }
        return CGPoint(x: cx, y: minY + height/2)
    }
    
    var cgRect : CGRect{
        CGRect(origin: origin, size: size)
    }
    
    var topLeftCoordinate : CLLocationCoordinate2D{
        topLeft.coordinate
    }
    
    var bottomRightCoordinate : CLLocationCoordinate2D{
        if spans180Medidian, let rect = remainderRect{
            return rect.bottomRightCoordinate
        }
        return bottomRight.coordinate
    }
    
    var centerCoordinate : CLLocationCoordinate2D{
        center.coordinate
    }
    
    var spans180Medidian : Bool{
        maxX > World.worldSize.width
    }
    
    var remainderRect : CGRect?{
        if !spans180Medidian{
            return nil
        }
        return CGRect(x: 0, y: origin.y, width: maxX - World.worldSize.width, height: height)
    }
    
    var string : String{
        "origin: \(origin.string), size: \(size.string)"
    }
    
    var normalizedRect : CGRect{
        if origin.x > World.worldSize.width{
            return CGRect(origin: CGPoint(x: origin.x - World.worldSize.width, y: origin.y), size: size)
        }
        return self
    }
    
}

