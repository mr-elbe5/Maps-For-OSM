//
//  TileAndOffsetData.swift
//  Maps For OSM Watch
//
//  Created by Michael Rönnau on 08.10.24.
//

import Foundation
import CoreLocation

struct TileAndOffsetData{
    
    var tileX: Int
    var tileY: Int
    var offsetX: Double
    var offsetY: Double
    
    init(location: CLLocation, zoom: Int, screenCenter: CGPoint) {
        let coordinate = location.coordinate
        print(coordinate)
        let zoomScaleFromWorld = World.zoomScaleFromWorld(to: zoom)
        print("zoom scale \(zoomScaleFromWorld)")
        let x = World.scaledX(coordinate.longitude, downScale: zoomScaleFromWorld)
        let y = World.scaledY(coordinate.latitude, downScale: zoomScaleFromWorld)
        
        tileX = Int(floor((x  - screenCenter.x) / World.tileExtent))
        tileY = Int(floor((y  - screenCenter.y) / World.tileExtent))
        
        print("top left tile \(tileX), \(tileY)")
        
        offsetX = Double(tileX)*World.tileExtent - x + 136.0
        offsetY = Double(tileY)*World.tileExtent - y + 8.0
        
        print("offsetX,offsetY \(offsetX), \(offsetY)")
    }
    
}
