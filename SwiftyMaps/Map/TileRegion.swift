/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import CoreLocation

class TileRegion : CoordinateRegion{
    
    var maxZoom : Int
    var size : Int
    
    var tiles = Dictionary<Int, TileSet>()
    
    init(topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D, maxZoom: Int){
        self.maxZoom = maxZoom
        size = 0
        super.init(topLeft: topLeft, bottomRight: bottomRight)
        updateTileSets()
        for zoom in tiles.keys{
            if let tileSet = tiles[zoom]{
                //print("zoom \(zoom): \(tileSet) with size \(tileSet.size)")
                size += tileSet.size
            }
        }
    }
    
    func updateTileSets(){
        tiles.removeAll()
        for zoom in 0...maxZoom{
            let bottomLeftTile = World.tileCoordinate(latitude: minLatitude, longitude: minLongitude, zoom: zoom)
            let topRightTile = World.tileCoordinate(latitude: maxLatitude, longitude: maxLongitude, zoom: zoom)
            let tileSet = TileSet(minX: bottomLeftTile.x, minY: bottomLeftTile.y, maxX: topRightTile.x, maxY: topRightTile.y)
            tiles[zoom] = tileSet
        }
    }
    
    override var string : String{
        super.string + ", size = \(size)"
    }
    
}

class TileSet{
    
    var minX = 0
    var minY = 0
    var maxX = 0
    var maxY = 0
    
    init(minX: Int, minY: Int, maxX: Int, maxY: Int){
        self.minX = min(minX, maxX)
        self.maxX = max(maxX, minX)
        self.minY = min(minY, maxY)
        self.maxY = max(maxY, minY)
    }
    
    var size : Int{
        (maxX - minX + 1) * (maxY - minY + 1)
    }
    
}
