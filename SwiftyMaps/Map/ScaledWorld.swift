//
//  ScaledPoint.swift
//  SwiftyMaps for OSM
//
//  Created by Michael Rönnau on 20.09.22.
//

import Foundation
import CoreLocation

struct ScaledWorld{
    
    // scale is always downscale from world to scaled world
    
    static func fullExtent(scale: Double) -> Double {
        World.fullExtent * scale
    }
    
    static func worldX(_ longitude: Double, scale: Double) -> Double {
        round(World.projectedLongitude(longitude) * World.fullExtent * scale)
    }
    
    static func worldY(_ latitude: Double, scale: Double) -> Double {
        round(World.projectedLatitude(latitude) * World.fullExtent * scale)
    }
    
    static func mapPoint(x : Double, y : Double, scale: Double) -> MapPoint{
        MapPoint(x: x / scale, y: y / scale)
    }
    
    
    static func mapPoint(worldPoint: MapPoint, scale: Double) -> MapPoint{
        mapPoint(x: worldPoint.x, y: worldPoint.y, scale: scale)
    }
    
    static func mapRect(x : Double, y : Double, width: Double, height: Double, scale: Double) -> MapRect{
        MapRect(x: x / scale, y: y / scale, width: width/scale, height: height/scale)
    }
    
    static func mapRect(worldRect: MapRect, scale: Double) -> MapRect{
        mapRect(x: worldRect.minX, y: worldRect.minY, width: worldRect.width, height: worldRect.height, scale: scale)
    }
    
    static func coordinate(x : Double, y : Double, scale: Double) -> CLLocationCoordinate2D {
        let mapPoint = mapPoint(x: x, y: y, scale: scale).normalizedPoint
        return mapPoint.coordinate
    }
    
}
