//
//  MapRect.swift
//  SwiftyMaps for OSM
//
//  Created by Michael Rönnau on 15.09.22.
//

import Foundation
import CoreLocation

class MapRect{
    
    static let null = MapRect()
    static let world = MapRect(origin: MapPoint(x: 0, y: 0), size: World.mapSize)
    
    var origin: MapPoint
    var size: MapSize
    
    var minX: Double{
        min(origin.x, origin.x + size.width)
    }
    
    var maxX: Double{
        max(origin.x, origin.x + size.width)
    }
    
    var minY: Double{
        min(origin.y, origin.y + size.height)
    }
    
    var maxY: Double{
        max(origin.y, origin.y + size.height)
    }
    
    var width: Double{
        size.width
    }
    
    var height: Double{
        size.height
    }
    
    var topLeft: MapPoint{
        MapPoint(x: minX, y: maxY)
    }
    
    var bottomRight: MapPoint{
        MapPoint(x: maxX, y: minY)
    }
    
    var center: MapPoint{
        var cx = minX + width/2
        if cx > World.worldSize.width{
            cx -= World.worldSize.width
        }
        return MapPoint(x: cx, y: minY + height/2)
    }
    
    var normalizedRect : MapRect{
        if origin.x > World.worldSize.width{
            return MapRect(origin: MapPoint(x: origin.x - World.worldSize.width, y: origin.y), size: size)
        }
        return self
    }
    
    var cgRect : CGRect{
        CGRect(origin: origin.cgPoint, size: size.cgSize)
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
    
    var remainderRect : MapRect?{
        if !spans180Medidian{
            return nil
        }
        return MapRect(x: 0, y: origin.y, width: maxX - World.worldSize.width, height: height)
    }
    
    var string : String{
        "origin: \(origin.string), size: \(size.string)"
    }
    
    init(){
        origin = MapPoint()
        size = MapSize()
    }
    
    init(x: Double, y: Double, width: Double, height: Double){
        origin = MapPoint(x: x, y: y)
        size = MapSize(width: width, height: height)
    }
    
    init(origin: MapPoint, size: MapSize){
        self.origin = origin
        self.size = size
    }
    
    init(rect: MapRect){
        origin = MapPoint(x: rect.origin.x, y: rect.origin.y)
        size = MapSize(width: rect.size.width, height: rect.size.height)
    }
    
    func scale(factor: Double) -> MapRect{
        MapRect(x: origin.x*factor, y: origin.y*factor, width: width*factor, height: height*factor)
    }
    
}
