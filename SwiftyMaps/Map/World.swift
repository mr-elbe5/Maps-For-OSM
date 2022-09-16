//
//  World.swift
//  SwiftyMaps for OSM
//
//  Created by Michael Rönnau on 16.09.22.
//

import Foundation

class World{
    
    static let maxZoom : Int = 20
    static let tileExtent : Double = 256.0
    static let tileSize : MapSize = MapSize(width: tileExtent, height: tileExtent)
    static let fullExtent : Double = pow(2,Double(maxZoom))*tileExtent
    static let equatorInMeters : CGFloat = 40075016.686
    static let mapSize = MapSize(width: fullExtent, height: fullExtent)
    
    static let mapRect = MapRect(origin: MapPoint(x: 0, y: 0), size: mapSize)
    
    static func zoomFactor(zoom: Int) -> Double{
        zoomFactor(fromZoom: maxZoom, toZoom: zoom)
    }
    
    static func zoomFactor(fromZoom: Int, toZoom: Int) -> Double{
        pow(2.0, Double(toZoom - fromZoom))
    }
    
    static func zoomedWorld(zoom: Int) -> MapRect{
        let factor = zoomFactor(fromZoom: zoom, toZoom: maxZoom)
        return MapRect(x: 0, y: 0, width: fullExtent/factor, height: fullExtent/factor)
    }
    
}
