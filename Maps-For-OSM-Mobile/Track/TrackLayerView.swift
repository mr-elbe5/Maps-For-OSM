/*
 Maps For OSM
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
    
    func updatePosition(offset: CGPoint, scale: CGFloat){
        self.offset = offset
        self.scale = scale
        setNeedsDisplay()
    }
    
    func getDrawPoints(track: TrackItem) -> Array<CGPoint>{
        var points = Array<CGPoint>()
        if let offset = offset{
            let mapOffset = CGPoint(x: offset.x/scale, y: offset.y/scale).normalizedPoint
            for idx in 0..<track.trackpoints.count{
                let mapPoint = CGPoint(track.trackpoints[idx].coordinate)
                let drawPoint = CGPoint(x: (mapPoint.x - mapOffset.x)*scale , y: (mapPoint.y - mapOffset.y)*scale)
                points.append(drawPoint)
            }
        }
        return points
    }
    
    override func draw(_ rect: CGRect) {
        if let track = TrackItem.visibleTrack{
            if !track.trackpoints.isEmpty{
                var drawPoints = Array<CGPoint>()
                if let offset = offset{
                    let mapOffset = CGPoint(x: offset.x/scale, y: offset.y/scale).normalizedPoint
                    for idx in 0..<track.trackpoints.count{
                        let trackpoint = track.trackpoints[idx]
                        let mapPoint = CGPoint(trackpoint.coordinate)
                        let drawPoint = CGPoint(x: (mapPoint.x - mapOffset.x)*scale , y: (mapPoint.y - mapOffset.y)*scale)
                        drawPoints.append(drawPoint)
                    }
                }
                let ctx = UIGraphicsGetCurrentContext()!
                ctx.beginPath()
                ctx.move(to: drawPoints[0])
                for idx in 1..<drawPoints.count{
                    ctx.addLine(to: drawPoints[idx])
                }
                ctx.setStrokeColor(UIColor.systemOrange.cgColor)
                ctx.setLineWidth(4.0)
                ctx.drawPath(using: .stroke)
                ctx.setFillColor(UIColor.black.cgColor)
                if Preferences.shared.showTrackpoints{
                    for idx in 0..<drawPoints.count{
                        let pnt = drawPoints[idx]
                        ctx.fillEllipse(in: CGRect(x: pnt.x - 1 , y: pnt.y - 1, width: 4, height: 4))
                    }
                }
            }
        }
    }
    
}
