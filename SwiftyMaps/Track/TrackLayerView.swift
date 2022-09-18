/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

class TrackLayerView: UIView {
    
    var offset = CGPoint()
    var scale : CGFloat = 1.0
    
    var track : TrackData? = nil
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
    
    func setTrack(track: TrackData? = nil){
        self.track = track
        setNeedsDisplay()
    }
    
    func updateTrack(){
        setNeedsDisplay()
    }
    
    func updatePosition(offset: CGPoint, scale: CGFloat){
        self.offset = offset
        self.scale = scale
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        if let track = track{
            if !track.trackpoints.isEmpty{
                let mapOffset = MapPoint(x: offset.x/scale, y: offset.y/scale).normalizedPoint.cgPoint
                let color = UIColor.systemOrange.cgColor
                let ctx = UIGraphicsGetCurrentContext()!
                ctx.beginPath()
                var locationPoint = MapPoint(track.trackpoints[0].coordinate)
                ctx.move(to: CGPoint(x: (locationPoint.x - mapOffset.x)*scale , y: (locationPoint.y - mapOffset.y)*scale))
                for idx in 1..<track.trackpoints.count{
                    locationPoint = MapPoint(track.trackpoints[idx].coordinate)
                    ctx.addLine(to: CGPoint(x: (locationPoint.x - mapOffset.x)*scale , y: (locationPoint.y - mapOffset.y)*scale))
                }
                ctx.setStrokeColor(color)
                ctx.setLineWidth(4.0)
                ctx.drawPath(using: .stroke)
            }
        }
    }
    
}


