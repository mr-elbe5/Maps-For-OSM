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
        let screenCenter = status.screenCenter
        print("screen center \(screenCenter)")
        let zoom = status.zoom
        print("zoom \(zoom)")
        let zoomScaleFromWorld = World.zoomScaleFromWorld(to: zoom)
        print("zoom scale \(zoomScaleFromWorld)")
        let x = World.scaledX(coordinate.longitude, downScale: zoomScaleFromWorld)
        let y = World.scaledY(coordinate.latitude, downScale: zoomScaleFromWorld)
        let worldSize = World.scaledExtent(downScale: zoomScaleFromWorld)
        print("world size \(worldSize)")
        let worldPoint = CGPoint(x: x, y: y)
        print("world point \(worldPoint)")
        tileX = Int(floor(worldPoint.x / 256.0))
        tileY = Int(floor(worldPoint.y / 256.0))
        print("tile \(tileX), \(tileY)")
        let worldDx = Int(worldPoint.x) % 256
        let worldDy = Int(worldPoint.y) % 256
        offsetX = -(Double(worldDx) * zoomScaleFromWorld)
        offsetY = -(Double(worldDy) * zoomScaleFromWorld)
        print("offsetX,offsetY \(offsetX), \(offsetY)")
    }
    
}
