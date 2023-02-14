/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

// point in the world at full scale in pixels
class MapPoint{
    
    var x: Double
    var y: Double
    
    init(){
        x = 0
        y = 0
    }
    
    init(x: Double, y: Double){
        self.x = x
        self.y = y
    }
    
    init (_ coord: CLLocationCoordinate2D){
        x = World.worldX(coord.longitude)
        y = World.worldY(coord.latitude)
    }
    
    var normalizedPoint : MapPoint{
        if x > World.worldSize.width{
            return MapPoint(x: x - World.worldSize.width, y: y)
        }
        return self
    }
    
    var cgPoint: CGPoint{
        CGPoint(x: x, y: y)
    }
    
    var coordinate : CLLocationCoordinate2D{
        let longitude = x/World.fullExtent*360.0 - 180.0
        let latitude = atan(sinh(.pi - (y/World.fullExtent)*2*CGFloat.pi))*(180.0/CGFloat.pi)
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var string : String{
        "x: \(x), y: \(y)"
    }
    
    func distance(to: MapPoint) -> CLLocationDistance{
        coordinate.distance(to: to.coordinate)
    }
    
}
