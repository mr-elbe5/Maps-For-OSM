//
//  TestCenter.swift
//  SwiftyMaps for OSM
//
//  Created by Michael Rönnau on 16.09.22.
//

import Foundation
import CoreLocation

struct TestCenter{
    
    static var coordinate = CLLocationCoordinate2D(latitude: 35.90, longitude: 9.40)
    
    static func test(){
        
        print("maxZoom = \(MapSize.maxZoom)")
        print("worldSize = \(MapSize.world.string)")
        
        let mapPoint = MapPoint(coordinate)
        print("coordinate = \(coordinate.shortString)")
        print("mapPoint = \(mapPoint.string)")
        let coord = mapPoint.coordinate
        print("mappoint coordinate = \(coord.shortString)")
        
    }
    
}
