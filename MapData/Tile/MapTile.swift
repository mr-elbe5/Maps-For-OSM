/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif
import E5Data

open class MapTile{
    
    public static func getTile(data: MapTileData) -> MapTile{
        let tile = MapTile(zoom: data.zoom, x: data.x, y: data.y)
        //Log.debug("get tile \(tile.shortDescription)")
        if tile.exists, let fileData = FileManager.default.contents(atPath: tile.fileUrl.path){
            tile.imageData = fileData
        }
        return tile
    }

    public static var tilesDirURL: URL = FileManager.default.urls(for: .applicationSupportDirectory,in: FileManager.SearchPathDomainMask.userDomainMask).first!.appendingPathComponent("tiles")
    
    public var x: Int
    public var y: Int
    public var zoom: Int
    
    public var imageData : Data? = nil
    
    public init(zoom: Int, x: Int, y: Int){
        self.zoom = zoom
        self.x = x
        self.y = y
    }
    
    public var fileUrl: URL{
        MapTile.tilesDirURL.appendingPathComponent("\(zoom)/\(x)/\(y).png")
    }
    
    public var exists: Bool{
        FileManager.default.fileExists(atPath: fileUrl.path)
    }
    
    public var shortDescription : String{
        "\(zoom)-\(x)-\(y)"
    }
    
    public var rectInZoomedWorld : CGRect{
        let origin = CGPoint(x: Double(x)*World.tileExtent , y: Double(y)*World.tileExtent)
        return CGRect(origin: origin, size: World.tileSize)
    }
    
    public var rectInWorld : CGRect{
        let scale = World.zoomScale(from: zoom, to: World.maxZoom)
        let origin = CGPoint(x: Double(x)*World.tileExtent*scale , y: Double(y)*World.tileExtent*scale)
        let scaledTileExtent = World.tileExtent/scale
        return CGRect(origin: origin, size: CGSize(width: scaledTileExtent, height: scaledTileExtent))
    }
        
    public func tileUrl(template: String) -> URL{
        URL(string: template.replacingOccurrences(of: "{z}", with: String(zoom)).replacingOccurrences(of: "{x}", with: String(x)).replacingOccurrences(of: "{y}", with: String(y)))!
    }
    
}

public struct MapTileData{
    
    public init(zoom: Int, x: Int, y: Int) {
        self.zoom = zoom
        self.x = x
        self.y = y
    }
    
    public var zoom: Int
    public var x: Int
    public var y: Int
    
}
