/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import E5Data
import E5MapData
import CoreLocation

class DrawTrackpoint{
    
    var trackpoint: Trackpoint
    var drawpoint: CGPoint
    
    var offset: CGPoint = .zero
    var zoom: Int
    
    init(trackpoint: Trackpoint, drawpoint: CGPoint, zoom: Int){
        self.trackpoint = trackpoint
        self.drawpoint = drawpoint
        self.zoom = zoom
    }
    
    func updateTrackpoint(offset: CGPoint){
        let downScale = World.zoomScale(from: World.maxZoom, to: zoom)
        let mapPoint = CGPoint(x: World.worldX(trackpoint.coordinate.longitude) + offset.x/downScale, y: World.worldY(trackpoint.coordinate.latitude) + offset.y/downScale)
        trackpoint.coordinate = World.coordinate(worldX: mapPoint.x, worldY: mapPoint.y)
    }
}

