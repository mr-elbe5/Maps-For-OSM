/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation
import E5Data

open class TileRegion : CoordinateRegion{
    
    public var maxZoom : Int
    public var size : Int
    
    public var tiles = Dictionary<Int, TileSet>()
    
    public init(topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D, maxZoom: Int){
        self.maxZoom = maxZoom
        size = 0
        super.init(topLeft: topLeft, bottomRight: bottomRight)
        updateTileSets()
        for zoom in tiles.keys{
            if let tileSet = tiles[zoom]{
                //debug("TileRegion zoom \(zoom): \(tileSet) with size \(tileSet.size)")
                size += tileSet.size
            }
        }
    }
    
    public func updateTileSets(){
        tiles.removeAll()
        for zoom in 0...maxZoom{
            let bottomLeftTile = tileCoordinate(latitude: minLatitude, longitude: minLongitude, zoom: zoom)
            let topRightTile = tileCoordinate(latitude: maxLatitude, longitude: maxLongitude, zoom: zoom)
            let tileSet = TileSet(minX: bottomLeftTile.x, minY: bottomLeftTile.y, maxX: topRightTile.x, maxY: topRightTile.y)
            tiles[zoom] = tileSet
        }
    }
    
    public func tileCoordinate(latitude: CLLocationDegrees, longitude: CLLocationDegrees, zoom: Int) -> (x: Int, y: Int){
        let x = World.tileX(longitude, withZoom: zoom)
        let y = World.tileY(latitude, withZoom: zoom)
        return (x: Int(x), y: Int(y))
    }
    
    override public var string : String{
        super.string + ", size = \(size)"
    }
    
}

public class TileSet{
    
    public var minX = 0
    public var minY = 0
    public var maxX = 0
    public var maxY = 0
    
    public init(minX: Int, minY: Int, maxX: Int, maxY: Int){
        self.minX = min(minX, maxX)
        self.maxX = max(maxX, minX)
        self.minY = min(minY, maxY)
        self.maxY = max(maxY, minY)
    }
    
    public var size : Int{
        (maxX - minX + 1) * (maxY - minY + 1)
    }
    
}
