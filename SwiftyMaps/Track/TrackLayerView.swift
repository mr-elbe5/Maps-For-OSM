/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

class TrackLayerView: UIView {
    
    var offset : CGPoint? = nil
    var scale : CGFloat = 0.0
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
    
    func getTrackRect() -> CGRect?{
        if let track = Tracks.visibleTrack, let offset = offset, let boundingRect = track.trackpoints.boundingMapRect{
            let mapOffset = MapPoint(x: offset.x/scale, y: offset.y/scale).normalizedPoint.cgPoint
            return CGRect(x: (boundingRect.minX  - mapOffset.x)*scale, y: (boundingRect.minY - mapOffset.y)*scale, width: boundingRect.width*scale, height: boundingRect.height*scale)
        }
        return nil
    }
    
    func updatePosition(offset: CGPoint, scale: CGFloat){
        self.offset = offset
        self.scale = scale
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        if let track = Tracks.visibleTrack{
            if !track.trackpoints.isEmpty, let offset = offset{
                let mapOffset = MapPoint(x: offset.x/scale, y: offset.y/scale).normalizedPoint.cgPoint
                let color = UIColor.systemOrange.cgColor
                let ctx = UIGraphicsGetCurrentContext()!
                ctx.beginPath()
                var mapPoint = MapPoint(track.trackpoints[0].coordinate)
                var drawPoint = CGPoint(x: (mapPoint.x - mapOffset.x)*scale , y: (mapPoint.y - mapOffset.y)*scale)
                ctx.move(to: drawPoint)
                for idx in 1..<track.trackpoints.count{
                    mapPoint = MapPoint(track.trackpoints[idx].coordinate)
                    drawPoint = CGPoint(x: (mapPoint.x - mapOffset.x)*scale , y: (mapPoint.y - mapOffset.y)*scale)
                    ctx.addLine(to: drawPoint)
                }
                ctx.setStrokeColor(color)
                ctx.setLineWidth(4.0)
                ctx.drawPath(using: .stroke)
            }
        }
    }
    
}
