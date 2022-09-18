/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

class MapTile{
    
    var x: Int
    var y: Int
    var zoom: Int
    
    var image : UIImage? = nil
    
    init(zoom: Int, x: Int, y: Int){
        self.zoom = zoom
        self.x = x
        self.y = y
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
