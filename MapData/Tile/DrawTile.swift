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

public class DrawTileData{
    
    public var drawRect: CGRect
    public var tile: MapTile
    public var complete = false
    
    public init(drawRect: CGRect, tile: MapTile){
        self.drawRect = drawRect
        self.tile = tile
    }
    
    public func assertTileImage(){
        if tile.image == nil {
            TileProvider.shared.loadTileImage(tile: tile, template: Preferences.shared.urlTemplate){ success in
                if success{
                    self.complete = true
                }
            }
        }
        else{
            complete = true
        }
    }
    
    public func draw(){
        if let image = tile.image{
            image.draw(in: drawRect)
        }
    }
    
}

public typealias DrawTileList = Array<DrawTileData>

extension DrawTileList{
    
    public static func getDrawTiles(size: CGSize, zoom: Int, downScale: CGFloat, scaledWorldViewRect: CGRect) -> DrawTileList{
        let tileExtent = World.tileSize.width
        let minTileX = Int(floor(scaledWorldViewRect.minX/tileExtent))
        let minTileY = Int(floor(scaledWorldViewRect.minY/tileExtent))
        let maxTileX = minTileX + Int(size.width/tileExtent) + 1
        let maxTileY = minTileY + Int(size.height/tileExtent) + 1
        var drawTileList = DrawTileList()
        var drawRect = CGRect()
        for x in minTileX...maxTileX{
            for y in Int(minTileY)...maxTileY{
                drawRect = CGRect(x: Double(x)*tileExtent - scaledWorldViewRect.minX, y: Double(y)*tileExtent - scaledWorldViewRect.minY, width: tileExtent, height: tileExtent)
                let tileData = MapTileData(zoom: zoom, x: x, y: y)
                let tile = MapTile.getTile(data: tileData)
                drawTileList.append(DrawTileData(drawRect: drawRect, tile: tile))
            }
        }
        return drawTileList
    }
    
    public var complete: Bool{
        for drawTile in self{
            if !drawTile.complete{
                return false
            }
        }
        return true
    }
    
    public func assertDrawTileImages() -> Bool{
        for drawTile in self{
            drawTile.assertTileImage()
        }
        return complete
    }
    
    public func draw(){
        for drawTile in self{
            drawTile.draw()
        }
    }
    
}
