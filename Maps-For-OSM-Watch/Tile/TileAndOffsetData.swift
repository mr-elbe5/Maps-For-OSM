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
    
    init(location: CLLocation, status: Status) {
        let coordinate = location.coordinate
        print(coordinate)
        let viewCenter = AppStatics.viewCenter
        print("view center \(viewCenter)")
        let zoom = status.zoom
        print("zoom \(zoom)")
        let zoomScaleFromWorld = World.zoomScaleFromWorld(to: zoom)
        print("zoom scale \(zoomScaleFromWorld)")
        let x = World.scaledX(coordinate.longitude, downScale: zoomScaleFromWorld) - viewCenter.x
        let y = World.scaledY(coordinate.latitude, downScale: zoomScaleFromWorld) - viewCenter.y
        
        tileX = Int(floor(x / 256.0))
        tileY = Int(floor(y / 256.0))
        
        print("tile \(tileX), \(tileY)")
        
        offsetX = Double(tileX)*256.0 - x
        offsetY = Double(tileY)*256.0 - y
        
        print("offsetX,offsetY \(offsetX), \(offsetY)")
    }
    
}
