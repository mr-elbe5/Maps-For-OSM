//
//  MapPoint.swift
//  SwiftyMaps for OSM
//
//  Created by Michael Rönnau on 15.09.22.
//

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
        x = (coord.longitude + 180)/360.0*World.fullExtent
        y = (1.0 - log(tan(coord.latitude*CGFloat.pi/180.0) + 1/cos(coord.latitude*CGFloat.pi/180.0 ))/CGFloat.pi )/2*World.fullExtent
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
