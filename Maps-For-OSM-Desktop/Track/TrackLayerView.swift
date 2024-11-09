/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

class TrackLayerView: NSView {
    
    var scale : CGFloat = 0.0
    
    override var isFlipped: Bool{
        true
    }
    
    func showTrack(_ track: TrackItem?){
        TrackItem.visibleTrack = track
        isHidden = track == nil
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if let track = TrackItem.visibleTrack{
            if !track.trackpoints.isEmpty{
                var drawPoints = Array<CGPoint>()
                    for idx in 0..<track.trackpoints.count{
                        let trackpoint = track.trackpoints[idx]
                        let mapPoint = CGPoint(trackpoint.coordinate)
                        let drawPoint = CGPoint(x: mapPoint.x*scale, y: mapPoint.y*scale)
                        drawPoints.append(drawPoint)
                    }
                let ctx = NSGraphicsContext.current!.cgContext
                ctx.beginPath()
                ctx.move(to: drawPoints[0])
                for idx in 1..<drawPoints.count{
                    ctx.addLine(to: drawPoints[idx])
                }
                ctx.setStrokeColor(NSColor.systemOrange.cgColor)
                ctx.setLineWidth(3.0)
                ctx.drawPath(using: .stroke)
                ctx.setFillColor(NSColor.black.cgColor)
                if Preferences.shared.showTrackpoints{
                    for idx in 0..<drawPoints.count{
                        let pnt = drawPoints[idx]
                        ctx.fillEllipse(in: CGRect(x: pnt.x - 1 , y: pnt.y - 1, width: 4, height: 4))
                    }
                }
            }
        }
    }
    
    func updateScale(scale: CGFloat){
        self.scale = scale
        self.needsDisplay = true
    }
    
    func getDrawPoints(track: TrackItem) -> Array<CGPoint>{
        var points = Array<CGPoint>()
        for idx in 0..<track.trackpoints.count{
            let mapPoint = CGPoint(track.trackpoints[idx].coordinate)
            let drawPoint = CGPoint(x: mapPoint.x*scale , y: mapPoint.y*scale)
            points.append(drawPoint)
        }
        return points
    }
    
}




