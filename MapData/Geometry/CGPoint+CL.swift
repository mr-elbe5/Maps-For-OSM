/*
 E5MapData
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation

extension CGPoint{
    
    public init(_ coord: CLLocationCoordinate2D){
        self.init(x: World.worldX(coord.longitude), y:  World.worldY(coord.latitude))
    }
    
    public var coordinate : CLLocationCoordinate2D{
        let longitude = x/World.fullExtent*360.0 - 180.0
        let latitude = atan(sinh(CGFloat.pi - (y/World.fullExtent)*2*CGFloat.pi))*(180.0/CGFloat.pi)
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public func distance(to: CGPoint) -> CLLocationDistance{
        coordinate.distance(to: to.coordinate)
    }
    
    public var normalizedPoint : CGPoint{
        if x > World.worldSize.width{
            return CGPoint(x: x - World.worldSize.width, y: y)
        }
        return self
    }
    
}
