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
    
    func setTrack(track: Track? = nil){
        Tracks.visibleTrack = track
        redrawTrack()
    }
    
    func updatePosition(offset: CGPoint, scale: CGFloat){
        self.offset = offset
        self.scale = scale
        redrawTrack()
    }
    
    func redrawTrack(){
        if let track = Tracks.visibleTrack, let offset = offset, let rect = track.trackpoints.boundingMapRect{
            let rect = rect.cgRect.scaleBy(scale).offsetBy(dx: -offset.x, dy: -offset.y)
            setNeedsDisplay(rect)
        }
        else{
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        if let track = Tracks.visibleTrack{
            if !track.trackpoints.isEmpty, let offset = offset{
                let mapOffset = MapPoint(x: offset.x/scale, y: offset.y/scale).normalizedPoint.cgPoint
                let color = UIColor.systemOrange.cgColor
                let ctx = UIGraphicsGetCurrentContext()!
                ctx.beginPath()
                var mapPointPoint = MapPoint(track.trackpoints[0].coordinate)
                ctx.move(to: CGPoint(x: (mapPointPoint.x - mapOffset.x)*scale , y: (mapPointPoint.y - mapOffset.y)*scale))
                for idx in 1..<track.trackpoints.count{
                    mapPointPoint = MapPoint(track.trackpoints[idx].coordinate)
                    ctx.addLine(to: CGPoint(x: (mapPointPoint.x - mapOffset.x)*scale , y: (mapPointPoint.y - mapOffset.y)*scale))
                }
                ctx.setStrokeColor(color)
                ctx.setLineWidth(4.0)
                ctx.drawPath(using: .stroke)
            }
        }
    }
    
}


