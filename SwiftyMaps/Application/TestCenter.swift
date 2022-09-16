//
//  TestCenter.swift
//  SwiftyMaps for OSM
//
//  Created by Michael Rönnau on 16.09.22.
//

import Foundation
import CoreLocation

struct TestCenter{
    
    static var coordinate = CLLocationCoordinate2D(latitude: 53.541905, longitude: 9.683107)
    
    static func test(){
        
        print("maxZoom = \(World.maxZoom)")
        print("worldSize = \(World.mapSize.string)")
        
        let mapPoint = MapPoint(coordinate)
        print("coordinate = \(coordinate.shortString)")
        print("mapPoint = \(mapPoint.string)")
        let coord = mapPoint.coordinate
        print("mappoint coordinate = \(coord.shortString)")
        
        //18/138123/84731
        let tile = MapTile(zoom: 18, x: 138123, y: 84732)
        print("tile mapRect = \(tile.rectInZoomedWorld.string)")
        let worldRect = tile.rectInWorld
        print("worldRect = \(worldRect.string)")
        print("tile origin = \(worldRect.origin.coordinate.shortString)")
    }
    
}
