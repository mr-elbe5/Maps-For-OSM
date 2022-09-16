//
//  MapRect.swift
//  SwiftyMaps for OSM
//
//  Created by Michael Rönnau on 15.09.22.
//

import Foundation

class MapRect{
    
    static let null = MapRect()
    static let world = MapRect(origin: MapPoint(x: 0, y: 0), size: MapSize.world)
    
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
    
}
