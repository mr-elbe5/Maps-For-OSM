/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

class MapTile{
    
    static func getTile(zoom: Int, x: Int, y: Int) -> MapTile{
        let tile = MapTile(zoom: zoom, x: x, y: y)
        if tile.exists, let fileData = FileManager.default.contents(atPath: tile.fileUrl.path){
            tile.image = UIImage(data: fileData)
        }
        return tile
    }
    
    var x: Int
    var y: Int
    var zoom: Int
    
    var image : UIImage? = nil
    
    init(zoom: Int, x: Int, y: Int){
        self.zoom = zoom
        self.x = x
        self.y = y
    }
    
    var tileUrl: URL{
        URL(string: AppState.currentUrlTemplate.replacingOccurrences(of: "{z}", with: String(zoom)).replacingOccurrences(of: "{x}", with: String(x)).replacingOccurrences(of: "{y}", with: String(y)))!
    }
    
    var fileUrl: URL{
        AppState.currentTileDirectory.appendingPathComponent("\(zoom)/\(x)/\(y).png")
    }
    
    var exists: Bool{
        FileManager.default.fileExists(atPath: fileUrl.path)
    }
    
    var string : String{
        "\(zoom)-\(x)-\(y)"
    }
    
    var rectInZoomedWorld : MapRect{
        let origin = MapPoint(x: Double(x)*World.tileExtent , y: Double(y)*World.tileExtent)
        return MapRect(origin: origin, size: World.tileSize)
    }
    
    var rectInWorld : MapRect{
        let scale = World.zoomScale(from: zoom, to: World.maxZoom)
        let origin = MapPoint(x: Double(x)*World.tileExtent*scale , y: Double(y)*World.tileExtent*scale)
        let scaledTileExtent = World.tileExtent/scale
        return MapRect(origin: origin, size: MapSize(width: scaledTileExtent, height: scaledTileExtent))
    }
        
}
